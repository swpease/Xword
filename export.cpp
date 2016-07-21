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

    // 1200 dpi -> 200 dpi ~ 12pt font;
    // dims: 9583 x 13699

    int twelve_point = 200;
    int total_width = 9583;
    int total_height = 13699;
//    int remaining_width = total_width;
    int remaining_height = total_height;
    int puzzle_width = 5000;
    int puzzle_height = puzzle_width;

    //metadata
    QString title = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString date = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author_date = author + "          " + date;

    QRect title_rect(0, 0, total_width, (twelve_point * 2));
    remaining_height -= (twelve_point * 2);

    QPoint info_top_left(title_rect.left(), (title_rect.bottom() + 100));
    QSize author_date_size((total_width - puzzle_width), twelve_point);
    QRect author_date_rect(info_top_left, author_date_size);
    remaining_height -= (twelve_point + 100);

    //puzzles
    QImage puzzle = qvariant_cast<QImage>(m_images.takeAt(0));
    QImage puz_ans = qvariant_cast<QImage>(m_images.takeAt(0));
    QSize puz_size(puzzle_width, puzzle_height);
    QPoint puz_top_left((total_width - puzzle_width), title_rect.bottom());
    QRect puz_rect(puz_top_left, puz_size);
    QRect ans_rect(0, 0, (puzzle_width / 2), (puzzle_height / 2));

    //filepath
    QString base_path = QDir::homePath();
    QString file_name = title == "" ? "/untitled.pdf" : "/" + title + ".pdf";

    // PAINTING //
    QPdfWriter pdf(base_path + file_name);
    QPainter painter;

    // getting info on available space in the appropriate units
    QPageLayout layout = pdf.pageLayout();
    int resolution = pdf.resolution();
    QRect printable_rect = layout.paintRectPixels(resolution);

    painter.begin(&pdf);  // BEGIN PAINTING

    // make the title
    QFont font = painter.font();
    font.setPixelSize(twelve_point * 2);
    font.setCapitalization(QFont::SmallCaps);
    painter.setFont(font);
    painter.drawText(title_rect, title);

    // make author and date
    font.setPixelSize(twelve_point / 2);
    font.setCapitalization(QFont::MixedCase);
    font.setItalic(true);
    painter.setFont(font);
    painter.drawText(author_date_rect, author_date);

    //clues
    QPoint clues_col_top_left(0, (author_date_rect.bottom() + 300));
    remaining_height -= 300;
    QSize clues_col_size(1300, remaining_height);
    QRect whole_clues_col(clues_col_top_left, clues_col_size);
    QRect eaten_clues_col = whole_clues_col;
    int col_shift = 228;  // (9583 - puzwidth) / 3, split b/w the clues_col_size and this.
    int col_num = 1;

    QString across = qvariant_cast<QString>(m_acrosses.takeAt(0));

    // make clues list
    font.setPixelSize(150);
    font.setBold(true);
    font.setItalic(false);
    painter.setFont(font);

    QRect space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, across);
    painter.drawText(eaten_clues_col, Qt::TextWordWrap, across, &space_needed);
    QPoint updated_top_left = space_needed.bottomLeft();
    eaten_clues_col.setTopLeft(updated_top_left);

    font.setBold(false);
    painter.setFont(font);

    foreach(QVariant across_clue, m_acrosses) {
        QString clue = qvariant_cast<QString>(across_clue);
        QRect space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, clue);
        if(space_needed.bottom() > eaten_clues_col.bottom()) {
            col_num += 1;
            eaten_clues_col = whole_clues_col;
            eaten_clues_col.setLeft(eaten_clues_col.right() + col_shift); // will this work?
            eaten_clues_col.setRight(eaten_clues_col.right() + col_shift + whole_clues_col.width());
            if(col_num > 3) {
                eaten_clues_col.setTop(puz_rect.bottom() + 300);
            }
            whole_clues_col = eaten_clues_col;

        }
        painter.drawText(eaten_clues_col, Qt::TextWordWrap, clue, &space_needed);
        QPoint updated_top_left = space_needed.bottomLeft();
        eaten_clues_col.setTopLeft(updated_top_left);
    }

    QString down = qvariant_cast<QString>(m_downs.takeAt(0));

    font.setBold(true);
    painter.setFont(font);
    space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, down);  //scope in confusing...
    if(space_needed.bottom() > eaten_clues_col.bottom()) {
        col_num += 1;
        eaten_clues_col = whole_clues_col;
        eaten_clues_col.setLeft(eaten_clues_col.right() + col_shift); // will this work?
        eaten_clues_col.setRight(eaten_clues_col.right() + col_shift + whole_clues_col.width());
        if(col_num > 3) {
            eaten_clues_col.setTop(puz_rect.bottom() + 300);
        }
        whole_clues_col = eaten_clues_col;
    }
    painter.drawText(eaten_clues_col, Qt::TextWordWrap, down, &space_needed);
    updated_top_left = space_needed.bottomLeft();
    eaten_clues_col.setTopLeft(updated_top_left);

    font.setBold(false);
    painter.setFont(font);

    foreach(QVariant down_clue, m_downs) {
        QString clue = qvariant_cast<QString>(down_clue);
        QRect space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, clue);
        if(space_needed.bottom() > eaten_clues_col.bottom()) {
            col_num += 1;
            eaten_clues_col = whole_clues_col;
            eaten_clues_col.setLeft(eaten_clues_col.right() + col_shift); // will this work?
            eaten_clues_col.setRight(eaten_clues_col.right() + col_shift + whole_clues_col.width());
            if(col_num > 3) {
                eaten_clues_col.setTop(puz_rect.bottom() + 300);
            }
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

void Export::paint_clues(QVariantList clues)
{

}
