#ifndef APPLOGIC_H
#define APPLOGIC_H

#include <QObject>

class Database;

class AppLogic : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loggedIn READ loggedIn WRITE setLoggedIn NOTIFY loggedInChanged)
    Q_PROPERTY(QString currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)

public:
    explicit AppLogic(QObject *parent = nullptr);
    
    void setDatabase(Database *database);

    bool loggedIn() const;
    void setLoggedIn(bool value);

    QString currentPage() const;
    void setCurrentPage(const QString &page);

signals:
    void loggedInChanged();
    void currentPageChanged();
    void navigationRequested(const QString &qmlFile);

public slots:
    bool navigateToPage(const QString &page);
    void login();
    void logout();

private:
    bool m_loggedIn;
    QString m_currentPage;
    Database *m_database;
};

#endif // APPLOGIC_H
