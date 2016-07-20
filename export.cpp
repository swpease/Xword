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
    // NOTE: for rich text painting, use QTextDocument::drawContents
    // painter will only support plaintext.

    //metadata
    QString title = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString date = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author_date = author + "          " + date;

    QRect title_rect(0, 0, 4000, 400);

    QPoint info_top_left(title_rect.left(), (title_rect.bottom() + 100));
    QSize author_date_size(5000, 200);
    QRect author_date_rect(info_top_left, author_date_size);

    //puzzles
    QImage puzzle = qvariant_cast<QImage>(m_images.takeAt(0));
    QImage puz_ans = qvariant_cast<QImage>(m_images.takeAt(0));
    QRect puz_rect(4000, 500, 5000, 5000);
    QRect ans_rect(0, 0, 2500, 2500);

    //filepath
    QString base_path = QDir::homePath();
    QString file_name = title == "" ? "/untitled.pdf" : "/" + title + ".pdf";


    // PAINTING //
    QPdfWriter pdf(base_path + file_name);
    QPainter painter;

    painter.begin(&pdf);  // BEGIN PAINTING

//    QRect page_rect = pdf;

    // make the title
    QFont font = painter.font();
    font.setPixelSize(400);
    font.setCapitalization(QFont::SmallCaps);
    painter.setFont(font);
    painter.drawText(title_rect, title);

    // make author and date
    font.setPixelSize(100);
    font.setCapitalization(QFont::MixedCase);
    font.setItalic(true);
    painter.setFont(font);
    painter.drawText(author_date_rect, author_date);


    //clues
    QString across = qvariant_cast<QString>(m_acrosses.takeAt(0));

    QPoint clues_col_top_left(author_date_rect.left(), (author_date_rect.bottom() + 300));
    QSize clues_col_size(1500, 10000);
    QRect whole_clues_col(clues_col_top_left, clues_col_size);
    QRect eaten_clues_col = whole_clues_col;
    int col_shift = 200;

    // make clues list
    font.setPixelSize(150);
    font.setBold(true);
    font.setItalic(false);
    painter.setFont(font);
    painter.drawText(2000, 2000, across);

    font.setBold(false);
    painter.setFont(font);

    foreach(QVariant across_clue, m_acrosses) {
        QString clue = qvariant_cast<QString>(across_clue);
        QRect space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, clue);
        if(space_needed.bottom() > eaten_clues_col.bottom()) {
            qDebug() << "before" << eaten_clues_col.topLeft() << eaten_clues_col.bottomRight();
            eaten_clues_col = whole_clues_col;
            qDebug() << "middle" << eaten_clues_col.topLeft() << eaten_clues_col.bottomRight();
            eaten_clues_col.setLeft(eaten_clues_col.right() + col_shift); // will this work?
            eaten_clues_col.setRight(eaten_clues_col.right() + col_shift + whole_clues_col.width());
            qDebug() << "after" << eaten_clues_col.topLeft() << eaten_clues_col.bottomRight();
            whole_clues_col = eaten_clues_col;

        }
        painter.drawText(eaten_clues_col, Qt::TextWordWrap, clue, &space_needed);
        QPoint updated_top_left = space_needed.bottomLeft();
        eaten_clues_col.setTopLeft(updated_top_left);
    }

    painter.drawImage(puz_rect, puzzle);

    pdf.newPage();
    painter.drawImage(ans_rect, puz_ans);

    painter.end();
}
