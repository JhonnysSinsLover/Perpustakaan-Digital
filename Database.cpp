#include "Database.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <algorithm>

namespace {
constexpr const char *kDatabaseName = "perpustakaan.db";
}

// ============================================================================
// Constructor & Destructor
// ============================================================================

Database::Database(QObject *parent)
    : QObject(parent)
    , currentUserId(-1)
    , m_sortedByTitle(false)
    , m_sortedByYear(false)
{
}

Database::~Database()
{
    if (db.isOpen()) {
        db.close();
    }
    m_books.clear();
    m_genreGraph.clear();
}

// ============================================================================
// Initialization
// ============================================================================

bool Database::initDatabase()
{
    if (!QSqlDatabase::contains(QSqlDatabase::defaultConnection)) {
        db = QSqlDatabase::addDatabase("QSQLITE");
    } else {
        db = QSqlDatabase::database(QSqlDatabase::defaultConnection);
    }

    db.setDatabaseName(kDatabaseName);

    if (!db.open()) {
        qDebug() << "Error: Failed to connect to database" << db.lastError().text();
        return false;
    }

    return createTables();
}

bool Database::createTables()
{
    QSqlQuery query(db);

    // Create users table
    QString createUsersTable = R"(
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT,
            created_at TEXT
        )
    )";

    if (!query.exec(createUsersTable)) {
        qDebug() << "Error creating users table:" << query.lastError().text();
        return false;
    }

    // Create books table with updated schema
    QString createBooksTable = R"(
        CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            author TEXT,
            genre TEXT,
            publisher TEXT,
            year INTEGER,
            copies INTEGER,
            image_path TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    )";

    if (!query.exec(createBooksTable)) {
        qDebug() << "Error creating books table:" << query.lastError().text();
        return false;
    }

    return true;
}

// ============================================================================
// User Management
// ============================================================================

bool Database::createUser(const QString &username, const QString &password, const QString &fullName)
{
    const QString trimmedUsername = username.trimmed();
    const QString trimmedName = fullName.trimmed();

    if (trimmedUsername.isEmpty() || password.isEmpty()) {
        qDebug() << "Error: Username and password cannot be empty";
        return false;
    }

    if (!getUserByUsername(trimmedUsername).isEmpty()) {
        qDebug() << "Error: Username already exists";
        return false;
    }

    QSqlQuery query(db);
    query.prepare("INSERT INTO users (username, password_hash, full_name, created_at) VALUES (?, ?, ?, ?)");
    query.addBindValue(trimmedUsername);
    query.addBindValue(hashPassword(password));
    query.addBindValue(trimmedName.isEmpty() ? trimmedUsername : trimmedName);
    query.addBindValue(QDateTime::currentDateTime().toString(Qt::ISODate));

    if (!query.exec()) {
        qDebug() << "Error creating user:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::loginUser(const QString &username, const QString &password)
{
    const QString trimmedUsername = username.trimmed();

    if (trimmedUsername.isEmpty() || password.isEmpty()) {
        qDebug() << "Error: Username and password cannot be empty";
        return false;
    }

    const QVariantMap user = getUserByUsername(trimmedUsername);
    if (user.isEmpty()) {
        qDebug() << "Error: User not found";
        return false;
    }

    const QString storedHash = user.value("password_hash").toString();
    if (!verifyPassword(password, storedHash)) {
        qDebug() << "Error: Invalid password";
        return false;
    }

    currentUserId = user.value("id").toInt();
    currentUsername = user.value("username").toString();

    // Load books after successful login
    loadBooks();

    return true;
}

void Database::logoutUser()
{
    currentUserId = -1;
    currentUsername.clear();
    m_books.clear();
    m_genreGraph.clear();
    m_sortedByTitle = false;
    m_sortedByYear = false;
    emit booksChanged();
}

bool Database::isUserLoggedIn() const
{
    return currentUserId > 0;
}

int Database::getCurrentUserId() const
{
    return currentUserId;
}

QString Database::getCurrentUsername() const
{
    return currentUsername;
}

bool Database::changePassword(const QString &currentPassword, const QString &newPassword)
{
    if (!isUserLoggedIn()) {
        qDebug() << "Error: No user logged in";
        return false;
    }

    const QVariantMap user = getUserByUsername(currentUsername);
    const QString storedHash = user.value("password_hash").toString();

    if (!verifyPassword(currentPassword, storedHash)) {
        qDebug() << "Error: Current password is incorrect";
        return false;
    }

    QSqlQuery query(db);
    query.prepare("UPDATE users SET password_hash = ? WHERE id = ?");
    query.addBindValue(hashPassword(newPassword));
    query.addBindValue(currentUserId);

    if (!query.exec()) {
        qDebug() << "Error changing password:" << query.lastError().text();
        return false;
    }

    return true;
}

// ============================================================================
// Core Book Management (with SQL Sync)
// ============================================================================

void Database::loadBooks()
{
    if (!isUserLoggedIn()) {
        qDebug() << "Error: No user logged in";
        return;
    }

    m_books.clear();
    m_sortedByTitle = false;
    m_sortedByYear = false;

    QSqlQuery query(db);
    query.prepare("SELECT id, title, author, genre, publisher, year, copies, image_path FROM books WHERE user_id = ?");
    query.addBindValue(currentUserId);

    if (!query.exec()) {
        qDebug() << "Error loading books:" << query.lastError().text();
        return;
    }

    while (query.next()) {
        Book book;
        book.id = query.value("id").toInt();
        book.title = query.value("title").toString();
        book.author = query.value("author").toString();
        book.genre = query.value("genre").toString();
        book.publisher = query.value("publisher").toString();
        book.year = query.value("year").toInt();
        book.copies = query.value("copies").toInt();
        book.image_path = query.value("image_path").toString();
        m_books.append(book);
    }

    // Build graph after loading
    buildGraph();
    emit booksChanged();
    emit sortStatusChanged();
}

QVariantList Database::getAllBooks()
{
    return booksToVariantList(m_books);
}

bool Database::addBook(const QString &title,
                       const QString &author,
                       const QString &genre,
                       const QString &publisher,
                       int year,
                       int copies,
                       const QString &image_path)
{
    if (!isUserLoggedIn()) {
        qDebug() << "Error: No user logged in";
        return false;
    }

    if (title.trimmed().isEmpty()) {
        qDebug() << "Error: Book title cannot be empty";
        return false;
    }

    // Insert into SQL database
    QSqlQuery query(db);
    query.prepare(
        "INSERT INTO books (user_id, title, author, genre, publisher, year, copies, image_path)"
        " VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );
    query.addBindValue(currentUserId);
    query.addBindValue(title.trimmed());
    query.addBindValue(author.trimmed());
    query.addBindValue(genre.trimmed());
    query.addBindValue(publisher.trimmed());
    query.addBindValue(year);
    query.addBindValue(copies);
    query.addBindValue(image_path.trimmed());

    if (!query.exec()) {
        qDebug() << "Error adding book:" << query.lastError().text();
        return false;
    }

    // Add to in-memory cache
    Book book;
    book.id = query.lastInsertId().toInt();
    book.title = title.trimmed();
    book.author = author.trimmed();
    book.genre = genre.trimmed();
    book.publisher = publisher.trimmed();
    book.year = year;
    book.copies = copies;
    book.image_path = image_path.trimmed();

    m_books.append(book);
    
    // Reset sorting flags since new book is added
    m_sortedByTitle = false;
    m_sortedByYear = false;

    // Rebuild graph
    buildGraph();
    emit booksChanged();
    emit sortStatusChanged();

    return true;
}

bool Database::updateBook(int id,
                          const QString &title,
                          const QString &author,
                          const QString &genre,
                          const QString &publisher,
                          int year,
                          int copies,
                          const QString &image_path)
{
    if (!isUserLoggedIn()) {
        qDebug() << "Error: No user logged in";
        return false;
    }

    if (id <= 0) {
        qDebug() << "Error: Invalid book ID";
        return false;
    }

    // Update SQL database
    QSqlQuery query(db);
    query.prepare(
        "UPDATE books SET title = ?, author = ?, genre = ?, publisher = ?, year = ?, copies = ?, image_path = ?"
        " WHERE id = ? AND user_id = ?"
    );
    query.addBindValue(title.trimmed());
    query.addBindValue(author.trimmed());
    query.addBindValue(genre.trimmed());
    query.addBindValue(publisher.trimmed());
    query.addBindValue(year);
    query.addBindValue(copies);
    query.addBindValue(image_path.trimmed());
    query.addBindValue(id);
    query.addBindValue(currentUserId);

    if (!query.exec()) {
        qDebug() << "Error updating book:" << query.lastError().text();
        return false;
    }

    // Update in-memory cache
    for (Book &book : m_books) {
        if (book.id == id) {
            book.title = title.trimmed();
            book.author = author.trimmed();
            book.genre = genre.trimmed();
            book.publisher = publisher.trimmed();
            book.year = year;
            book.copies = copies;
            book.image_path = image_path.trimmed();
            
            // Reset sorting flags since book is updated
            m_sortedByTitle = false;
            m_sortedByYear = false;
            break;
        }
    }

    // Rebuild graph
    buildGraph();
    emit booksChanged();
    emit sortStatusChanged();

    return true;
}

bool Database::deleteBook(int id)
{
    if (!isUserLoggedIn()) {
        qDebug() << "Error: No user logged in";
        return false;
    }

    if (id <= 0) {
        qDebug() << "Error: Invalid book ID";
        return false;
    }

    // Delete from SQL database
    QSqlQuery query(db);
    query.prepare("DELETE FROM books WHERE id = ? AND user_id = ?");
    query.addBindValue(id);
    query.addBindValue(currentUserId);

    if (!query.exec()) {
        qDebug() << "Error deleting book:" << query.lastError().text();
        return false;
    }

    // Remove from in-memory cache
    for (int i = 0; i < m_books.size(); ++i) {
        if (m_books[i].id == id) {
            m_books.remove(i);
            
            // Reset sorting flags since book is removed
            m_sortedByTitle = false;
            m_sortedByYear = false;
            break;
        }
    }

    // Rebuild graph
    buildGraph();
    emit booksChanged();
    emit sortStatusChanged();

    return true;
}

// ============================================================================
// ALGORITHM 1: MERGE SORT (Manual Implementation) - FIXED
// ============================================================================

void Database::sortBooks(const QString &criteria)
{
    if (m_books.isEmpty()) {
        return;
    }

    bool byTitle = (criteria.toLower() == "title");
    bool byYear = (criteria.toLower() == "year");
    
    if (!byTitle && !byYear) {
        qDebug() << "Error: Invalid sort criteria. Use 'title' or 'year'";
        return;
    }

    // Reset sorting flags
    m_sortedByTitle = false;
    m_sortedByYear = false;
    
    // Sort using merge sort
    mergeSort(m_books, 0, m_books.size() - 1, byTitle);
    
    // Update sorting flags
    if (byTitle) {
        m_sortedByTitle = true;
    } else {
        m_sortedByYear = true;
    }
    
    emit booksChanged();
    emit sortStatusChanged();
}

bool Database::isSortedByTitle() const
{
    return m_sortedByTitle;
}

bool Database::isSortedByYear() const
{
    return m_sortedByYear;
}

void Database::mergeSort(QVector<Book>& list, int left, int right, bool byTitle)
{
    if (left >= right) {
        return;
    }

    int mid = left + (right - left) / 2;

    // Sort first and second halves
    mergeSort(list, left, mid, byTitle);
    mergeSort(list, mid + 1, right, byTitle);

    // Merge the sorted halves
    merge(list, left, mid, right, byTitle);
}

void Database::merge(QVector<Book>& list, int left, int mid, int right, bool byTitle)
{
    int n1 = mid - left + 1;
    int n2 = right - mid;

    // Create temporary vectors
    QVector<Book> leftVec(n1);
    QVector<Book> rightVec(n2);

    // Copy data to temp vectors
    for (int i = 0; i < n1; i++) {
        leftVec[i] = list[left + i];
    }
    for (int j = 0; j < n2; j++) {
        rightVec[j] = list[mid + 1 + j];
    }

    // Merge the temp vectors back
    int i = 0, j = 0, k = left;

    while (i < n1 && j < n2) {
        bool leftIsLess = false;
        
        if (byTitle) {
            // Case-insensitive string comparison
            leftIsLess = leftVec[i].title.compare(rightVec[j].title, Qt::CaseInsensitive) <= 0;
        } else {
            // Numeric comparison for year
            leftIsLess = leftVec[i].year <= rightVec[j].year;
        }

        if (leftIsLess) {
            list[k] = leftVec[i];
            i++;
        } else {
            list[k] = rightVec[j];
            j++;
        }
        k++;
    }

    // Copy remaining elements
    while (i < n1) {
        list[k] = leftVec[i];
        i++;
        k++;
    }

    while (j < n2) {
        list[k] = rightVec[j];
        j++;
        k++;
    }
}

// ============================================================================
// ALGORITHM 2: BINARY SEARCH (Manual Implementation) - FIXED
// ============================================================================

void Database::ensureSortedForSearch()
{
    // Ensure the list is sorted by title for binary search to work
    if (!m_sortedByTitle && !m_books.isEmpty()) {
        sortBooks("title");
    }
}

int Database::binarySearch(const QString &title)
{
    if (m_books.isEmpty()) {
        return -1;
    }

    ensureSortedForSearch();

    QString searchTitle = title.trimmed().toLower();
    int left = 0;
    int right = m_books.size() - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        QString midTitle = m_books[mid].title.trimmed().toLower();

        if (midTitle == searchTitle) {
            return mid;  // Found exact match
        } else if (midTitle < searchTitle) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }

    return -1;  // Not found
}

QVariantList Database::searchBook(const QString &query)
{
    QVariantList results;

    if (query.trimmed().isEmpty()) {
        // Return all books if query is empty
        return getAllBooks();
    }

    QString searchQuery = query.trimmed().toLower();

    // First, try binary search for exact title match
    int exactIndex = binarySearch(query);
    
    if (exactIndex != -1) {
        // Found exact match, return it
        results.append(bookToVariantMap(m_books[exactIndex]));
        
        // Check for adjacent matches (in case of multiple exact matches)
        int left = exactIndex - 1;
        while (left >= 0 && m_books[left].title.trimmed().compare(query.trimmed(), Qt::CaseInsensitive) == 0) {
            results.prepend(bookToVariantMap(m_books[left]));
            left--;
        }
        
        int right = exactIndex + 1;
        while (right < m_books.size() && m_books[right].title.trimmed().compare(query.trimmed(), Qt::CaseInsensitive) == 0) {
            results.append(bookToVariantMap(m_books[right]));
            right++;
        }
        
        // Return exact matches first
        return results;
    }

    // If not found by binary search, do linear search for partial matches
    for (const Book &book : m_books) {
        if (book.title.trimmed().toLower().contains(searchQuery) ||
            book.author.trimmed().toLower().contains(searchQuery) ||
            book.genre.trimmed().toLower().contains(searchQuery) ||
            book.publisher.trimmed().toLower().contains(searchQuery)) {
            
            // Check if book is already in results
            bool alreadyExists = false;
            for (const QVariant &result : results) {
                QVariantMap map = result.toMap();
                if (map["id"].toInt() == book.id) {
                    alreadyExists = true;
                    break;
                }
            }
            
            if (!alreadyExists) {
                results.append(bookToVariantMap(book));
            }
        }
    }

    return results;
}

// ============================================================================
// ALGORITHM 3: GRAPH (Adjacency List for Recommendations) - IMPROVED
// ============================================================================

void Database::buildGraph()
{
    m_genreGraph.clear();

    // Build adjacency list: Genre -> List of Book IDs
    for (const Book &book : m_books) {
        QString genre = book.genre.trimmed().toLower();
        if (!genre.isEmpty()) {
            if (!m_genreGraph.contains(genre)) {
                m_genreGraph[genre] = QVector<int>();
            }
            m_genreGraph[genre].append(book.id);
        }
    }
    
    // Also build connections by author for better recommendations
    QMap<QString, QVector<int>> authorGraph;
    for (const Book &book : m_books) {
        QString author = book.author.trimmed().toLower();
        if (!author.isEmpty()) {
            authorGraph[author].append(book.id);
        }
    }
    
    // Combine genre and author connections (optional enhancement)
    // You can use this for more diverse recommendations
}

QVariantList Database::getRelatedBooks(int bookId)
{
    QVariantList recommendations;

    if (bookId <= 0) {
        return recommendations;
    }

    // Find the book by ID and its genre
    QString bookGenre;
    QString bookAuthor;
    
    for (const Book &book : m_books) {
        if (book.id == bookId) {
            bookGenre = book.genre.trimmed().toLower();
            bookAuthor = book.author.trimmed().toLower();
            break;
        }
    }

    if (bookGenre.isEmpty()) {
        return recommendations;
    }

    // Get all book IDs in the same genre from the graph
    if (!m_genreGraph.contains(bookGenre)) {
        return recommendations;
    }

    const QVector<int> &relatedIds = m_genreGraph[bookGenre];

    // Convert to Book objects and return (exclude the original book)
    for (int id : relatedIds) {
        if (id != bookId) {
            for (const Book &book : m_books) {
                if (book.id == id) {
                    // Prioritize books with same author for better recommendations
                    bool sameAuthor = book.author.trimmed().compare(bookAuthor, Qt::CaseInsensitive) == 0;
                    QVariantMap bookMap = bookToVariantMap(book);
                    bookMap.insert("sameAuthor", sameAuthor);
                    recommendations.append(bookMap);
                    break;
                }
            }
        }
        
        // Limit to 5 recommendations max
        if (recommendations.size() >= 5) {
            break;
        }
    }

    return recommendations;
}

// ============================================================================
// Helper Methods
// ============================================================================

QVariantMap Database::getUserByUsername(const QString &username)
{
    QVariantMap user;

    QSqlQuery query(db);
    query.prepare("SELECT id, username, password_hash, full_name FROM users WHERE username = ?");
    query.addBindValue(username);

    if (query.exec() && query.next()) {
        user.insert("id", query.value("id"));
        user.insert("username", query.value("username"));
        user.insert("password_hash", query.value("password_hash"));
        user.insert("full_name", query.value("full_name"));
    }

    return user;
}

QString Database::hashPassword(const QString &password)
{
    return QString(QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256).toHex());
}

bool Database::verifyPassword(const QString &password, const QString &hashedPassword)
{
    return hashPassword(password) == hashedPassword;
}

QVariantMap Database::bookToVariantMap(const Book &book) const
{
    QVariantMap map;
    map.insert("id", book.id);
    map.insert("title", book.title);
    map.insert("author", book.author);
    map.insert("genre", book.genre);
    map.insert("publisher", book.publisher);
    map.insert("year", book.year);
    map.insert("copies", book.copies);
    map.insert("image_path", book.image_path);
    return map;
}

QVariantList Database::booksToVariantList(const QVector<Book> &list) const
{
    QVariantList result;
    for (const Book &book : list) {
        result.append(bookToVariantMap(book));
    }
    return result;
}

Database::Book Database::variantMapToBook(const QVariantMap &map) const
{
    Book book;
    book.id = map.value("id").toInt();
    book.title = map.value("title").toString();
    book.author = map.value("author").toString();
    book.genre = map.value("genre").toString();
    book.publisher = map.value("publisher").toString();
    book.year = map.value("year").toInt();
    book.copies = map.value("copies").toInt();
    book.image_path = map.value("image_path").toString();
    return book;
}

// ============================================================================
// Statistics Methods
// ============================================================================

QString Database::getTopGenre()
{
    if (m_books.isEmpty()) {
        return "-";
    }
    
    // Count books per genre
    QMap<QString, int> genreCount;
    for (const Book &book : m_books) {
        QString genre = book.genre.trimmed();
        if (!genre.isEmpty()) {
            genreCount[genre]++;
        }
    }
    
    if (genreCount.isEmpty()) {
        return "-";
    }
    
    // Find genre with most books
    QString topGenre;
    int maxCount = 0;
    for (auto it = genreCount.constBegin(); it != genreCount.constEnd(); ++it) {
        if (it.value() > maxCount) {
            maxCount = it.value();
            topGenre = it.key();
        }
    }
    
    return topGenre.isEmpty() ? "-" : topGenre;
}

QString Database::getLastAddedTitle()
{
    if (m_books.isEmpty()) {
        return "-";
    }
    
    // Find book with highest ID (last added)
    int maxId = 0;
    QString lastTitle;
    for (const Book &book : m_books) {
        if (book.id > maxId) {
            maxId = book.id;
            lastTitle = book.title;
        }
    }
    
    return lastTitle.isEmpty() ? "-" : lastTitle;
}