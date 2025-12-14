import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: root
    color: "#F8FAFC"
    
    // Properties
    property var books: []
    property var displayedBooks: []
    property string searchText: ""
    property int selectedBookId: -1
    property var relatedBooks: []
    property bool sortedByTitle: database ? database.isSortedByTitle() : false
    property bool sortedByYear: database ? database.isSortedByYear() : false
    
    // Theme
    property color primaryColor: "#1565C0"
    property color primaryLight: "#E3F2FD"
    property color textPrimary: "#212121"
    property color textSecondary: "#757575"
    property color successColor: "#2E7D32"
    property color warningColor: "#EF6C00"
    
    // Functions
    function refreshBooks() {
        if (database) {
            books = database.getAllBooks()
            if (searchText === "") {
                displayedBooks = books
            } else {
                performSearch()
            }
            updateSortStatus()
        }
    }
    
    function performSearch() {
        if (searchText.trim() === "") {
            displayedBooks = books
        } else {
            displayedBooks = database.searchBook(searchText)
        }
        bookCountText.text = "Menampilkan " + displayedBooks.length + " dari " + books.length + " buku"
    }
    
    function sortByTitle() {
        database.sortBooks("title")
        refreshBooks()
        toast.show("Buku diurutkan berdasarkan Judul (A-Z)")
    }
    
    function sortByYear() {
        database.sortBooks("year")
        refreshBooks()
        toast.show("Buku diurutkan berdasarkan Tahun Terbit")
    }
    
    function showRecommendations(bookId) {
        selectedBookId = bookId
        relatedBooks = database.getRelatedBooks(bookId)
        recommendationsDialog.open()
    }
    
    function updateSortStatus() {
        sortedByTitle = database.isSortedByTitle()
        sortedByYear = database.isSortedByYear()
    }
    
    // Initialize
    Component.onCompleted: refreshBooks()
    
    // Connections
    Connections {
        target: database
        function onBooksChanged() {
            refreshBooks()
        }
        function onSortStatusChanged() {
            updateSortStatus()
        }
    }
    
    // Main Layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20
        
        // ========== HEADER ==========
        RowLayout {
            Layout.fillWidth: true
            
            ColumnLayout {
                spacing: 4
                
                Text {
                    text: "Katalog Buku"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    color: textPrimary
                }
                
                Text {
                    id: bookCountText
                    text: "Total " + books.length + " buku dalam koleksi"
                    font.pixelSize: 14
                    color: textSecondary
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // Quick Stats
            RowLayout {
                spacing: 20
                
                Rectangle {
                    implicitWidth: 120
                    implicitHeight: 60
                    radius: 8
                    color: "white"
                    border.width: 1
                    border.color: "#E0E0E0"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "📊"
                            font.pixelSize: 14
                            color: primaryColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Genre Teratas"
                            font.pixelSize: 10
                            color: textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: database ? database.getTopGenre() : "-"
                            font.pixelSize: 12
                            font.bold: true
                            color: textPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    implicitWidth: 120
                    implicitHeight: 60
                    radius: 8
                    color: "white"
                    border.width: 1
                    border.color: "#E0E0E0"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "🆕"
                            font.pixelSize: 14
                            color: successColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Terakhir Ditambah"
                            font.pixelSize: 10
                            color: textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: database ? database.getLastAddedTitle() : "-"
                            font.pixelSize: 12
                            font.bold: true
                            color: textPrimary
                            Layout.alignment: Qt.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }
            }
        }
        
        // ========== CONTROL BAR ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: 12
            color: "white"
            border.width: 1
            border.color: "#E0E0E0"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                // Search Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 20
                    color: "#F5F7FA"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10
                        
                        Text { 
                            text: "🔍"
                            font.pixelSize: 14
                            color: textSecondary
                        }
                        
                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Cari berdasarkan judul, penulis, genre, atau penerbit..."
                            font.pixelSize: 13
                            background: Item {}
                            onTextChanged: {
                                searchText = text
                                performSearch()
                            }
                        }
                        
                        // Clear Search Button
                        ToolButton {
                            visible: searchField.text.length > 0
                            text: "✕"
                            font.pixelSize: 12
                            onClicked: {
                                searchField.text = ""
                                searchText = ""
                                performSearch()
                            }
                        }
                    }
                }
                
                // Sort Buttons
                RowLayout {
                    spacing: 10
                    
                    Button {
                        id: titleSortBtn
                        text: sortedByTitle ? "Judul ✓" : "Urutkan Judul"
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 140
                        
                        background: Rectangle {
                            color: sortedByTitle ? primaryLight : "white"
                            radius: 8
                            border.color: sortedByTitle ? primaryColor : "#E0E0E0"
                            border.width: sortedByTitle ? 2 : 1
                        }
                        
                        contentItem: RowLayout {
                            spacing: 8
                            
                            Text {
                                text: sortedByTitle ? "📖" : "🔤"
                                font.pixelSize: 14
                                color: sortedByTitle ? primaryColor : textSecondary
                            }
                            
                            Text {
                                text: parent.parent.text
                                color: sortedByTitle ? primaryColor : textPrimary
                                font.bold: sortedByTitle
                                font.pixelSize: 13
                            }
                        }
                        
                        onClicked: sortByTitle()
                    }
                    
                    Button {
                        id: yearSortBtn
                        text: sortedByYear ? "Tahun ✓" : "Urutkan Tahun"
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 140
                        
                        background: Rectangle {
                            color: sortedByYear ? primaryLight : "white"
                            radius: 8
                            border.color: sortedByYear ? primaryColor : "#E0E0E0"
                            border.width: sortedByYear ? 2 : 1
                        }
                        
                        contentItem: RowLayout {
                            spacing: 8
                            
                            Text {
                                text: sortedByYear ? "📅" : "🗓️"
                                font.pixelSize: 14
                                color: sortedByYear ? primaryColor : textSecondary
                            }
                            
                            Text {
                                text: parent.parent.text
                                color: sortedByYear ? primaryColor : textPrimary
                                font.bold: sortedByYear
                                font.pixelSize: 13
                            }
                        }
                        
                        onClicked: sortByYear()
                    }
                }
            }
        }
        
        // ========== BOOK GRID ==========
        GridView {
            id: bookGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: 250
            cellHeight: 380
            model: displayedBooks
            visible: displayedBooks.length > 0
            
            delegate: Rectangle {
                width: bookGrid.cellWidth - 10
                height: bookGrid.cellHeight - 10
                radius: 12
                color: "white"
                
                // Shadow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 8
                    samples: 17
                    color: "#20000000"
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // Book Cover
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        radius: 8
                        color: primaryLight
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "📚"
                                font.pixelSize: 48
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: modelData.genre || "Umum"
                                font.pixelSize: 10
                                font.bold: true
                                color: primaryColor
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Book Title
                    Text {
                        text: modelData.title
                        Layout.fillWidth: true
                        font.pixelSize: 16
                        font.bold: true
                        color: textPrimary
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    
                    // Author
                    RowLayout {
                        spacing: 6
                        
                        Text {
                            text: "✍️"
                            font.pixelSize: 12
                            color: textSecondary
                        }
                        
                        Text {
                            text: modelData.author || "Penulis tidak diketahui"
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            color: textSecondary
                            elide: Text.ElideRight
                        }
                    }
                    
                    // Publisher & Year
                    RowLayout {
                        spacing: 6
                        
                        Text {
                            text: "🏢"
                            font.pixelSize: 12
                            color: textSecondary
                        }
                        
                        Text {
                            text: (modelData.publisher || "Tidak diketahui") + " • " + modelData.year
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            color: textSecondary
                            elide: Text.ElideRight
                        }
                    }
                    
                    // Copies Badge
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        radius: 4
                        color: modelData.copies > 0 ? "#E8F5E9" : "#FFEBEE"
                        border.width: 1
                        border.color: modelData.copies > 0 ? "#C8E6C9" : "#FFCDD2"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.copies > 0 ? 
                                  "Stok: " + modelData.copies + " eksemplar" : 
                                  "Stok Habis"
                            font.pixelSize: 11
                            font.bold: true
                            color: modelData.copies > 0 ? successColor : "#D32F2F"
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    // Recommendation Button
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: "📚 Lihat Rekomendasi"
                        
                        background: Rectangle {
                            color: parent.hovered ? primaryColor : "#1976D2"
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: showRecommendations(modelData.id)
                    }
                }
                
                // Hover Effect
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: {
                        parent.scale = 1.02
                        parent.z = 1
                    }
                    onExited: {
                        parent.scale = 1.0
                        parent.z = 0
                    }
                }
            }
            
            // Empty State
            Rectangle {
                anchors.centerIn: parent
                width: 400
                height: 200
                color: "transparent"
                visible: displayedBooks.length === 0
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        text: searchText.length > 0 ? "🔍" : "📚"
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: searchText.length > 0 ? 
                              "Tidak ditemukan buku dengan kata kunci: '" + searchText + "'" :
                              "Belum ada buku dalam koleksi"
                        font.pixelSize: 16
                        color: textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Button {
                        text: "➕ Tambah Buku Pertama"
                        visible: searchText.length === 0
                        Layout.alignment: Qt.AlignHCenter
                        
                        background: Rectangle {
                            color: primaryColor
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                        }
                        
                        onClicked: mainWindow.currentIndex = 2
                    }
                }
            }
        }
    }
    
    // ========== RECOMMENDATIONS DIALOG ==========
    Dialog {
        id: recommendationsDialog
        anchors.centerIn: parent
        width: Math.min(600, parent.width * 0.8)
        height: Math.min(500, parent.height * 0.8)
        modal: true
        title: "📚 Rekomendasi Buku Terkait"
        standardButtons: Dialog.Close
        
        background: Rectangle {
            color: "white"
            radius: 12
            border.width: 1
            border.color: "#E0E0E0"
            
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 16
                samples: 33
                color: "#40000000"
            }
        }
        
        header: Rectangle {
            height: 60
            color: primaryLight
            radius: 12
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                
                Text {
                    text: "📚"
                    font.pixelSize: 20
                }
                
                Text {
                    text: recommendationsDialog.title
                    font.pixelSize: 16
                    font.bold: true
                    color: textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                ToolButton {
                    text: "✕"
                    font.pixelSize: 14
                    onClicked: recommendationsDialog.close()
                }
            }
        }
        
        contentItem: ColumnLayout {
            spacing: 15
            
            Text {
                text: relatedBooks.length > 0 ? 
                      "Buku-buku berikut memiliki genre, penulis, atau tahun terbit yang serupa:" :
                      "Belum ada rekomendasi untuk buku ini."
                font.pixelSize: 14
                color: textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.leftMargin: 5
                Layout.rightMargin: 5
            }
            
            ListView {
                id: recommendationsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: relatedBooks
                spacing: 10
                visible: relatedBooks.length > 0
                
                delegate: Rectangle {
                    width: recommendationsList.width
                    height: 70
                    radius: 8
                    color: index % 2 === 0 ? "#F8FAFC" : "white"
                    border.width: 1
                    border.color: "#F1F3F4"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 15
                        
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 6
                            color: modelData.sameAuthor ? "#FFF3E0" : primaryLight
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.sameAuthor ? "✍️" : "📖"
                                font.pixelSize: 16
                                color: modelData.sameAuthor ? warningColor : primaryColor
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 4
                            
                            Text {
                                text: modelData.title
                                font.bold: true
                                font.pixelSize: 14
                                color: textPrimary
                                elide: Text.ElideRight
                            }
                            
                            RowLayout {
                                spacing: 10
                                
                                Text {
                                    text: "Penulis: " + modelData.author
                                    font.pixelSize: 12
                                    color: textSecondary
                                }
                                
                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: textSecondary
                                    opacity: 0.5
                                }
                                
                                Text {
                                    text: "Tahun: " + modelData.year
                                    font.pixelSize: 12
                                    color: textSecondary
                                }
                                
                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: textSecondary
                                    opacity: 0.5
                                }
                                
                                Text {
                                    text: modelData.genre
                                    font.pixelSize: 12
                                    color: primaryColor
                                    font.bold: true
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 24
                            radius: 4
                            color: modelData.copies > 0 ? "#E8F5E9" : "#FFEBEE"
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.copies > 0 ? "Ada" : "Habis"
                                font.pixelSize: 11
                                font.bold: true
                                color: modelData.copies > 0 ? successColor : "#D32F2F"
                            }
                        }
                    }
                    
                    // Hover effect
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: {
                            parent.border.color = primaryColor
                            parent.border.width = 2
                        }
                        onExited: {
                            parent.border.color = "#F1F3F4"
                            parent.border.width = 1
                        }
                    }
                }
                
                // Empty recommendations state
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: relatedBooks.length === 0
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 15
                        
                        Text {
                            text: "🔍"
                            font.pixelSize: 48
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Tidak ada rekomendasi tersedia"
                            font.pixelSize: 16
                            color: textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Sistem akan memberikan rekomendasi setelah Anda menambahkan lebih banyak buku dengan genre yang sama"
                            font.pixelSize: 12
                            color: textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                        }
                    }
                }
            }
        }
    }
    
    // Toast notification
    Popup {
        id: toast
        anchors.centerIn: parent
        width: 300
        height: 50
        modal: false
        closePolicy: Popup.NoAutoClose
        
        background: Rectangle {
            color: "#323232"
            radius: 8
            opacity: 0.95
        }
        
        contentItem: Text {
            text: toast.text
            color: "white"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        property string text: ""
        
        function show(message, duration = 2000) {
            text = message
            open()
            toastTimer.interval = duration
            toastTimer.start()
        }
        
        Timer {
            id: toastTimer
            onTriggered: toast.close()
        }
    }
}