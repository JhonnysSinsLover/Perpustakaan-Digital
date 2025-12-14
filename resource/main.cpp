#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "../AppLogic.h"
#include "../Database.h"
#include "../CircularImage.h"
#include <QtQuickControls2/QQuickStyle>

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");
    QGuiApplication app(argc, argv);

    // Register CircularImage component for QML
    qmlRegisterType<CircularImage>("CircularImage", 1, 0, "CircularImage");

    QQmlApplicationEngine engine;
    AppLogic appLogic;
    Database database;
    
    if (!database.initDatabase()) {
        qDebug() << "Failed to initialize database";
        return -1;
    }

    // Connect AppLogic with Database
    appLogic.setDatabase(&database);

    engine.rootContext()->setContextProperty("appLogic", &appLogic);
    engine.rootContext()->setContextProperty("database", &database);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    return app.exec();
}
