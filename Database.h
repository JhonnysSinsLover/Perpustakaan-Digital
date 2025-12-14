#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <QMap>
#include <QString>
#include <algorithm>

class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    // ========== Data Structure ==========
    struct Book {
        int id = 0;
        QString title;
        QString author;
        QString genre;
        QString publisher;
        int year = 0;
        int copies = 0;
        QString image_path;
        
        // For graph connections
        QVector<int> relatedBooks;
    };

    // ========== Initialization ==========
    Q_INVOKABLE bool initDatabase();

    // ========== User Management ==========
    Q_INVOKABLE bool createUser(const QString &username, const QString &password, const QString &fullName = QString());
    Q_INVOKABLE bool loginUser(const QString &username, const QString &password);
    Q_INVOKABLE void logoutUser();
    Q_INVOKABLE bool isUserLoggedIn() const;
    Q_INVOKABLE int getCurrentUserId() const;
    Q_INVOKABLE QString getCurrentUsername() const;
    Q_INVOKABLE bool changePassword(const QString &currentPassword, const QString &newPassword);

    // ========== Core Book Management (with SQL sync) ==========
    Q_INVOKABLE void loadBooks();
    Q_INVOKABLE QVariantList getAllBooks();
    Q_INVOKABLE bool addBook(const QString &title,
                             const QString &author,
                             const QString &genre,
                             const QString &publisher,
                             int year,
                             int copies,
                             const QString &image_path);
    Q_INVOKABLE bool updateBook(int id,
                                const QString &title,
                                const QString &author,
                                const QString &genre,
                                const QString &publisher,
                                int year,
                                int copies,
                                const QString &image_path);
    Q_INVOKABLE bool deleteBook(int id);

    // ========== Algorithms (In-Memory) ==========
    Q_INVOKABLE void sortBooks(const QString &criteria);
    Q_INVOKABLE QVariantList searchBook(const QString &query);
    Q_INVOKABLE QVariantList getRelatedBooks(int bookId);
    
    // ========== Statistics ==========
    Q_INVOKABLE QString getTopGenre();
    Q_INVOKABLE QString getLastAddedTitle();
    
    // ========== Sorting State ==========
    Q_INVOKABLE bool isSortedByTitle() const;
    Q_INVOKABLE bool isSortedByYear() const;

signals:
    void booksChanged();
    void sortStatusChanged();

private:
    // Database
    QSqlDatabase db;
    int currentUserId;
    QString currentUsername;

    // ========== In-Memory Cache ==========
    QVector<Book> m_books;
    
    // ========== Sorting State ==========
    bool m_sortedByTitle = false;
    bool m_sortedByYear = false;

    // ========== Graph for Recommendations ==========
    QMap<QString, QVector<int>> m_genreGraph;  // genre -> list of bookIds

    // Helper methods
    bool createTables();
    QVariantMap getUserByUsername(const QString &username);
    QString hashPassword(const QString &password);
    bool verifyPassword(const QString &password, const QString &hashedPassword);

    // ========== Algorithm Implementations ==========
    // Merge Sort
    void mergeSort(QVector<Book>& list, int left, int right, bool byTitle);
    void merge(QVector<Book>& list, int left, int mid, int right, bool byTitle);

    // Binary Search
    int binarySearch(const QString &title);
    
    // Ensure list is sorted for binary search
    void ensureSortedForSearch();
    
    // Linear search fallback
    QVector<Book> linearSearch(const QString &query);

    // Graph
    void buildGraph();
    void addGraphConnection(int book1Id, int book2Id);

    // Conversion helpers
    QVariantMap bookToVariantMap(const Book &book) const;
    QVariantList booksToVariantList(const QVector<Book> &list) const;
    Book variantMapToBook(const QVariantMap &map) const;
};

#endif // DATABASE_H