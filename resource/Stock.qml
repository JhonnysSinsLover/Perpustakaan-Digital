import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#F5F7FA"
    
    property var books: []
    property var displayedBooks: []
    property string searchText: ""
    property int selectedBookId: -1
    property var relatedBooks: []
    
    function refreshBooks() {
        books = database ? database.getAllBooks() : []
        displayedBooks = books
    }
    
    function performSearch() {
        if (searchText.trim() === "") {
            displayedBooks = books
        } else {
            displayedBooks = database.searchBook(searchText)
        }
    }
    
    function sortByTitle() {
        database.sortBooks("title")
        refreshBooks()
    }
    
    function sortByYear() {
        database.sortBooks("year")
        refreshBooks()
    }
    
    function showRecommendations(bookId) {
        selectedBookId = bookId
        relatedBooks = database.getRelatedBooks(bookId)
        recommendationsDialog.open()
    }
    
    Component.onCompleted: refreshBooks()
    
    Connections {
        target: database
        function onBooksChanged() {
            refreshBooks()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        anchors.topMargin: 105
        spacing: 24
        
        // Top Bar Controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            // Search Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 10
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    
                    Text {
                        text: "🔍"
                        font.pixelSize: 20
                        color: "#6B7280"
                    }
                    
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Cari judul, penulis, atau genre..."
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        background: Item {}
                        onTextChanged: {
                            searchText = text
                            performSearch()
                        }
                    }
                }
            }
            
            // Sort by Title Button
            Button {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48
                
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#0D47A1" : (parent.hovered ? "#1565C0" : "#1976D2")
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: RowLayout {
                    spacing: 10
                    anchors.centerIn: parent
                    
                    Text {
                        text: "🅰️"
                        font.pixelSize: 18
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "Urutkan Judul"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }
                }
                
                onClicked: sortByTitle()
            }
            
            // Sort by Year Button
            Button {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48
                
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#0D47A1" : (parent.hovered ? "#1565C0" : "#1976D2")
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: RowLayout {
                    spacing: 10
                    anchors.centerIn: parent
                    
                    Text {
                        text: "📅"
                        font.pixelSize: 18
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "Urutkan Tahun"
                        font.pixelSize: 14
                        font.family: "Segoe UI"
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }
                }
                
                onClicked: sortByYear()
            }
            
            // Refresh Button
            Button {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                
                background: Rectangle {
                    radius: 10
                    color: parent.down ? "#E5E7EB" : (parent.hovered ? "#F3F4F6" : "#FFFFFF")
                    border.color: "#E5E7EB"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: "🔄"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: refreshBooks()
            }
        }
        
        // Results Count
        Text {
            text: displayedBooks.length + " buku ditemukan"
            font.pixelSize: 15
            font.family: "Segoe UI"
            font.weight: Font.Medium
            color: "#6B7280"
        }
        
        // GridView with Book Cards
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            GridView {
                id: bookGrid
                anchors.fill: parent
                cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 320)))
                cellHeight: 380
                model: displayedBooks
                
                delegate: Item {
                    width: bookGrid.cellWidth
                    height: bookGrid.cellHeight
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 12
                        radius: 14
                        color: "#FFFFFF"
                        border.color: "#E5E7EB"
                        border.width: 1
                        
                        layer.enabled: true
                        layer.effect: Item {
                            ShaderEffect {
                                property real shadow: 0.1
                            }
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            
                            // Book Cover Placeholder
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                radius: 14
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#1976D2" }
                                    GradientStop { position: 1.0; color: "#1565C0" }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📚"
                                    font.pixelSize: 64
                                }
                            }
                            
                            // Book Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.margins: 18
                                spacing: 10
                                
                                Text {
                                    text: modelData.title || ""
                                    font.pixelSize: 17
                                    font.family: "Segoe UI"
                                    font.weight: Font.Bold
                                    color: "#1F2937"
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: modelData.author || "Unknown"
                                    font.pixelSize: 14
                                    font.family: "Segoe UI"
                                    color: "#6B7280"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    Rectangle {
                                        Layout.preferredHeight: 26
                                        Layout.preferredWidth: genreLabel.implicitWidth + 18
                                        radius: 13
                                        color: "#E3F2FD"
                                        
                                        Text {
                                            id: genreLabel
                                            anchors.centerIn: parent
                                            text: modelData.genre || "N/A"
                                            font.pixelSize: 12
                                            font.family: "Segoe UI"
                                            font.weight: Font.Bold
                                            color: "#1565C0"
                                        }
                                    }
                                    
                                    Text {
                                        text: modelData.year || ""
                                        font.pixelSize: 12
                                        font.family: "Segoe UI"
                                        font.weight: Font.Medium
                                        color: "#9CA3AF"
                                    }
                                }
                                
                                Text {
                                    text: "Stok: " + (modelData.copies || 0)
                                    font.pixelSize: 14
                                    font.family: "Segoe UI"
                                    font.weight: Font.Bold
                                    color: "#059669"
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // Recommendations Button
                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    
                                    background: Rectangle {
                                        radius: 8
                                        color: parent.down ? "#0D47A1" : (parent.hovered ? "#1565C0" : "#1976D2")
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: "Lihat Rekomendasi"
                                        font.pixelSize: 13
                                        font.family: "Segoe UI"
                                        font.weight: Font.Bold
                                        color: "#FFFFFF"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: showRecommendations(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Empty State
        ColumnLayout {
            visible: displayedBooks.length === 0
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            
            Text {
                text: "📚"
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: searchText ? "Tidak ada hasil untuk pencarian Anda" : "Belum ada buku"
                font.pixelSize: 18
                font.family: "Segoe UI"
                font.bold: true
                color: "#6B7280"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
    
    // Recommendations Dialog
    Dialog {
        id: recommendationsDialog
        width: 640
        height: 540
        modal: true
        anchors.centerIn: parent
        title: "Rekomendasi Buku"
        
        background: Rectangle {
            radius: 16
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            
            Text {
                text: "Buku dengan Genre Serupa"
                font.pixelSize: 20
                font.family: "Segoe UI"
                font.weight: Font.Bold
                color: "#1F2937"
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 2
                radius: 1
                color: "#E5E7EB"
            }
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: parent.width
                    spacing: 12
                    
                    Repeater {
                        model: relatedBooks
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 90
                            radius: 12
                            color: "#F9FAFB"
                            border.color: "#E5E7EB"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16
                                
                                Rectangle {
                                    width: 64
                                    height: 64
                                    radius: 10
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#1976D2" }
                                        GradientStop { position: 1.0; color: "#1565C0" }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📖"
                                        font.pixelSize: 32
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    
                                    Text {
                                        text: modelData.title || ""
                                        font.pixelSize: 16
                                        font.family: "Segoe UI"
                                        font.weight: Font.Bold
                                        color: "#1F2937"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: modelData.author || ""
                                        font.pixelSize: 14
                                        font.family: "Segoe UI"
                                        color: "#6B7280"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: "Stok: " + (modelData.copies || 0)
                                        font.pixelSize: 13
                                        font.family: "Segoe UI"
                                        font.weight: Font.Medium
                                        color: "#059669"
                                    }
                                }
                            }
                        }
                    }
                    
                    Text {
                        visible: relatedBooks.length === 0
                        text: "Tidak ada rekomendasi buku untuk genre ini"
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        color: "#9CA3AF"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 60
                    }
                }
            }
            
            Button {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 44
                text: "Tutup"
                
                background: Rectangle {
                    radius: 8
                    color: parent.down ? "#E5E7EB" : (parent.hovered ? "#F3F4F6" : "#FFFFFF")
                    border.color: "#D1D5DB"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 15
                    font.family: "Segoe UI"
                    font.weight: Font.Medium
                    color: "#6B7280"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: recommendationsDialog.close()
            }
        }
    }
}
