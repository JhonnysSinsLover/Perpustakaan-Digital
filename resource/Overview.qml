import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialogs

Rectangle {
    id: root
    width: parent ? parent.width : 1280
    height: parent ? parent.height : 720
    color: "#f0f1f3"
    readonly property real spacing: 24
    readonly property real sidebarWidth: 280
    
    // Search functionality
    property string searchText: ""
    property bool isSearching: false
    property int searchResultCount: 0
    property var searchTimer: Timer {
        id: searchTimer
        interval: 300  // 300ms debounce
        repeat: false
        onTriggered: {
            performSearchWithTimer(searchText)
        }
    }
    
    // Purchase list model
    property var purchaseList: []    // Edit mode properties
    property bool isEditing: false
    property var editingPurchase: null

    // Message system properties
    property string messageText: ""
    property bool showMessage: false
    property bool isSuccessMessage: true
    property string editImagePath: ""

    // Function to format numbers for Indonesian currency display
    function formatRupiah(value) {
        // Convert to number and ensure it's an integer
        var number = Math.round(Number(value));

        // Convert to string and add thousand separators
        var numberStr = number.toString();
        var formattedStr = "";
        var counter = 0;

        // Add separators from right to left
        for (var i = numberStr.length - 1; i >= 0; i--) {
            if (counter > 0 && counter % 3 === 0) {
                formattedStr = "." + formattedStr;
            }
            formattedStr = numberStr[i] + formattedStr;
            counter++;
        }

        return formattedStr;
    }

    // Function to show message to user
    function showMessageToUser(message, isSuccess) {
        messageText = message;
        isSuccessMessage = isSuccess;
        showMessage = true;
        messageTimer.start();
    }    // Timer for hiding messages
    Timer {
        id: messageTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            showMessage = false;
        }
    }

    // Timer to load purchases after component is ready
    Timer {
        id: loadTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            if (mainWindow.selectedProduct) {
                console.log("Timer triggered - loading purchases for product:", mainWindow.selectedProduct.id);
                loadPurchases();
            }
        }
    }    // Load purchases when component is completed
    Component.onCompleted: {
        console.log("Overview component completed, selectedProduct:", mainWindow.selectedProduct);
        // Use a timer to ensure everything is initialized
        loadTimer.start();
    }    // Load purchases when selectedProduct changes
    onVisibleChanged: {
        console.log("Overview visibility changed to:", visible);
        if (visible && mainWindow.selectedProduct) {
            console.log("Page became visible - loading purchases");
            loadPurchases();
        }
    }    // Watch for selectedProduct changes
    Connections {
        target: mainWindow
        function onSelectedProductChanged() {
            console.log("Selected product changed to:", mainWindow.selectedProduct);
            if (root.visible) {
                loadPurchases();
            }
        }
    }// Function to load purchases from database
    function loadPurchases() {
        console.log("loadPurchases called, selectedProduct:", mainWindow.selectedProduct);

        if (!mainWindow.selectedProduct) {
            console.log("No selected product, clearing purchase list");
            purchaseList = [];
            updateSummary();
            return;
        }

        console.log("Loading purchases for product ID:", mainWindow.selectedProduct.id);
        var purchases = database.getPurchasesByProduct(parseInt(mainWindow.selectedProduct.id));
        console.log("Retrieved purchases:", purchases.length, "items");

        purchaseList = purchases;
        updateSummary();
    }
      // Function to add purchase
    function addPurchase(name, quantity, notes) {
        // Validate stock before adding purchase
        if (!mainWindow.selectedProduct) {
            showMessageToUser("Tidak ada produk yang dipilih", false);
            return false;
        }
          var currentStock = mainWindow.selectedProduct.stock;
        if (quantity > currentStock) {
            showMessageToUser("Stok tidak mencukupi! Stok tersedia: " + currentStock + " unit", false);
            return false;
        }

        var unitPrice = mainWindow.selectedProduct ? parseInt(mainWindow.selectedProduct.price) : 0;
        var totalPrice = quantity * unitPrice;
        var productId = parseInt(mainWindow.selectedProduct.id);        // Add purchase to database and get the purchase ID
        var purchaseId = database.addPurchaseWithReturn(productId, name, quantity, totalPrice, notes || "");

        if (purchaseId > 0) {
            // Reduce stock in database
            var newStock = currentStock - quantity;
            var stockUpdateSuccess = database.updateProductStock(productId, newStock);            if (stockUpdateSuccess) {
                // Update local selectedProduct object by reassigning the entire object
                var updatedProduct = {
                    id: mainWindow.selectedProduct.id,
                    name: mainWindow.selectedProduct.name,
                    category: mainWindow.selectedProduct.category,
                    price: mainWindow.selectedProduct.price,
                    stock: newStock,
                    image_path: mainWindow.selectedProduct.image_path || ""
                };
                mainWindow.selectedProduct = updatedProduct;                // Auto-record purchase in Income Records (Catatan Pemasukan) with link
                var currentDate = new Date();
                var timeString = currentDate.getHours().toString().padStart(2, '0') + ":" + currentDate.getMinutes().toString().padStart(2, '0');
                var dateString = currentDate.getDate().toString().padStart(2, '0') + " " +
                    ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"][currentDate.getMonth()] +
                    " " + currentDate.getFullYear();
                var incomeDescription = mainWindow.selectedProduct.name + "-" + name + "-" + quantity;
                var incomeNominal = "Rp " + formatRupiah(totalPrice);
                
                var incomeId = database.insertPemasukanWithReturn(incomeNominal, incomeDescription, dateString, timeString, purchaseId);
                if (incomeId > 0) {
                    // Link the purchase to the income record
                    database.linkPurchaseToIncome(purchaseId, incomeId);
                } else {
                    console.log("Warning: Failed to record income transaction");
                }

                // Reload purchases from database
                loadPurchases();
                refreshStockPageStats(); // Refresh stock statistics
                showMessageToUser("Pembelian berhasil ditambahkan", true);
                return true;
            } else {
                // If stock update fails, we should remove the purchase we just added
                console.log("Failed to update stock, purchase may be inconsistent");
                showMessageToUser("Gagal mengupdate stok", false);
                return false;
            }
        } else {
            console.log("Failed to add purchase to database");
            showMessageToUser("Gagal menambahkan pembelian", false);
            return false;
        }
    }      // Function to edit purchase
    function editPurchase(purchaseId, newName, newQuantity, newNotes) {
        if (!mainWindow.selectedProduct) {
            showMessageToUser("Tidak ada produk yang dipilih", false);
            return false;
        }

        var unitPrice = mainWindow.selectedProduct ? parseInt(mainWindow.selectedProduct.price) : 0;
        var newTotalPrice = newQuantity * unitPrice;

        // Find the existing purchase
        var oldPurchase = null;
        for (var i = 0; i < purchaseList.length; i++) {
            if (purchaseList[i].id === purchaseId) {
                oldPurchase = purchaseList[i];
                break;
            }
        }

        if (!oldPurchase) {
            showMessageToUser("Pembelian tidak ditemukan", false);
            return false;
        }

        var oldQuantity = oldPurchase.quantity;
        var quantityDifference = newQuantity - oldQuantity;
        var currentStock = mainWindow.selectedProduct.stock;

        // Check if we have enough stock for the increased quantity
        if (quantityDifference > 0 && quantityDifference > currentStock) {
            showMessageToUser("Stok tidak mencukupi! Stok tersedia: " + currentStock + " unit", false);
            return false;
        }

        // Update purchase in database
        var success = database.updatePurchase(purchaseId, newName, newQuantity, newTotalPrice, newNotes || "");

        if (success) {
            // Update stock in database
            var newStock = currentStock - quantityDifference;
            var stockUpdateSuccess = database.updateProductStock(parseInt(mainWindow.selectedProduct.id), newStock);            if (stockUpdateSuccess) {
                // Update local selectedProduct object by reassigning the entire object
                var updatedProduct = {
                    id: mainWindow.selectedProduct.id,
                    name: mainWindow.selectedProduct.name,
                    category: mainWindow.selectedProduct.category,
                    price: mainWindow.selectedProduct.price,
                    stock: newStock,
                    image_path: mainWindow.selectedProduct.image_path || ""
                };
                mainWindow.selectedProduct = updatedProduct;                // Reload purchases from database
                loadPurchases();
                refreshStockPageStats(); // Refresh stock statistics
                showMessageToUser("Pembelian berhasil diupdate", true);
                return true;
            } else {
                showMessageToUser("Gagal mengupdate stok", false);
                return false;
            }
        } else {
            showMessageToUser("Gagal mengupdate pembelian", false);
            return false;
        }
    }
      // Function to remove purchase
    function removePurchase(purchaseId) {
        if (!mainWindow.selectedProduct) {
            showMessageToUser("Tidak ada produk yang dipilih", false);
            return false;
        }

        // Find the purchase to remove
        var purchaseToRemove = null;
        for (var i = 0; i < purchaseList.length; i++) {
            if (purchaseList[i].id === purchaseId) {
                purchaseToRemove = purchaseList[i];
                break;
            }
        }

        if (!purchaseToRemove) {
            showMessageToUser("Pembelian tidak ditemukan", false);
            return false;
        }

        // Delete purchase from database
        var success = database.deletePurchase(purchaseId);

        if (success) {
            // Restore stock in database
            var currentStock = mainWindow.selectedProduct.stock;
            var newStock = currentStock + purchaseToRemove.quantity;
            var stockUpdateSuccess = database.updateProductStock(parseInt(mainWindow.selectedProduct.id), newStock);            if (stockUpdateSuccess) {
                // Update local selectedProduct object by reassigning the entire object
                var updatedProduct = {
                    id: mainWindow.selectedProduct.id,
                    name: mainWindow.selectedProduct.name,
                    category: mainWindow.selectedProduct.category,
                    price: mainWindow.selectedProduct.price,
                    stock: newStock,
                    image_path: mainWindow.selectedProduct.image_path || ""
                };
                mainWindow.selectedProduct = updatedProduct;                // Reload purchases from database
                loadPurchases();
                refreshStockPageStats(); // Refresh stock statistics
                showMessageToUser("Pembelian berhasil dihapus", true);
                return true;
            } else {
                showMessageToUser("Gagal mengupdate stok", false);
                return false;
            }
        } else {
            showMessageToUser("Gagal menghapus pembelian", false);
            return false;
        }
    }    // Function to update summary
    function updateSummary() {
        var totalOrders = purchaseList.length;
        var totalRevenue = purchaseList.reduce(function(sum, item) {
            return sum + item.total_price; // Note: database returns total_price, not totalPrice
        }, 0);        totalOrdersText.text = totalOrders + " pesanan";
        totalRevenueText.text = "Rp " + formatRupiah(totalRevenue);
    }

    // Function to add stock
    function addStock(additionalStock) {
        if (!mainWindow.selectedProduct) {
            showMessageToUser("Tidak ada produk yang dipilih", false);
            return false;
        }

        var productId = parseInt(mainWindow.selectedProduct.id);
        var currentStock = mainWindow.selectedProduct.stock;
        var newStock = currentStock + additionalStock;

        // Update stock in database
        var success = database.updateProductStock(productId, newStock);        if (success) {
            // Update local selectedProduct object by reassigning the entire object
            // This forces QML bindings to update
            var updatedProduct = {
                id: mainWindow.selectedProduct.id,
                name: mainWindow.selectedProduct.name,
                category: mainWindow.selectedProduct.category,
                price: mainWindow.selectedProduct.price,
                stock: newStock,
                image_path: mainWindow.selectedProduct.image_path || ""
            };            mainWindow.selectedProduct = updatedProduct;
            refreshStockPageStats(); // Refresh stock statistics
            showMessageToUser("Stok berhasil ditambahkan! Stok sekarang: " + newStock + " unit", true);
            return true;
        } else {
            showMessageToUser("Gagal menambahkan stok", false);
            return false;
        }
    }

    // Function to refresh Stock page statistics
    function refreshStockPageStats() {
        // Check if Stock page exists and has the refresh function
        if (mainWindow && mainWindow.stackView) {
            var stockPage = mainWindow.stackView.find(function(item) {
                return item.toString().indexOf("Stock") !== -1;
            });

            if (stockPage && stockPage.refreshSummaryStats) {
                stockPage.refreshSummaryStats();
            }
        }
    }

    // Function to convert Windows path to QML compatible URL
    function pathToUrl(path) {
        if (!path || path === "") return "";
        
        // If it's already a file URL, return as is
        if (path.startsWith("file:///")) return path;
        
        // Convert Windows path to file URL
        // Replace backslashes with forward slashes and add file:/// prefix
        var normalizedPath = path.replace(/\\/g, "/");
        if (normalizedPath.match(/^[A-Za-z]:/)) {
            return "file:///" + normalizedPath;
        }
        
        return normalizedPath;
    }

    // Sidebar
    Rectangle {
        id: sidebar
        width: sidebarWidth
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        color: "#FFC800"        // Logo container
        Rectangle {
            id: logoContainer
            width: parent.width
            height: 120
            color: "transparent"

            Image {
                x: 36
                y: 28
                width: 48
                height: 48
                source: "../assets/Rectangle2807.png"
                cache: true
                fillMode: Image.PreserveAspectFit
            }

            Image {
                x: 96
                y: 37
                width: 161
                height: 30
                source: "../assets/SIGMATERIAL.png"
                cache: true
                fillMode: Image.PreserveAspectFit
            }
        }

        // Menu items
        Column {
            anchors.top: logoContainer.bottom
            anchors.topMargin: 40
            width: parent.width
            spacing: 10

            // Dashboard
            Rectangle {
                width: parent.width
                height: 50
                color: mouseAreaDashboard.containsMouse ? "#FFE17F" : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    spacing: 12

                    Image {
                        width: 24
                        height: 24
                        source: "../assets/Home.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Dashboard"
                        font.pixelSize: 16
                        color: "#1A1A1A"
                    }
                }

                MouseArea {
                    id: mouseAreaDashboard
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: mainWindow.navigateToPage("dashboard")
                }
            }

            // Stok (highlighted karena ini halaman overview produk)
            Rectangle {
                width: parent.width
                height: 50
                color: "#FFD84D"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    spacing: 12

                    Image {
                        width: 24
                        height: 24
                        source: "../assets/stockIcon.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Stok"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1A1A1A"
                    }
                }
            }

            // Kelola Toko
            Rectangle {
                width: parent.width
                height: 50
                color: mouseAreaKelola.containsMouse ? "#FFE17F" : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    spacing: 12

                    Image {
                        width: 24
                        height: 24
                        source: "../assets/ManageStore.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Kelola Toko"
                        font.pixelSize: 16
                        color: "#1A1A1A"
                    }
                }

                MouseArea {
                    id: mouseAreaKelola
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: mainWindow.navigateToPage("managestore")
                }
            }
        }        // Bottom menu items
        Column {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20            // Settings Row with left margin
            Rectangle {
                width: parent.width
                height: 50
                color: settingsMouseArea.containsMouse ? "#FFE17F" : "transparent"
                
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Image {
                        width: 24
                        height: 24
                        source: "../assets/Settings.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Pengaturan"
                        font.pixelSize: 16
                        color: "#1A1A1A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: settingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        settingsPopup.openSettings();
                    }
                }
            }

            // Logout Rectangle spans full width
            Rectangle {
                width: parent.width
                height: 50
                color: logoutMouseArea.containsMouse ? "#FFE17F" : "transparent"
                
                Row {
                    spacing: 12
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    
                    Image {
                        width: 24
                        height: 24
                        source: "../assets/LogOut.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Logout"
                        font.pixelSize: 16
                        color: "#1A1A1A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainWindow.logout()
                    }
                }
            }
        }
    }    // Top Header
    Rectangle {
        id: header
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
        }
        height: 100
        color: "#FFFFFF"// Search Bar
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 32
            width: 480
            height: 40
            color: "#F3F4F6"
            radius: 5
            border.width: searchField.activeFocus ? 2 : 0
            border.color: "#0F50AA"
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: 8
                clip: true

                Text {
                    text: "🔍"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: searchField.activeFocus ? "#0F50AA" : "#6B7280"
                }

                TextInput {
                    id: searchField
                    anchors.verticalCenter: parent.verticalCenter
                    width: {
                        // Calculate available width dynamically
                        var baseWidth = parent.width - 32; // Account for search icon and spacing
                        var indicatorWidth = 0;
                        
                        if (isSearching) {
                            indicatorWidth += Math.min(80, searchResultText.width + 18); // Search indicator + spacing
                        }
                        if (text !== "") {
                            indicatorWidth += 26; // Clear button + spacing
                        }
                        
                        return Math.max(100, baseWidth - indicatorWidth); // Minimum 100px for input
                    }
                    font.pixelSize: 14
                    color: "#1A1A1A"
                    clip: true
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Cari pembelian, supplier..."
                        color: "#6B7280"
                        font.pixelSize: 14
                        visible: !parent.activeFocus && parent.text === ""
                    }
                    
                    onTextChanged: {
                        performSearch(text)
                    }
                }
                
                // Search indicator and clear button
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    
                    // Search result indicator
                    Rectangle {
                        visible: isSearching
                        width: Math.min(80, searchResultText.width + 12) // Limit max width
                        height: 20
                        radius: 10
                        color: searchResultCount > 0 ? "#DCFCE7" : "#FEE2E2"
                        clip: true
                        
                        Text {
                            id: searchResultText
                            anchors.centerIn: parent
                            text: searchResultCount + " hasil"
                            font.pixelSize: 10
                            font.bold: true
                            color: searchResultCount > 0 ? "#16A34A" : "#DC2626"
                            elide: Text.ElideRight
                        }
                    }
                    
                    // Clear button
                    Rectangle {
                        visible: searchField.text !== ""
                        width: 20
                        height: 20
                        radius: 10
                        color: clearMouseArea.containsMouse ? "#FEE2E2" : "#F3F4F6"
                        border.width: 1
                        border.color: "#E5E7EB"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 10
                            color: "#6B7280"
                        }
                        
                        MouseArea {
                            id: clearMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                searchField.text = ""
                                clearSearch()
                            }
                        }
                    }
                }
            }
        }        // User Profile
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 32
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: database && database.isUserLoggedIn() ? 
                      (database.getCurrentUser().full_name || database.getCurrentUsername() || "User") : 
                      "Guest"
                font.pixelSize: 16
                color: "#1A1A1A"
            }            // User Profile with high-performance circular image
            CircularProfilePhoto {
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                borderWidth: 2
                borderColor: "#E5E7EB"
                
                source: {
                    if (database && database.isUserLoggedIn()) {
                        var user = database.getCurrentUser()
                        var photoPath = user.profile_photo || ""
                        if (photoPath !== "") {
                            // Convert Windows path to file URL for CircularImage
                            var normalizedPath = photoPath.replace(/\\/g, '/');
                            if (!normalizedPath.startsWith('/') && !normalizedPath.startsWith("file://")) {
                                normalizedPath = '/' + normalizedPath;
                            }
                            return "file://" + normalizedPath;
                        }
                    }
                    return ""
                }
                
                fallbackText: {
                    if (database && database.isUserLoggedIn()) {
                        var user = database.getCurrentUser()
                        var name = user.full_name || database.getCurrentUsername() || "U"
                        return name.charAt(0).toUpperCase()
                    }
                    return "G"
                }
                
                fallbackBackgroundColor: "#E0E0E0"
                fallbackTextColor: "#1A1A1A"
            }
        }
    }    // Content area
    Rectangle {
        id: contentArea
        anchors {
            left: sidebar.right
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
            margins: spacing
        }
        color: "transparent"
        clip: true

        // ScrollView to handle content overflow
        ScrollView {
            anchors.fill: parent
            contentWidth: contentRow.width
            contentHeight: contentRow.height
            clip: true
            
            // Row untuk membagi area menjadi 2 kolom
            Row {
                id: contentRow
                width: Math.max(contentArea.width, 800) // Minimum width to prevent cramping
                height: Math.max(contentArea.height, 500) // Minimum height reduced
                spacing: root.spacing
                
                // Rectangle kiri (30% dari total lebar)
                Rectangle {
                id: leftSection
                width: Math.max((contentRow.width - root.spacing) * 0.3, 250) // 30% with minimum width
                height: contentRow.height
                color: "#FFFFFF"
                radius: 20
                clip: true

                // Content container with margins
                Item {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    // Title with Edit Button - anchored to top
                    Item {
                        id: leftTitleArea
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        height: 32
                        Text {
                            text: "Rincian Barang"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#1A1A1A"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Edit Button positioned at the right
                        Rectangle {
                            width: 50
                            height: 27
                            color: editButtonMouseArea.containsMouse ? Qt.darker("#1366D9", 1.2) : "#1366D9"
                            radius: 6
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "Edit"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: editButtonMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {                                    if (mainWindow.selectedProduct) {
                                        // Populate edit form with current product data
                                        editProductNameField.text = mainWindow.selectedProduct.name || "";
                                        editProductCategoryCombo.currentIndex = editProductCategoryCombo.find(mainWindow.selectedProduct.category || "Material");
                                        editProductPriceField.text = mainWindow.selectedProduct.price ? mainWindow.selectedProduct.price.toString() : "";
                                        editImagePath = ""; // Reset edit image path
                                        editProductPopup.open();
                                    }
                                }
                            }
                        }
                    }
                    
                    // Image upload area - anchored below title
                    Rectangle {
                        id: leftImageArea
                        anchors {
                            top: leftTitleArea.bottom
                            topMargin: 16
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        height: 200
                        color: "#F9FAFB"
                        border.width: 2
                        border.color: "#D1D5DB"
                        radius: 8// Show product photo if available, otherwise show placeholder
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 4
                            color: "transparent"
                            clip: true
                            visible: mainWindow.selectedProduct && mainWindow.selectedProduct.image_path && mainWindow.selectedProduct.image_path !== ""
                              Image {
                                id: productImage
                                anchors.fill: parent
                                source: pathToUrl(mainWindow.selectedProduct && mainWindow.selectedProduct.image_path ? mainWindow.selectedProduct.image_path : "")
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                        
                        // Canvas untuk garis putus-putus (only when no image)
                        Canvas {
                            anchors.fill: parent
                            anchors.margins: 4
                            visible: !(mainWindow.selectedProduct && mainWindow.selectedProduct.image_path && mainWindow.selectedProduct.image_path !== "")
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.save();
                                ctx.setLineDash([5, 4]);
                                ctx.strokeStyle = "#6B7280";
                                ctx.lineWidth = 2;
                                // Rounded rect path
                                var r = 4;
                                ctx.beginPath();
                                ctx.moveTo(r, 0);
                                ctx.lineTo(width - r, 0);
                                ctx.quadraticCurveTo(width, 0, width, r);
                                ctx.lineTo(width, height - r);
                                ctx.quadraticCurveTo(width, height, width - r, height);
                                ctx.lineTo(r, height);
                                ctx.quadraticCurveTo(0, height, 0, height - r);
                                ctx.lineTo(0, r);
                                ctx.quadraticCurveTo(0, 0, r, 0);
                                ctx.closePath();
                                ctx.stroke();
                                ctx.restore();
                            }
                        }
                        
                        // Placeholder content (only when no image)
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            visible: !(mainWindow.selectedProduct && mainWindow.selectedProduct.image_path && mainWindow.selectedProduct.image_path !== "")

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 48
                                height: 48
                                source: "../assets/Inventory.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                text: "Tidak Ada Foto Produk"
                                font.pixelSize: 14
                                color: "#6B7280"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    // Product details - anchored to bottom
                    Column {
                        id: leftDetailsArea
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        spacing: 12// Product Name
                        Column {
                            width: parent.width
                            spacing: 6
                            Text {
                                text: "Nama Barang"
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            Text {
                                text: mainWindow.selectedProduct ? mainWindow.selectedProduct.name : "-"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1A1A1A"
                            }
                        }
                        
                        // Product ID
                        Column {
                            width: parent.width
                            spacing: 6
                            Text {
                                text: "ID Produk"
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            Text {
                                text: mainWindow.selectedProduct ? mainWindow.selectedProduct.id : "-"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1A1A1A"
                            }
                        }
                        
                        // Product Category
                        Column {
                            width: parent.width
                            spacing: 6
                            Text {
                                text: "Kategori"
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            Text {
                                text: mainWindow.selectedProduct ? mainWindow.selectedProduct.category : "-"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#1A1A1A"
                            }
                        }
                        
                        // Product Stock
                        Column {
                            width: parent.width
                            spacing: 6
                            Text {
                                text: "Stok Barang"
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            // Row untuk stock text dan tombol +
                            Row {
                                width: parent.width
                                spacing: 12
                                anchors.left: parent.left
                                Text {
                                    text: mainWindow.selectedProduct ? mainWindow.selectedProduct.stock + " unit" : "0 unit"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#1A1A1A"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Tombol + untuk menambah stock
                                Rectangle {
                                    width: 32
                                    height: 32
                                    color: "#059669"
                                    radius: 16
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = "#047857"
                                        onExited: parent.color = "#059669"
                                        onClicked: {
                                            if (mainWindow.selectedProduct) {
                                                addStockPopup.open();
                                                stockInput.focus = true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }                }
            }
            
            // Rectangle kanan (70% dari total lebar)
            Rectangle {
                id: rightSection
                width: Math.max((contentRow.width - root.spacing) * 0.7, 550) // 70% with minimum width
                height: contentRow.height
                color: "#FFFFFF"
                radius: 20
                clip: true

                // Content container with margins
                Item {
                    anchors.fill: parent
                    anchors.margins: 16
                    
                    // Title and Back Button Header - anchored to top
                    Item {
                        id: rightTitleArea
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        height: 32

                        Text {
                            text: "Riwayat Pembelian"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#1A1A1A"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Back button positioned at the right
                        Rectangle {
                            width: 100
                            height: 36
                            color: "#6B7280"
                            radius: 8
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "← Kembali"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#4B5563"
                                onExited: parent.color = "#6B7280"
                                onClicked: {
                                    mainWindow.navigateToPage("stock");
                                }
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    
                    // List riwayat pemesanan - anchored below title
                    Rectangle {
                        id: rightListArea
                        anchors {
                            top: rightTitleArea.bottom
                            topMargin: 16
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        height: 350
                        color: "#F9FAFB"
                        border.width: 1
                        border.color: "#E5E7EB"
                        radius: 8
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 12

                            Column {
                                width: parent.width
                                spacing: 8                                // Header list
                                Rectangle {
                                    width: parent.width
                                    height: 32
                                    color: "#FFFFFF"
                                    radius: 6
                                    border.width: 1
                                    border.color: "#E5E7EB"
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.right: parent.right
                                        anchors.rightMargin: 12
                                        spacing: 12

                                        Text {
                                            width: parent.width * 0.34
                                            text: "Nama Pembeli"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#374151"
                                        }
                                        Text {
                                            width: parent.width * 0.09
                                            text: "Kuantitas"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#374151"
                                        }
                                        Text {
                                            width: parent.width * 0.39
                                            text: "Total Harga"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#374151"
                                            horizontalAlignment: Text.AlignHCenter
                                            leftPadding: 6
                                        }
                                        Text {
                                            width: parent.width * 0.2
                                            text: "Aksi"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "#374151"
                                            leftPadding: 6
                                        }                                    }
                                }
                                
                                // Purchase list or empty state
                                Item {
                                    width: parent.width
                                    height: purchaseList.length > 0 ? listColumn.height : 150

                                    // Dynamic purchase list
                                    Column {
                                        id: listColumn
                                        width: parent.width
                                        visible: purchaseList.length > 0

                                        Repeater {
                                            model: purchaseList
                                            delegate: Rectangle {
                                                width: parent.width
                                                height: 48
                                                color: index % 2 === 0 ? "#FFFFFF" : "#F9FAFB"
                                                border.width: index === purchaseList.length - 1 ? 0 : 1
                                                border.color: "#F3F4F6"

                                                Row {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 12
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: 12
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 12
                                                    Row {
                                                        width: parent.width * 0.35
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 6
                                                        
                                                        Text {
                                                            text: modelData.customer_name
                                                            font.pixelSize: 14
                                                            color: "#374151"
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            elide: Text.ElideRight
                                                            width: parent.width - (syncBadge.visible ? syncBadge.width + 6 : 0)
                                                        }
                                                          // Sync indicator badge
                                                        Rectangle {
                                                            id: syncBadge
                                                            visible: false  // Badge disembunyikan
                                                            width: 35
                                                            height: 16
                                                            color: "#3B82F6"
                                                            radius: 8
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            
                                                            Text {
                                                                text: "Auto"
                                                                anchors.centerIn: parent
                                                                font.pixelSize: 8
                                                                font.weight: Font.DemiBold
                                                                color: "#FFFFFF"
                                                            }
                                                        }
                                                    }

                                                    Text {
                                                        width: parent.width * 0.1
                                                        text: modelData.quantity + " unit"
                                                        font.pixelSize: 14
                                                        color: "#374151"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }                                                    Text {
                                                        width: parent.width * 0.35
                                                        text: "Rp " + formatRupiah(modelData.total_price)
                                                        font.pixelSize: 14
                                                        color: "#374151"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        horizontalAlignment: Text.AlignHCenter
                                                        leftPadding: 6
                                                    }

                                                    Row {
                                                        width: parent.width * 0.2
                                                        spacing: 8
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        leftPadding: 6                                                        // Edit button
                                                        Rectangle {
                                                            width: 24
                                                            height: 24
                                                            color: "#3B82F6"
                                                            radius: 4

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: "✎"
                                                                font.pixelSize: 10
                                                                color: "#FFFFFF"
                                                            }                                                            MouseArea {
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                onEntered: parent.color = "#2563EB"
                                                                onExited: parent.color = "#3B82F6"
                                                                onClicked: {
                                                                    // Check if this purchase is linked to an income record
                                                                    if (modelData.income_id && modelData.income_id !== "") {
                                                                        purchaseSyncWarningDialog.warningType = "edit";
                                                                        purchaseSyncWarningDialog.targetPurchase = modelData;
                                                                        purchaseSyncWarningDialog.open();
                                                                    } else {
                                                                        isEditing = true
                                                                        editingPurchase = modelData
                                                                        nameInput.text = modelData.customer_name
                                                                        quantityInput.text = modelData.quantity.toString()
                                                                        addPurchasePopup.open()
                                                                        nameInput.focus = true
                                                                    }
                                                                }
                                                            }
                                                        }                                                        // Delete button
                                                        Rectangle {
                                                            width: 24
                                                            height: 24
                                                            color: "#EF4444"
                                                            radius: 4

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: "✕"
                                                                font.pixelSize: 10
                                                                color: "#FFFFFF"
                                                            }                                                            MouseArea {
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                onEntered: parent.color = "#DC2626"
                                                                onExited: parent.color = "#EF4444"
                                                                onClicked: {
                                                                    // Check if this purchase is linked to an income record
                                                                    if (modelData.income_id && modelData.income_id !== "") {
                                                                        purchaseSyncWarningDialog.warningType = "delete";
                                                                        purchaseSyncWarningDialog.targetPurchase = modelData;
                                                                        purchaseSyncWarningDialog.open();
                                                                    } else {
                                                                        removePurchase(modelData.id);
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Empty state message
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 12
                                        visible: purchaseList.length === 0

                                        Image {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 48
                                            height: 48
                                            source: "../assets/Inventory.png"
                                            fillMode: Image.PreserveAspectFit
                                            opacity: 0.5
                                        }

                                        Text {
                                            text: "Belum ada riwayat pembelian"
                                            font.pixelSize: 14
                                            color: "#9CA3AF"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "Data akan muncul setelah ada pembelian masuk"
                                            font.pixelSize: 12
                                            color: "#D1D5DB"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Summary information - anchored to bottom
                    Column {
                        id: rightSummaryArea
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                        width: parent.width
                        spacing: 12
                        
                        // Total orders
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Total Pesanan"
                                font.pixelSize: 14
                                color: "#6B7280"
                            }
                            Text {
                                id: totalOrdersText
                                text: "0 pesanan"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#1A1A1A"
                            }
                        }
                        
                        // Total revenue, unit price, and add purchase button in one row
                        Row {
                            width: parent.width
                            spacing: 12
                            
                            // Total revenue (left side)
                            Column {
                                width: (parent.width - 2 * parent.spacing - 140) / 2 // Adjust for button width
                                spacing: 6

                                Text {
                                    text: "Total Pendapatan"
                                    font.pixelSize: 14
                                    color: "#6B7280"
                                }
                                
                                Text {
                                    id: totalRevenueText
                                    text: "Rp 0"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#059669"
                                }
                            }
                            
                            // Product Price (middle)
                            Column {
                                width: (parent.width - 2 * parent.spacing - 140) / 2 // Adjust for button width
                                spacing: 6

                                Text {
                                    text: "Harga Satuan"
                                    font.pixelSize: 14
                                    color: "#6B7280"
                                }
                                
                                Text {
                                    text: mainWindow.selectedProduct ? "Rp " + formatRupiah(mainWindow.selectedProduct.price) : "Rp 0"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#059669"
                                }
                            }
                            
                            // Add Purchase Button (right side)
                            Rectangle {
                                width: 140
                                height: 36
                                color: "#059669"
                                radius: 8
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "Tambahkan Pembelian"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#FFFFFF"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.color = "#047857"
                                    onExited: parent.color = "#059669"
                                    onClicked: {
                                        isEditing = false;
                                        editingPurchase = null;
                                        addPurchasePopup.open();
                                        nameInput.focus = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }    // Add Purchase Popup
    Popup {
        id: addPurchasePopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: 400
        height: 340
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.width: 1
            border.color: "#E5E7EB"
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Title
            Text {
                text: isEditing ? "Edit Pembelian" : "Tambahkan Pembelian"
                font.pixelSize: 20
                font.bold: true
                color: "#1A1A1A"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Nama Pembeli input
            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: "Nama Pembeli"
                    font.pixelSize: 14
                    color: "#374151"
                    font.bold: true
                }
                TextField {
                    id: nameInput
                    width: parent.width
                    height: 40
                    font.pixelSize: 14
                    placeholderText: "Masukkan nama pembeli"
                    selectByMouse: true
                    color: "#1A1A1A"
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8

                    background: Rectangle {
                        anchors.fill: parent
                        border.width: 1
                        border.color: nameInput.activeFocus ? "#3B82F6" : "#D1D5DB"
                        radius: 6
                        color: "#FFFFFF"
                    }
                }
            }            // Kuantitas input
            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: "Kuantitas"
                    font.pixelSize: 14
                    color: "#374151"
                    font.bold: true
                }                TextField {
                    id: quantityInput
                    width: parent.width
                    height: 40
                    font.pixelSize: 14
                    placeholderText: "Masukkan jumlah (max: " + (mainWindow.selectedProduct ? mainWindow.selectedProduct.stock : 0) + ")"
                    selectByMouse: true
                    validator: IntValidator {
                        bottom: 1;
                        top: mainWindow.selectedProduct ? mainWindow.selectedProduct.stock : 9999
                    }
                    color: "#1A1A1A"
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8

                    background: Rectangle {
                        anchors.fill: parent
                        border.width: 1
                        border.color: quantityInput.activeFocus ? "#3B82F6" : "#D1D5DB"
                        radius: 6
                        color: "#FFFFFF"
                    }                }            }

            // Buttons
            Row {
                width: parent.width
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                // Cancel button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 40
                    color: "#F3F4F6"
                    radius: 6
                    border.width: 1
                    border.color: "#D1D5DB"

                    Text {
                        anchors.centerIn: parent
                        text: "Batal"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#374151"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#E5E7EB"
                        onExited: parent.color = "#F3F4F6"
                        onClicked: {
                            addPurchasePopup.close();
                        }
                    }
                }

                // Submit button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 40
                    color: "#059669"
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: isEditing ? "Simpan" : "Tambahkan"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#047857"
                        onExited: parent.color = "#059669"
                        onClicked: {
                            if (nameInput.text.trim() !== "" && quantityInput.text.trim() !== "") {
                                var quantity = parseInt(quantityInput.text);
                                var success = false;

                                if (isEditing && editingPurchase) {
                                    success = editPurchase(editingPurchase.id, nameInput.text.trim(), quantity, "");
                                    if (success) {
                                        isEditing = false;
                                        editingPurchase = null;
                                    }
                                } else {
                                    success = addPurchase(nameInput.text.trim(), quantity, "");
                                }

                                if (success) {
                                    addPurchasePopup.close();
                                } else {
                                    // Show error message - for now just log
                                    console.log("Operation failed - check stock availability");
                                }
                            } else {
                                console.log("Please fill all fields");
                            }
                        }
                    }
                }
            }
        }        // Handle popup close events
        onAboutToHide: {
            nameInput.text = "";
            quantityInput.text = "";
            isEditing = false;
            editingPurchase = null;
        }
    }    // Add Stock Popup
    Popup {
        id: addStockPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: 350
        height: 280
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.width: 1
            border.color: "#E5E7EB"
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Title
            Text {
                text: "Tambah Stok Barang"
                font.pixelSize: 20
                font.bold: true
                color: "#1A1A1A"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Product info
            Column {
                width: parent.width
                spacing: 4

                Text {
                    text: "Produk: " + (mainWindow.selectedProduct ? mainWindow.selectedProduct.name : "-")
                    font.pixelSize: 14
                    color: "#6B7280"
                }

                Text {
                    text: "Stok saat ini: " + (mainWindow.selectedProduct ? mainWindow.selectedProduct.stock + " unit" : "0 unit")
                    font.pixelSize: 14
                    color: "#374151"
                    font.bold: true
                }
            }

            // Stock input
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Jumlah Stok yang Ditambahkan"
                    font.pixelSize: 14
                    color: "#374151"
                    font.bold: true
                }

                TextField {
                    id: stockInput
                    width: parent.width
                    height: 40
                    font.pixelSize: 14
                    placeholderText: "Masukkan jumlah stok..."
                    selectByMouse: true
                    validator: IntValidator {
                        bottom: 1;
                        top: 999999
                    }
                    color: "#1A1A1A"
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8

                    background: Rectangle {
                        anchors.fill: parent
                        border.width: 1
                        border.color: stockInput.activeFocus ? "#3B82F6" : "#D1D5DB"
                        radius: 6
                        color: "#FFFFFF"
                    }
                }
            }

            // Buttons
            Row {
                width: parent.width
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                // Cancel button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 40
                    color: "#F3F4F6"
                    radius: 6
                    border.width: 1
                    border.color: "#D1D5DB"

                    Text {
                        anchors.centerIn: parent
                        text: "Batal"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#374151"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#E5E7EB"
                        onExited: parent.color = "#F3F4F6"
                        onClicked: {
                            addStockPopup.close();
                        }
                    }
                }

                // Submit button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 40
                    color: "#059669"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "Tambah Stok"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = "#047857"
                        onExited: parent.color = "#059669"
                        onClicked: {
                            var stock = parseInt(stockInput.text);
                            if (stockInput.text === "" || isNaN(stock) || stock <= 0) {
                                showMessageToUser("Masukkan jumlah stok yang valid", false);
                                return;
                            }

                            var success = addStock(stock);
                            if (success) {
                                addStockPopup.close();
                            }
                        }
                    }
                }
            }
        }

        // Handle popup close events
        onAboutToHide: {
            stockInput.text = "";
        }
    }

    // Message box for user feedback
    Rectangle {
        id: messageBox
        visible: showMessage
        width: 300
        height: 100
        color: isSuccessMessage ? "#D1E7DD" : "#F8D7DA"
        radius: 8
        border.width: 1
        border.color: isSuccessMessage ? "#B6E0CE" : "#F5C6CB"
        anchors {
            top: parent.top
            topMargin: 32
            right: parent.right
            rightMargin: 32
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Message text
            Text {
                text: messageText
                font.pixelSize: 14
                color: isSuccessMessage ? "#0F5132" : "#842029"
                wrapMode: Text.WordWrap
            }

            // Close button
            Rectangle {
                width: 80
                height: 30
                color: isSuccessMessage ? "#198754" : "#DC3545"
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "Tutup"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#FFFFFF"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = isSuccessMessage ? "#157347" : "#C82333"
                    onExited: parent.color = isSuccessMessage ? "#198754" : "#DC3545"
                    onClicked: {
                        showMessage = false;
                    }
                }            }
        }
    }    // Edit Product Popup
    Popup {
        id: editProductPopup
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: 420
        height: 480
        anchors.centerIn: Overlay.overlay

        background: Rectangle {
            color: "white"
            radius: 15
            border.width: 0
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // Header with rounded top corners
            Rectangle {
                width: parent.width
                height: 120
                color: "white"
                antialiasing: true
                radius: Qt.vector4d(24, 24, 0, 0)

                Column {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 24
                    spacing: 12
                    Item { height: 24 }

                    // Icon and text row
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12                        // Icon
                        Rectangle {
                            id: editIconRect
                            width: 64
                            height: 64
                            radius: 20
                            color: "#FFFFFF"
                            border.width: 0

                            // Dashed border
                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.save();
                                    ctx.setLineDash([5, 4]);
                                    ctx.strokeStyle = "#E5E7EB";
                                    ctx.lineWidth = 1.5;
                                    var r = 20;
                                    ctx.beginPath();
                                    ctx.moveTo(r, 0);
                                    ctx.lineTo(width - r, 0);
                                    ctx.quadraticCurveTo(width, 0, width, r);
                                    ctx.lineTo(width, height - r);
                                    ctx.quadraticCurveTo(width, height, width - r, height);
                                    ctx.lineTo(r, height);
                                    ctx.quadraticCurveTo(0, height, 0, height - r);
                                    ctx.lineTo(0, r);
                                    ctx.quadraticCurveTo(0, 0, r, 0);
                                    ctx.closePath();
                                    ctx.stroke();
                                    ctx.restore();
                                }
                            }
                            
                            // Plus icon (always visible in edit popup)
                            Canvas {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                visible: true
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.strokeStyle = "#1366D9";
                                    ctx.lineWidth = 3;
                                    ctx.lineCap = "round";
                                    ctx.beginPath();
                                    // Horizontal line
                                    ctx.moveTo(8, 16);
                                    ctx.lineTo(24, 16);
                                    // Vertical line
                                    ctx.moveTo(16, 8);
                                    ctx.lineTo(16, 24);
                                    ctx.stroke();
                                }
                            }

                            // Mouse area for clicking to select image
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    editPhotoDialog.open();
                                }
                            }
                        }

                        // Upload text
                        Text {
                            text: "Edit Foto Disini"
                            font.pixelSize: 14
                            color: "#1366D9"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: "Edit Produk"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#1A1A1A"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Form
            Column {
                spacing: 12
                width: parent.width - 64
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 10

                Item { height: 20 }

                // Product Name
                Text {
                    text: "Nama Produk"
                    font.pixelSize: 14
                    color: "#374151"
                }
                TextField {
                    id: editProductNameField
                    width: parent.width
                    height: 36
                    placeholderText: "Masukkan nama produk"
                    font.pixelSize: 14
                    leftPadding: 8
                    background: Rectangle {
                        color: "#F3F4F6"
                        radius: 6
                    }
                    color: "#374151"
                    placeholderTextColor: "#9CA3AF"
                }

                // Category
                Text {
                    text: "Kategori"
                    font.pixelSize: 14
                    color: "#374151"
                }
                ComboBox {
                    id: editProductCategoryCombo
                    width: parent.width
                    height: 36
                    model: ["Material", "Perkakas", "Lainnya"]
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#F3F4F6"
                        radius: 6
                    }
                    contentItem: Text {
                        text: editProductCategoryCombo.displayText
                        color: "#374151"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                }

                // Price
                Text {
                    text: "Harga"
                    font.pixelSize: 14
                    color: "#374151"
                }
                TextField {
                    id: editProductPriceField
                    width: parent.width
                    height: 36
                    placeholderText: "Masukkan harga (cth: 1000000)"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0 }
                    font.pixelSize: 14
                    leftPadding: 8
                    background: Rectangle {
                        color: "#F3F4F6"
                        radius: 6
                    }
                    color: "#374151"
                    placeholderTextColor: "#9CA3AF"
                    onTextChanged: {
                        text = text.replace(/[^\d]/g, "");
                    }
                }

                // Buttons
                Item { height: 24 }
                Row {
                    spacing: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    topPadding: 10

                    Rectangle {
                        width: 100
                        height: 36
                        radius: 8
                        color: editCancelMouseArea.containsMouse ? Qt.darker("#F3F4F6", 1.15) : "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "Batal"
                            font.pixelSize: 14
                            color: "#1F2937"
                        }

                        MouseArea {
                            id: editCancelMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: editProductPopup.close()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 36
                        radius: 8
                        color: editSaveMouseArea.containsMouse ? Qt.darker("#1366D9", 1.2) : "#1366D9"

                        Text {
                            anchors.centerIn: parent
                            text: "Simpan"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: editSaveMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                // Validate inputs
                                if (editProductNameField.text.trim() === "") {
                                    showMessageToUser("Nama produk tidak boleh kosong", false);
                                    return;
                                }                                if (!mainWindow.selectedProduct) {
                                    showMessageToUser("Tidak ada produk yang dipilih", false);
                                    return;
                                }
                                
                                // Update product in database
                                var success;
                                var finalImagePath = editImagePath || (mainWindow.selectedProduct ? mainWindow.selectedProduct.image_path : "");
                                
                                // Convert file URL back to Windows path for database storage
                                var pathForDatabase = finalImagePath;
                                if (editImagePath !== "") {
                                    pathForDatabase = editImagePath.toString().replace("file:///", "").replace(/\//g, "\\");
                                }
                                
                                if (editImagePath !== "") {
                                    // Update with new image
                                    success = database.updateProductWithImage(
                                        parseInt(mainWindow.selectedProduct.id),
                                        editProductNameField.text.trim(),
                                        editProductCategoryCombo.currentText,
                                        parseFloat(editProductPriceField.text) || 0,
                                        pathForDatabase
                                    );
                                } else {
                                    // Update without changing image
                                    success = database.updateProduct(
                                        parseInt(mainWindow.selectedProduct.id),
                                        editProductNameField.text.trim(),
                                        editProductCategoryCombo.currentText,
                                        parseFloat(editProductPriceField.text) || 0
                                    );
                                }                                if (success) {
                                    // Update local selectedProduct object
                                    var updatedImagePath = pathForDatabase || (mainWindow.selectedProduct ? mainWindow.selectedProduct.image_path : "");
                                    var updatedProduct = {
                                        id: mainWindow.selectedProduct.id,
                                        name: editProductNameField.text.trim(),
                                        category: editProductCategoryCombo.currentText,
                                        price: parseFloat(editProductPriceField.text) || 0,
                                        stock: mainWindow.selectedProduct.stock,
                                        image_path: updatedImagePath
                                    };
                                    mainWindow.selectedProduct = updatedProduct;

                                    // Refresh stock page if it exists
                                    refreshStockPageStats();

                                    showMessageToUser("Produk berhasil diperbarui", true);
                                    editProductPopup.close();
                                } else {
                                    showMessageToUser("Gagal memperbarui produk", false);
                                }
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }        // Handle popup close events
        onAboutToHide: {
            editProductNameField.text = "";
            editProductCategoryCombo.currentIndex = 0;
            editProductPriceField.text = "";
            editImagePath = "";
        }        // File dialog for selecting product image
        FileDialog {
            id: editPhotoDialog
            title: "Pilih Foto Produk"
            fileMode: FileDialog.OpenFile
            nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif)"]
            onAccepted: {
                // Keep the full URL format for QML Image component
                editImagePath = selectedFile.toString();
                console.log("Selected image path:", editImagePath);
            }        }
    }
    
    // Purchase Sync Warning Dialog
    Popup {
        id: purchaseSyncWarningDialog
        width: 400
        height: 200
        anchors.centerIn: Overlay.overlay
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property string warningType: ""  // "edit" or "delete"
        property var targetPurchase: null
        
        background: Rectangle {
            color: "#ffffff"
            radius: 8
            border.color: "#e0e0e0"
            border.width: 1
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

                Row {
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: "#fff3cd"
                        border.color: "#ffc107"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "⚠"
                            font.pixelSize: 18
                            color: "#856404"
                        }
                    }

                    Column {
                        spacing: 8

                        Text {
                            text: purchaseSyncWarningDialog.warningType === "edit" ? 
                                  "Edit Pembelian Tersinkronisasi" : 
                                  "Hapus Pembelian Tersinkronisasi"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: "#333333"
                        }

                        Text {
                            text: purchaseSyncWarningDialog.warningType === "edit" ? 
                                  "Pembelian ini terhubung dengan catatan pemasukan. Perubahan akan mempengaruhi kedua data secara otomatis." :
                                  "Pembelian ini terhubung dengan catatan pemasukan. Menghapus pembelian akan menghapus catatan pemasukan terkait."
                            font.pixelSize: 11
                            color: "#666666"
                            wrapMode: Text.WordWrap
                            width: 280
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    spacing: 8

                    Rectangle {
                        width: 80
                        height: 32
                        color: "#F3F4F6"
                        radius: 4
                        border.width: 1
                        border.color: "#dee2e6"

                        Text {
                            anchors.centerIn: parent
                            text: "Batal"
                            font.pixelSize: 11
                            color: "#495057"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#e9ecef"
                            onExited: parent.color = "#F3F4F6"
                            onClicked: {
                                purchaseSyncWarningDialog.close();
                            }
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 32
                        color: "#007bff"
                        radius: 4
                        border.width: 1
                        border.color: "#007bff"

                        Text {
                            anchors.centerIn: parent
                            text: purchaseSyncWarningDialog.warningType === "edit" ? "Lanjut Edit" : "Lanjut Hapus"
                            font.pixelSize: 11
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = "#0056b3"
                            onExited: parent.color = "#007bff"
                            onClicked: {
                                if (purchaseSyncWarningDialog.warningType === "edit") {
                                    // Proceed with edit
                                    isEditing = true;
                                    editingPurchase = purchaseSyncWarningDialog.targetPurchase;
                                    addPurchasePopup.open();
                                } else if (purchaseSyncWarningDialog.warningType === "delete") {
                                    // Proceed with delete - restore stock to previous state
                                    var targetPurchase = purchaseSyncWarningDialog.targetPurchase;
                                    var success = database.deletePurchase(targetPurchase.id);
                                    if (success) {
                                        // Restore stock in database - add back the quantity that was purchased
                                        var currentStock = mainWindow.selectedProduct.stock;
                                        var newStock = currentStock + targetPurchase.quantity;
                                        var stockUpdateSuccess = database.updateProductStock(parseInt(mainWindow.selectedProduct.id), newStock);
                                        
                                        if (stockUpdateSuccess) {
                                            // Update local selectedProduct object by reassigning the entire object
                                            var updatedProduct = {
                                                id: mainWindow.selectedProduct.id,
                                                name: mainWindow.selectedProduct.name,
                                                category: mainWindow.selectedProduct.category,
                                                price: mainWindow.selectedProduct.price,
                                                stock: newStock,
                                                image_path: mainWindow.selectedProduct.image_path || ""
                                            };
                                            mainWindow.selectedProduct = updatedProduct;
                                            
                                            loadPurchases();
                                            refreshStockPageStats();
                                            showMessageToUser("Pembelian berhasil dihapus dan stok dipulihkan", true);
                                        } else {
                                            showMessageToUser("Pembelian dihapus tapi gagal memulihkan stok", false);
                                        }
                                    } else {
                                        showMessageToUser("Gagal menghapus pembelian", false);
                                    }
                                }
                                purchaseSyncWarningDialog.close();
                            }
                        }
                    }
                }
            }
        }    }
    
    // Search functionality for Overview
    property var originalPurchaseData: []
    
    // Function to perform search with debouncing
    function performSearch(text) {
        searchText = text
        searchTimer.restart()
    }
    
    // Function to perform actual search with timer debouncing
    function performSearchWithTimer(text) {
        var searchQuery = text.toLowerCase().trim()
        isSearching = searchQuery !== ""
        
        if (database) {
            if (searchQuery !== "") {
                // Search in purchase data
                var allPurchases = database.loadPurchaseData()
                var filteredPurchases = allPurchases.filter(function(item) {
                    var nameMatch = item.productName && item.productName.toLowerCase().indexOf(searchQuery) !== -1
                    var supplierMatch = item.supplier && item.supplier.toLowerCase().indexOf(searchQuery) !== -1
                    var quantityMatch = item.quantity && item.quantity.toString().indexOf(searchQuery) !== -1
                    var priceMatch = item.price && item.price.toString().indexOf(searchQuery) !== -1
                    var dateMatch = item.purchaseDate && item.purchaseDate.toLowerCase().indexOf(searchQuery) !== -1
                    return nameMatch || supplierMatch || quantityMatch || priceMatch || dateMatch
                })
                
                purchaseList = filteredPurchases
                searchResultCount = filteredPurchases.length
            } else {
                // Reset to original data
                loadPurchaseData()
                searchResultCount = 0
            }
        }
    }
    
    // Function to clear search
    function clearSearch() {
        searchText = ""
        isSearching = false
        searchResultCount = 0
        loadPurchaseData()
    }
    
    // Settings Popup
    SettingsPopup {
        id: settingsPopup
        onProfileUpdated: {
            // Refresh user profile display
            // The header will automatically update through binding
        }
    }
}
