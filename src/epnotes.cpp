#include <ncurses.h>
#include <fstream>
#include <vector>
#include <string>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

std::string file_path;
std::string title;
std::vector<std::string> lines;

int cx = 0, cy = 0;
int scroll_offset = 0;

void load_file(const std::string& path) {
    file_path = path;
    std::ifstream f(path);
    json j;
    f >> j;

    title = j.value("title", "Notes");
    lines = j.value("content", std::vector<std::string>{""});
}

void save_file() {
    json j;
    j["title"] = title;
    j["content"] = lines;
    std::ofstream f(file_path);
    f << j.dump(2);
}

void init_colors() {
    start_color();
    use_default_colors();
    init_pair(1, COLOR_CYAN, -1);   // header
    init_pair(2, COLOR_GREEN, -1);  // checkbox checked
    init_pair(3, COLOR_WHITE, -1);  // normal text
    init_pair(4, COLOR_BLACK, COLOR_WHITE); // status bar
}

void draw_header() {
    attron(COLOR_PAIR(1) | A_BOLD);
    mvhline(0, 0, ' ', COLS);
    mvprintw(0, 2, "%s", title.c_str());
    attroff(COLOR_PAIR(1) | A_BOLD);
}

void draw_status() {
    attron(COLOR_PAIR(4));
    mvhline(LINES - 1, 0, ' ', COLS);
    mvprintw(LINES - 1, 2, "CTRL+S save | CTRL+Q quit | Mouse enabled");
    attroff(COLOR_PAIR(4));
}

void draw_content() {
    int h = LINES - 2;
    for (int i = 0; i < h; i++) {
        int idx = i + scroll_offset;
        if (idx >= (int)lines.size()) break;

        std::string line = lines[idx];

        if (line.rfind("- [x]", 0) == 0) {
            attron(COLOR_PAIR(2));
            mvprintw(i + 1, 2, "[✓]%s", line.substr(5).c_str());
            attroff(COLOR_PAIR(2));
        } else if (line.rfind("- [ ]", 0) == 0) {
            mvprintw(i + 1, 2, "[ ]%s", line.substr(5).c_str());
        } else {
            mvprintw(i + 1, 2, "%s", line.c_str());
        }
    }

    move(cy - scroll_offset + 1, cx + 2);
}

void toggle_checkbox(int y) {
    if (y < 0 || y >= (int)lines.size()) return;

    if (lines[y].rfind("- [ ]", 0) == 0)
        lines[y].replace(0, 5, "- [x]");
    else if (lines[y].rfind("- [x]", 0) == 0)
        lines[y].replace(0, 5, "- [ ]");
}

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Usage: epnotes <file.note>\n");
        return 1;
    }

    load_file(argv[1]);

    initscr();
    raw();
    keypad(stdscr, TRUE);
    mousemask(ALL_MOUSE_EVENTS, NULL);
    noecho();
    curs_set(1);

    init_colors();

    int ch;
    while (true) {
        clear();
        draw_header();
        draw_content();
        draw_status();
        refresh();

        ch = getch();

        if (ch == 17) break;          // CTRL+Q
        if (ch == 19) save_file();    // CTRL+S

        if (ch == KEY_UP && cy > 0) cy--;
        if (ch == KEY_DOWN && cy < (int)lines.size() - 1) cy++;
        if (ch == KEY_LEFT && cx > 0) cx--;
        if (ch == KEY_RIGHT && cx < (int)lines[cy].size()) cx++;

        if (ch == '\n') {
            lines.insert(lines.begin() + cy + 1, "");
            cy++; cx = 0;
        }

        if (ch == KEY_BACKSPACE || ch == 127) {
            if (cx > 0) {
                lines[cy].erase(cx - 1, 1);
                cx--;
            }
        }

        if (ch == KEY_MOUSE) {
            MEVENT ev;
            if (getmouse(&ev) == OK) {
                int my = ev.y - 1 + scroll_offset;
                if (ev.bstate & BUTTON1_CLICKED)
                    toggle_checkbox(my);
            }
        }

        if (isprint(ch)) {
            lines[cy].insert(cx, 1, ch);
            cx++;
        }

        if (cy - scroll_offset >= LINES - 2) scroll_offset++;
        if (cy < scroll_offset) scroll_offset--;
    }

    save_file();
    endwin();
    return 0;
}

