module scone.window;

import scone.color;
import scone.os;

import std.conv : to, text;
import std.stdio;// : write, writef, writeln, writefln;

///
struct Window
{
    ///initializes the window.
    ///NOTE: should only be used once. use `size(w,h);` to resize
    this(uint width, uint height)
    {
        cursorVisible = false;

        _cells = new Cell[][](height, width);
        _backbuffer = new bool[][](height, width);

        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ');
            _backbuffer[n][] = true;
        }

        //properly set the size of the console
        size(width, height);

        clear();
    }

    ///write practically anything to the window
    ///NOTE: does not directly write to the window, changes will only be visible after `print();`
    void write(Args...)(in uint x, in uint y, Args args)
    {
        //Check if writing outside border
        if(x < 0 || y < 0 || x > w || y > h)
        {
            //sconeLog.logf("Warning: Cannot write at (%s, %s). x must be between 0 <-> %s, y must be between 0 <-> %s", x, y, _w, _h);
            return;
        }

        //everything which will be written to the window's internal memory
        Cell[] cells;

        fg foreground = fg.white_dark;
        bg background = bg.black_dark;

        //flag to warn if color arguments will not be written
        bool unsetColors;
        foreach(ref arg; args)
        {
            static if(is(typeof(arg) == fg))
            {
                foreground = arg;
                unsetColors = true;
            }
            else static if(is(typeof(arg) == bg))
            {
                background = arg;
                unsetColors = true;
            }
            else static if(is(typeof(arg) == Cell))
            {
                cells ~= arg;
                
            }
            else static if(is(typeof(arg) == Cell[]))
            {
                foreach(cell; arg)
                {
                    cells ~= cell;
                }
                unsetColors = false;
            }
            else
            {
                foreach(c; to!string(arg))
                {
                    cells ~= Cell(c, foreground, background);
                }

                unsetColors = false;
            }
        }

        //If the last argument is a color, warn
        if(cells.length && unsetColors)
        {
            //sconeLog.logf("Warning: The last argument in %s is a color, which will not be set!", args);
        }

        if(!cells.length)
        {
            _cells[y][x].foreground = foreground;
            _cells[y][x].background = background;
        }
        else
        {
            //some hokus pokus to store stuff into memory
            int wx, wy;
            foreach(ref cell; cells)
            {
                if(x + wx >= w || cell.character == '\n')
                {
                    wx = 0;
                    ++wy;
                    continue;
                }
                else
                {
                    if(_cells[y + wy][x + wx] != cell)
                    {
                        _backbuffer[y + wy][x + wx] = true;
                        _cells[y + wy][x + wx] = cell;
                    }
                    ++wx;
                }
            }
        }
    }

    ///displays all which has been written
    void print()
    {
        //windows version, using winapi
        version(Windows)
        {
            foreach(cy, ref y; _cells)
            {
                foreach(cx, ref cell; y)
                {
                    if(_backbuffer[cy][cx])
                    {
                        OS.Windows.writeCell(cx, cy, cell);

                        //update backbuffer
                        _backbuffer[cy][cx] = false;
                    }
                }
            }
        }

        //for posix, a different method printing is used
        version(Posix)
        {
            //simple flag if row is unaffected
            enum rowUnchanged = -1;

            //Temporary string that will be printed out for each line.
            string printed;

            //Loop through all rows.
            foreach (sy, y; _cells)
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

                //If no cell on this y has been modified, continue
                if(f == rowUnchanged)
                {
                    continue;
                }

                //Loop from the first changed cell to the last edited cell.
                foreach (px; f .. l + 1)
                {
                    //TODO: colors are not supported yet on POSIX
                    printed ~= text
                    (
                        "\033[", 0, ";", OS.Posix.ansiColor(_cells[sy][px].foreground),
                                    ";", OS.Posix.ansiColor(_cells[sy][px].background),
                                    "m", _cells[sy][px].character, "\033[0m"
                    );
                }

                //Set the cursor at the firstly edited cell... (POSIX magic)
                OS.Posix.setCursor(f, to!uint(sy));

                //...and then print out the string via the regular write function.
                std.stdio.write(printed);

                //Reset 'printed'.
                printed = null;
            }

            //Flush. Without this problems may occur.
            //stdout.flush(); //TODO: Check if needed for POSIX. I know without this it caused a lot of problems on the Windows console, but you know... this part is POSIX only
        }
    }

    ///Clear the screen, making it ready for the next `print();`
    void clear()
    {
        foreach(ref y; _cells)
        {
            y[] = Cell(' ');
        }
    }

    ///Causes next `print()` to write out all cells.
    ///NOTE: Only use this if some sort of visual bug occurs.
    void flush()
    {
        foreach(ref row; _backbuffer)
        {
            row[] = true;
        }
    }

    ///Set the title of the window
    void title(string title) @property
    {
        OS.title(title);
    }

    ///set if the cursor should be visible
    void cursorVisible(bool visible) @property
    {
        OS.cursorVisible(visible);
    }

    alias size = OS.size;

    ///get the width of the window
    uint width()
    {
        return size[0];
    }

    ///get the height of the window
    uint height()
    {
        return size[1];
    }

    alias w = width;
    alias h = height;

    private Cell[][] _cells;
    ///to know what to update. 'true' means something changed
    bool[][] _backbuffer;
}

///
struct Cell
{
    ///character
    char character;
    ///foreground color
    fg foreground = fg(Color.white_dark);
    ///background color
    bg background = bg(Color.black_dark);
}

Cell[] cellString(string str, Color color, Color background)
{
    Cell[] ret;
    ret.length = str.length;

    foreach(n, ref c; str)
    {
        ret[n] = Cell(c, fg(color), bg(background));
    }

    return ret;
}