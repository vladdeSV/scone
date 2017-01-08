module scone.window;

import scone.color;
import scone.os.independent;

import std.conv : to, text;
import std.stdio;// : write, writef, writeln, writefln;

///
struct Window
{
    this(uint width, uint height)
    {
        OS.init();

        cursorVisible = false;

        _cells = new Cell[][](height, width);
        _backbuffer = new Cell[][](height, width);
        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ');
        }

        _w = width;
        _h = height;

        clear();
    }

    auto write(Args...)(in uint x, in uint y, Args args)
    {
        //Check if writing outside border
        if(x < 0 || y < 0 || x > _w || y > _h)
        {
            //sconeLog.logf("Warning: Cannot write at (%s, %s). x must be between 0 <-> %s, y must be between 0 <-> %s", x, y, _w, _h);
            return;
        }

        Cell[] cells;
        fg foreground = fg.white_dark;
        bg background = bg.black_dark;

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
                unsetColors = false;
            }
            else static if(is(typeof(arg) == Cell[]))
            {
                foreach(cell; arg)
                {
                    cells ~= cell;
                    unsetColors = false;
                }
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
            int wx, wy;
            foreach(ref cell; cells)
            {
                if(x + wx >= _w || cell.character == '\n')
                {
                    wx = 0;
                    ++wy;
                    continue;
                }
                else
                {
                    _cells[y + wy][x + wx] = cell;
                    ++wx;
                }
            }
        }
    }

    //TODO
    auto print()
    {
        version(Windows)
        {
            import scone.os.windows : win_writeCell;

            foreach(cy, ref y; _cells)
            {
                foreach(cx, ref cell; y)
                {
                    if(cell != _backbuffer[cy][cx])
                    {
                        win_writeCell(cx, cy, cell);

                        //update backbuffer
                        _backbuffer[cy][cx] = cell;
                    }
                }
            }
        }

        version(Posix)
        {
            import scone.os.posix : posix_setCursor;

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
                    printed ~= text("\033[", 0, ";", cast(uint)(_cells[sy][px].foreground), ";", cast(uint)(_cells[sy][px].background + 10), "m", _cells[sy][px].character, "\033[0m");
                }

                //Set the cursor at the firstly edited cell... (POSIX magic)
                posix_setCursor(f, to!uint(sy));

                //...and then print out the string via the regue write function.
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
        foreach(ref y; _cells)
        {
            y[] = Cell(' ');
        }
    }

    ///Causes next `print()` to write out all cells.
    ///NOTE: Only use this if some sort of visual bug occurs.
    auto flush()
    {
        foreach(ref y; _backbuffer)
        {
            y[] = Cell(' ');
        }
    }

    ///Set the title of the window
    void title(string title) @property
    {
        OS.title(title);
    }

    auto cursorVisible(bool visible) @property
    {
        OS.cursorVisible(visible);
    }

    void windowSize(uint width, uint height)
    {
        
    }

    auto windowSize()
    {
        return OS.windowSize();
    }

    private Cell[][] _cells, _backbuffer;
    private uint _w, _h;
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