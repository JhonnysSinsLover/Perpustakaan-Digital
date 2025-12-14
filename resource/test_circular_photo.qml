import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: "CircularProfilePhoto Test - QImage Implementation"

    Column {
        anchors.centerIn: parent
        spacing: 30

        Text {
            text: "High-Performance Circular Profile Photos"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1A1A1A"
        }

        Text {
            text: "Using QImage + QPainter for perfect circular clipping"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#666666"
        }

        // Test row with different sizes
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Column {
                spacing: 10
                
                Text {
                    text: "Small (32px)"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 32
                    height: 32
                    borderWidth: 1
                    borderColor: "#E5E7EB"
                    fallbackText: "A"
                    fallbackBackgroundColor: "#3B82F6"
                    fallbackTextColor: "#FFFFFF"
                }
            }

            Column {
                spacing: 10
                
                Text {
                    text: "Medium (64px)"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 64
                    height: 64
                    borderWidth: 2
                    borderColor: "#10B981"
                    fallbackText: "B"
                    fallbackBackgroundColor: "#10B981"
                    fallbackTextColor: "#FFFFFF"
                }
            }

            Column {
                spacing: 10
                
                Text {
                    text: "Large (96px)"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 96
                    height: 96
                    borderWidth: 3
                    borderColor: "#F59E0B"
                    fallbackText: "C"
                    fallbackBackgroundColor: "#F59E0B"
                    fallbackTextColor: "#FFFFFF"
                }
            }

            Column {
                spacing: 10
                
                Text {
                    text: "XL (128px)"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 128
                    height: 128
                    borderWidth: 4
                    borderColor: "#EF4444"
                    fallbackText: "D"
                    fallbackBackgroundColor: "#EF4444"
                    fallbackTextColor: "#FFFFFF"
                }
            }
        }

        // Test with actual image path (Windows file path)
        Column {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            
            Text {
                text: "With Image Source (120px)"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#666666"
            }
            
            CircularProfilePhoto {
                width: 120
                height: 120
                borderWidth: 3
                borderColor: "#8B5CF6"
                
                // Test with a sample image path
                source: "../assets/logoSigmaterial.png"
                
                fallbackText: "IMG"
                fallbackBackgroundColor: "#8B5CF6"
                fallbackTextColor: "#FFFFFF"
            }
        }

        // Performance comparison text
        Text {
            text: "✓ Hardware-accelerated QImage rendering\n✓ Perfect circular clipping\n✓ Smooth antialiasing\n✓ High-quality scaling\n✓ Memory efficient"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#059669"
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.5
        }

        // Status indicators
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Column {
                spacing: 5
                
                Text {
                    text: "Loading State"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 48
                    height: 48
                    borderWidth: 2
                    borderColor: "#6B7280"
                    source: "invalid://path/to/test/loading"
                    fallbackText: "L"
                    showLoadingIndicator: true
                }
            }

            Column {
                spacing: 5
                
                Text {
                    text: "Error State"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"
                }
                
                CircularProfilePhoto {
                    width: 48
                    height: 48
                    borderWidth: 2
                    borderColor: "#EF4444"
                    source: "file:///nonexistent/path/image.jpg"
                    fallbackText: "" // No fallback to show error state
                }
            }
        }
    }
}
