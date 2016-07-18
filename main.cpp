#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>

#include "fileio.h"
#include "export.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    FileIO fileIO;
    Export exportPDF;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("FileIO", &fileIO);
    engine.rootContext()->setContextProperty("ExportPDF", &exportPDF);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *rootObject = engine.rootObjects().first();
    QObject::connect(&fileIO, SIGNAL(fileExists()), rootObject, SLOT(overwriteFile()));
    QObject::connect(&fileIO, SIGNAL(fileSaved()), rootObject, SLOT(afterSaving()));

    return app.exec();
}

