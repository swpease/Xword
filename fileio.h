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

    Q_INVOKABLE QVariantList on_open(const QUrl &url);
    static QString get_app_dir();

signals:
    void fileExists();
    void fileSaved();

public slots:
    void on_saveAs(QUrl url, QVariantList data, bool overwrite = false);  // write as const T &?
    void on_save(QUrl url, QVariantList data);
};

#endif // FILEIO_H
