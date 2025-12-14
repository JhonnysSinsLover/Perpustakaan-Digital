// ============================================================================
// QUICK REFERENCE: Database Backend API
// ============================================================================
// This file provides quick examples for using the refactored Database backend
// DO NOT COMPILE - This is documentation only
// ============================================================================

// ============================================================================
// 1. INITIALIZATION & LOGIN
// ============================================================================

// Initialize database (call once at app startup)
database.initDatabase()

// Create a new user
database.createUser("username", "password", "Full Name")

// Login user (automatically loads books and builds graph)
database.loginUser("username", "password")

// Check if user is logged in
if (database.isUserLoggedIn()) {
    console.log("User ID:", database.getCurrentUserId())
    console.log("Username:", database.getCurrentUsername())
}

// Logout (clears cache and graph)
database.logoutUser()

// ============================================================================
// 2. BOOK MANAGEMENT (CRUD Operations)
// ============================================================================

// Load all books from database (called automatically after login)
database.loadBooks()

// Get all books
var allBooks = database.getAllBooks()
// Returns: Array of objects with {id, title, author, genre, year, copies, image_path}

// Example: Display all books
for (var i = 0; i < allBooks.length; i++) {
    console.log("Book:", allBooks[i].title, "by", allBooks[i].author)
}

// Add a new book
var success = database.addBook(
    "The Lord of the Rings",     // title
    "J.R.R. Tolkien",             // author
    "Fantasy",                    // genre
    1954,                         // year
    3,                            // copies
    "assets/images/lotr.jpg"      // image_path
)

// Update an existing book
success = database.updateBook(
    5,                            // id
    "Harry Potter and the Philosopher's Stone",
    "J.K. Rowling",
    "Fantasy",
    1997,
    5,
    "assets/images/hp1.jpg"
)

// Delete a book
success = database.deleteBook(5)  // Delete book with id = 5

// ============================================================================
// 3. ALGORITHM: MERGE SORT
// ============================================================================
// Sort books in the cache using manual merge sort implementation
// Time Complexity: O(n log n)

// Sort by title (ascending, case-insensitive)
database.sortBooks(true)

// Sort by author (ascending, case-insensitive)
database.sortBooks(false)

// After sorting, get the sorted list
var sortedBooks = database.getAllBooks()

// Example: Sort and display
database.sortBooks(true)
var books = database.getAllBooks()
for (var i = 0; i < books.length; i++) {
    console.log(i + 1, ".", books[i].title)
}

// ============================================================================
// 4. ALGORITHM: BINARY SEARCH
// ============================================================================
// Search for books using binary search (exact match) + linear search (partial)
// Time Complexity: O(log n) for exact, O(n) for partial

// Search for books matching query
var results = database.searchBook("Harry Potter")
// Returns: Array of matching books

// The search algorithm:
// 1. First tries binary search for exact title match
// 2. If found, returns the match and adjacent duplicates
// 3. If not found, performs linear search for partial matches in:
//    - title (case-insensitive)
//    - author (case-insensitive)
//    - genre (case-insensitive)

// Example: Search and display results
var searchResults = database.searchBook("tolkien")
if (searchResults.length > 0) {
    console.log("Found", searchResults.length, "result(s):")
    for (var i = 0; i < searchResults.length; i++) {
        console.log("-", searchResults[i].title, "by", searchResults[i].author)
    }
} else {
    console.log("No results found")
}

// ============================================================================
// 5. ALGORITHM: GRAPH (Recommendations)
// ============================================================================
// Get book recommendations based on genre using adjacency list graph
// Time Complexity: O(1) lookup + O(k) where k = books in same genre

// Get related books (same genre)
var recommendations = database.getRelatedBooks(5)  // Get books related to book id=5
// Returns: Array of books in the same genre (excluding the original book)

// Example: Show recommendations
var bookId = 5
var related = database.getRelatedBooks(bookId)
console.log("Recommendations for book", bookId + ":")
for (var i = 0; i < related.length; i++) {
    console.log("-", related[i].title, "(Genre:", related[i].genre + ")")
}

// The graph structure (internal):
// m_genreGraph = {
//     "fantasy": [1, 3, 5, 7, 9],      // Book IDs in Fantasy genre
//     "science fiction": [2, 6, 10],    // Book IDs in Sci-Fi genre
//     "mystery": [4, 8, 11]             // Book IDs in Mystery genre
// }

// ============================================================================
// 6. SIGNALS
// ============================================================================

// Listen for changes to books
Connections {
    target: database
    function onBooksChanged() {
        console.log("Books have been modified!")
        // Refresh your UI here
        refreshBookList()
    }
}

// booksChanged() is emitted when:
// - Books are loaded after login
// - A book is added
// - A book is updated
// - A book is deleted
// - Books are sorted
// - User logs out

// ============================================================================
// 7. COMPLETE WORKFLOW EXAMPLE
// ============================================================================

// Step 1: Initialize and login
database.initDatabase()
database.loginUser("john_doe", "password123")

// Step 2: Add some books
database.addBook("1984", "George Orwell", "Dystopian", 1949, 4, "assets/1984.jpg")
database.addBook("Animal Farm", "George Orwell", "Dystopian", 1945, 3, "assets/animal.jpg")
database.addBook("Dune", "Frank Herbert", "Science Fiction", 1965, 2, "assets/dune.jpg")
database.addBook("Foundation", "Isaac Asimov", "Science Fiction", 1951, 5, "assets/foundation.jpg")

// Step 3: Sort books by title
database.sortBooks(true)
console.log("Books sorted by title")

// Step 4: Search for a book
var searchResults = database.searchBook("dune")
if (searchResults.length > 0) {
    var book = searchResults[0]
    console.log("Found:", book.title, "by", book.author)
    
    // Step 5: Get recommendations for this book
    var related = database.getRelatedBooks(book.id)
    console.log("You might also like:")
    for (var i = 0; i < related.length; i++) {
        console.log("-", related[i].title)
    }
}

// Step 6: Update a book
database.updateBook(book.id, "Dune", "Frank Herbert", "Science Fiction", 1965, 10, "assets/dune_new.jpg")
console.log("Book updated!")

// Step 7: Get all books
var allBooks = database.getAllBooks()
console.log("Total books:", allBooks.length)

// ============================================================================
// 8. DATA STRUCTURE REFERENCE
// ============================================================================

// Book object structure returned by API:
{
    id: 1,                              // Integer: Unique book ID
    title: "The Hobbit",                // QString: Book title
    author: "J.R.R. Tolkien",          // QString: Book author
    genre: "Fantasy",                   // QString: Book genre
    year: 1937,                         // Integer: Publication year
    copies: 5,                          // Integer: Number of copies
    image_path: "assets/hobbit.jpg"     // QString: Path to cover image
}

// ============================================================================
// 9. ALGORITHM IMPLEMENTATIONS (For Reference)
// ============================================================================

/* MERGE SORT - Implemented in Database.cpp
   - Divide and conquer sorting algorithm
   - Stable sort (maintains relative order of equal elements)
   - O(n log n) time complexity
   - O(n) space complexity
   - Can sort by title or author
*/

/* BINARY SEARCH - Implemented in Database.cpp
   - Requires sorted array (call sortBooks first for best results)
   - O(log n) time complexity for exact match
   - Returns index of found book or -1
   - Automatically falls back to linear search for partial matches
*/

/* GRAPH (Adjacency List) - Implemented in Database.cpp
   - Maps genres to lists of book IDs
   - Provides O(1) genre lookup
   - Automatically rebuilt after book modifications
   - Used for genre-based recommendations
*/

// ============================================================================
// 10. BEST PRACTICES
// ============================================================================

// Always check if user is logged in before book operations
if (!database.isUserLoggedIn()) {
    console.error("User must be logged in to manage books")
    return
}

// Sort before searching for better performance
database.sortBooks(true)  // Sort by title
var results = database.searchBook("query")  // Binary search will be more effective

// Check return values
if (database.addBook(...)) {
    console.log("Book added successfully")
} else {
    console.error("Failed to add book")
}

// Use signals to update UI
Connections {
    target: database
    function onBooksChanged() {
        bookListModel.clear()
        var books = database.getAllBooks()
        for (var i = 0; i < books.length; i++) {
            bookListModel.append(books[i])
        }
    }
}

// ============================================================================
// 11. ERROR HANDLING
// ============================================================================

// All functions log errors to console with qDebug()
// Boolean return values indicate success (true) or failure (false)

// Example error checking
if (!database.initDatabase()) {
    console.error("Failed to initialize database")
    // Handle error
}

if (!database.loginUser(username, password)) {
    console.error("Login failed - check credentials")
    // Show error message to user
}

// ============================================================================
// END OF REFERENCE
// ============================================================================
