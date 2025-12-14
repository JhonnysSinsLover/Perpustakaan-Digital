import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs

Popup {
    id: settingsPopup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: 450
    height: 650  // Increased height to accommodate all content
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    property string currentUserName: ""
    property string currentProfilePhoto: ""
    property string selectedImagePath: ""
    property bool hasRecoveryKey: false

    signal profileUpdated()

    function openSettings() {
        if (database && database.isUserLoggedIn()) {
            var user = database.getCurrentUser();
            currentUserName = user.full_name || database.getCurrentUsername() || "";
            currentProfilePhoto = user.profile_photo || "";
            nameInput.text = currentUserName;
            selectedImagePath = "";
            
            // Check if user has recovery key set
            hasRecoveryKey = database.currentUserHasRecoveryKey();
        }
        open();
    }

    function pathToUrl(path) {
        if (path === "" || !path) return "";
        if (path.startsWith("file:///")) return path;
        if (path.startsWith("qrc:/")) return path;
        
        // Convert Windows path to file URL
        var normalizedPath = path.replace(/\\/g, '/');
        if (!normalizedPath.startsWith('/')) {
            normalizedPath = '/' + normalizedPath;
        }
        return "file://" + normalizedPath;
    }    background: Rectangle {
        color: "white"
        radius: 15
        border.width: 0
    }    contentItem: ScrollView {
        anchors.fill: parent
        anchors.margins: 30
        clip: true
        
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        Column {
            width: settingsPopup.width - 60  // Parent width minus margins (30*2)
            spacing: 24        // Header
        Text {
            text: "Pengaturan Profil"
            font.pixelSize: 24
            font.bold: true
            color: "#1A1A1A"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        // Profile Photo Section
        Column {
            width: parent.width
            spacing: 12

            Text {
                text: "Foto Profil"
                font.pixelSize: 16
                font.bold: true
                color: "#1A1A1A"
            }            // High-performance circular profile photo display
            CircularProfilePhoto {
                width: 120
                height: 120
                borderWidth: 2
                borderColor: "#E5E7EB"
                x: (parent.width - width) / 2  // Center horizontally without anchors
                
                source: selectedImagePath !== "" ? pathToUrl(selectedImagePath) : pathToUrl(currentProfilePhoto)
                
                fallbackText: {
                    if (selectedImagePath !== "" || currentProfilePhoto !== "") return "";
                    if (currentUserName !== "") return currentUserName.charAt(0).toUpperCase();
                    return "U";
                }
                
                fallbackBackgroundColor: "#F3F4F6"
                fallbackTextColor: "#6B7280"
                fallbackFontSize: 48
                  // Upload overlay
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2  // Circular radius
                    color: "black"
                    opacity: photoMouseArea.containsMouse ? 0.3 : 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📷"
                        font.pixelSize: 24
                        color: "white"
                        opacity: parent.opacity > 0 ? 1 : 0
                    }
                }

                MouseArea {
                    id: photoMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: fileDialog.open()
                }
            }// Upload button
            Rectangle {
                width: 160
                height: 36
                color: "#3B82F6"
                radius: 8
                x: (parent.width - width) / 2  // Center horizontally without anchors

                Text {
                    anchors.centerIn: parent
                    text: "Pilih Foto"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#FFFFFF"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#2563EB"
                    onExited: parent.color = "#3B82F6"
                    onClicked: fileDialog.open()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Name Section
        Column {
            width: parent.width
            spacing: 12

            Text {
                text: "Nama Lengkap"
                font.pixelSize: 16
                font.bold: true
                color: "#1A1A1A"
            }

            TextField {
                id: nameInput
                width: parent.width
                height: 48
                font.pixelSize: 16
                placeholderText: "Masukkan nama lengkap"
                selectByMouse: true
                color: "#1A1A1A"
                leftPadding: 16
                rightPadding: 16

                background: Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: nameInput.activeFocus ? "#3B82F6" : "#D1D5DB"
                    radius: 8
                    color: "#FFFFFF"
                }
            }        }

        // Recovery Key Section
        Column {
            width: parent.width
            spacing: 12

            Text {
                text: "Kata Kunci Pemulihan"
                font.pixelSize: 16
                font.bold: true
                color: "#1A1A1A"
            }            Text {
                text: hasRecoveryKey ? "✅ Kata kunci pemulihan sudah diset - Anda dapat mengubahnya di bawah" : "Set kata kunci pemulihan untuk reset password jika lupa"
                font.pixelSize: 12
                color: hasRecoveryKey ? "#10B981" : "#6B7280"
                wrapMode: Text.WordWrap
                width: parent.width
            }Row {
                width: parent.width
                spacing: 12
                TextField {
                    id: recoveryKeyInput
                    width: parent.width - 112  // Fixed width calculation: 100 (button) + 12 (spacing)
                    height: 48
                    font.pixelSize: 14
                    placeholderText: hasRecoveryKey ? "Kata kunci sudah diset - masukkan yang baru untuk mengubah" : "Masukkan kata kunci pemulihan (min. 6 karakter)"
                    selectByMouse: true
                    color: "#1A1A1A"
                    leftPadding: 16
                    rightPadding: 16
                    echoMode: TextInput.Password

                    background: Rectangle {
                        anchors.fill: parent
                        border.width: 1
                        border.color: recoveryKeyInput.activeFocus ? "#3B82F6" : (hasRecoveryKey ? "#10B981" : "#D1D5DB")
                        radius: 8
                        color: "#FFFFFF"
                    }
                }

                Rectangle {
                    id: setRecoveryButton
                    width: 100
                    height: 48
                    radius: 8
                    color: setRecoveryMouseArea.containsMouse ? "#E6B800" : "#FFC800"
                    Text {
                        anchors.centerIn: parent
                        text: hasRecoveryKey ? "Ubah" : "Set"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1A1A1A"
                    }

                    MouseArea {
                        id: setRecoveryMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {                            if (recoveryKeyInput.text.trim().length >= 6) {
                                if (database.setRecoveryKey(recoveryKeyInput.text.trim())) {
                                    recoveryKeyInput.text = ""
                                    hasRecoveryKey = true  // Update status immediately
                                    recoverySuccessText.text = hasRecoveryKey ? "✅ Kata kunci pemulihan berhasil diubah" : "✅ Kata kunci pemulihan berhasil diset"
                                    recoverySuccessText.visible = true
                                    recoveryErrorText.visible = false
                                    hideRecoveryMessageTimer.start()
                                } else {
                                    recoveryErrorText.text = "❌ Gagal mengset kata kunci pemulihan"
                                    recoveryErrorText.visible = true
                                    recoverySuccessText.visible = false
                                    hideRecoveryMessageTimer.start()
                                }
                            } else {
                                recoveryErrorText.text = "❌ Kata kunci pemulihan minimal 6 karakter"
                                recoveryErrorText.visible = true
                                recoverySuccessText.visible = false
                                hideRecoveryMessageTimer.start()
                            }
                        }
                    }
                }
            }            // Success message
            Text {
                id: recoverySuccessText
                text: "✅ Kata kunci pemulihan berhasil diset"  // This will be updated dynamically in onClick
                font.pixelSize: 12
                color: "#10B981"
                visible: false
            }

            // Error message
            Text {
                id: recoveryErrorText
                text: "❌ Gagal mengset kata kunci pemulihan"
                font.pixelSize: 12
                color: "#EF4444"
                visible: false
            }

            // Timer to hide messages
            Timer {
                id: hideRecoveryMessageTimer
                interval: 3000
                onTriggered: {
                    recoverySuccessText.visible = false
                    recoveryErrorText.visible = false
                }
            }
        }        // Buttons
        Row {
            width: parent.width
            spacing: 16

            // Cancel button
            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: 48
                color: "#F3F4F6"
                radius: 8
                border.width: 1
                border.color: "#D1D5DB"

                Text {
                    anchors.centerIn: parent
                    text: "Batal"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#374151"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#E5E7EB"
                    onExited: parent.color = "#F3F4F6"
                    onClicked: settingsPopup.close()
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Save button
            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: 48
                color: "#059669"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: "Simpan"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#FFFFFF"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#047857"
                    onExited: parent.color = "#059669"
                    onClicked: {
                        if (nameInput.text.trim() === "") {
                            // Could add error message here
                            return;
                        }

                        var success = false;
                        var finalImagePath = selectedImagePath !== "" ? selectedImagePath : currentProfilePhoto;
                        
                        // Convert file URL to Windows path for database storage
                        var pathForDatabase = finalImagePath;
                        if (selectedImagePath !== "" && selectedImagePath.startsWith("file:///")) {
                            pathForDatabase = selectedImagePath.replace("file:///", "").replace(/\//g, "\\");
                        }

                        if (selectedImagePath !== "" || currentProfilePhoto !== "") {
                            success = database.updateUserProfileWithPhoto(nameInput.text.trim(), pathForDatabase);
                        } else {
                            success = database.updateUserProfile(nameInput.text.trim());
                        }

                        if (success) {
                            profileUpdated();
                            settingsPopup.close();
                        }
                    }
                    cursorShape: Qt.PointingHandCursor                }
            }
        }
        } // End of Column
    } // End of ScrollView

    // File Dialog for photo selection
    FileDialog {
        id: fileDialog
        title: "Pilih Foto Profil"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif)"]
        onAccepted: {
            selectedImagePath = selectedFile.toString();
        }
    }
}
