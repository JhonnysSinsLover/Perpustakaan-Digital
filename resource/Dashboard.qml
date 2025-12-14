import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#F5F7FA"
    
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
    
    Connections {
        target: database
        function onBooksChanged() {
            books = database.getAllBooks()
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 75
        clip: true
        
        ColumnLayout {
            width: parent.width - 80
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32
            anchors.topMargin: 40
        
        // Welcome Header
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Selamat Datang di Perpustakaan Digital"
                font.pixelSize: 32
                font.family: "Segoe UI"
                font.weight: Font.Bold
                color: "#1F2937"
            }
            
            Text {
                text: "Kelola koleksi perpustakaan digital Anda dengan mudah dan efisien"
                font.pixelSize: 16
                font.family: "Segoe UI"
                color: "#6B7280"
            }
        }
        
        // Stats Cards Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 24
            
            // Total Koleksi Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1976D2" }
                    GradientStop { position: 1.0; color: "#1565C0" }
                }
                
                layer.enabled: true
                layer.effect: Item {
                    ShaderEffect {
                        property real shadow: 0.15
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16
                    
                    Text {
                        text: "📚"
                        font.pixelSize: 40
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: totalBooks.toString()
                        font.pixelSize: 42
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "Total Koleksi Buku"
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        font.weight: Font.Medium
                        color: "#BBDEFB"
                    }
                }
            }
            
            // Kategori/Genre Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0D47A1" }
                    GradientStop { position: 1.0; color: "#1565C0" }
                }
                
                layer.enabled: true
                layer.effect: Item {
                    ShaderEffect {
                        property real shadow: 0.15
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16
                    
                    Text {
                        text: "🏷️"
                        font.pixelSize: 40
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: genreCount.toString()
                        font.pixelSize: 42
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "Kategori/Genre"
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        font.weight: Font.Medium
                        color: "#90CAF9"
                    }
                }
            }
            
            // Total Stok Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1E88E5" }
                    GradientStop { position: 1.0; color: "#1976D2" }
                }
                
                layer.enabled: true
                layer.effect: Item {
                    ShaderEffect {
                        property real shadow: 0.15
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16
                    
                    Text {
                        text: "📦"
                        font.pixelSize: 40
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: totalCopies.toString()
                        font.pixelSize: 42
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                    
                    Text {
                        text: "Total Stok Buku"
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        font.weight: Font.Medium
                        color: "#BBDEFB"
                    }
                }
            }
        }
        
        // Recent Activity Section
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 400
            radius: 14
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 20
                
                Text {
                    text: "Aktivitas Terbaru"
                    font.pixelSize: 22
                    font.family: "Segoe UI"
                    font.weight: Font.Bold
                    color: "#1F2937"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#E5E7EB"
                    radius: 1
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 12
                        
                        Repeater {
                            model: Math.min(5, books.length)
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 72
                                radius: 10
                                color: "#F9FAFB"
                                border.color: "#E5E7EB"
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 16
                                    
                                    Rectangle {
                                        width: 48
                                        height: 48
                                        radius: 24
                                        color: "#1565C0"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📖"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        
                                        Text {
                                            text: books[index] ? ("Buku Ditambahkan: " + books[index].title) : ""
                                            font.pixelSize: 15
                                            font.family: "Segoe UI"
                                            font.weight: Font.DemiBold
                                            color: "#1F2937"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        
                                        Text {
                                            text: books[index] ? ("Penulis: " + books[index].author) : ""
                                            font.pixelSize: 13
                                            font.family: "Segoe UI"
                                            color: "#6B7280"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                        
                        Text {
                            visible: books.length === 0
                            text: "Belum ada buku yang ditambahkan.\nMulai tambahkan buku baru!"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            color: "#9CA3AF"
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 60
                        }
                    }
                }
            }
        }
        
        Item { height: 40 }
        }
    }
}
