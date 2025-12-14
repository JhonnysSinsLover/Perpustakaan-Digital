import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.3
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    color: "#F8FAFC"
    
    // Properties
    property var books: database ? database.getAllBooks() : []
    property int totalBooks: books.length
    property int totalCopies: {
        var sum = 0
        for (var i = 0; i < books.length; i++) {
            sum += books[i].copies || 0
        }
        return sum
    }
    property int genreCount: {
        var genres = {}
        for (var i = 0; i < books.length; i++) {
            var genre = books[i].genre || "Unknown"
            genres[genre] = true
        }
        return Object.keys(genres).length
    }
    property var topGenres: []
    property var recentBooks: []
    
    // Theme Colors
    property color primaryColor: "#1565C0"
    property color primaryDark: "#0D47A1"
    property color primaryLight: "#E3F2FD"
    property color accentColor: "#FF9800"
    property color textPrimary: "#212121"
    property color textSecondary: "#757575"
    property color successColor: "#2E7D32"
    property color warningColor: "#EF6C00"
    
    // Functions
    function calculateTopGenres() {
        var genreMap = {}
        for (var i = 0; i < books.length; i++) {
            var genre = books[i].genre || "Lainnya"
            genreMap[genre] = (genreMap[genre] || 0) + 1
        }
        
        var genreArray = []
        for (var g in genreMap) {
            genreArray.push({name: g, count: genreMap[g]})
        }
        
        // Sort by count descending
        genreArray.sort(function(a, b) {
            return b.count - a.count
        })
        
        topGenres = genreArray.slice(0, 5) // Top 5 genres
    }
    
    function getRecentBooks() {
        // Sort by ID descending to get newest first
        var sorted = books.slice().sort(function(a, b) {
            return b.id - a.id
        })
        recentBooks = sorted.slice(0, 5) // Last 5 added books
    }
    
    function updateData() {
        books = database.getAllBooks()
        calculateTopGenres()
        getRecentBooks()
    }
    
    // Initialize
    Component.onCompleted: {
        updateData()
        refreshTimer.start()
    }
    
    // Connections
    Connections {
        target: database
        function onBooksChanged() {
            updateData()
        }
    }
    
    // Auto-refresh timer
    Timer {
        id: refreshTimer
        interval: 30000 // Refresh every 30 seconds
        repeat: true
        onTriggered: updateData()
    }
    
    // Main Layout
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        
        ColumnLayout {
            width: Math.min(1400, root.width - 40)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24
            
            // ========== HEADER ==========
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Dashboard Perpustakaan"
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: textPrimary
                }
                
                Text {
                    text: "Selamat datang, " + (database ? database.getCurrentUsername() : "Admin") + 
                          "! Kelola koleksi perpustakaan digital Anda dengan mudah."
                    font.pixelSize: 16
                    color: textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            
            // ========== QUICK STATS ROW ==========
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // Stat Card Component
                component StatCard: Rectangle {
                    property string title: ""
                    property string value: ""
                    property string icon: ""
                    property color bgColor: primaryColor
                    property color iconColor: "white"
                    
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: 12
                    color: "white"
                    
                    // Shadow
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 8
                        samples: 17
                        color: "#20000000"
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        // Icon
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 24
                            color: parent.parent.bgColor
                            
                            Text {
                                anchors.centerIn: parent
                                text: parent.parent.icon
                                font.pixelSize: 20
                                color: parent.parent.iconColor
                            }
                        }
                        
                        // Content
                        ColumnLayout {
                            spacing: 4
                            
                            Text {
                                text: parent.parent.value
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Text {
                                text: parent.parent.title
                                font.pixelSize: 14
                                color: textSecondary
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                StatCard {
                    title: "Total Judul Buku"
                    value: totalBooks.toString()
                    icon: "📚"
                    bgColor: primaryLight
                    iconColor: primaryColor
                }
                
                StatCard {
                    title: "Total Eksemplar"
                    value: totalCopies.toString()
                    icon: "📦"
                    bgColor: "#E8F5E9"
                    iconColor: successColor
                }
                
                StatCard {
                    title: "Kategori Genre"
                    value: genreCount.toString()
                    icon: "🏷️"
                    bgColor: "#FFF3E0"
                    iconColor: warningColor
                }
                
                StatCard {
                    title: "Genre Terpopuler"
                    value: topGenres.length > 0 ? topGenres[0].name : "-"
                    icon: "📊"
                    bgColor: "#F3E5F5"
                    iconColor: "#9C27B0"
                }
            }
            
            // ========== CHARTS & ACTIVITY SECTION ==========
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // Genre Distribution Chart
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.minimumHeight: 400
                    radius: 12
                    color: "white"
                    
                    // Shadow
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 8
                        samples: 17
                        color: "#20000000"
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Distribusi Genre"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: topGenres.length + " genre teratas"
                                font.pixelSize: 12
                                color: textSecondary
                            }
                        }
                        
                        // Chart or Empty State
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            
                            // Simple Bar Chart using rectangles
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 8
                                
                                Repeater {
                                    model: topGenres.length > 0 ? topGenres : 1
                                    
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 12
                                        
                                        // Genre name
                                        Text {
                                            text: topGenres.length > 0 ? 
                                                  modelData.name.substring(0, 15) + (modelData.name.length > 15 ? "..." : "") : 
                                                  "Belum ada data genre"
                                            font.pixelSize: 12
                                            color: textSecondary
                                            Layout.preferredWidth: 100
                                        }
                                        
                                        // Bar
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 24
                                            radius: 4
                                            color: index === 0 ? primaryColor : 
                                                   index === 1 ? "#2196F3" :
                                                   index === 2 ? "#03A9F4" :
                                                   index === 3 ? "#00BCD4" : "#B3E5FC"
                                            
                                            Rectangle {
                                                width: topGenres.length > 0 ? 
                                                       (modelData.count / Math.max(...topGenres.map(g => g.count))) * parent.width : 0
                                                height: parent.height
                                                radius: 4
                                                color: "white"
                                                opacity: 0.3
                                            }
                                            
                                            // Count label on bar
                                            Text {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: topGenres.length > 0 ? modelData.count : ""
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: index < 2 ? "white" : textPrimary
                                            }
                                        }
                                        
                                        // Percentage
                                        Text {
                                            text: topGenres.length > 0 ? 
                                                  ((modelData.count / totalBooks) * 100).toFixed(1) + "%" : ""
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: textPrimary
                                            Layout.preferredWidth: 40
                                        }
                                    }
                                }
                                
                                // Empty state
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 200
                                    height: 150
                                    color: "transparent"
                                    visible: topGenres.length === 0
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 16
                                        
                                        Text {
                                            text: "📊"
                                            font.pixelSize: 48
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: "Belum ada data genre"
                                            font.pixelSize: 14
                                            color: textSecondary
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: "Tambahkan buku untuk melihat distribusi genre"
                                            font.pixelSize: 12
                                            color: textSecondary
                                            horizontalAlignment: Text.AlignHCenter
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Recent Activity
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 400
                    radius: 12
                    color: "white"
                    
                    // Shadow
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 8
                        samples: 17
                        color: "#20000000"
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16
                        
                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Aktivitas Terbaru"
                                font.pixelSize: 18
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "Lihat Semua"
                                font.pixelSize: 12
                                flat: true
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: primaryColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                onClicked: mainWindow.currentIndex = 1
                            }
                        }
                        
                        // Activity List
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            ColumnLayout {
                                width: parent.width
                                spacing: 12
                                
                                Repeater {
                                    model: recentBooks
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 70
                                        radius: 8
                                        color: index % 2 === 0 ? "#F8FAFC" : "white"
                                        border.width: 1
                                        border.color: "#F1F3F4"
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 12
                                            
                                            // Book icon
                                            Rectangle {
                                                Layout.preferredWidth: 36
                                                Layout.preferredHeight: 36
                                                radius: 6
                                                color: primaryLight
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "📖"
                                                    font.pixelSize: 16
                                                    color: primaryColor
                                                }
                                            }
                                            
                                            // Book info
                                            ColumnLayout {
                                                spacing: 4
                                                Layout.fillWidth: true
                                                
                                                Text {
                                                    text: modelData.title
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    color: textPrimary
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }
                                                
                                                RowLayout {
                                                    spacing: 8
                                                    
                                                    Text {
                                                        text: modelData.author
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
                                                        text: modelData.year
                                                        font.pixelSize: 12
                                                        color: textSecondary
                                                    }
                                                    
                                                    Item { Layout.fillWidth: true }
                                                    
                                                    Text {
                                                        text: "Ditambahkan"
                                                        font.pixelSize: 10
                                                        color: successColor
                                                        font.bold: true
                                                    }
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
                                                parent.border.width = 1
                                            }
                                            onExited: {
                                                parent.border.color = "#F1F3F4"
                                                parent.border.width = 1
                                            }
                                        }
                                    }
                                }
                                
                                // Empty state
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 200
                                    height: 150
                                    color: "transparent"
                                    visible: recentBooks.length === 0
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 16
                                        
                                        Text {
                                            text: "📚"
                                            font.pixelSize: 48
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: "Belum ada aktivitas"
                                            font.pixelSize: 14
                                            color: textSecondary
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Button {
                                            text: "➕ Tambah Buku Pertama"
                                            Layout.alignment: Qt.AlignHCenter
                                            
                                            background: Rectangle {
                                                color: primaryColor
                                                radius: 8
                                            }
                                            
                                            contentItem: Text {
                                                text: parent.text
                                                color: "white"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            
                                            onClicked: mainWindow.currentIndex = 2
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // ========== QUICK ACTIONS ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 12
                color: "white"
                
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 8
                    samples: 17
                    color: "#20000000"
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "Aksi Cepat"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: textPrimary
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Button {
                            text: "📖 Katalog Buku"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            
                            background: Rectangle {
                                color: primaryLight
                                radius: 8
                                border.width: 1
                                border.color: primaryColor
                            }
                            
                            contentItem: RowLayout {
                                spacing: 8
                                
                                Text {
                                    text: "📖"
                                    font.pixelSize: 16
                                    color: primaryColor
                                }
                                
                                Text {
                                    text: "Lihat Katalog"
                                    color: primaryColor
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                            
                            onClicked: mainWindow.currentIndex = 1
                        }
                        
                        Button {
                            text: "➕ Tambah Buku"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            
                            background: Rectangle {
                                color: primaryColor
                                radius: 8
                            }
                            
                            contentItem: RowLayout {
                                spacing: 8
                                
                                Text {
                                    text: "➕"
                                    font.pixelSize: 16
                                    color: "white"
                                }
                                
                                Text {
                                    text: "Tambah Buku Baru"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                            
                            onClicked: mainWindow.currentIndex = 2
                        }
                        
                        Button {
                            text: "🔍 Cari Buku"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            
                            background: Rectangle {
                                color: primaryLight
                                radius: 8
                                border.width: 1
                                border.color: primaryColor
                            }
                            
                            contentItem: RowLayout {
                                spacing: 8
                                
                                Text {
                                    text: "🔍"
                                    font.pixelSize: 16
                                    color: primaryColor
                                }
                                
                                Text {
                                    text: "Pencarian Lanjut"
                                    color: primaryColor
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                            
                            onClicked: {
                                mainWindow.currentIndex = 1
                                if (stockPage) {
                                    stockPage.searchField.focus = true
                                }
                            }
                        }
                        
                        Button {
                            text: "📈 Statistik"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            
                            background: Rectangle {
                                color: "#E8F5E9"
                                radius: 8
                                border.width: 1
                                border.color: successColor
                            }
                            
                            contentItem: RowLayout {
                                spacing: 8
                                
                                Text {
                                    text: "📈"
                                    font.pixelSize: 16
                                    color: successColor
                                }
                                
                                Text {
                                    text: "Lihat Statistik"
                                    color: successColor
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                            }
                            
                            onClicked: mainWindow.currentIndex = 3
                        }
                    }
                }
            }
            
            Item { height: 40 } // Bottom spacer
        }
    }
}