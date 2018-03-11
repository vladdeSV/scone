module scone.window;

import scone.input;
import scone.os;

import std.algorithm : min;
import std.conv : text, to;
import std.stdio : stdout, writef;

///
struct Window
{
    ///initializes the window.
    ///NOTE: should only be used once. use `size(w,h);` to resize
    this(in int width, in int height)
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
    auto write(Args...)(in int x, in int y, Args args)
    {
        // Check if writing outside border
        if(x >= this.width() || y >= this.height())
        {
            //logf("Warning: Cannot write at (%s, %s). x must be less than or equal to %s, y must be less than or equal to%s", x, y, w, h);
            //return;
        }

        // Everything which will be written to the window's internal memory
        Cell[] cells;

        fg foreground = defaultForeground;
        bg background = defaultBackground;

        // Flag to warn if color arguments will not be written
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

        // If there are cells to write, and the last argument is a color, warn
        if(cells.length && unsetColors)
        {
            //logf("Warning: The last argument in %s is a color, which will not be set!", args);
        }

        // If only colors were provided, just update the colors
        if(!cells.length)
        {
            _cells[y][x].foreground = foreground;
            _cells[y][x].background = background;
        }
        else
        {
            // Some hokus pokus to store stuff into memory
            int wx, wy;
            foreach(ref cell; cells)
            {
                if(x + wx >= this.width() || cell.character == '\n')
                {
                    wx = 0;
                    ++wy;
                    continue;
                }
                else
                {
                    if(x + wx >= 0 && y + wy >= 0)
                    {
                        _cells[y + wy][x + wx] = cell;
                    }

                    ++wx;
                }
            }
        }
    }

    ///Displays what has been written
    auto print()
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

        // A different method printing is used for POSIX
        // This method is built upon optimizing a string being printed
        version(Posix)
        {
            // simple flag if row is unaffected
            enum rowUnchanged = -1;

            // Temporary string that will be printed out for each line.
            string printed;

            // Loop through all rows.
            foreach (sy, y; _cells)
            {
                if(sy >= OS.Posix.size[1])
                {
                    break;
                }

                // first modified cell, last modified cell
                uint firstChanged = rowUnchanged, lastChanged;

                // Go through all cells of every line
                // Find first modified cell
                foreach(sx, cell; _cells[sy])
                {
                    //If backbuffer says something has changed
                    if(_backbuffer[sy][sx] != cell)
                    {
                        firstChanged = to!uint(sx);
                        break;
                    }
                }

                // If no cell on this line has been modified, continue
                // If first changed cell it outside the window border, continue
                if(firstChanged == rowUnchanged || firstChanged >= OS.Posix.size[0])
                {
                    continue;
                }

                //Now loop backwards to find the last modified cell
                foreach_reverse(sx, cell; _cells[sy])
                {
                    //If backbuffer says something has changed
                    if(_backbuffer[sy][sx] != cell)
                    {
                        lastChanged = to!uint(sx);
                        break;
                    }
                }

                // If last changed cell it outside the window border, set last changed cell to the window width
                lastChanged = min(lastChanged, OS.Posix.size[0] - 1);

                // Loop from the first changed cell to the last edited cell.
                foreach (px; firstChanged .. lastChanged + 1)
                {
                    // To save excecution time, check if the prevoisly printed
                    // chracter has the same attributes as the current one being
                    // printed. If so, simply write the new character instead of
                    // executing ANSI commands.
                    if
                    (
                        px == firstChanged ||
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
                OS.Posix.setCursor(firstChanged + 1, to!uint(sy));

                //...and then print out the string via the regular write function.
                writef(printed);

                //Reset 'printed'.
                printed = null;
            }

            //Flush. Without this problems may occur.
            stdout.flush(); //TODO: Check if needed for POSIX. I know without this it caused a lot of problems on the Windows console, but you know... this part is POSIX only
        }
    }

    ///Clear the screen, making it ready for the next `print();`
    auto clear()
    {
        foreach(ref y; _cells)
        {
            y[] = Cell(' ', defaultForeground, defaultBackground);
        }
    }

    ///Causes next `print()` to write out all cells.
    ///NOTE: Only use this if some sort of visual bug occurs.
    auto flush()
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
    auto getInputs()
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

    /// Set the size of the window
    auto title(in string title) @property
    {
        OS.title(title);
    }

    /// Set if the cursor should be visible
    auto cursorVisible(in bool visible) @property
    {
        OS.cursorVisible(visible);
    }

    ///Changes the size of the window
    ///NOTE: (POSIX) Does not work if terminal is maximized
    ///NOTE: Clears the buffer
    auto resize(in size_t width, in size_t height)
    {
        OS.resize(width, height);

        _cells = new Cell[][](height, width);
        _backbuffer = new Cell[][](height, width);

        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ', defaultForeground, defaultBackground);
        }
    }

    /// Reposition the window.
    auto reposition(in size_t x, in size_t y)
    {
        OS.reposition(x,y);
    }

    /// Get the width of the window
    auto width()
    {
        return to!int(_cells[0].length);
    }

    /// Get the height of the window
    auto height()
    {
        return to!int(_cells.length);
    }

    ///
    alias w = width;
    ///
    alias h = height;

    /// The default foreground color used with `window.write(x, y, ...);`
    public fg defaultForeground = fg(Color.white_dark);
    /// The default background color used with `window.write(x, y, ...);`
    public bg defaultBackground = bg(Color.black_dark);

    // All cells which can be written to;
    private Cell[][] _cells;
    // Backbuffer, storing the last printed cells. Used to compare against
    // when printing to optimize
    private Cell[][] _backbuffer;
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
 * black      //dark grey
 * black_dark //black
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
 * white      //white
 * white_dark //light grey
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
