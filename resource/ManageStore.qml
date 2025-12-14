import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

Rectangle {
    id: root
    color: "#F8FAFC"
    
    // Properties
    property string errorMessage: ""
    property string successMessage: ""
    property string imagePath: ""
    property bool isSubmitting: false
    
    // Theme Colors
    property color primaryColor: "#1565C0"
    property color primaryDark: "#0D47A1"
    property color primaryLight: "#E3F2FD"
    property color textPrimary: "#212121"
    property color textSecondary: "#757575"
    property color errorColor: "#D32F2F"
    property color successColor: "#2E7D32"
    
    // Data
    readonly property var genres: [
        "Fiksi", "Non-Fiksi", "Sains", "Teknologi", "Sejarah", 
        "Biografi", "Seni", "Agama", "Filosofi", "Pendidikan",
        "Bisnis", "Kesehatan", "Sastra", "Remaja", "Anak-anak", "Lainnya"
    ]
    
    // Functions
    function resetForm() {
        titleField.text = ""
        genreCombo.currentIndex = 0
        authorField.text = ""
        publisherField.text = ""
        yearField.text = new Date().getFullYear().toString()
        copiesField.text = "1"
        imagePath = ""
        errorMessage = ""
        successMessage = ""
        isSubmitting = false
    }
    
    function validateInputs() {
        var yearValue = parseInt(yearField.text)
        var copiesValue = parseInt(copiesField.text)
        var currentYear = new Date().getFullYear()
        
        if (!titleField.text.trim()) {
            return { valid: false, message: "Judul buku tidak boleh kosong" }
        }
        if (titleField.text.trim().length < 2) {
            return { valid: false, message: "Judul buku terlalu pendek" }
        }
        if (!authorField.text.trim()) {
            return { valid: false, message: "Nama penulis tidak boleh kosong" }
        }
        if (isNaN(yearValue)) {
            return { valid: false, message: "Tahun terbit harus berupa angka" }
        }
        if (yearValue < 1000 || yearValue > currentYear + 5) {
            return { valid: false, message: "Tahun terbit tidak valid (1000-" + (currentYear + 5) + ")" }
        }
        if (isNaN(copiesValue)) {
            return { valid: false, message: "Jumlah salinan harus berupa angka" }
        }
        if (copiesValue < 1) {
            return { valid: false, message: "Jumlah salinan minimal 1" }
        }
        if (copiesValue > 1000) {
            return { valid: false, message: "Jumlah salinan maksimal 1000" }
        }
        
        return {
            valid: true,
            year: yearValue,
            copies: copiesValue
        }
    }
    
    // Initialize form
    Component.onCompleted: resetForm()
    
    // Main Layout
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        
        ColumnLayout {
            width: Math.min(800, root.width - 40)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24
            
            // ========== HEADER ==========
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Tambah Buku Baru"
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: textPrimary
                }
                
                Text {
                    text: "Lengkapi form di bawah untuk menambahkan buku ke koleksi perpustakaan digital. " +
                          "Field yang ditandai dengan * wajib diisi."
                    font.pixelSize: 14
                    color: textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            
            // ========== STATUS MESSAGES ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: errorMessage || successMessage ? 56 : 0
                radius: 8
                visible: errorMessage !== "" || successMessage !== ""
                color: errorMessage ? "#FFEBEE" : "#E8F5E9"
                border.width: 1
                border.color: errorMessage ? "#FFCDD2" : "#C8E6C9"
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300 }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        radius: 12
                        color: errorMessage ? errorColor : successColor
                        
                        Text {
                            anchors.centerIn: parent
                            text: errorMessage ? "✕" : "✓"
                            font.pixelSize: 12
                            font.bold: true
                            color: "white"
                        }
                    }
                    
                    Text {
                        text: errorMessage || successMessage
                        font.pixelSize: 14
                        color: errorMessage ? errorColor : successColor
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    
                    ToolButton {
                        text: "✕"
                        font.pixelSize: 14
                        onClicked: {
                            errorMessage = ""
                            successMessage = ""
                        }
                    }
                }
            }
            
            // ========== FORM CARD ==========
            Rectangle {
                Layout.fillWidth: true
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
                    anchors.margins: 32
                    spacing: 24
                    
                    // Title Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            spacing: 4
                            
                            Text {
                                text: "Judul Buku"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Text {
                                text: "*"
                                font.pixelSize: 14
                                color: errorColor
                            }
                        }
                        
                        TextField {
                            id: titleField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Masukkan judul buku lengkap"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                radius: 8
                                color: "#F8FAFC"
                                border.color: parent.activeFocus ? primaryColor : (parent.text ? "#C8E6C9" : "#E0E0E0")
                                border.width: parent.activeFocus ? 2 : 1
                            }
                            
                            onTextChanged: {
                                if (text.length > 0) {
                                    errorMessage = ""
                                }
                            }
                        }
                    }
                    
                    // Author Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            spacing: 4
                            
                            Text {
                                text: "Penulis"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Text {
                                text: "*"
                                font.pixelSize: 14
                                color: errorColor
                            }
                        }
                        
                        TextField {
                            id: authorField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Nama penulis atau pengarang"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                radius: 8
                                color: "#F8FAFC"
                                border.color: parent.activeFocus ? primaryColor : (parent.text ? "#C8E6C9" : "#E0E0E0")
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Genre Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            spacing: 4
                            
                            Text {
                                text: "Genre/Kategori"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: textPrimary
                            }
                            
                            Text {
                                text: "*"
                                font.pixelSize: 14
                                color: errorColor
                            }
                        }
                        
                        ComboBox {
                            id: genreCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            model: genres
                            font.pixelSize: 14
                            currentIndex: 0
                            
                            background: Rectangle {
                                radius: 8
                                color: "#F8FAFC"
                                border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                font: parent.font
                                color: textPrimary
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                            
                            popup: Popup {
                                y: parent.height
                                width: parent.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1
                                
                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: parent.parent.model
                                    currentIndex: parent.parent.currentIndex
                                    
                                    delegate: ItemDelegate {
                                        width: parent.width
                                        height: 40
                                        
                                        contentItem: Text {
                                            text: modelData
                                            color: textPrimary
                                            font.pixelSize: 14
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 12
                                        }
                                        
                                        background: Rectangle {
                                            color: parent.highlighted ? primaryLight : "transparent"
                                        }
                                    }
                                    
                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }
                                
                                background: Rectangle {
                                    radius: 8
                                    border.color: "#E0E0E0"
                                    color: "white"
                                    
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        radius: 8
                                        samples: 17
                                        color: "#20000000"
                                    }
                                }
                            }
                        }
                    }
                    
                    // Publisher Field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Penerbit"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: textPrimary
                        }
                        
                        TextField {
                            id: publisherField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Nama penerbit (opsional)"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                radius: 8
                                color: "#F8FAFC"
                                border.color: parent.activeFocus ? primaryColor : "#E0E0E0"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }
                    }
                    
                    // Year and Copies Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        // Year Field
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            RowLayout {
                                spacing: 4
                                
                                Text {
                                    text: "Tahun Terbit"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: textPrimary
                                }
                                
                                Text {
                                    text: "*"
                                    font.pixelSize: 14
                                    color: errorColor
                                }
                            }
                            
                            TextField {
                                id: yearField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: new Date().getFullYear().toString()
                                inputMethodHints: Qt.ImhDigitsOnly
                                font.pixelSize: 14
                                maximumLength: 4
                                
                                background: Rectangle {
                                    radius: 8
                                    color: "#F8FAFC"
                                    border.color: parent.activeFocus ? primaryColor : (parent.text ? "#C8E6C9" : "#E0E0E0")
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                
                                validator: IntValidator {
                                    bottom: 1000
                                    top: new Date().getFullYear() + 5
                                }
                            }
                        }
                        
                        // Copies Field
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            RowLayout {
                                spacing: 4
                                
                                Text {
                                    text: "Jumlah Salinan"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: textPrimary
                                }
                                
                                Text {
                                    text: "*"
                                    font.pixelSize: 14
                                    color: errorColor
                                }
                            }
                            
                            TextField {
                                id: copiesField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                placeholderText: "1"
                                inputMethodHints: Qt.ImhDigitsOnly
                                font.pixelSize: 14
                                
                                background: Rectangle {
                                    radius: 8
                                    color: "#F8FAFC"
                                    border.color: parent.activeFocus ? primaryColor : (parent.text ? "#C8E6C9" : "#E0E0E0")
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                
                                validator: IntValidator {
                                    bottom: 1
                                    top: 1000
                                }
                            }
                        }
                    }
                    
                    // Image Upload
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Gambar Sampul"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: textPrimary
                        }
                        
                        Text {
                            text: "Unggah gambar sampul buku (opsional, maks. 5MB)"
                            font.pixelSize: 12
                            color: textSecondary
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 8
                            color: imagePath ? "transparent" : "#F8FAFC"
                            border.width: 2
                            border.color: imagePath ? primaryColor : "#E0E0E0"
                            border.style: imagePath ? Border.SolidLine : Border.DashLine
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 12
                                
                                Text {
                                    text: imagePath ? "📷" : "📁"
                                    font.pixelSize: 32
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                Text {
                                    text: imagePath ? 
                                          imagePath.substring(imagePath.lastIndexOf("/") + 1) :
                                          "Klik untuk memilih gambar"
                                    font.pixelSize: 12
                                    color: imagePath ? textPrimary : textSecondary
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                Text {
                                    text: imagePath ? 
                                          "Gambar terpilih" : 
                                          "Format: JPG, PNG, GIF"
                                    font.pixelSize: 10
                                    color: textSecondary
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: coverDialog.open()
                            }
                        }
                    }
                }
            }
            
            // ========== ACTION BUTTONS ==========
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "🗑️ Hapus Form"
                    Layout.preferredHeight: 48
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#F5F5F5" : (parent.hovered ? "#FAFAFA" : "#FFFFFF")
                        border.width: 1
                        border.color: "#E0E0E0"
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        
                        Text {
                            text: "🗑️"
                            font.pixelSize: 14
                            color: textSecondary
                        }
                        
                        Text {
                            text: parent.parent.text
                            color: textSecondary
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }
                    }
                    
                    onClicked: {
                        resetForm()
                        toast.show("Form telah direset")
                    }
                }
                
                Button {
                    text: isSubmitting ? "⏳ Menyimpan..." : "💾 Simpan Buku"
                    Layout.preferredHeight: 48
                    Layout.fillWidth: true
                    enabled: !isSubmitting
                    
                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#0D47A1" : 
                               parent.enabled ? (parent.hovered ? "#1565C0" : primaryColor) : "#B0BEC5"
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        
                        Text {
                            text: isSubmitting ? "⏳" : "💾"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        Text {
                            text: parent.parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }
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
                            imagePath
                        )
                        
                        if (saved) {
                            successMessage = "✓ Buku berhasil ditambahkan ke koleksi!"
                            toast.show("Buku berhasil ditambahkan ke perpustakaan")
                            resetForm()
                        } else {
                            errorMessage = "✗ Gagal menyimpan data buku. Silakan coba lagi."
                        }
                        
                        isSubmitting = false
                    }
                }
            }
            
            Item { height: 40 } // Bottom spacer
        }
    }
    
    // ========== FILE DIALOG ==========
    FileDialog {
        id: coverDialog
        title: "Pilih Gambar Sampul Buku"
        nameFilters: ["Gambar (*.png *.jpg *.jpeg *.bmp *.gif)"]
        fileMode: FileDialog.OpenFile
        
        onAccepted: {
            var file = file.toString()
            imagePath = file.replace("file:///", "")
            toast.show("Gambar sampul berhasil dipilih")
        }
    }
    
    // ========== TOAST NOTIFICATION ==========
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