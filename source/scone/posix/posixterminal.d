module scone.posix.posixterminal;

version(Posix):

import core.sys.posix.sys.ioctl;
import core.sys.posix.unistd : STDOUT_FILENO;
import std.conv : text;
import std.stdio;

auto posix_setCursor(int x, int y)
{
    stdout.flush();
    writef("\033[%d;%dH", y, x);
}

auto posix_cursorVisible(bool vis) @property
{
    vis ? write("\033[?25h") : write("\033[?25l");
}

auto posix_lineWrapping(bool wrap) @property
{
    wrap ? write("\033[?7h") : write("\033[?7l");
}

auto posix_setTitle(string title)
{
    write("\033]0;", title, "\007");
}

auto posix_windowSize() @property
{
    winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    return [w.ws_col, w.ws_row];
}
