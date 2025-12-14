import QtQuick 2.15
import CircularImage 1.0

// High-performance circular profile photo component using QImage
Item {
    id: root
    
    // Public properties
    property alias source: circularImage.source
    property alias borderWidth: circularImage.borderWidth
    property alias borderColor: circularImage.borderColor
    property alias smooth: circularImage.smooth
    property alias antialiasing: circularImage.antialiasing
    property alias status: circularImage.status
    
    // Avatar fallback properties
    property string fallbackText: ""
    property color fallbackBackgroundColor: "#E0E0E0"
    property color fallbackTextColor: "#1A1A1A"
    property int fallbackFontSize: Math.max(12, Math.min(width, height) * 0.4)
    
    // Status properties
    property bool showLoadingIndicator: true
    property color loadingColor: "#6B7280"
    
    implicitWidth: 40
    implicitHeight: 40
    
    // Main circular image using C++ QImage implementation
    CircularImage {
        id: circularImage
        anchors.fill: parent
        smooth: true
        antialiasing: true
        borderWidth: 0
        borderColor: Qt.rgba(0, 0, 0, 0)
        
        // High-performance rendering with QImage and QPainter
        // This provides much better performance than QML clipping
        // and ensures perfect circular clipping regardless of image size
    }
    
    // Fallback avatar when no image is loaded or image failed to load
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: fallbackBackgroundColor
        visible: circularImage.status !== CircularImage.Ready && fallbackText !== ""
        
        Text {
            anchors.centerIn: parent
            text: fallbackText
            font.pixelSize: fallbackFontSize
            font.bold: true
            color: fallbackTextColor
        }
    }
    
    // Loading indicator
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: loadingColor
        opacity: 0.3
        visible: showLoadingIndicator && circularImage.status === CircularImage.Loading
        
        // Simple loading animation
        RotationAnimation on rotation {
            running: parent.visible
            loops: Animation.Infinite
            duration: 1000
            from: 0
            to: 360
        }
        
        Rectangle {
            width: parent.width * 0.1
            height: parent.height * 0.3
            color: loadingColor
            radius: width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.1
        }
    }
    
    // Error indicator (subtle red border when image fails to load)
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: "#EF4444"
        visible: circularImage.status === CircularImage.Error && fallbackText === ""
        
        Text {
            anchors.centerIn: parent
            text: "?"
            font.pixelSize: fallbackFontSize
            font.bold: true
            color: "#EF4444"
        }
    }
}
