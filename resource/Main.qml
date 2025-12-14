import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: mainWindow
    width: Screen.width
    height: Screen.height
    minimumWidth: 1200
    minimumHeight: 700
    visible: true
    title: "Library Management System"
    flags: Qt.Window | Qt.FramelessWindowHint
    
    property int currentIndex: 0
    property string currentPageTitle: "Dashboard"
    
    // Bind properties from C++
    property bool loggedIn: appLogic ? appLogic.loggedIn : false
    
    Connections {
        target: appLogic
        function onLoggedInChanged() {
            if (appLogic.loggedIn) {
                currentIndex = 0
            }
        }
    }
    
    function logout() {
        if (database) {
            database.logoutUser()
        }
        if (appLogic) {
            appLogic.logout()
        }
    }
    
    // Window drag functionality
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: function(mouse) { 
            lastMousePos = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                mainWindow.x += (mouse.x - lastMousePos.x)
                mainWindow.y += (mouse.y - lastMousePos.y)
            }
        }
    }
    
    // Title Bar
    Rectangle {
        id: titleBar
        width: parent.width
        height: 32
        color: "#0D47A1"
        z: 1000
        
        Row {
            anchors.right: parent.right
            spacing: 0
            
            Rectangle {
                width: 46
                height: 32
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "−"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: mainWindow.showMinimized()
                    hoverEnabled: true
                    onEntered: parent.color = "#1565C0"
                    onExited: parent.color = "transparent"
                }
            }
            
            Rectangle {
                width: 46
                height: 32
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "□"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (mainWindow.visibility === Window.Maximized) {
                            mainWindow.showNormal()
                        } else {
                            mainWindow.showMaximized()
                        }
                    }
                    hoverEnabled: true
                    onEntered: parent.color = "#1565C0"
                    onExited: parent.color = "transparent"
                }
            }
            
            Rectangle {
                width: 46
                height: 32
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: mainWindow.close()
                    hoverEnabled: true
                    onEntered: parent.color = "#D32F2F"
                    onExited: parent.color = "transparent"
                }
            }
        }
    }
    
    // Main Content Area
    Rectangle {
        anchors.top: titleBar.bottom
        width: parent.width
        height: parent.height - titleBar.height
        color: "#F5F7FA"
        
        Component {
            id: loginComponent
            Login {
                onLoginSuccess: {
                    if (appLogic) {
                        appLogic.login()
                    }
                }
            }
        }
        
        // Main Layout with Sidebar
        RowLayout {
            anchors.fill: parent
            spacing: 0
            visible: appLogic && appLogic.loggedIn
            
            // Sidebar
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 250
                color: "#0D47A1"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // Logo/Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#0A3A7A"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: "📚"
                                font.pixelSize: 36
                                color: "#FFFFFF"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Perpustakaan Digital"
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                font.bold: true
                                color: "#FFFFFF"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Menu Items
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ColumnLayout {
                            anchors.top: parent.top
                            anchors.topMargin: 24
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8
                            
                            // Dashboard
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 8
                                color: currentIndex === 0 ? "#1565C0" : "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    spacing: 14
                                    
                                    Text {
                                        text: "🏠"
                                        font.pixelSize: 20
                                        color: "#FFFFFF"
                                    }
                                    
                                    Text {
                                        text: "Dashboard"
                                        font.pixelSize: 15
                                        font.family: "Segoe UI"
                                        font.weight: Font.Medium
                                        color: "#FFFFFF"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        currentIndex = 0
                                        currentPageTitle = "Dashboard"
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = currentIndex === 0 ? "#1565C0" : "#1565C0"
                                    onExited: parent.color = currentIndex === 0 ? "#1565C0" : "transparent"
                                }
                            }
                            
                            // Katalog & Peminjaman
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 8
                                color: currentIndex === 1 ? "#1565C0" : "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    spacing: 14
                                    
                                    Text {
                                        text: "📖"
                                        font.pixelSize: 20
                                        color: "#FFFFFF"
                                    }
                                    
                                    Text {
                                        text: "Katalog Buku"
                                        font.pixelSize: 15
                                        font.family: "Segoe UI"
                                        font.weight: Font.Medium
                                        color: "#FFFFFF"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        currentIndex = 1
                                        currentPageTitle = "Katalog Buku"
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = currentIndex === 1 ? "#1565C0" : "#1565C0"
                                    onExited: parent.color = currentIndex === 1 ? "#1565C0" : "transparent"
                                }
                            }
                            
                            // Manajemen Buku
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 8
                                color: currentIndex === 2 ? "#1565C0" : "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    spacing: 14
                                    
                                    Text {
                                        text: "➕"
                                        font.pixelSize: 20
                                        color: "#FFFFFF"
                                    }
                                    
                                    Text {
                                        text: "Tambah Buku"
                                        font.pixelSize: 15
                                        font.family: "Segoe UI"
                                        font.weight: Font.Medium
                                        color: "#FFFFFF"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        currentIndex = 2
                                        currentPageTitle = "Tambah Buku"
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = currentIndex === 2 ? "#1565C0" : "#1565C0"
                                    onExited: parent.color = currentIndex === 2 ? "#1565C0" : "transparent"
                                }
                            }
                        }
                    }
                    
                    // Logout Button at Bottom
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "transparent"
                        
                        Rectangle {
                            width: parent.width - 24
                            height: 48
                            anchors.centerIn: parent
                            color: "#D32F2F"
                            radius: 8
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 10
                                
                                Text {
                                    text: "🚪"
                                    font.pixelSize: 20
                                    color: "#FFFFFF"
                                }
                                
                                Text {
                                    text: "Logout"
                                    font.pixelSize: 15
                                    font.family: "Segoe UI"
                                    font.weight: Font.DemiBold
                                    color: "#FFFFFF"
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: logout()
                                hoverEnabled: true
                                onEntered: parent.color = "#B71C1C"
                                onExited: parent.color = "#D32F2F"
                            }
                        }
                    }
                }
            }
            
            // Right Content Area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                
                // Top Bar Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 75
                    color: "#FFFFFF"
                    
                    layer.enabled: true
                    layer.effect: Item {
                        ShaderEffect {
                            property real shadow: 0.08
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 36
                        anchors.rightMargin: 36
                        spacing: 0
                        
                        Text {
                            text: currentPageTitle
                            font.pixelSize: 26
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#1F2937"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 40
                            radius: 20
                            color: "#F3F4F6"
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 10
                                
                                Text {
                                    text: "👤"
                                    font.pixelSize: 18
                                }
                                
                                Text {
                                    text: database ? database.getCurrentUsername() : "User"
                                    font.pixelSize: 14
                                    font.family: "Segoe UI"
                                    font.weight: Font.Medium
                                    color: "#374151"
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
                
                // StackLayout for Pages
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: mainWindow.currentIndex
                    
                    // Page 0: Dashboard
                    Dashboard {}
                    
                    // Page 1: Stock (Katalog)
                    Stock {}
                    
                    // Page 2: ManageStore
                    ManageStore {}
                }
            }
        }
        
        // Login Screen (shown when not logged in)
        Loader {
            anchors.fill: parent
            sourceComponent: loginComponent
            active: !appLogic || !appLogic.loggedIn
        }
    }
}
