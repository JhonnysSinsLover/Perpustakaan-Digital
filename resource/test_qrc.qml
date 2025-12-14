import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    width: 500
    height: 400
    visible: true
    title: "QRC Test - Unified res.qrc"

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Testing Unified res.qrc"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1A1A1A"
        }

        Text {
            text: "Assets should load from unified res.qrc file"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#666666"
        }

        // Test logo image
        Rectangle {
            width: 120
            height: 120
            color: "#F0F0F0"
            border.color: "#CCCCCC"
            border.width: 1
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.centerIn: parent
                width: 100
                height: 100
                source: "qrc:/assets/logoSigmaterial.png"
                fillMode: Image.PreserveAspectFit
                
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: parent.status === Image.Ready ? "green" : "red"
                    border.width: 2
                    radius: 4
                }
            }
        }

        Text {
            text: "Logo: " + (logoImage.status === Image.Ready ? "✓ Loaded" : "✗ Failed")
            anchors.horizontalCenter: parent.horizontalCenter
            color: logoImage.status === Image.Ready ? "green" : "red"
            font.bold: true
        }

        // Test home icon
        Rectangle {
            width: 60
            height: 60
            color: "#F0F0F0"
            border.color: "#CCCCCC"
            border.width: 1
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: homeImage
                anchors.centerIn: parent
                width: 40
                height: 40
                source: "qrc:/assets/Home.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Text {
            text: "Home Icon: " + (homeImage.status === Image.Ready ? "✓ Loaded" : "✗ Failed")
            anchors.horizontalCenter: parent.horizontalCenter
            color: homeImage.status === Image.Ready ? "green" : "red"
            font.bold: true
        }

        Text {
            text: "Status: " + (allImagesLoaded ? "All resources loaded successfully!" : "Some resources failed to load")
            anchors.horizontalCenter: parent.horizontalCenter
            color: allImagesLoaded ? "green" : "red"
            font.bold: true
            font.pixelSize: 16
        }
    }

    property bool allImagesLoaded: logoImage.status === Image.Ready && homeImage.status === Image.Ready

    Image {
        id: logoImage
        visible: false
        source: "qrc:/assets/logoSigmaterial.png"
    }
}