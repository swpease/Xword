#include "fileio.h"

FileIO::FileIO(QObject *parent) : QObject(parent)
{

}

void FileIO::on_saveAs(QUrl url, QVariantList data)
{
    QString fileName = url.toString();
    fileName += ".xwd";
    fileName.remove(0, 5);

    QFile file(fileName);

    if(!file.open(QFile::WriteOnly)) {
        qDebug() << "Cannot open file for writing.";
        return;
    }

    QDataStream out(&file);
    out << data;

    file.close();
}

QVariantList FileIO::on_open(QUrl url)
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
