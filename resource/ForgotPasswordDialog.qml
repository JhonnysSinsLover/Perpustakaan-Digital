import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    id: forgotPasswordDialog
    modal: true
    focus: true
    closePolicy: Dialog.CloseOnEscape
    width: 450
    height: 500
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    property string currentStep: "username" // "username", "recovery", "newpassword", "success"
    property string enteredUsername: ""
    property string enteredRecoveryKey: ""
    
    signal passwordResetSuccess()
    
    function openDialog() {
        currentStep = "username"
        enteredUsername = ""
        enteredRecoveryKey = ""
        usernameField.text = ""
        recoveryKeyField.text = ""
        newPasswordField.text = ""
        confirmPasswordField.text = ""
        errorText.text = ""
        open()
    }
    
    function nextStep() {
        errorText.text = ""
        
        if (currentStep === "username") {
            if (usernameField.text.trim() === "") {
                errorText.text = "Username tidak boleh kosong"
                return
            }
            
            enteredUsername = usernameField.text.trim()
            
            // Check if user exists - skip recovery key check for now
            // Recovery key feature can be added later
            // For now, just verify username exists
            var userExists = database.loginUser(enteredUsername, "") // This will fail but check username
            // Continue to recovery step regardless
            // TODO: Implement hasRecoveryKey in Database backend
            
            currentStep = "recovery"
        } else if (currentStep === "recovery") {
            if (recoveryKeyField.text.trim() === "") {
                errorText.text = "Kata kunci pemulihan tidak boleh kosong"
                return
            }
            
            enteredRecoveryKey = recoveryKeyField.text.trim()
            
            // Verify recovery key - temporarily disabled
            // TODO: Implement verifyRecoveryKey in Database backend
            var keyValid = true // Placeholder
            if (!keyValid) {
                errorText.text = "Kata kunci pemulihan salah"
                return
            }
            
            currentStep = "newpassword"
        } else if (currentStep === "newpassword") {
            if (newPasswordField.text.length < 6) {
                errorText.text = "Password minimal 6 karakter"
                return
            }
            
            if (newPasswordField.text !== confirmPasswordField.text) {
                errorText.text = "Konfirmasi password tidak cocok"
                return
            }
            
            // Reset password
            if (database.resetPasswordWithRecovery(enteredUsername, enteredRecoveryKey, newPasswordField.text)) {
                currentStep = "success"
            } else {
                errorText.text = "Gagal mengubah password. Silakan coba lagi."
            }
        }
    }
    
    background: Rectangle {
        color: "#FFFFFF"
        radius: 15
        border.width: 1
        border.color: "#E5E7EB"
    }
    
    contentItem: Rectangle {
        color: "transparent"
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            // Header
            Row {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "🔑"
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: {
                        switch(currentStep) {
                            case "username": return "Lupa Password"
                            case "recovery": return "Verifikasi Kata Kunci"
                            case "newpassword": return "Password Baru"
                            case "success": return "Berhasil!"
                            default: return "Lupa Password"
                        }
                    }
                    font.pixelSize: 20
                    font.bold: true
                    color: "#1A1A1A"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Progress indicator
            Row {
                width: parent.width
                spacing: 8
                
                Repeater {
                    model: 4
                    delegate: Rectangle {
                        width: (parent.width - 24) / 4
                        height: 4
                        radius: 2
                        color: {
                            var stepIndex = index
                            var currentIndex = {
                                "username": 0,
                                "recovery": 1,
                                "newpassword": 2,
                                "success": 3
                            }[currentStep] || 0
                            
                            return stepIndex <= currentIndex ? "#FFC800" : "#E5E7EB"
                        }
                    }
                }
            }
            
            // Content based on current step
            Rectangle {
                width: parent.width
                height: 250
                color: "transparent"
                
                // Step 1: Username
                Column {
                    visible: currentStep === "username"
                    anchors.fill: parent
                    spacing: 16
                    
                    Text {
                        text: "Masukkan username akun Anda"
                        font.pixelSize: 14
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#F9FAFB"
                        radius: 8
                        border.width: usernameField.activeFocus ? 2 : 1
                        border.color: usernameField.activeFocus ? "#FFC800" : "#E5E7EB"
                        
                        TextInput {
                            id: usernameField
                            anchors.fill: parent
                            anchors.margins: 12
                            font.pixelSize: 14
                            verticalAlignment: TextInput.AlignVCenter
                            
                            Keys.onReturnPressed: nextStep()
                            
                            Text {
                                visible: parent.text === "" && !parent.activeFocus
                                text: "Username"
                                color: "#9CA3AF"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                
                // Step 2: Recovery Key
                Column {
                    visible: currentStep === "recovery"
                    anchors.fill: parent
                    spacing: 16
                    
                    Text {
                        text: "Masukkan kata kunci pemulihan untuk akun: " + enteredUsername
                        font.pixelSize: 14
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#F9FAFB"
                        radius: 8
                        border.width: recoveryKeyField.activeFocus ? 2 : 1
                        border.color: recoveryKeyField.activeFocus ? "#FFC800" : "#E5E7EB"
                        
                        TextInput {
                            id: recoveryKeyField
                            anchors.fill: parent
                            anchors.margins: 12
                            font.pixelSize: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            
                            Keys.onReturnPressed: nextStep()
                            
                            Text {
                                visible: parent.text === "" && !parent.activeFocus
                                text: "Kata kunci pemulihan"
                                color: "#9CA3AF"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                
                // Step 3: New Password
                Column {
                    visible: currentStep === "newpassword"
                    anchors.fill: parent
                    spacing: 16
                    
                    Text {
                        text: "Buat password baru untuk akun Anda"
                        font.pixelSize: 14
                        color: "#6B7280"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#F9FAFB"
                        radius: 8
                        border.width: newPasswordField.activeFocus ? 2 : 1
                        border.color: newPasswordField.activeFocus ? "#FFC800" : "#E5E7EB"
                        
                        TextInput {
                            id: newPasswordField
                            anchors.fill: parent
                            anchors.margins: 12
                            font.pixelSize: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            
                            Text {
                                visible: parent.text === "" && !parent.activeFocus
                                text: "Password baru (minimal 6 karakter)"
                                color: "#9CA3AF"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#F9FAFB"
                        radius: 8
                        border.width: confirmPasswordField.activeFocus ? 2 : 1
                        border.color: confirmPasswordField.activeFocus ? "#FFC800" : "#E5E7EB"
                        
                        TextInput {
                            id: confirmPasswordField
                            anchors.fill: parent
                            anchors.margins: 12
                            font.pixelSize: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            
                            Keys.onReturnPressed: nextStep()
                            
                            Text {
                                visible: parent.text === "" && !parent.activeFocus
                                text: "Konfirmasi password baru"
                                color: "#9CA3AF"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                
                // Step 4: Success
                Column {
                    visible: currentStep === "success"
                    anchors.centerIn: parent
                    spacing: 16
                    
                    Text {
                        text: "✅"
                        font.pixelSize: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Password berhasil diubah!"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#10B981"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Silakan login dengan password baru Anda"
                        font.pixelSize: 14
                        color: "#6B7280"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            // Error message
            Text {
                id: errorText
                text: ""
                font.pixelSize: 12
                color: "#EF4444"
                wrapMode: Text.WordWrap
                width: parent.width
                visible: text !== ""
            }
            
            // Buttons
            Row {
                width: parent.width
                spacing: 12
                layoutDirection: Qt.RightToLeft
                
                // Primary button
                Rectangle {
                    width: 120
                    height: 45
                    radius: 8
                    color: primaryButtonMouseArea.containsMouse ? "#E6B800" : "#FFC800"
                    visible: currentStep !== "success"
                    
                    Text {
                        anchors.centerIn: parent
                        text: {
                            switch(currentStep) {
                                case "username": return "Lanjut"
                                case "recovery": return "Verifikasi"
                                case "newpassword": return "Ubah Password"
                                default: return "Lanjut"
                            }
                        }
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1A1A1A"
                    }
                    
                    MouseArea {
                        id: primaryButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nextStep()
                    }
                }
                
                // Close button for success step
                Rectangle {
                    width: 120
                    height: 45
                    radius: 8
                    color: closeButtonMouseArea.containsMouse ? "#E6B800" : "#FFC800"
                    visible: currentStep === "success"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Tutup"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1A1A1A"
                    }
                    
                    MouseArea {
                        id: closeButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passwordResetSuccess()
                            close()
                        }
                    }
                }
                
                // Cancel button
                Rectangle {
                    width: 80
                    height: 45
                    radius: 8
                    color: cancelButtonMouseArea.containsMouse ? "#F3F4F6" : "transparent"
                    border.width: 1
                    border.color: "#E5E7EB"
                    visible: currentStep !== "success"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Batal"
                        font.pixelSize: 14
                        color: "#6B7280"
                    }
                    
                    MouseArea {
                        id: cancelButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: close()
                    }
                }
            }
        }
    }
}
