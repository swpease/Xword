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

void Export::export_pdf(int columns)
{
    // 1200 dpi -> 200 dpi ~ 12pt font;
    // dims: 9583 x 13699

    int twelve_point = 200;
    int total_width = 9583;
    int total_height = 13699;
    int remaining_height = total_height;
    int puzzle_width = columns > 15 ? 6000 : 5000;
    int puzzle_height = puzzle_width;
    int clues_three_cols_width = total_width - puzzle_width;
    int clues_col_width_w_gap = clues_three_cols_width / 3;
    int col_gap = 225;  // empirically determined
    int clues_col_width = clues_col_width_w_gap - col_gap;
    int col_num = 1;

    //metadata
    QString title = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString date = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author = qvariant_cast<QString>(m_metadata.takeAt(0));
    QString author_date = author + "          " + date;

    QRect title_rect(0, 0, total_width, (twelve_point * 2));
    remaining_height -= (twelve_point * 2);

    QPoint info_top_left(0, (title_rect.bottom() + 100));
    QSize author_date_size((total_width - puzzle_width), twelve_point);
    QRect author_date_rect(info_top_left, author_date_size);
    remaining_height -= (twelve_point + 100);

    //clues
    QPoint clues_col_top_left(0, (author_date_rect.bottom() + 300));
    remaining_height -= 300;
    QSize clues_col_size(clues_col_width, remaining_height);
    QRect whole_clues_col(clues_col_top_left, clues_col_size);
    QRect eaten_clues_col = whole_clues_col;

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

    // getting info on available space in the appropriate units (used for the seemingly random
    // numbers for the constants at the start of the function).
//    QPageLayout layout = pdf.pageLayout();
//    int resolution = pdf.resolution();
//    QRect printable_rect = layout.paintRectPixels(resolution);

    painter.begin(&pdf);

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

    // across header
    font.setPixelSize(150);
    font.setBold(true);
    font.setItalic(false);
    painter.setFont(font);

    QString across_header = qvariant_cast<QString>(m_acrosses.takeAt(0));
    QRect space_needed = painter.boundingRect(eaten_clues_col, Qt::TextWordWrap, across_header);
    draw_clue(painter, eaten_clues_col, across_header, space_needed, Qt::AlignHCenter);
    eaten_clues_col.setTop(eaten_clues_col.top() + 100);  //ref: Export::paint_clues

    // across clues
    font.setBold(false);
    painter.setFont(font);
    paint_clues(painter, eaten_clues_col, m_acrosses, col_num, whole_clues_col, col_gap, puz_rect);

    // down header
    QVariantList down_header;
    down_header.append(m_downs.takeAt(0));  // is there a better way?

    font.setBold(true);
    painter.setFont(font);
    paint_clues(painter, eaten_clues_col, down_header, col_num, whole_clues_col,
                col_gap, puz_rect, Qt::AlignHCenter);

    // down clues
    font.setBold(false);
    painter.setFont(font);
    paint_clues(painter, eaten_clues_col, m_downs, col_num, whole_clues_col, col_gap, puz_rect);

    // images
    painter.drawImage(puz_rect, puzzle);
    pdf.newPage();
    painter.drawImage(ans_rect, puz_ans);

    painter.end();

    emit export_completed(file_name);
}

void Export::paint_clues(QPainter &painter, QRect &eaten_clues_col, QVariantList clues_list,
                         int &col_num, QRect &whole_clues_col, const int &col_gap, const QRect &puz_rect,
                         int alignment)
{
    foreach(QVariant raw_clue, clues_list) {
        QString clue = qvariant_cast<QString>(raw_clue);
        QRect space_needed = painter.boundingRect(eaten_clues_col, alignment, clue);
        if(space_needed.bottom() > eaten_clues_col.bottom()) {
            col_num += 1;
            eaten_clues_col = whole_clues_col;
            eaten_clues_col.setLeft(eaten_clues_col.right() + col_gap);
            eaten_clues_col.setRight(eaten_clues_col.right() + col_gap + whole_clues_col.width());
            if(col_num > 3) {
                eaten_clues_col.setTop(puz_rect.bottom() + 300);
            }
            whole_clues_col = eaten_clues_col;
        }
        draw_clue(painter, eaten_clues_col, clue, space_needed, alignment);
    }
    eaten_clues_col.setTop(eaten_clues_col.top() + 100);  //ref: across header section
}

void Export::draw_clue(QPainter &painter, QRect &eaten_clues_col, const QString &text,
                       QRect &space_needed, int alignment)
{
    painter.drawText(eaten_clues_col, alignment, text, &space_needed);
    int updated_top = space_needed.bottom();
    QPoint updated_top_left(eaten_clues_col.left(), updated_top);
    eaten_clues_col.setTopLeft(updated_top_left);
}
