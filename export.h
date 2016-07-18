#ifndef EXPORT_H
#define EXPORT_H

#include <QObject>
#include <QtCore>
#include <QtGui>
#include <QUrl>
#include <QVariant>

class Export : public QObject
{
    Q_OBJECT
public:
    explicit Export(QObject *parent = 0);

signals:

public slots:
    void export_pdf(QVariant image);
};

#endif // EXPORT_H
