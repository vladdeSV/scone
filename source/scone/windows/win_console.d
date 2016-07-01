module scone.windows.win_console;

package(scone):

import core.sys.windows.windows;
import scone.utility;
import scone.frame;
import scone.color;
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

private HANDLE _hConsoleOutput, _hConsoleError;
private CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;

private ushort attributesFromSlot(Slot slot)
{
    ushort attributes;

    switch(slot.foreground)
    {
    case Color.blue:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
        break;
    case Color.blue_dark:
        attributes |= FOREGROUND_BLUE;
        break;
    case Color.cyan:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.cyan_dark:
        attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.white:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.white_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.black:
        attributes |= FOREGROUND_INTENSITY;
        break;
    case Color.black_dark:
        attributes |= 0;
        break;
    case Color.green:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
        break;
    case Color.green_dark:
        attributes |= FOREGROUND_GREEN;
        break;
    case Color.magenta:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case Color.magenta_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case Color.red:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
        break;
    case Color.red_dark:
        attributes |= FOREGROUND_RED;
        break;
    case Color.yellow:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    case Color.yellow_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    default:
        break;
    }

    switch(slot.background)
    {
    case Color.blue:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
        break;
    case Color.blue_dark:
        attributes |= BACKGROUND_BLUE;
        break;
    case Color.cyan:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.cyan_dark:
        attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.white:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.white_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.black:
        attributes |= BACKGROUND_INTENSITY;
        break;
    case Color.black_dark:
        attributes |= 0;
        break;
    case Color.green:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
        break;
    case Color.green_dark:
        attributes |= BACKGROUND_GREEN;
        break;
    case Color.magenta:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case Color.magenta_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case Color.red:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
        break;
    case Color.red_dark:
        attributes |= BACKGROUND_RED;
        break;
    case Color.yellow:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    case Color.yellow_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    default:
        break;
    }

    return attributes;
}
