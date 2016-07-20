#include "export.h"
#include <QPainter>
#include <QPdfWriter>
#include <QDir>
#include <QDebug>

Export::Export(QObject *parent) : QObject(parent)
{

}

void Export::add_image(QVariant image)
{
//    QImage img = qvariant_cast<QImage>(image);   // is this necessary? image.typename is already QImage
    m_images.append(image);
}

void Export::add_metadata(QVariantList metadata)
{
    m_metadata = metadata;
}

void Export::add_clues(QVariantList acrosses, QVariantList downs)
{
    m_acrosses = acrosses;
    m_downs = downs;
}

void Export::export_pdf()
{
    QString title = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString date = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author = qvariant_cast<QString>(m_metadata.takeAt(0));

    qDebug() << title << date << author;

    QString basePath = QDir::homePath();
    //give option of export being either the puzzle name (if it exists) or the filename.pdf
    QPdfWriter pdf(basePath + "/test_pdf_export.pdf");
    QPainter painter;
    QRect rect_a(0, 0, 5000, 5000);
    QRect rect_b(0, 5000, 2500, 2500);

    QImage image_a = qvariant_cast<QImage>(m_images.takeAt(0));
    QImage image_b = qvariant_cast<QImage>(m_images.takeAt(0));
    QImage image_c = image_b.mirrored();

    painter.begin(&pdf);
    painter.drawImage(rect_a, image_a);
    painter.drawImage(rect_b, image_c);
    painter.end();
}
