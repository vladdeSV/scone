module scone.os.posix;
version(Posix):

///needs to be specifically set, otherwise ioctl crashes ;(
version (OSX) enum TIOCGWINSZ = 0x40087468;

import core.sys.posix.sys.ioctl;
import core.sys.posix.unistd : STDOUT_FILENO;
import std.conv : to, text;
import std.stdio : write;

auto posix_init()
{
    //turn off linewrapping
    std.stdio.write("\033[?7l");
}

auto posix_deinit()
{
    //turn on linewrapping
    std.stdio.write("\033[?7h");
}

auto posix_setCursor(uint x, uint y)
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