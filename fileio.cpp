#include "fileio.h"

FileIO::FileIO(QObject *parent) : QObject(parent)
{

}

QVariantList FileIO::on_open(const QUrl &url)
{
    QString fileName = url.toString();
    fileName.remove(0, 5);

    QFile file(fileName);
    if(!file.open(QFile::ReadOnly)) {
        qDebug() << "Cannot open file for reading.";  // Need to do try/except or something.
        QString dummy1, dummy2;
        QVariantList dummyList;
        dummyList << dummy1 << dummy2;
        return dummyList;
    }

    QVariantList data;
    QDataStream in(&file);
    in >> data;

    file.close();
    return data;
}

QString FileIO::get_app_dir()  // static , for osx
{
    QString raw_base_path = QCoreApplication::applicationDirPath();
    QString partial_base_path = raw_base_path.split(".app")[0];
    int last_backslash = partial_base_path.lastIndexOf("/");
    QString base_path = partial_base_path.left(last_backslash);

    return base_path;
}

void FileIO::on_saveAs(QUrl url, QVariantList data, bool overwrite)
{
    QString fileName = url.toString();
    fileName.endsWith(".xwd") ? fileName : fileName += ".xwd";
//    fileName += ".xwd";
    fileName.remove(0, 5);
    QFile file(fileName);

    QFileInfo fileInfo(file);
    if(!overwrite && fileInfo.exists()) {
        emit fileExists();
        return;
    }

    if(!file.open(QFile::WriteOnly)) {
        qDebug() << "Cannot open file for writing.";
        return;
    }

    QDataStream out(&file);
    out << data;
    file.close();

    emit fileSaved();
}

void FileIO::on_save(QUrl url, QVariantList data)
{
    on_saveAs(url, data, true);
}
