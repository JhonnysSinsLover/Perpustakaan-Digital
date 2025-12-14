import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: mainWindow
    width: 1400
    height: 900
    visible: true
    title: "Sistem Perpustakaan Digital 2025"
    minimumWidth: 1200
    minimumHeight: 700

    // Color Theme
    property color primaryColor: "#1565C0"
    property color primaryDark: "#0D47A1"
    property color primaryLight: "#E3F2FD"
    property color accentColor: "#FF9800"
    property color textPrimary: "#212121"
    property color textSecondary: "#757575"
    property color background: "#F8FAFC"

    // Application State
    property int currentIndex: 0
    property string currentPageTitle: "Dashboard"
    property bool isUserLoggedIn: appLogic ? appLogic.loggedIn : false

    onIsUserLoggedInChanged: {
        if (isUserLoggedIn) {
            currentIndex = 0
            currentPageTitle = "Dashboard"
        }
    }

    // Functions
    function logoutSystem() {
        if (database) database.logoutUser()
        if (appLogic) appLogic.logout()
    }

    function formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    }

    // --- MAIN LAYOUT (Sidebar + Content) ---
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ========== SIDEBAR ==========
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: primaryDark

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Logo Area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 60
                            height: 60
                            radius: 12
                            color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: "📚"
                                font.pixelSize: 32
                            }
                        }

                        Text {
                            text: "DIGITAL\nLIBRARY"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Sistem Perpustakaan"
                            color: "#90CAF9"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true;
                    height: 1;
                    color: "#2196F3"
                    opacity: 0.3
                }

                // Navigation Menu
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    spacing: 8

                    // Menu Button Component
                    component MenuButton: Rectangle {
                        property string icon: ""
                        property string label: ""
                        property int index: 0

                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: 8
                        color: currentIndex === index ? primaryColor : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            spacing: 15

                            Text {
                                text: icon
                                font.pixelSize: 18
                                color: currentIndex === index ? "white" : "#BBDEFB"
                            }

                            Text {
                                text: label
                                font.pixelSize: 14
                                font.bold: currentIndex === index
                                color: currentIndex === index ? "white" : "#E3F2FD"
                            }
                        }

                        Rectangle {
                            visible: currentIndex === index
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: 24
                            radius: 2
                            color: accentColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentIndex = index
                                currentPageTitle = label
                            }
                        }
                    }

                    MenuButton { icon: "📊"; label: "Dashboard"; index: 0 }
                    MenuButton { icon: "📚"; label: "Katalog Buku"; index: 1 }
                    MenuButton { icon: "➕"; label: "Manajemen Buku"; index: 2 }
                    MenuButton { icon: "📈"; label: "Statistik"; index: 3 }
                    MenuButton { icon: "⚙️"; label: "Pengaturan"; index: 4 }
                }

                // Spacer
                Item { Layout.fillHeight: true }

                // User Info
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    Layout.margins: 16
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 24
                            color: primaryColor

                            Text {
                                anchors.centerIn: parent
                                text: "👤"
                                font.pixelSize: 20
                                color: "white"
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: database ? database.getCurrentUsername() : "Guest"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 14
                            }

                            Text {
                                text: "Administrator"
                                color: "#90CAF9"
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                // Logout Button
                Button {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.preferredHeight: 45
                    text: "Keluar"

                    background: Rectangle {
                        color: "#D32F2F"
                        radius: 8
                        border.width: 0

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: parent.color
                            opacity: parent.parent.hovered ? 0.8 : 1.0
                        }
                    }

                    contentItem: RowLayout {
                        spacing: 10

                        Text {
                            text: "🚪"
                            font.pixelSize: 16
                            color: "white"
                        }

                        Text {
                            text: parent.parent.text
                            color: "white"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    onClicked: logoutSystem()
                }

                Item { Layout.preferredHeight: 20 }
            }
        }

        // ========== MAIN CONTENT AREA ==========
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "white"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#E0E0E0"
                    opacity: 0.5
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    spacing: 20

                    // Page Title
                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: currentPageTitle
                            font.pixelSize: 24
                            font.bold: true
                            color: textPrimary
                        }

                        Text {
                            text: {
                                var date = new Date()
                                var days = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"]
                                var months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni",
                                             "Juli", "Agustus", "September", "Oktober", "November", "Desember"]
                                return days[date.getDay()] + ", " + date.getDate() + " " +
                                       months[date.getMonth()] + " " + date.getFullYear()
                            }
                            font.pixelSize: 12
                            color: textSecondary
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Search Bar
                    Rectangle {
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 40
                        radius: 20
                        color: background
                        border.color: "#E0E0E0"
                        border.width: 1

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
                                Layout.fillWidth: true
                                placeholderText: "Cari buku..."
                                font.pixelSize: 13
                                background: Item {}
                                onTextChanged: {
                                    if (currentIndex === 1 && stockPage) {
                                        stockPage.searchText = text
                                        stockPage.performSearch()
                                    }
                                }
                            }
                        }
                    }

                    // Status Indicators
                    RowLayout {
                        spacing: 20

                        Rectangle {
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: 20
                            color: primaryLight

                            Text {
                                anchors.centerIn: parent
                                text: "📖"
                                font.pixelSize: 18
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: currentIndex = 1
                            }
                        }

                        Rectangle {
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: 20
                            color: primaryLight

                            Text {
                                anchors.centerIn: parent
                                text: "🔔"
                                font.pixelSize: 18
                            }
                        }
                    }
                }
            }

            // Page Content
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: background

                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    currentIndex: mainWindow.currentIndex

                    Dashboard { id: dashboardPage }
                    Stock { id: stockPage }
                    ManageStore { id: managePage }
                    Overview { id: statsPage }
                    Settings { id: settingsPage }
                }
            }
        }
    }

    // ========== LOGIN OVERLAY ==========
    Loader {
        anchors.fill: parent
        z: 9999
        active: !isUserLoggedIn
        sourceComponent: Login {
            onLoginSuccess: {
                if (appLogic) appLogic.login()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: background
            visible: parent.active
            z: -1
        }
    }

    // ========== STATUS TOAST ==========
    Popup {
        id: toast
        anchors.centerIn: parent
        width: 300
        height: 60
        modal: false
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#323232"
            radius: 8
            opacity: 0.9
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
            timer.interval = duration
            timer.start()
        }

        Timer {
            id: timer
            onTriggered: toast.close()
        }
    }
}
