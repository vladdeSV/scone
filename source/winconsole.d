module scone.winconsole;

version (Windows):

import core.sys.windows.windows;
import std.algorithm : max, min;
import std.conv : to;
import std.stdio : stdout;
import std.string : toStringz;

enum Color{
    fg_black        = 0                                                                         ,
    fg_blue         = FOREGROUND_INTENSITY |                                     FOREGROUND_BLUE,
    fg_blue_dark    =                                                            FOREGROUND_BLUE,
    fg_cyan         = FOREGROUND_INTENSITY |                  FOREGROUND_GREEN | FOREGROUND_BLUE,
    fg_cyan_dark    =                                         FOREGROUND_GREEN | FOREGROUND_BLUE,
    fg_gray         = FOREGROUND_INTENSITY                                                      ,
    fg_green        = FOREGROUND_INTENSITY |                  FOREGROUND_GREEN                  ,
    fg_green_dark   =                                         FOREGROUND_GREEN                  ,
    fg_grey_dark    =                        FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE,
    fg_magenta      = FOREGROUND_INTENSITY | FOREGROUND_RED |                    FOREGROUND_BLUE,
    fg_magenta_dark =                        FOREGROUND_RED |                    FOREGROUND_BLUE,
    fg_red          = FOREGROUND_INTENSITY | FOREGROUND_RED                                     ,
    fg_red_dark     =                        FOREGROUND_RED                                     ,
    fg_white        = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE,
    fg_yellow       = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN                  ,
    fg_yellow_dark  =                        FOREGROUND_RED | FOREGROUND_GREEN                  ,

    bg_black        = 0                                                                        ,
    bg_blue         = BACKGROUND_INTENSITY |                                     BACKGROUND_BLUE,
    bg_blue_dark    =                                                            BACKGROUND_BLUE,
    bg_cyan         = BACKGROUND_INTENSITY |                  BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_cyan_dark    =                                         BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_gray         = BACKGROUND_INTENSITY                                                      ,
    bg_gray_dark    =                        BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_green        = BACKGROUND_INTENSITY |                  BACKGROUND_GREEN                  ,
    bg_green_dark   =                                         BACKGROUND_GREEN                  ,
    bg_magenta      = BACKGROUND_INTENSITY | BACKGROUND_RED |                    BACKGROUND_BLUE,
    bg_magenta_dark =                        BACKGROUND_RED |                    BACKGROUND_BLUE,
    bg_red          = BACKGROUND_INTENSITY | BACKGROUND_RED                                     ,
    bg_red_dark     =                        BACKGROUND_RED                                     ,
    bg_white        = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_yellow       = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN                  ,
    bg_yellow_dark  =                        BACKGROUND_RED | BACKGROUND_GREEN
}

protected:

auto win_initConsole()
{

    _hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    _hConsoleInput  = GetStdHandle(STD_INPUT_HANDLE);
    _hConsoleError  = GetStdHandle(STD_ERROR_HANDLE);

    if(_hConsoleOutput == INVALID_HANDLE_VALUE)
        assert(0, "_hConsoleOutput == INVALID_HANDLE_VALUE");
    if(_hConsoleInput == INVALID_HANDLE_VALUE)
        assert(0, "_hConsoleInput == INVALID_HANDLE_VALUE");
    if(_hConsoleError == INVALID_HANDLE_VALUE)
        assert(0, "_hConsoleError == INVALID_HANDLE_VALUE");

    win_cursorVisible = false;
    win_lineWrapping = false;

    /+
    ushort ww = to!ushort(w), wh = to!ushort(h);
    Set up the required window size:
    SMALL_RECT windowSize = {0, 0, ww, wh};
    Change the console window size:
    SetConsoleWindowInfo(_hConsoleOutput, TRUE, &windowSize);
    _hConsoleOutput = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE, 0, null, CONSOLE_TEXTMODE_BUFFER, null);
    SetConsoleActiveScreenBuffer(_hConsoleOutput);
    +/
}

auto win_exitConsole()
{
    win_cursorVisible = true;
    win_lineWrapping = true;
}

auto win_writeCharacter(int x, int y, char c, int attributes = Color.fg_red | Color.bg_white)
{
    ushort wx = to!ushort(x), wy = to!ushort(y);
    COORD charBufSize = {1,1};
    COORD characterPos = {0,0};
    SMALL_RECT writeArea = {wx, wy, wx, wy};
    CHAR_INFO character;
    character.AsciiChar = c;
    //character.UnicodeChar = to!wchar(c);
    character.Attributes = to!ushort(attributes);
    WriteConsoleOutputA(_hConsoleOutput, &character, charBufSize, characterPos, &writeArea);
}

/** Set cursor position. */
auto win_setCursor(int x, int y)
{
    GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);
    COORD change = { cast(short) min(_consoleScreenBufferInfo.srWindow.Right - _consoleScreenBufferInfo.srWindow.Left + 1, max(0, x)), cast(short) max(0, y) };
    stdout.flush();
    SetConsoleCursorPosition(_hConsoleOutput, change);
}

auto win_title(string title) @property
{
    SetConsoleTitleA(title.toStringz);
}

/** Set cursor visible. */
auto win_cursorVisible(bool visible) @property
{
    CONSOLE_CURSOR_INFO cci;
    GetConsoleCursorInfo(_hConsoleOutput, &cci);
    cci.bVisible = visible;
    SetConsoleCursorInfo(_hConsoleOutput, &cci);
}

/** Set line wrapping. */
auto win_lineWrapping(bool lw) @property
{
    lw ? SetConsoleMode(_hConsoleOutput, 0x0002) : SetConsoleMode(_hConsoleOutput, 0x0);
}

private:
HANDLE _hConsoleOutput, _hConsoleInput, _hConsoleError;
CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;
//private SMALL_RECT _oldWindowSize;
