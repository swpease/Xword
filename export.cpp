#include "export.h"
#include <QPainter>
#include <QPdfWriter>
#include <QDir>
#include <QDebug>

Export::Export(QObject *parent) : QObject(parent)
{

}

void Export::export_pdf(QVariant image)
{
    QImage img = qvariant_cast<QImage>(image);  // is this necessary? image.typename is already QImage
    QString basePath = QDir::homePath();
    //give option of export being either the puzzle name (if it exists) or the filename.pdf
    QPdfWriter pdf(basePath + "/test_pdf_export.pdf");
    QPainter painter;
    QRect rect(0, 0, 5000, 5000);

    painter.begin(&pdf);
    painter.drawImage(rect, img);
    painter.end();
}
