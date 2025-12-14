import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    signal loginSuccess

    // Gradient background
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#E3F2FD" }
        GradientStop { position: 1.0; color: "#FFFFFF" }
    }

    // Properties untuk menyimpan nilai input
    property string password: ""
    property string username: ""
    property string fullName: ""
    property string confirmPassword: ""
    property bool isRegistering: false
    property string errorMessage: ""

    Row {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 40

        // Kolom kiri: Logo dan judul
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20
            width: parent.width / 2
            
            Text {
                text: "📚"
                font.pointSize: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: "PERPUSTAKAAN DIGITAL"
                font.pointSize: 36
                font.bold: true
                color: "#1976D2"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width * 0.8
            }
        }
        
        // Kolom kanan: Form login
        Item {
            width: parent.width / 2.2
            height: parent.height * 0.8
            anchors.verticalCenter: parent.verticalCenter

            // Kotak putih sebagai background
            Rectangle {
                anchors.fill: parent
                radius: 15
                color: "#FFFFFF"
                border.color: "#BBDEFB"
                border.width: 2
                z: -1
            }
            
            // Form login di atas background, tetap solid
            Column {
                anchors.centerIn: parent
                spacing: 12
                width: parent.width * 0.8

                Text {
                    text: isRegistering ? "Buat Akun Baru" : "Masuk ke Akun Anda"
                    font.pointSize: 22
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#1976D2"
                }

                // Error message display
                Rectangle {
                    width: parent.width
                    height: errorText.contentHeight + 20
                    color: "#ffebee"
                    border.color: "#f44336"
                    radius: 5
                    visible: errorMessage !== ""
                    
                    Text {
                        id: errorText
                        anchors.centerIn: parent
                        text: errorMessage
                        color: "#f44336"
                        font.pointSize: 10
                        wrapMode: Text.WordWrap
                        width: parent.width - 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                // Username field
                Text {
                    text: "Username *"
                    color: "#424242"
                    font.pixelSize: 14
                    font.bold: true
                }
                TextField {
                    id: usernameField
                    width: parent.width
                    placeholderText: "Masukkan username"
                    color: "#333333"
                    font.pixelSize: 14
                    padding: 12
                    onTextChanged: username = text
                    background: Rectangle {
                        radius: 8
                        border.color: usernameField.activeFocus ? "#2196F3" : "#BDBDBD"
                        border.width: 2
                        color: "white"
                    }
                }

                // Full name field (only for registration)
                Text {
                    text: "Nama Lengkap"
                    color: "#424242"
                    font.pixelSize: 14
                    font.bold: true
                    visible: isRegistering
                }
                TextField {
                    id: fullNameField
                    width: parent.width
                    placeholderText: "Masukkan nama lengkap (opsional)"
                    color: "#333333"
                    font.pixelSize: 14
                    padding: 12
                    visible: isRegistering
                    onTextChanged: fullName = text
                    background: Rectangle {
                        radius: 8
                        border.color: fullNameField.activeFocus ? "#2196F3" : "#BDBDBD"
                        border.width: 2
                        color: "white"
                    }
                }

                // Password field
                Text {
                    text: "Password *"
                    color: "#424242"
                    font.pixelSize: 14
                    font.bold: true
                }
                TextField {
                    id: passwordField
                    width: parent.width
                    placeholderText: "Masukkan password"
                    color: "#333333"
                    font.pixelSize: 14
                    padding: 12
                    echoMode: TextInput.Password
                    onTextChanged: password = text
                    background: Rectangle {
                        radius: 8
                        border.color: passwordField.activeFocus ? "#2196F3" : "#BDBDBD"
                        border.width: 2
                        color: "white"
                    }
                }
                
                // Confirm password field (only for registration)
                Text {
                    text: "Konfirmasi Password *"
                    color: "#424242"
                    font.pixelSize: 14
                    font.bold: true
                    visible: isRegistering
                }
                TextField {
                    id: confirmPasswordField
                    width: parent.width
                    placeholderText: "Masukkan ulang password"
                    color: "#333333"
                    font.pixelSize: 14
                    padding: 12
                    echoMode: TextInput.Password
                    visible: isRegistering
                    onTextChanged: confirmPassword = text
                    background: Rectangle {
                        radius: 8
                        border.color: confirmPasswordField.activeFocus ? "#2196F3" : "#BDBDBD"
                        border.width: 2
                        color: "white"
                    }
                }

                // Main action button (Login/Register)
                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 8
                    color: "#2196F3"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: isRegistering ? "Daftar" : "Masuk"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#1976D2"
                        onExited: parent.color = "#2196F3"
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            errorMessage = ""
                            
                            if (isRegistering) {
                                // Registration logic
                                if (username.trim() === "" || password === "") {
                                    errorMessage = "Please fill in all required fields"
                                    return
                                }
                                
                                if (password !== confirmPassword) {
                                    errorMessage = "Passwords do not match"
                                    return
                                }
                                
                                if (password.length < 6) {
                                    errorMessage = "Password must be at least 6 characters long"
                                    return
                                }
                                
                                // Call database registration
                                if (database.createUser(username.trim(), password, fullName.trim())) {
                                    // Auto login after successful registration
                                    if (database.loginUser(username.trim(), password)) {
                                        loginSuccess()
                                    } else {
                                        errorMessage = "Registration successful but login failed"
                                    }
                                } else {
                                    errorMessage = "Registration failed. Username may already exist."
                                }
                            } else {
                                // Login logic
                                if (username.trim() === "" || password === "") {
                                    errorMessage = "Please enter username and password"
                                    return
                                }
                                
                                // Try to login user
                                if (database.loginUser(username.trim(), password)) {
                                    loginSuccess()
                                } else {
                                    errorMessage = "Invalid username or password"
                                }
                            }
                        }
                    }
                }

                // Toggle between login and registration
                Text {
                    text: isRegistering ? "Sudah punya akun? Masuk" : "Belum punya akun? Daftar"
                    color: "#2196F3"
                    font.pointSize: 10
                    font.underline: toggleMouseArea.containsMouse
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    MouseArea {
                        id: toggleMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            isRegistering = !isRegistering
                            errorMessage = ""
                            // Clear all fields when switching
                            passwordField.text = ""
                            usernameField.text = ""
                            fullNameField.text = ""
                            confirmPasswordField.text = ""
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                  // Forgot password (only for login)
                Text {
                    text: "Lupa password?"
                    color: "#2196F3"
                    font.pointSize: 10
                    visible: !isRegistering
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.underline: forgotPasswordMouseArea.containsMouse
                    
                    MouseArea {
                        id: forgotPasswordMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            forgotPasswordDialog.openDialog()
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }            }
        }
    }

    // Forgot Password Dialog
    ForgotPasswordDialog {
        id: forgotPasswordDialog
        onPasswordResetSuccess: {
            errorMessage = ""
            // Optionally show a success message on login page
        }
    }
}
