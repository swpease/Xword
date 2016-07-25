#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>

#include "fileio.h"
#include "export.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    //    app.setWindowIcon(QIcon(":/xword.icns"));  // may be needed for non-osx deployment?

    FileIO fileIO;
    Export exportPDF;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("FileIO", &fileIO);
    engine.rootContext()->setContextProperty("ExportPDF", &exportPDF);
    engine.rootContext()->setContextProperty("AppPath", FileIO::get_app_dir());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *rootObject = engine.rootObjects().first();
    QObject::connect(&fileIO, SIGNAL(fileExists()), rootObject, SLOT(overwriteFile()));
    QObject::connect(&fileIO, SIGNAL(fileSaved()), rootObject, SLOT(afterSaving()));
    QObject::connect(&exportPDF, SIGNAL(export_completed(QVariant)), rootObject, SLOT(displayPdfLocation(QVariant)));

    return app.exec();
}

