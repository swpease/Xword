#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>

#include "fileio.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    FileIO fileIO;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("FileIO", &fileIO);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

