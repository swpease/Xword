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
    Q_INVOKABLE void export_pdf(int columns);

signals:
    void export_completed(QVariant file_name);

public slots:

private:
    QVariantList m_images;
    QVariantList m_metadata;
    QVariantList m_acrosses;
    QVariantList m_downs;

    void paint_clues(QPainter &painter, QRect &eaten_clues_col, QVariantList clues_list, int &col_num,
                     QRect &whole_clues_col, const int &col_gap, const QRect &puz_rect,
                     int alignment = Qt::TextWordWrap);

    void draw_clue(QPainter &painter, QRect &eaten_clues_col, const QString &text,
                   QRect &space_needed, int alignment = Qt::TextWordWrap);
};

#endif // EXPORT_H
