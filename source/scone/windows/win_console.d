module scone.windows.win_console;

version (Windows):
package(scone):

import core.sys.windows.windows;
import scone.utility;
import scone.frame;
import std.algorithm : max, min;
import std.conv : to;
import std.stdio : stdout;
import std.string : toStringz;

auto win_initConsole()
{

    _hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    _hConsoleError  = GetStdHandle(STD_ERROR_HANDLE);

    if(_hConsoleOutput == INVALID_HANDLE_VALUE)
        assert(0, "_hConsoleOutput == INVALID_HANDLE_VALUE");
    if(_hConsoleError == INVALID_HANDLE_VALUE)
        assert(0, "_hConsoleError == INVALID_HANDLE_VALUE");

    win_cursorVisible = false;
    win_setCursor(0,0);

    //TODO: clear the screen?

    //SetConsoleOutputCP(65001);

    ////Set up the required window size:
    //SMALL_RECT windowSize = {0, 0, to!ushort(w), to!ushort(h)};
    ////Change the console window size:
    //SetConsoleWindowInfo(_hConsoleOutput, TRUE, &windowSize);

    //_hConsoleOutput = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE, 0, null, CONSOLE_TEXTMODE_BUFFER, null);
    //SetConsoleActiveScreenBuffer(_hConsoleOutput);

}

auto win_exitConsole()
{
    win_cursorVisible = true;
}

auto win_writeSlot(int x, int y, ref Slot slot)
{
    ushort wx = to!ushort(x), wy = to!ushort(y);
    COORD charBufSize = {1,1};
    COORD characterPos = {0,0};
    SMALL_RECT writeArea = {wx, wy, wx, wy};
    CHAR_INFO character;
    character.AsciiChar = slot.character;
    character.Attributes = attributesFromSlot(slot);
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

/** Set window title */
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

auto win_windowSize() @property
{
    GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);
    return [_consoleScreenBufferInfo.srWindow.Right  - _consoleScreenBufferInfo.srWindow.Left + 1, _consoleScreenBufferInfo.srWindow.Bottom - _consoleScreenBufferInfo.srWindow.Top  + 1];
}

private:
HANDLE _hConsoleOutput, _hConsoleError;
CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;
//private SMALL_RECT _oldWindowSize;

ushort attributesFromSlot(Slot slot)
{
    ushort attributes;

    switch(slot.foreground)
    {
    case fg.init:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case fg.blue:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
        break;
    case fg.blue_dark:
        attributes |= FOREGROUND_BLUE;
        break;
    case fg.cyan:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case fg.cyan_dark:
        attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case fg.gray:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case fg.gray_dark:
        attributes |= FOREGROUND_INTENSITY;
        break;
    case fg.green:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
        break;
    case fg.green_dark:
        attributes |= FOREGROUND_GREEN;
        break;
    case fg.magenta:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case fg.magenta_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case fg.red:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
        break;
    case fg.red_dark:
        attributes |= FOREGROUND_RED;
        break;
    case fg.white:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case fg.yellow:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    case fg.yellow_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    default:
        break;
    }

    switch(slot.background)
    {
    case bg.init:
        attributes |= 0;
        break;
    case bg.blue:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
        break;
    case bg.blue_dark:
        attributes |= BACKGROUND_BLUE;
        break;
    case bg.cyan:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case bg.cyan_dark:
        attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case bg.gray:
        attributes |= BACKGROUND_INTENSITY;
        break;
    case bg.gray_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case bg.green:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
        break;
    case bg.green_dark:
        attributes |= BACKGROUND_GREEN;
        break;
    case bg.magenta:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case bg.magenta_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case bg.red:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
        break;
    case bg.red_dark:
        attributes |= BACKGROUND_RED;
        break;
    case bg.white:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case bg.yellow:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    case bg.yellow_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    default:
        break;
    }

    return attributes;
}
