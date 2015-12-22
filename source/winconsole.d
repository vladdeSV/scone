module winconsole;

version (Windows):

import core.sys.windows.windows;
import std.conv : to;
import std.string : toStringz;

enum Color{
    fg_black        = 0,
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

    bg_black        = 10                                                                        ,
    bg_blue         = BACKGROUND_INTENSITY |                                     BACKGROUND_BLUE,
    bg_blue_dark    =                                                            BACKGROUND_BLUE,
    bg_cyan         = BACKGROUND_INTENSITY |                  BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_cyan_dark    =                                         BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_gray         = BACKGROUND_INTENSITY                                                      ,
    bg_green        = BACKGROUND_INTENSITY |                  BACKGROUND_GREEN                  ,
    bg_green_dark   =                                         BACKGROUND_GREEN                  ,
    bg_grey_dark    =                        BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_magenta      = BACKGROUND_INTENSITY | BACKGROUND_RED |                    BACKGROUND_BLUE,
    bg_magenta_dark =                        BACKGROUND_RED |                    BACKGROUND_BLUE,
    bg_red          = BACKGROUND_INTENSITY | BACKGROUND_RED                                     ,
    bg_red_dark     =                        BACKGROUND_RED                                     ,
    bg_white        = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
    bg_yellow       = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN                  ,
    bg_yellow_dark  =                        BACKGROUND_RED | BACKGROUND_GREEN
}


void winWriteCharacter(int x, int y, char c, int attributes = Color.fg_red | Color.bg_white)
{
    ushort wx = to!ushort(x), wy = to!ushort(y);

    COORD charBufSize = {1,1};
    COORD characterPos = {0,0};
    SMALL_RECT writeArea = {wx, wy, wx, wy};

    CHAR_INFO character;
    character.AsciiChar = c;
    character.UnicodeChar = to!wchar(c);
    character.Attributes = to!ushort(attributes);

    WriteConsoleOutputA(m_hConsoleOutput, &character, charBufSize, characterPos, &writeArea);
}

protected auto initWin(string title, int w, int h)
{
    ushort ww = to!ushort(w), wh = to!ushort(h);

    SetConsoleTitleA(title.toStringz);

    m_hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    m_hConsoleInput  = GetStdHandle(STD_INPUT_HANDLE);
    m_hConsoleError  = GetStdHandle(STD_ERROR_HANDLE);

    if(m_hConsoleOutput == INVALID_HANDLE_VALUE)
        assert(0, "m_hConsoleOutput == INVALID_HANDLE_VALUE");

    //Set up the required window size:
    SMALL_RECT windowSize = {0, 0, ww, wh};
    //Change the console window size:
    SetConsoleWindowInfo(m_hConsoleOutput, TRUE, &windowSize);

    m_hConsoleOutput = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE, 0, null, CONSOLE_TEXTMODE_BUFFER, null);
    SetConsoleActiveScreenBuffer(m_hConsoleOutput);
}

private HANDLE m_hConsoleOutput, m_hConsoleInput, m_hConsoleError;
    //CONSOLE_SCREEN_BUFFER_INFO m_consoleScreenBufferInfo;
