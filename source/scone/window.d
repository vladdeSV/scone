module scone.window;

import color;
import std.stdio : write, writef, writeln, writefln;

///needs to be specifically set, otherwise ioctl crashes ;(
version (OSX) enum TIOCGWINSZ = 0x40087468;

version(Windows)
{
    import core.sys.windows.windows;
    import utility;
    import color;
    import win_console;
    import std.algorithm : max, min;
    import std.conv : to;
    import std.string : toStringz;
}
version(Posix)
{
    import core.sys.posix.sys.ioctl;
    import core.sys.posix.unistd : STDOUT_FILENO;
    import std.conv : to, text;
}

struct Window
{
    this(uint width, uint height)
    {
        version(Windows)
        {
            _hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            _hConsoleError  = GetStdHandle(STD_ERROR_HANDLE);

            if(_hConsoleOutput == INVALID_HANDLE_VALUE)
                assert(0, "_hConsoleOutput == INVALID_HANDLE_VALUE");
            if(_hConsoleError == INVALID_HANDLE_VALUE)
                assert(0, "_hConsoleError == INVALID_HANDLE_VALUE");
        }

        version(Posix)
        {
            //turn off linewrapping
            std.stdio.write("\033[?7l");
        }

        cursorVisible = false;

        _cells = new Cell[][](width, height);
        _backbuffer = new Cell[][](width, height);
        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ');
        }

        clear();
    }

    ~this()
    {
        version(Posix)
        {
            //turn on linewrapping
            std.stdio.write("\033[?7h");
        }

        cursorVisible = true;
        //TODO: setCursor(0,0);
    }

    //TODO
    auto print()
    {
        version(Windows)
        {
            foreach(cy, ref row; _cells)
            {
                foreach(cx, ref cell; row)
                {
                    if(cell != _backbuffer[cy][cx])
                    {
                        //handle writing to the console
                        ushort wx = to!ushort(cx), wy = to!ushort(cy);
                        COORD charBufSize = {1,1};
                        COORD characterPos = {0,0};
                        SMALL_RECT writeArea = {wx, wy, wx, wy};
                        CHAR_INFO character;
                        character.AsciiChar = cell.character;
                        character.Attributes = attributesFromSlot(cell);
                        WriteConsoleOutputA(_hConsoleOutput, &character, charBufSize, characterPos, &writeArea);

                        //update backbuffer
                        _backbuffer[cy][cx] = cell;
                    }
                }
            }
        }

        version(Posix)
        {
            enum rowUnchanged = -1;

            //Temporary string that will be printed out for each line.
            string printed;

            //Loop through all rows.
            foreach (sy, row; _cells)
            {
                //f = first modified cell, l = last modified cell
                uint f = rowUnchanged, l;

                //TOOD: add a foreach_reverse to maybe speed up time
                //Go through each line
                foreach(sx, cell; _cells[sy])
                {
                    //If the cell at current position differs from backbuffer
                    if(cell != _backbuffer[sy][sx])
                    {
                        //Set f once
                        if(f == rowUnchanged)
                        {
                            f = to!uint(sx);
                        }

                        //Update l as many times as needed
                        l = to!uint(sx);

                        //Backbuffer is checked, make it "un-differ"
                        _backbuffer[sy][sx] = cell;
                    }
                }

                //If no cell on this row has been modified, continue
                if(f == rowUnchanged)
                {
                    continue;
                }

                //Loop from the first changed cell to the last edited cell.
                foreach (px; f .. l + 1)
                {
                    //TODO: colors are not supported yet on POSIX
                    printed ~= text("\033[", 0, ";", cast(uint)(_cells[sy][px].foreground), ";", cast(uint)(_cells[sy][px].background + 10), "m", _cells[sy][px].character, "\033[0m");
                }

                //Set the cursor at the firstly edited cell... (POSIX magic)
                writef("\033[%d;%dH", f, sy);

                //...and then print out the string via the terminals write function.
                std.stdio.write(printed);

                //Reset 'printed'.
                printed = null;
            }

            //Flush. Without this problems may occur.
            //stdout.flush(); //TODO: Check if needed for POSIX. I know without this it caused a lot of problems on the Windows console, but you know... this part is POSIX only
        }
    }

    auto clear()
    {
        foreach(ref row; _cells)
        {
            row[] = Cell(' ');
        }
    }

    ///Causes next `print()` to write out all cells.
    ///NOTE: Only use this if some sort of visual bug occurs.
    auto flush()
    {
        foreach(ref row; _backbuffer)
        {
            row[] = Cell(' ');
        }
    }

    ///Set the title of the window
    void title(string title) @property
    {
        version(Windows)
        {
            SetConsoleTitleA(title.toStringz);
        }

        version(Posix)
        {
            std.stdio.write("\033]0;", title, "\007");
        }
    }

    auto cursorVisible(bool visible) @property
    {
        version(Windows)
        {
            CONSOLE_CURSOR_INFO cci;
            GetConsoleCursorInfo(_hConsoleOutput, &cci);
            cci.bVisible = visible;
            SetConsoleCursorInfo(_hConsoleOutput, &cci);
        }
        else
        {
            vis ? std.stdio.write("\033[?25h") : write("\033[?25l");
        }
    }

    void windowSize(uint width, uint height)
    {
        version(Windows)
        {
            //TODO
        }

        version(Posix)
        {
            //TODO
        }
    }

    auto windowSize()
    {
        version(Windows)
        {
            GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);

            return
            [
                _consoleScreenBufferInfo.srWindow.Right -
                _consoleScreenBufferInfo.srWindow.Left + 1,
                _consoleScreenBufferInfo.srWindow.Bottom -
                _consoleScreenBufferInfo.srWindow.Top  + 1
            ];
        }

        version(Posix)
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return [to!uint(w.ws_col), to!uint(w.ws_row)];
        }
    }

    version(Windows)
    {
        private HANDLE _hConsoleOutput, _hConsoleError;
        private CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;
    }

    private Cell[][] _cells, _backbuffer;
}

///
struct Cell
{
    ///character
    char character;
    ///foreground color
    fg foreground= fg(Color.white_dark);
    ///background color
    bg background= bg(Color.black_dark);
}