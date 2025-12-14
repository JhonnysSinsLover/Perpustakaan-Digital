import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: "Weekly Trend Debug Tool"

    property var testDatabase: database

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20

        Column {
            width: parent.width
            spacing: 20

            Text {
                text: "🔍 Weekly Trend Debug Tool"
                font.pixelSize: 24
                font.bold: true
                color: "#1A1A1A"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "#E5E7EB"
            }

            // 1. Check User Login Status
            GroupBox {
                title: "👤 User Status Check"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Button {
                        text: "Check Current User"
                        onClicked: {
                            if (testDatabase) {
                                var userId = testDatabase.getCurrentUserId()
                                var isLoggedIn = testDatabase.isUserLoggedIn()
                                userStatusText.text = "User ID: " + userId + "\nLogged In: " + isLoggedIn
                                console.log("User ID:", userId, "Logged In:", isLoggedIn)
                            } else {
                                userStatusText.text = "Database not available!"
                            }
                        }
                    }

                    Text {
                        id: userStatusText
                        text: "Click 'Check Current User' to see login status"
                        color: "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // 2. Check Data Existence
            GroupBox {
                title: "📊 Data Existence Check"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Row {
                        spacing: 10
                        Button {
                            text: "Check Total Revenue"
                            onClicked: {
                                if (testDatabase) {
                                    var total = testDatabase.getTotalPemasukan()
                                    dataCheckText.text += "Total Revenue: " + testDatabase.formatCurrency(total) + "\n"
                                }
                            }
                        }
                        Button {
                            text: "Check Total Expense"
                            onClicked: {
                                if (testDatabase) {
                                    var total = testDatabase.getTotalPengeluaran()
                                    dataCheckText.text += "Total Expense: " + testDatabase.formatCurrency(total) + "\n"
                                }
                            }
                        }
                    }

                    Button {
                        text: "Clear Results"
                        onClicked: dataCheckText.text = ""
                    }

                    ScrollView {
                        width: parent.width
                        height: 100
                        
                        Text {
                            id: dataCheckText
                            text: "Click buttons above to check data"
                            color: "#333333"
                            wrapMode: Text.WordWrap
                            width: parent.parent.width - 20
                        }
                    }
                }
            }

            // 3. Test Weekly Trend Functions
            GroupBox {
                title: "📈 Weekly Trend Function Test"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Grid {
                        columns: 2
                        spacing: 10

                        Button {
                            text: "Test Revenue Change"
                            onClicked: {
                                if (testDatabase) {
                                    var result = testDatabase.calculateRevenueChange()
                                    trendResultsText.text += "Revenue Change: " + result + "\n"
                                    console.log("Revenue Change:", result)
                                }
                            }
                        }

                        Button {
                            text: "Test Expense Change"
                            onClicked: {
                                if (testDatabase) {
                                    var result = testDatabase.calculateExpenseChange()
                                    trendResultsText.text += "Expense Change: " + result + "\n"
                                    console.log("Expense Change:", result)
                                }
                            }
                        }

                        Button {
                            text: "Test Net Profit Change"
                            onClicked: {
                                if (testDatabase) {
                                    var result = testDatabase.calculateNetProfitChange()
                                    trendResultsText.text += "Net Profit Change: " + result + "\n"
                                    console.log("Net Profit Change:", result)
                                }
                            }
                        }

                        Button {
                            text: "Test Margin Change"
                            onClicked: {
                                if (testDatabase) {
                                    var result = testDatabase.calculateProfitMarginChange()
                                    trendResultsText.text += "Margin Change: " + result + "\n"
                                    console.log("Margin Change:", result)
                                }
                            }
                        }
                    }

                    Button {
                        text: "Test All Functions"
                        width: parent.width
                        onClicked: {
                            if (testDatabase) {
                                trendResultsText.text = "=== TESTING ALL FUNCTIONS ===\n"
                                
                                var revenue = testDatabase.calculateRevenueChange()
                                var expense = testDatabase.calculateExpenseChange()
                                var netProfit = testDatabase.calculateNetProfitChange()
                                var margin = testDatabase.calculateProfitMarginChange()
                                
                                trendResultsText.text += "Revenue Change: " + revenue + "\n"
                                trendResultsText.text += "Expense Change: " + expense + "\n"
                                trendResultsText.text += "Net Profit Change: " + netProfit + "\n"
                                trendResultsText.text += "Margin Change: " + margin + "\n"
                                
                                console.log("All Results:", revenue, expense, netProfit, margin)
                            }
                        }
                    }

                    Button {
                        text: "Clear Results"
                        onClicked: trendResultsText.text = ""
                    }

                    ScrollView {
                        width: parent.width
                        height: 150
                        
                        Text {
                            id: trendResultsText
                            text: "Click buttons above to test trend functions"
                            color: "#333333"
                            wrapMode: Text.WordWrap
                            width: parent.parent.width - 20
                            font.family: "Consolas, Monaco, monospace"
                        }
                    }
                }
            }

            // 4. Debug Info
            GroupBox {
                title: "🔍 Detailed Debug Info"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Button {
                        text: "Get Weekly Debug Info"
                        width: parent.width
                        onClicked: {
                            if (testDatabase) {
                                var debugInfo = testDatabase.getWeeklyTrendDebugInfo()
                                
                                debugInfoText.text = "=== WEEKLY TREND DEBUG INFO ===\n"
                                debugInfoText.text += "Current Week Revenue: Rp " + debugInfo.currentWeekRevenue + "\n"
                                debugInfoText.text += "Current Week Expense: Rp " + debugInfo.currentWeekExpense + "\n"
                                debugInfoText.text += "Current Week Profit: Rp " + debugInfo.currentWeekProfit + "\n\n"
                                
                                debugInfoText.text += "Previous Week Revenue: Rp " + debugInfo.previousWeekRevenue + "\n"
                                debugInfoText.text += "Previous Week Expense: Rp " + debugInfo.previousWeekExpense + "\n"
                                debugInfoText.text += "Previous Week Profit: Rp " + debugInfo.previousWeekProfit + "\n\n"
                                
                                debugInfoText.text += "Date Ranges:\n"
                                debugInfoText.text += "Current Week: " + debugInfo.currentWeekRange + "\n"
                                debugInfoText.text += "Previous Week: " + debugInfo.previousWeekRange + "\n\n"
                                
                                // Check if all values are zero
                                if (debugInfo.currentWeekRevenue == 0 && debugInfo.previousWeekRevenue == 0) {
                                    debugInfoText.text += "❌ ISSUE: No revenue data found for both weeks!\n"
                                    debugInfoText.text += "💡 Suggestion: Add test data using buttons below\n"
                                } else if (debugInfo.previousWeekRevenue == 0) {
                                    debugInfoText.text += "⚠️ INFO: No previous week data - should show 'Baru'\n"
                                } else {
                                    debugInfoText.text += "✅ DATA: Both weeks have data - calculations should work\n"
                                }
                                
                                console.log("Debug Info:", JSON.stringify(debugInfo, null, 2))
                            }
                        }
                    }

                    ScrollView {
                        width: parent.width
                        height: 200
                        
                        Text {
                            id: debugInfoText
                            text: "Click 'Get Weekly Debug Info' to see detailed information"
                            color: "#333333"
                            wrapMode: Text.WordWrap
                            width: parent.parent.width - 20
                            font.family: "Consolas, Monaco, monospace"
                        }
                    }
                }
            }

            // 5. Quick Test Data
            GroupBox {
                title: "🧪 Quick Test Data"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: "Add test data to verify trend calculations work:"
                        color: "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Row {
                        spacing: 10
                        Button {
                            text: "Add Current Week Data"
                            onClicked: {
                                if (testDatabase) {
                                    var today = new Date()
                                    var dateStr = today.getFullYear() + "-" + 
                                                String(today.getMonth() + 1).padStart(2, '0') + "-" + 
                                                String(today.getDate()).padStart(2, '0')
                                    
                                    testDatabase.addTestPemasukanWithDate("Rp 1.000.000", "Debug Test Current", dateStr, "10:00:00")
                                    testDatabase.addTestPengeluaranWithDate("Rp 400.000", "Debug Test Current", dateStr, "14:00:00")
                                    
                                    testResultText.text = "✅ Added current week: Rev 1M, Exp 400K"
                                }
                            }
                        }

                        Button {
                            text: "Add Previous Week Data"
                            onClicked: {
                                if (testDatabase) {
                                    var tenDaysAgo = new Date()
                                    tenDaysAgo.setDate(tenDaysAgo.getDate() - 10)
                                    var dateStr = tenDaysAgo.getFullYear() + "-" + 
                                                String(tenDaysAgo.getMonth() + 1).padStart(2, '0') + "-" + 
                                                String(tenDaysAgo.getDate()).padStart(2, '0')
                                    
                                    testDatabase.addTestPemasukanWithDate("Rp 800.000", "Debug Test Previous", dateStr, "11:00:00")
                                    testDatabase.addTestPengeluaranWithDate("Rp 300.000", "Debug Test Previous", dateStr, "15:00:00")
                                    
                                    testResultText.text = "✅ Added previous week: Rev 800K, Exp 300K"
                                }
                            }
                        }

                        Button {
                            text: "Clear Test Data"
                            onClicked: {
                                if (testDatabase) {
                                    testDatabase.clearTestData()
                                    testResultText.text = "🗑️ Cleared all test data"
                                }
                            }
                        }
                    }

                    Text {
                        id: testResultText
                        text: "Ready to add test data"
                        color: "#666666"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // 6. Complete Diagnostic
            GroupBox {
                title: "🩺 Complete Diagnostic"
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 10

                    Button {
                        text: "🚀 Run Complete Diagnostic"
                        width: parent.width
                        height: 40
                        onClicked: runCompleteDiagnostic()
                    }

                    ScrollView {
                        width: parent.width
                        height: 200
                        
                        Text {
                            id: diagnosticText
                            text: "Click 'Run Complete Diagnostic' for full analysis"
                            color: "#333333"
                            wrapMode: Text.WordWrap
                            width: parent.parent.width - 20
                            font.family: "Consolas, Monaco, monospace"
                        }
                    }
                }
            }
        }
    }

    function runCompleteDiagnostic() {
        if (!testDatabase) {
            diagnosticText.text = "❌ DATABASE NOT AVAILABLE!"
            return
        }

        diagnosticText.text = "🩺 RUNNING COMPLETE DIAGNOSTIC...\n\n"

        // Step 1: User Status
        var userId = testDatabase.getCurrentUserId()
        var isLoggedIn = testDatabase.isUserLoggedIn()
        diagnosticText.text += "1️⃣ USER STATUS:\n"
        diagnosticText.text += "   User ID: " + userId + "\n"
        diagnosticText.text += "   Logged In: " + isLoggedIn + "\n"
        
        if (userId <= 0) {
            diagnosticText.text += "   ❌ CRITICAL: No user logged in!\n\n"
            return
        } else {
            diagnosticText.text += "   ✅ User is logged in\n\n"
        }

        // Step 2: Data Check
        diagnosticText.text += "2️⃣ DATA CHECK:\n"
        var totalRevenue = testDatabase.getTotalPemasukan()
        var totalExpense = testDatabase.getTotalPengeluaran()
        diagnosticText.text += "   Total Revenue: " + testDatabase.formatCurrency(totalRevenue) + "\n"
        diagnosticText.text += "   Total Expense: " + testDatabase.formatCurrency(totalExpense) + "\n"
        
        if (totalRevenue == 0 && totalExpense == 0) {
            diagnosticText.text += "   ⚠️ WARNING: No financial data found\n\n"
        } else {
            diagnosticText.text += "   ✅ Financial data exists\n\n"
        }

        // Step 3: Weekly Debug Info
        diagnosticText.text += "3️⃣ WEEKLY DATA ANALYSIS:\n"
        var debugInfo = testDatabase.getWeeklyTrendDebugInfo()
        diagnosticText.text += "   Current Week Revenue: Rp " + debugInfo.currentWeekRevenue + "\n"
        diagnosticText.text += "   Current Week Expense: Rp " + debugInfo.currentWeekExpense + "\n"
        diagnosticText.text += "   Previous Week Revenue: Rp " + debugInfo.previousWeekRevenue + "\n"
        diagnosticText.text += "   Previous Week Expense: Rp " + debugInfo.previousWeekExpense + "\n"

        // Step 4: Trend Calculations
        diagnosticText.text += "\n4️⃣ TREND CALCULATIONS:\n"
        var revenue = testDatabase.calculateRevenueChange()
        var expense = testDatabase.calculateExpenseChange()
        var netProfit = testDatabase.calculateNetProfitChange()
        var margin = testDatabase.calculateProfitMarginChange()
        
        diagnosticText.text += "   Revenue Change: " + revenue + "\n"
        diagnosticText.text += "   Expense Change: " + expense + "\n"
        diagnosticText.text += "   Net Profit Change: " + netProfit + "\n"
        diagnosticText.text += "   Margin Change: " + margin + "\n"

        // Step 5: Analysis
        diagnosticText.text += "\n5️⃣ ANALYSIS:\n"
        
        if (debugInfo.currentWeekRevenue == 0 && debugInfo.previousWeekRevenue == 0) {
            diagnosticText.text += "   ❌ ISSUE: No revenue data for both weeks\n"
            diagnosticText.text += "   📝 ACTION: Add financial data to see trends\n"
        } else if (debugInfo.previousWeekRevenue == 0) {
            diagnosticText.text += "   ℹ️ INFO: No previous week data\n"
            diagnosticText.text += "   ✅ EXPECTED: Should show 'Baru' for all trends\n"
        } else if (debugInfo.currentWeekRevenue == 0) {
            diagnosticText.text += "   ⚠️ INFO: No current week data\n"
            diagnosticText.text += "   ✅ EXPECTED: Should show -100% for revenue\n"
        } else {
            diagnosticText.text += "   ✅ GOOD: Both weeks have data\n"
            diagnosticText.text += "   ✅ EXPECTED: Should show calculated percentages\n"
        }

        diagnosticText.text += "\n🎯 CONCLUSION:\n"
        
        if (revenue === "0%" && expense === "0%" && netProfit === "0%" && margin === "0%") {
            diagnosticText.text += "   ❌ PROBLEM: All trends showing 0%\n"
            diagnosticText.text += "   💡 SOLUTION: Add test data and check date formats\n"
        } else if (revenue === "Baru" || expense === "Baru") {
            diagnosticText.text += "   ✅ WORKING: Trends showing 'Baru' (new data)\n"
            diagnosticText.text += "   💡 TIP: Add previous week data to see percentages\n"
        } else {
            diagnosticText.text += "   ✅ WORKING: Trends showing calculated percentages\n"
            diagnosticText.text += "   🎉 SUCCESS: Weekly trend functionality is working!\n"
        }
    }
}
