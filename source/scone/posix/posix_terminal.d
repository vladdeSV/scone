module scone.posix.posix_terminal;

version(Posix):

import core.sys.posix.sys.ioctl;
import core.sys.posix.unistd : STDOUT_FILENO;
import std.conv : text, to;
import std.stdio;

auto posix_initTerminal()
{
    posix_lineWrapping = false;
    posix_cursorVisible = false;
}

auto posix_exitTerminal()
{
    posix_lineWrapping = true;
    posix_cursorVisible = true;
    write("\033[0m"); //Reset colors to default
    //write("\033[c") //Clears the screen
}

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

auto posix_title(string title) @property
{
    write("\033]0;", title, "\007");
}

auto posix_windowSize() @property
{
    winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    return [to!int(w.ws_col), to!int(w.ws_row)];
}

version (OSX) enum TIOCGWINSZ = 0x40087468;