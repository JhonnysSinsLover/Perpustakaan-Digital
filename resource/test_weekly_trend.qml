import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    width: 900
    height: 700
    visible: true
    title: "Weekly Trend Comprehensive Test"

    property var testDatabase: database

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20

        Column {
            width: parent.width
            spacing: 20

            Text {
                text: "Weekly Trend Function Comprehensive Test"
                font.pixelSize: 24
                font.bold: true
                color: "#1A1A1A"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "This tool will test all weekly trend calculations and help you verify the functionality."
                font.pixelSize: 14
                color: "#666666"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#E5E7EB"
            }

            // Current Status
            GroupBox {
                title: "📊 Current Financial Status"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Grid {
                        columns: 2
                        spacing: 20
                        columnSpacing: 50

                        Text { text: "Total Pemasukan:"; font.bold: true; width: 200 }
                        Text { 
                            text: testDatabase ? testDatabase.formatCurrency(testDatabase.getTotalPemasukan()) : "N/A"
                            color: "#10B981"
                        }

                        Text { text: "Total Pengeluaran:"; font.bold: true }
                        Text { 
                            text: testDatabase ? testDatabase.formatCurrency(testDatabase.getTotalPengeluaran()) : "N/A"
                            color: "#EF4444"
                        }

                        Text { text: "Net Profit:"; font.bold: true }
                        Text { 
                            text: testDatabase ? testDatabase.formatCurrency(testDatabase.getNetProfit()) : "N/A"
                            color: "#1A1A1A"
                        }

                        Text { text: "Profit Margin:"; font.bold: true }
                        Text { 
                            text: testDatabase ? testDatabase.getProfitMargin().toFixed(2) + "%" : "N/A"
                            color: "#1A1A1A"
                        }
                    }
                }
            }

            // Weekly Trend Results
            GroupBox {
                title: "📈 Weekly Trend Changes"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 15

                    Grid {
                        columns: 3
                        spacing: 20
                        columnSpacing: 30

                        Text { text: "Metric"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "Change"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "Action"; font.bold: true; font.pixelSize: 14 }

                        Text { text: "Revenue Change:"; font.bold: true }
                        Text {
                            id: revenueChangeText
                            text: testDatabase ? testDatabase.calculateRevenueChange() : "N/A"
                            color: {
                                if (!testDatabase) return "#666666"
                                var change = testDatabase.calculateRevenueChange()
                                if (change === "Baru") return "#3B82F6"
                                return change.startsWith("+") ? "#10B981" : "#EF4444"
                            }
                            font.bold: true
                        }
                        Button {
                            text: "Test"
                            onClicked: {
                                if (testDatabase) {
                                    console.log("Revenue Change:", testDatabase.calculateRevenueChange())
                                    revenueChangeText.text = testDatabase.calculateRevenueChange()
                                }
                            }
                        }

                        Text { text: "Expense Change:"; font.bold: true }
                        Text {
                            id: expenseChangeText
                            text: testDatabase ? testDatabase.calculateExpenseChange() : "N/A"
                            color: {
                                if (!testDatabase) return "#666666"
                                var change = testDatabase.calculateExpenseChange()
                                if (change === "Baru") return "#3B82F6"
                                return change.startsWith("+") ? "#EF4444" : "#10B981"
                            }
                            font.bold: true
                        }
                        Button {
                            text: "Test"
                            onClicked: {
                                if (testDatabase) {
                                    console.log("Expense Change:", testDatabase.calculateExpenseChange())
                                    expenseChangeText.text = testDatabase.calculateExpenseChange()
                                }
                            }
                        }

                        Text { text: "Net Profit Change:"; font.bold: true }
                        Text {
                            id: netProfitChangeText
                            text: testDatabase ? testDatabase.calculateNetProfitChange() : "N/A"
                            color: {
                                if (!testDatabase) return "#666666"
                                var change = testDatabase.calculateNetProfitChange()
                                if (change === "Baru") return "#3B82F6"
                                return change.startsWith("+") ? "#10B981" : "#EF4444"
                            }
                            font.bold: true
                        }
                        Button {
                            text: "Test"
                            onClicked: {
                                if (testDatabase) {
                                    console.log("Net Profit Change:", testDatabase.calculateNetProfitChange())
                                    netProfitChangeText.text = testDatabase.calculateNetProfitChange()
                                }
                            }
                        }

                        Text { text: "Profit Margin Change:"; font.bold: true }
                        Text {
                            id: profitMarginChangeText
                            text: testDatabase ? testDatabase.calculateProfitMarginChange() : "N/A"
                            color: {
                                if (!testDatabase) return "#666666"
                                var change = testDatabase.calculateProfitMarginChange()
                                if (change === "Baru") return "#3B82F6"
                                return change.startsWith("+") ? "#10B981" : "#EF4444"
                            }
                            font.bold: true
                        }
                        Button {
                            text: "Test"
                            onClicked: {
                                if (testDatabase) {
                                    console.log("Profit Margin Change:", testDatabase.calculateProfitMarginChange())
                                    profitMarginChangeText.text = testDatabase.calculateProfitMarginChange()
                                }
                            }
                        }
                    }
                }
            }

            // Debug Information
            GroupBox {
                title: "🔍 Debug Information"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 15

                    Button {
                        text: "🔍 Get Weekly Trend Debug Info"
                        width: parent.width
                        height: 40
                        onClicked: {
                            if (testDatabase) {
                                var debugInfo = testDatabase.getWeeklyTrendDebugInfo()
                                debugText.text = "=== Weekly Trend Debug Info ===\n" +
                                    "Current Week Revenue: Rp " + debugInfo.currentWeekRevenue + "\n" +
                                    "Current Week Expense: Rp " + debugInfo.currentWeekExpense + "\n" +
                                    "Current Week Profit: Rp " + debugInfo.currentWeekProfit + "\n\n" +
                                    "Previous Week Revenue: Rp " + debugInfo.previousWeekRevenue + "\n" +
                                    "Previous Week Expense: Rp " + debugInfo.previousWeekExpense + "\n" +
                                    "Previous Week Profit: Rp " + debugInfo.previousWeekProfit + "\n\n" +
                                    "Date Ranges:\n" +
                                    "Current Week: " + debugInfo.currentWeekRange + "\n" +
                                    "Previous Week: " + debugInfo.previousWeekRange
                                console.log("Debug Info:", JSON.stringify(debugInfo, null, 2))
                            }
                        }
                    }

                    ScrollView {
                        width: parent.width
                        height: 150
                        
                        Text {
                            id: debugText
                            text: "Click 'Get Weekly Trend Debug Info' to see detailed information"
                            font.pixelSize: 12
                            color: "#333333"
                            wrapMode: Text.WordWrap
                            width: parent.parent.width - 20
                        }
                    }
                }
            }

            // Test Data Management
            GroupBox {
                title: "🧪 Test Data Management"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 15

                    Text {
                        text: "Add sample data with specific dates to test weekly trend calculations:"
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    // Current Week Test Data
                    GroupBox {
                        title: "Current Week Test Data"
                        width: parent.width

                        Row {
                            spacing: 10
                            Button {
                                text: "Add Current Week Revenue (Rp 2,000,000)"
                                onClicked: {
                                    if (testDatabase) {
                                        var today = new Date()
                                        var dateStr = today.getFullYear() + "-" + 
                                                    String(today.getMonth() + 1).padStart(2, '0') + "-" + 
                                                    String(today.getDate()).padStart(2, '0')
                                        var success = testDatabase.addTestPemasukanWithDate("Rp 2.000.000", "Test Revenue Current Week", dateStr, "10:00:00")
                                        testDataResult.text = success ? "✓ Added current week revenue" : "✗ Failed to add revenue"
                                        if (success) refreshAllData()
                                    }
                                }
                            }
                            Button {
                                text: "Add Current Week Expense (Rp 800,000)"
                                onClicked: {
                                    if (testDatabase) {
                                        var today = new Date()
                                        var dateStr = today.getFullYear() + "-" + 
                                                    String(today.getMonth() + 1).padStart(2, '0') + "-" + 
                                                    String(today.getDate()).padStart(2, '0')
                                        var success = testDatabase.addTestPengeluaranWithDate("Rp 800.000", "Test Expense Current Week", dateStr, "14:00:00")
                                        testDataResult.text = success ? "✓ Added current week expense" : "✗ Failed to add expense"
                                        if (success) refreshAllData()
                                    }
                                }
                            }
                        }
                    }

                    // Previous Week Test Data
                    GroupBox {
                        title: "Previous Week Test Data"
                        width: parent.width

                        Row {
                            spacing: 10
                            Button {
                                text: "Add Previous Week Revenue (Rp 1,500,000)"
                                onClicked: {
                                    if (testDatabase) {
                                        var tenDaysAgo = new Date()
                                        tenDaysAgo.setDate(tenDaysAgo.getDate() - 10)
                                        var dateStr = tenDaysAgo.getFullYear() + "-" + 
                                                    String(tenDaysAgo.getMonth() + 1).padStart(2, '0') + "-" + 
                                                    String(tenDaysAgo.getDate()).padStart(2, '0')
                                        var success = testDatabase.addTestPemasukanWithDate("Rp 1.500.000", "Test Revenue Previous Week", dateStr, "11:00:00")
                                        testDataResult.text = success ? "✓ Added previous week revenue" : "✗ Failed to add revenue"
                                        if (success) refreshAllData()
                                    }
                                }
                            }
                            Button {
                                text: "Add Previous Week Expense (Rp 600,000)"
                                onClicked: {
                                    if (testDatabase) {
                                        var tenDaysAgo = new Date()
                                        tenDaysAgo.setDate(tenDaysAgo.getDate() - 10)
                                        var dateStr = tenDaysAgo.getFullYear() + "-" + 
                                                    String(tenDaysAgo.getMonth() + 1).padStart(2, '0') + "-" + 
                                                    String(tenDaysAgo.getDate()).padStart(2, '0')
                                        var success = testDatabase.addTestPengeluaranWithDate("Rp 600.000", "Test Expense Previous Week", dateStr, "15:00:00")
                                        testDataResult.text = success ? "✓ Added previous week expense" : "✗ Failed to add expense"
                                        if (success) refreshAllData()
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 10
                        Button {
                            text: "🗑️ Clear All Test Data"
                            onClicked: {
                                if (testDatabase) {
                                    var success = testDatabase.clearTestData()
                                    testDataResult.text = success ? "✓ Test data cleared" : "✗ Failed to clear test data"
                                    if (success) refreshAllData()
                                }
                            }
                        }
                        Button {
                            text: "🔄 Refresh All Data"
                            onClicked: refreshAllData()
                        }
                    }

                    Text {
                        id: testDataResult
                        text: "Ready to add test data"
                        font.pixelSize: 12
                        color: "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // Complete Test Suite
            GroupBox {
                title: "🚀 Complete Test Suite"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Button {
                        text: "🧪 Run Complete Weekly Trend Test"
                        width: parent.width
                        height: 50
                        onClicked: runCompleteTest()
                    }

                    Text {
                        id: completeTestResult
                        text: "Click 'Run Complete Weekly Trend Test' to execute full test suite"
                        font.pixelSize: 12
                        color: "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }

    function refreshAllData() {
        if (!testDatabase) return
        
        // Refresh trend calculations
        revenueChangeText.text = testDatabase.calculateRevenueChange()
        expenseChangeText.text = testDatabase.calculateExpenseChange()
        netProfitChangeText.text = testDatabase.calculateNetProfitChange()
        profitMarginChangeText.text = testDatabase.calculateProfitMarginChange()
        
        // Update debug info
        var debugInfo = testDatabase.getWeeklyTrendDebugInfo()
        debugText.text = "=== Updated Debug Info ===\n" +
            "Current Week Revenue: Rp " + debugInfo.currentWeekRevenue + "\n" +
            "Current Week Expense: Rp " + debugInfo.currentWeekExpense + "\n" +
            "Current Week Profit: Rp " + debugInfo.currentWeekProfit + "\n\n" +
            "Previous Week Revenue: Rp " + debugInfo.previousWeekRevenue + "\n" +
            "Previous Week Expense: Rp " + debugInfo.previousWeekExpense + "\n" +
            "Previous Week Profit: Rp " + debugInfo.previousWeekProfit
    }

    function runCompleteTest() {
        if (!testDatabase) {
            completeTestResult.text = "❌ Database not available!"
            return
        }

        completeTestResult.text = "⏳ Running complete test suite...\n"

        // Step 1: Clear existing test data
        testDatabase.clearTestData()
        completeTestResult.text += "✓ Cleared existing test data\n"

        // Step 2: Add previous week data
        var tenDaysAgo = new Date()
        tenDaysAgo.setDate(tenDaysAgo.getDate() - 10)
        var prevDateStr = tenDaysAgo.getFullYear() + "-" + 
                        String(tenDaysAgo.getMonth() + 1).padStart(2, '0') + "-" + 
                        String(tenDaysAgo.getDate()).padStart(2, '0')
        
        testDatabase.addTestPemasukanWithDate("Rp 1.000.000", "Auto Test Revenue Previous", prevDateStr, "10:00:00")
        testDatabase.addTestPengeluaranWithDate("Rp 400.000", "Auto Test Expense Previous", prevDateStr, "14:00:00")
        completeTestResult.text += "✓ Added previous week data (Rev: 1M, Exp: 400K)\n"

        // Step 3: Add current week data  
        var today = new Date()
        var currDateStr = today.getFullYear() + "-" + 
                        String(today.getMonth() + 1).padStart(2, '0') + "-" + 
                        String(today.getDate()).padStart(2, '0')
        
        testDatabase.addTestPemasukanWithDate("Rp 1.500.000", "Auto Test Revenue Current", currDateStr, "11:00:00")
        testDatabase.addTestPengeluaranWithDate("Rp 500.000", "Auto Test Expense Current", currDateStr, "15:00:00")
        completeTestResult.text += "✓ Added current week data (Rev: 1.5M, Exp: 500K)\n"

        // Step 4: Calculate trends
        var revenueChange = testDatabase.calculateRevenueChange()
        var expenseChange = testDatabase.calculateExpenseChange()
        var netProfitChange = testDatabase.calculateNetProfitChange()
        var marginChange = testDatabase.calculateProfitMarginChange()

        completeTestResult.text += "\n📊 TREND RESULTS:\n"
        completeTestResult.text += "Revenue Change: " + revenueChange + "\n"
        completeTestResult.text += "Expense Change: " + expenseChange + "\n"
        completeTestResult.text += "Net Profit Change: " + netProfitChange + "\n"
        completeTestResult.text += "Profit Margin Change: " + marginChange + "\n"

        // Step 5: Expected vs Actual
        completeTestResult.text += "\n✅ EXPECTED RESULTS:\n"
        completeTestResult.text += "Revenue: +50% (1.5M vs 1M)\n"
        completeTestResult.text += "Expense: +25% (500K vs 400K)\n"
        completeTestResult.text += "Net Profit: +66.7% (1M vs 600K)\n"

        // Refresh all displays
        refreshAllData()

        completeTestResult.text += "\n🎉 Test completed! Check if results match expectations."
    }
}
