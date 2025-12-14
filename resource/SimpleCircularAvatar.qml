import QtQuick 2.15
import Qt5Compat.GraphicalEffects

// Komponen circular avatar sederhana menggunakan OpacityMask
// Alternatif langsung untuk CircularProfilePhoto tanpa QImage
Item {
    id: root
    
    // Properties yang bisa dikustomisasi
    property string source: ""
    property color borderColor: "#4ECDC4"
    property int borderWidth: 2
    property alias fillMode: image.fillMode
    property alias status: image.status
    property bool enableHover: true
    
    // Internal properties
    property real hoverScale: enableHover ? 1.05 : 1.0
    
    width: 100
    height: 100
    
    // Main image
    Image {
        id: image
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        visible: false // Hidden karena akan di-mask
        
        // Fallback untuk gambar yang gagal load
        Rectangle {
            anchors.fill: parent
            color: "#e0e0e0"
            visible: parent.status === Image.Error
            
            Text {
                anchors.centerIn: parent
                text: "?"
                color: "#999"
                font.pixelSize: parent.width * 0.3
            }
        }
    }
    
    // Circular mask
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: width / 2
        visible: false
    }
    
    // Apply mask to image
    OpacityMask {
        id: maskedImage
        anchors.fill: image
        source: image
        maskSource: mask
        
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }
    
    // Border
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: borderColor
        border.width: borderWidth
        radius: width / 2
        
        Behavior on border.width {
            NumberAnimation { duration: 150 }
        }
    }
    
    // Hover effect
    MouseArea {
        anchors.fill: parent
        hoverEnabled: enableHover
        
        onEntered: {
            if (enableHover) {
                maskedImage.scale = hoverScale
                parent.children[2].border.width = borderWidth + 1
            }
        }
        
        onExited: {
            if (enableHover) {
                maskedImage.scale = 1.0
                parent.children[2].border.width = borderWidth
            }
        }
        
        onClicked: {
            // Emit click signal atau trigger action
            root.clicked()
        }
    }
    
    // Signals
    signal clicked()
    
    // Functions
    function refresh() {
        // Force reload image jika dibutuhkan
        var temp = image.source
        image.source = ""
        image.source = temp
    }
}