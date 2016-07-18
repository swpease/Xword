#include "export.h"
#include <QPainter>
#include <QPdfWriter>
#include <QDebug>

Export::Export(QObject *parent) : QObject(parent)
{

}

void Export::export_pdf(QVariant image)
{
//    qDebug() << image.typeName();
    QImage img = qvariant_cast<QImage>(image);  // is this necessary?
    QPdfWriter pdf("/Users/Scott/test_pdf_export.pdf");
    QPainter painter;
    QRect rect(0, 0, 5000, 5000);

    painter.begin(&pdf);
    painter.drawImage(rect, img);
    painter.end();
}
