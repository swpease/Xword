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

    Q_INVOKABLE void add_image(QVariant image);
    Q_INVOKABLE void add_metadata(QVariantList text);
    Q_INVOKABLE void add_clues(QVariantList acrosses, QVariantList downs);
    Q_INVOKABLE void export_pdf();

signals:

public slots:

private:
    QVariantList m_images;
    QVariantList m_metadata;
    QVariantList m_acrosses;
    QVariantList m_downs;
};

#endif // EXPORT_H
