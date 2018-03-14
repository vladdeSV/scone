module scone.window;

import scone.input;
import scone.os;

import std.algorithm : min;
import std.conv : text, to;
import std.stdio : stdout, writef;

///
struct Window
{
    /// Settins for the window
    public Settings settings;

    ///initializes the window.
    this(in size_t width, in size_t height)
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
        // Check if writing outside border (assuming we only write right-to-left)
        if(x >= this.width() || y >= this.height())
        {
            //logf("Warning: Cannot write at (%s, %s). x must be less than or equal to %s, y must be less than or equal to%s", x, y, w, h);
            return;
        }

        // Everything that will be written to the window's internal memory
        Cell[] cells;

        fg foreground = this.settings.defaultForeground;
        bg background = this.settings.defaultBackground;

        // Flag to warn if color arguments will not be written
        foreach(ref arg; args)
        {
            static if(is(typeof(arg) == fg))
            {
                foreground = arg;
            }
            else static if(is(typeof(arg) == bg))
            {
                background = arg;
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
            }
            else
            {
                foreach(c; to!string(arg))
                {
                    cells ~= Cell(c, foreground, background);
                }
            }
        }

        // If there are cells to write, and the last argument is a color, warn
        auto lastArgument = args[$-1];
        if(cells.length && (is(typeof(lastArgument) == fg) || is(typeof(lastArgument) == bg)))
        {
            //logf("Warning: The last argument in %s is a color, which will not be set!", args);
        }

        // If only colors were provided, just update the colors
        if(!cells.length)
        {
            _cells[y][x].foreground = foreground;
            _cells[y][x].background = background;
            return;
        }

        // Some hokus pokus to store stuff into memory
        // write x, write y
        int wx, wy;
        foreach(ref cell; cells)
        {
            // If a newline character is present, increase the write y and set write x to zero
            if(cell.character == '\n')
            {
                wx = 0;
                ++wy;
                continue;
            }

            // Make sure we are writing inside the buffer
            if(x + wx >= 0 && y + wy >= 0 && x + wx < _cells[0].length && y + wy < _cells.length)
            {
                _cells[y + wy][x + wx] = cell;
            }

            ++wx;
        }
    }

    ///Displays what has been written
    auto print()
    {
        int[2] windowSize = OS.size;
        int[2] bufferSize = this.size;

        // If the window has changed size, resize the the screen depending on the settings. If `this.settings.fixedSize` is true, keep the window at the same size as the buffre, else resize the buffer to the window size
        if(bufferSize != windowSize)
        {
            if(this.settings.fixedSize)
            {
                OS.setCursor(0,0);
            }
            else
            {
                this.resize(windowSize[0], windowSize[1]);
            }
        }

        //windows version, using winapi (super fast)
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
            // If fixed size setting is set, and the border character is not `char(0)`
            if(this.settings.fixedSize && this.settings.fixedSizeBorder.character != char(0))
            {
                if(windowSize[0] < bufferSize[0])
                {
                    foreach(int cy; 0 .. windowSize[1])
                    {
                        this.write(cast(int)(windowSize[0] - 1), cy, bg(Color.red), ' ');
                    }
                }

                if(windowSize[1] < bufferSize[1])
                {
                    foreach(int cx; 0 .. windowSize[0])
                    {
                        this.write(cx, cast(int)(windowSize[1] - 1), bg(Color.red), ' ');
                    }
                }
            }

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

                //Set the cursor at the firstly edited cell... (POSIX magic)
                OS.Posix.setCursor(firstChanged + 1, to!uint(sy));

                //...and then print out the string via the regular write function.
                writef(printed);

                //Reset 'printed'.
                printed = null;
            }

            // Flush. Without this "problems" may occur.
            stdout.flush();
        }
    }

    ///Clear the screen, making it ready for the next `print();`
    auto clear()
    {
        foreach(ref y; _cells)
        {
            y[] = Cell(' ', this.settings.defaultForeground, this.settings.defaultBackground);
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

    /**
     * Get the size of the current window buffer
     * Return: int[2], [width, height];
     */
    auto size() @property
    {
        return to!(int[2])([_cells[0].length, _cells.length]);
    }

    ///Changes the size of the window
    ///NOTE: (POSIX) Does not work if terminal is maximized
    ///NOTE: Clears the buffer
    auto resize(in size_t width, in size_t height)
    {
        // Resize the screen
        OS.resize(width, height);

        _cells = new Cell[][](height, width);
        _backbuffer = new Cell[][](height, width);

        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ', this.settings.defaultForeground, this.settings.defaultBackground);
        }
    }

    /// Reposition the window.
    auto reposition(in size_t x, in size_t y)
    {
        OS.reposition(x,y);
    }

    /// Get the internal width of the window
    alias w = width;
    ///
    auto width()
    {
        //return to!int(this.size[0]);
        return to!int(_cells[0].length);
    }

    /// Get the internal height of the window
    alias h = height;
    ///
    auto height()
    {
        //return to!int(this.size[1]);
        return to!int(_cells.length);
    }

    // All cells which can be written to.
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

private struct Settings
{
    /// If the window buffer always should stay the same
    bool fixedSize = false;
    /**
     * The fixed window border (when the window is smaller than the buffer).
     * If the char is `char(0)`, no border is printed
     */
    Cell fixedSizeBorder = Cell(' ', fg(Color.white), bg(Color.red));

    /// The default foreground color used with `window.write(x, y, ...);`
    fg defaultForeground = fg(Color.white_dark);
    /// The default background color used with `window.write(x, y, ...);`
    bg defaultBackground = bg(Color.black_dark);


}
