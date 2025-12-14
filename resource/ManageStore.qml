import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

Rectangle {
    id: root
    color: "#F5F7FA"
    
    property string errorMessage: ""
    property string successMessage: ""
    property string imagePath: ""
    property bool isSubmitting: false
    
    readonly property var genres: ["Fiksi", "Non-Fiksi", "Sains", "Sejarah", "Biografi", "Teknologi", "Seni", "Agama", "Filosofi", "Lainnya"]
    
    function resetForm() {
        titleField.text = ""
        genreCombo.currentIndex = 0
        authorField.text = ""
        publisherField.text = ""
        yearField.text = ""
        copiesField.text = ""
        imagePath = ""
        errorMessage = ""
        successMessage = ""
    }
    
    function validateInputs() {
        var yearValue = parseInt(yearField.text)
        var copiesValue = parseInt(copiesField.text)
        
        if (!titleField.text.trim()) {
            return { valid: false, message: "Judul tidak boleh kosong" }
        }
        if (!authorField.text.trim()) {
            return { valid: false, message: "Penulis tidak boleh kosong" }
        }
        if (isNaN(yearValue) || yearValue < 1000 || yearValue > 2100) {
            return { valid: false, message: "Tahun terbit harus antara 1000-2100" }
        }
        if (isNaN(copiesValue) || copiesValue < 1) {
            return { valid: false, message: "Jumlah salinan minimal 1" }
        }
        
        return {
            valid: true,
            year: yearValue,
            copies: copiesValue
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.topMargin: 75
        clip: true
        
        ColumnLayout {
            width: Math.min(900, root.width - 80)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 28
            
            Item { height: 40 }
            
            // Header Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "Tambah Buku Baru"
                    font.pixelSize: 32
                    font.family: "Segoe UI"
                    font.weight: Font.Bold
                    color: "#1F2937"
                }
                
                Text {
                    text: "Lengkapi form di bawah untuk menambahkan buku ke koleksi perpustakaan digital"
                    font.pixelSize: 16
                    font.family: "Segoe UI"
                    color: "#6B7280"
                }
            }
            
            // Success/Error Message
            Rectangle {
                Layout.fillWidth: true
                height: 64
                radius: 10
                visible: errorMessage !== "" || successMessage !== ""
                color: errorMessage ? "#FEE2E2" : "#D1FAE5"
                border.color: errorMessage ? "#F87171" : "#34D399"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14
                    
                    Text {
                        text: errorMessage ? "❌" : "✅"
                        font.pixelSize: 24
                    }
                    
                    Text {
                        text: errorMessage !== "" ? errorMessage : successMessage
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                        font.weight: Font.Medium
                        color: errorMessage ? "#991B1B" : "#065F46"
                        Layout.fillWidth: true
                    }
                }
            }
            
            // Form Card
            Rectangle {
                Layout.fillWidth: true
                radius: 14
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 36
                    spacing: 28
                    
                    // Title Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Judul Buku *"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#374151"
                        }
                        
                        TextField {
                            id: titleField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Masukkan judul buku"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            
                            background: Rectangle {
                                radius: 8
                                color: "#FFFFFF"
                                border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Genre ComboBox
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Genre *"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#374151"
                        }
                        
                        ComboBox {
                            id: genreCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            model: genres
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            
                            background: Rectangle {
                                radius: 8
                                color: "#FFFFFF"
                                border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Author Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Penulis *"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#374151"
                        }
                        
                        TextField {
                            id: authorField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Nama penulis"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            
                            background: Rectangle {
                                radius: 8
                                color: "#FFFFFF"
                                border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Publisher Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Penerbit"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#374151"
                        }
                        
                        TextField {
                            id: publisherField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Nama penerbit (opsional)"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            
                            background: Rectangle {
                                radius: 8
                                color: "#FFFFFF"
                                border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Year and Copies Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "Tahun Terbit *"
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                font.weight: Font.Bold
                                color: "#374151"
                            }
                            
                            TextField {
                                id: yearField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: "2024"
                                inputMethodHints: Qt.ImhDigitsOnly
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                
                                background: Rectangle {
                                    radius: 8
                                    color: "#FFFFFF"
                                    border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "Jumlah Salinan *"
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                font.weight: Font.Bold
                                color: "#374151"
                            }
                            
                            TextField {
                                id: copiesField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: "1"
                                inputMethodHints: Qt.ImhDigitsOnly
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                
                                background: Rectangle {
                                    radius: 8
                                    color: "#FFFFFF"
                                    border.color: parent.activeFocus ? "#1565C0" : "#D1D5DB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                            }
                        }
                    }
                    
                    // Image Path
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Gambar Sampul (Opsional)"
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                            font.weight: Font.Bold
                            color: "#374151"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 14
                            
                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                readOnly: true
                                text: imagePath
                                placeholderText: "Belum ada file dipilih"
                                font.pixelSize: 15
                                font.family: "Segoe UI"
                                
                                background: Rectangle {
                                    radius: 8
                                    color: "#F9FAFB"
                                    border.color: "#D1D5DB"
                                    border.width: 1
                                }
                            }
                            
                            Button {
                                Layout.preferredHeight: 48
                                text: "Pilih File"
                                
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
                                    color: "#374151"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: coverDialog.open()
                            }
                        }
                    }
                }
            }
            
            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Reset Form"
                    enabled: !isSubmitting
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 52
                    
                    background: Rectangle {
                        radius: 10
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
                    
                    onClicked: resetForm()
                }
                
                Button {
                    text: isSubmitting ? "Menyimpan..." : "Simpan Buku"
                    enabled: !isSubmitting
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 52
                    
                    background: Rectangle {
                        radius: 10
                        color: parent.down ? "#0D47A1" : (parent.hovered ? "#1565C0" : "#1976D2")
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        font.family: "Segoe UI"
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        errorMessage = ""
                        successMessage = ""
                        
                        var validation = validateInputs()
                        if (!validation.valid) {
                            errorMessage = validation.message
                            return
                        }
                        
                        isSubmitting = true
                        var saved = database.addBook(
                                    titleField.text.trim(),
                                    authorField.text.trim(),
                                    genres[genreCombo.currentIndex],
                                    publisherField.text.trim(),
                                    validation.year,
                                    validation.copies,
                                    imagePath)
                        
                        if (saved) {
                            successMessage = "Buku berhasil ditambahkan ke koleksi!"
                            resetForm()
                        } else {
                            errorMessage = "Gagal menyimpan data buku"
                        }
                        isSubmitting = false
                    }
                }
            }
            
            Item { height: 40 }
        }
    }
    
    FileDialog {
        id: coverDialog
        title: "Pilih gambar sampul"
        nameFilters: ["Gambar (*.png *.jpg *.jpeg *.bmp)"]
        onAccepted: {
            imagePath = coverDialog.file.toString().replace("file:///", "")
        }
    }
}
