module scone.window;

import scone.os;
import scone.input;

import std.conv : to, text;
import std.stdio;// : write, writef, writeln, writefln;

///
struct Window
{
    ///initializes the window.
    ///NOTE: should only be used once. use `size(w,h);` to resize
    this(uint width, uint height)
    {
        //properly set the size of the console
        resize(width, height);
    }

    ///Write practically anything to the window
    ///Example:
    ///---
    ///window.write(3, 5, "hello ", fg(Color.green)'w', Cell('o', fg(Color.red)), "rld ", 42, [1337, 1001, 1]);
    ///---
    ///NOTE: Does not directly write to the window, changes will only be visible after `window.print();`
    void write(Args...)(in size_t x, in size_t y, Args args)
    {
        //Check if writing outside border
        if(/+x < 0 || y < 0 ||+/ x >= w || y >= h)
        {
            //logf("Warning: Cannot write at (%s, %s). x must be between 0 <-> %s, y must be between 0 <-> %s", x, y, w, h);
            return;
        }

        //everything which will be written to the window's internal memory
        Cell[] cells;

        fg foreground = defaultForeground;
        bg background = defaultBackground;

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
            //logf("Warning: The last argument in %s is a color, which will not be set!", args);
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
                    _cells[y + wy][x + wx] = cell;
                    ++wx;
                }
            }
        }
    }

    ///Displays what has been written
    void print()
    {
        //windows version, using winapi
        version(Windows)
        {
            foreach(cy, ref y; _cells)
            {
                foreach(cx, ref cell; y)
                {
                    if(cell != _backbuffer[cy][cx])
                    {
                        OS.Windows.writeCell(cx, cy, cell);

                        //update backbuffer
                        _backbuffer[cy][cx] = cell;
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

                //TOOD: add a foreach_reverse to maybe speed up time,
                //      meaning once first changed cell is found, do
                //      another foreach_reverse loop.
                //
                //2017 clarafication of this:
                //find the first the first modified cell with foreach.
                //Once one has been found, do foreach_reverse to look
                //for the last modified cell.
                //
                //I think that would speed it up?

                //Go through each line
                foreach(sx, cell; _cells[sy])
                {
                    //If backbuffer says something has changed
                    if(_backbuffer[sy][sx] != cell)
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
                    //To save excecution time, check if the prevoisly printed
                    //chracter has the same attributes as the current one being
                    //printed. If so, simply write the new character instead of
                    //executing ANSI commands.

                    if
                    (
                        px == f ||
                        _cells[sy][px - 1].foreground != _cells[sy][px].foreground ||
                        _cells[sy][px - 1].background != _cells[sy][px].background
                    )
                    {
                        printed ~= text
                        (
                            "\033[",
                            0,
                            ";", OS.Posix.ansiColor(_cells[sy][px].foreground),
                            ";", OS.Posix.ansiColor(_cells[sy][px].background) + 10,
                            "m",
                        );
                    }

                    printed ~= _cells[sy][px].character;
                }

                printed ~= "\033[0m";

                //Set the cursor at the firstly edited cell... (POSIX magic)
                OS.Posix.setCursor(f + 1, to!uint(sy));

                //...and then print out the string via the regular write function.
                std.stdio.write(printed);

                //Reset 'printed'.
                printed = null;
            }

            //Flush. Without this problems may occur.
            stdout.flush(); //TODO: Check if needed for POSIX. I know without this it caused a lot of problems on the Windows console, but you know... this part is POSIX only
        }
    }

    ///Clear the screen, making it ready for the next `print();`
    void clear()
    {
        foreach(ref y; _cells)
        {
            y[] = Cell(' ', defaultForeground, defaultBackground);
        }
    }

    ///Causes next `print()` to write out all cells.
    ///NOTE: Only use this if some sort of visual bug occurs.
    void flush()
    {
        foreach(ref row; _backbuffer)
        {
            row[] = Cell(char(0), defaultForeground, defaultBackground);
        }
    }

    /**
     * Get a range of all inputs since last call.
     * Returns: InputEvent[]
     */
    InputEvent[] getInputs()
    {
        version(Windows)
        {
            return OS.Windows.retreiveInputs();
        }
        version(Posix)
        {
            return OS.Posix.retreiveInputs();
        }
    }

    ///Set the size of the window
    void title(string title) @property
    {
        OS.title(title);
    }

    ///Set if the cursor should be visible
    void cursorVisible(bool visible) @property
    {
        OS.cursorVisible(visible);
    }

    ///Changes the size of the window
    ///NOTE: (POSIX) Does not work if terminal is maximized
    ///NOTE: Clears the buffer
    void resize(uint width, uint height)
    {
        OS.resize(width, height);

        _cells = new Cell[][](height, width);
        _backbuffer = new Cell[][](height, width);

        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ', defaultForeground, defaultBackground);
        }
    }

    ///Get the width of the window
    uint width()
    {
        return to!uint(_cells[0].length);
    }

    ///Get the height of the window
    uint height()
    {
        return to!uint(_cells.length);
    }

    ///
    alias w = width;
    ///
    alias h = height;

    ///The default foreground color used with `window.write(x, y, ...);`
    public fg defaultForeground = fg(Color.white_dark);
    ///The default background color used with `window.write(x, y, ...);`
    public bg defaultBackground = bg(Color.black_dark);

    //all cells which can be written to, and backbuffer
    private Cell[][] _cells, _backbuffer;
}

///
struct Cell
{
    ///character
    char character;
    ///foreground color
    fg foreground;
    ///background color
    bg background;
}

/**
 * All colors
 *
 * Example:
 * --------------------
 * //Available colors:
 * black
 * black_dark
 * blue
 * blue_dark
 * cyan
 * cyan_dark
 * green
 * green_dark
 * magenta
 * magenta_dark
 * red
 * red_dark
 * white
 * white_dark
 * yellow
 * yellow_dark
 * --------------------
 */
enum Color
{
    black   = 0,
    red     = 1,
    green   = 2,
    yellow  = 3,
    blue    = 4,
    magenta = 5,
    cyan    = 6,
    white   = 7,

    black_dark   = 8,
    red_dark     = 9,
    green_dark   = 10,
    yellow_dark  = 11,
    blue_dark    = 12,
    magenta_dark = 13,
    cyan_dark    = 14,
    white_dark   = 15,
}

/**
 * Definition of a foreground color.
 * Example:
 * ---
 * window.write(0,0, fg(Color.red), "item");
 * ---
 */
struct fg
{
    mixin ColorTemplate;
}

/**
 * Definition of a background color.
 * Example:
 * ---
 * window.write(0,0, bg(Color.whites), "item");
 * ---
 */
struct bg
{
    mixin ColorTemplate;
}

///both `fg` and `bg` work the same way. this is not not have duplicate code :)
private template ColorTemplate()
{
    this(Color c)
    {
        color = c;
    }

    Color color;
    alias color this;
}
