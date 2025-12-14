// New enhanced revenue calculation function - backup and replacement
QString Database::calculateRevenueChangeNew()
{
    if (currentUserId <= 0) {
        qDebug() << "Error: No user logged in";
        return "0%";
    }
    
    // Calculate current week and previous week dates
    QDate today = QDate::currentDate();
    QDate currentWeekStart = today.addDays(-7);
    QDate previousWeekStart = today.addDays(-14);
    QDate previousWeekEnd = today.addDays(-7);
    
    // Get all revenue data for this user
    QSqlQuery allRevenueQuery;
    allRevenueQuery.prepare("SELECT nominal, tanggal FROM pemasukan WHERE user_id = ?");
    allRevenueQuery.addBindValue(currentUserId);
    
    double currentWeekRevenue = 0.0;
    double previousWeekRevenue = 0.0;
    
    if (allRevenueQuery.exec()) {
        while (allRevenueQuery.next()) {
            QString nominal = allRevenueQuery.value("nominal").toString();
            QString tanggal = allRevenueQuery.value("tanggal").toString();
            
            // Parse nominal value
            QString cleanNominal = nominal;
            cleanNominal.remove("Rp ");
            cleanNominal.remove(".");
            double value = cleanNominal.toDouble();
            
            // Convert date and check which week this data belongs to
            QDate dateEntry = parseDate(tanggal);
            if (dateEntry.isValid()) {
                if (dateEntry >= currentWeekStart && dateEntry <= today) {
                    currentWeekRevenue += value;
                } else if (dateEntry >= previousWeekStart && dateEntry < previousWeekEnd) {
                    previousWeekRevenue += value;
                }
            }
        }
    }
    
    qDebug() << "Revenue Change - Current:" << currentWeekRevenue << "Previous:" << previousWeekRevenue;
    
    // Enhanced logic for better percentage calculation
    if (previousWeekRevenue == 0 && currentWeekRevenue == 0) {
        return "0%"; // No data in both periods
    } else if (previousWeekRevenue == 0 && currentWeekRevenue > 0) {
        return "Baru"; // New data this week
    } else if (previousWeekRevenue > 0 && currentWeekRevenue == 0) {
        return "-100%"; // No revenue this week but had revenue last week
    }
    
    double changePercent = ((currentWeekRevenue - previousWeekRevenue) / previousWeekRevenue) * 100.0;
    QString sign = changePercent >= 0 ? "+" : "";
    return QString("%1%2%").arg(sign).arg(QString::number(changePercent, 'f', 0));
}

// Helper function to parse date from string
QDate Database::parseDate(const QString &dateStr) {
    // Try to parse DD MMM YYYY format first (e.g., "18 Des 2024")
    if (dateStr.contains(" ")) {
        QStringList parts = dateStr.split(" ");
        if (parts.size() == 3) {
            int day = parts[0].toInt();
            QString monthStr = parts[1];
            int year = parts[2].toInt();
            
            QStringList monthNames = {"Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
                                      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"};
            int month = monthNames.indexOf(monthStr) + 1;
            
            if (month > 0 && day > 0 && year > 0) {
                return QDate(year, month, day);
            }
        }
    } else if (dateStr.contains("-")) {
        // Parse YYYY-MM-DD format
        return QDate::fromString(dateStr, "yyyy-MM-dd");
    }
    
    return QDate(); // Invalid date
}
