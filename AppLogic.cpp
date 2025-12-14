#include "AppLogic.h"
#include "Database.h"
#include <QDebug>

AppLogic::AppLogic(QObject *parent) 
    : QObject(parent)
    , m_loggedIn(false)
    , m_currentPage("dashboard")
    , m_database(nullptr)
{
}

void AppLogic::setDatabase(Database *database)
{
    m_database = database;
}

bool AppLogic::loggedIn() const {
    return m_loggedIn;
}

void AppLogic::setLoggedIn(bool value) {
    if (m_loggedIn != value) {
        m_loggedIn = value;
        emit loggedInChanged();
    }
}

QString AppLogic::currentPage() const {
    return m_currentPage;
}

void AppLogic::setCurrentPage(const QString &page) {
    if (m_currentPage != page) {
        m_currentPage = page;
        emit currentPageChanged();
    }
}

bool AppLogic::navigateToPage(const QString &page) {
    if (!m_loggedIn) {
        return false;
    }    QString qmlFile;
    if (page == "dashboard") {
        qmlFile = "qrc:/Dashboard.qml";
    } else if (page == "stock") {
        qmlFile = "qrc:/Stock.qml";
    } else if (page == "managestore") {
        qmlFile = "qrc:/ManageStore.qml";
    } else if (page == "overview") {
        qmlFile = "qrc:/Overview.qml";
    } else {
        return false;
    }

    setCurrentPage(page);
    emit navigationRequested(qmlFile);
    return true;
}

void AppLogic::login() {
    // Check if user is actually logged in via database
    if (m_database && m_database->isUserLoggedIn()) {
        setLoggedIn(true);
        navigateToPage("dashboard");
    } else {
        qDebug() << "Login failed: no authenticated user in database";
        setLoggedIn(false);
    }
}

void AppLogic::logout() {
    if (m_database) {
        m_database->logoutUser();
    }
    setLoggedIn(false);
}

