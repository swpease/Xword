#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QtCore>
#include <QUrl>
#include <QVariant>

class FileIO : public QObject
{
    Q_OBJECT
public:
    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE QVariantList on_open(QUrl url);

signals:

public slots:
    void on_saveAs(QUrl url, QVariantList data);  // write as const T &?
};

#endif // FILEIO_H
