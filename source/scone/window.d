module scone.window;

import scone.color;
import scone.input;
import scone.os;

import std.algorithm : min;
import std.conv : text, to;
import std.stdio : stdout, write;
import std.traits : isNumeric;
import std.experimental.logger;

///
struct Window
{
    /// Initializes the window.
    this(in uint width, in uint height)
    {
        logf("Initalize window (%dx%d)", width, height);
        // properly set the size of the console
        resize(width, height);
    }

    /**
     * Write to the internal buffer. Later on `print()` must be used to display onto the window
     * Params:
     *     tx = The x-position of where to write in the internal buffer
     *     ty = The y-position of where to write in the internal buffer
     *     args = What is to be written. Arguments will be converted to strings, except special types `foreground`, `background`, and `Cell`.
     * Example:
     * ---
     * // will display on screen "hello world 42[1337, 1001, 1]" in varied colors
     * window.write(3, 5, "hello ", Color.green.foreground, 'w', Cell('o', Color.red.foreground), "rld ", 42, [1337, 1001, 1]);
     * window.print();
     * ---
     *
     * Example:
     * ----
     * // will display "lorem" at position [x: 4, y: 3]
     * real x = 4;
     * float y = 3.84;
     * window.write(x, y, "lorem"); // `x` and `y` are trucated/converted to `int`
     * window.print();
     * ----
     * Note: Does not directly write to the window, changes will only be visible after `window.print();`
     * Note: (Authors note) When I got into D, I thought template functions were odd. So for beginners, the method can be viewed as `void write(int x, int y, arg1, arg2, ..., argN)`. The `x` and `y` arguments must be numbers, and you can enter how many arguments as you want.
     */
    auto write(X, Y, Args...)(X tx, Y ty, Args args) if (isNumeric!X && isNumeric!Y && args.length >= 1)
    {
        auto x = to!int(tx);
        auto y = to!int(ty);

        // Check if writing outside border (assuming we only write left-to-right)
        if (x >= this.width() || y >= this.height())
        {
            // logf("Cannot write at (%s, %s). x must be less than or equal to %s, y must be less than or equal to%s", x, y, w, h);
            return;
        }

        // Calculate the lenght of what is to be printed
        int counter = 0;
        foreach (arg; args)
        {
            static if (is(typeof(arg) : Color))
            {
                continue;
            }

            else static if (is(typeof(arg) == Cell))
            {
                ++counter;
                continue;
            }
            else static if (is(typeof(arg) == Cell[]))
            {
                counter += arg.length;
                continue;
            }
            else
            {
                counter += to!string(arg).length;
            }
        }

        Cell[] outputCells;
        outputCells.length = counter;

        ForegroundColor foreground = Color.same;
        BackgroundColor background = Color.same;

        int i = 0;
        foreach (arg; args)
        {
            static if (is(typeof(arg) == ForegroundColor))
            {
                foreground = arg;
            }
            else static if (is(typeof(arg) == BackgroundColor))
            {
                background = arg;
            }
            else static if (is(typeof(arg) == Cell))
            {
                outputCells[i] = arg;
                ++i;
            }
            else static if (is(typeof(arg) == Cell[]))
            {
                foreach (cell; arg)
                {
                    outputCells[i] = cell;
                    ++i;
                }
            }
            else static if (is(typeof(arg) == Color))
            {
                logf("Type `Color` passed in, which has no effect");
            }
            else
            {
                foreach (c; to!string(arg))
                {
                    outputCells[i] = Cell(c, foreground, background);
                    ++i;
                }
            }
        }

        // If there are cells to write, and the last argument is a color, warn
        auto lastArgument = args[$ - 1];
        if (outputCells.length && is(typeof(lastArgument) : Color))
        {
            logf("The last argument in %s is a color, which will not be set.", args);
        }

        // If only colors were provided, just update the colors
        if (!outputCells.length)
        {
            if (y < 0 || x < 0)
            {
                return;
            }

            if (foreground.isActualColor)
            {
                cells[y][x].foreground = foreground;
            }

            if (background.isActualColor)
            {
                cells[y][x].background = background;
            }

            return;
        }

        // Some hokus pokus to store stuff into memory
        // write x, write y
        int wx, wy;
        foreach (ref cell; outputCells)
        {
            // If a newline character is present, increase the write y and set write x to zero
            if (cell.character == '\n')
            {
                wx = 0;
                ++wy;
                if (wy >= cells.length)
                {
                    break;
                }

                continue;
            }

            // Make sure we are writing inside the buffer
            if (x + wx >= 0 && y + wy >= 0 && x + wx < cells[0].length && y + wy < cells.length)
            {
                auto cellX = x + wx;
                auto cellY = y + wy;

                if (cell.foreground == Color.same)
                {
                    cell.foreground = cells[cellY][cellX].foreground;
                }

                if (cell.background == Color.same)
                {
                    cell.background = cells[cellY][cellX].background;
                }

                cells[cellY][cellX] = cell;
            }

            ++wx;
        }
    }

    /// Displays what has been written to the internal buffer
    auto print()
    {
        // Windows version of printing, using winapi (super duper fast)
        version (Windows)
        {
            foreach (cy, ref y; cells)
            {
                foreach (cx, ref cell; y)
                {
                    if (cell != backbuffer[cy][cx])
                    {
                        WindowsOS.writeCell(cast(uint) cx, cast(uint) cy, cell);

                        // update backbuffer
                        backbuffer[cy][cx] = cell;
                    }
                }
            }
        }

        // A different method printing is used for POSIX
        // This method is built upon optimizing a string being printed
        version (Posix)
        {
            // simple flag if row is unaffected
            enum rowUnchanged = -1;

            // Temporary string that will be printed out for each line.
            string printed;

            // Loop through all rows.
            foreach (sy, y; cells)
            {
                if (sy >= PosixOS.size[1])
                {
                    break;
                }

                // first modified cell, last modified cell
                uint firstChanged = rowUnchanged, lastChanged;

                // Go through all cells of every line
                // Find first modified cell
                foreach (sx, cell; cells[sy])
                {
                    // If backbuffer says something has changed
                    if (backbuffer[sy][sx] != cell)
                    {
                        firstChanged = to!uint(sx);
                        break;
                    }
                }

                // If no cell on this line has been modified, continue
                // If first changed cell it outside the window border, continue
                if (firstChanged == rowUnchanged || firstChanged >= PosixOS.size[0])
                {
                    continue;
                }

                // Now loop backwards to find the last modified cell
                foreach_reverse (sx, cell; cells[sy])
                {
                    // If backbuffer says something has changed
                    if (backbuffer[sy][sx] != cell)
                    {
                        lastChanged = to!uint(sx);
                        break;
                    }
                }

                // If last changed cell it outside the window border, set last changed cell to the window width
                lastChanged = min(lastChanged, PosixOS.size[0] - 1);

                // Loop from the first changed cell to the last edited cell.
                foreach (px; firstChanged .. lastChanged + 1)
                {
                    // To save time spent printing, check if the prevoisly printed
                    // chracter has the same attributes as the current one being
                    // printed. If so, simply write the new character instead of
                    // executing ANSI commands.
                    if (px == firstChanged || cells[sy][px - 1].foreground != cells[sy][px].foreground || cells[sy][px - 1].background != cells[sy][px].background)
                    {
                        printed ~= text("\033[", 0, ";", PosixOS.ansiColor(cells[sy][px].foreground), ";", PosixOS.ansiColor(cells[sy][px].background) + 10, "m",);
                    }

                    printed ~= cells[sy][px].character;
                }

                // Set the cursor at the firstly edited cell... (POSIX magic)
                PosixOS.setCursor(firstChanged + 1, to!uint(sy));

                static import std.stdio;

                //...and then print out the string via the regular write function.
                std.stdio.write(printed);

                // Reset 'printed'.
                printed = null;
            }

            // Flush. Without this "problems" may occur.
            stdout.flush();
        }
    }

    /**
     * Clears the internal buffer.
     * Example:
     * ---
     * while(running)
     * {
     *     window.clear();
     *     window.write(x,y,arguments);
     *     window.print();
     * }
     * ---
     */
    auto clear()
    {
        foreach (ref y; cells)
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
        return OS.retreiveInputs();
    }

    /// Set the title of the window
    auto title(in string title) @property
    {
        OS.title = title;
    }

    /// Set if the cursor should be visible
    auto cursorVisible(in bool visible) @property
    {
        OS.cursorVisible = visible;
    }

    /**
     * Get the size of the current window buffer
     * Return: int[2], [width, height];
     */
    auto size() @property
    {
        return to!(uint[2])([cells[0].length, cells.length]);
    }

    /**
     * Changes the size of the window
     * Note: (POSIX) Does not work if terminal is maximized
     * Note: Clears the internal buffer, menaing everything needs to be redrawn
     */
    auto resize(in uint width, in uint height)
    {
        // Resize the screen
        OS.resize(width, height);

        cells = new Cell[][](height, width);
        backbuffer = new Cell[][](height, width);

        foreach (n; 0 .. height)
        {
            cells[n][] = Cell(' ', this.settings.defaultForeground, this.settings.defaultBackground);
        }
    }

    /// Reposition the window on the monitor
    auto reposition(X, Y)(X tx, Y ty) if (isNumeric!X && isNumeric!Y)
    {
        auto x = to!int(tx);
        auto y = to!int(ty);

        OS.reposition(x, y);
    }

    /// Get the internal width of the window
    auto width()
    {
        return to!int(cells[0].length);
    }
    /// ditto
    alias w = width;

    /// Get the internal height of the window
    auto height()
    {
        return to!int(cells.length);
    }
    /// ditto
    alias h = height;

    /// Settings for the window
    public Settings settings;

    // All cells which can be written to.
    private Cell[][] cells;

    // Backbuffer, storing the last printed cells. Used to compare against when printing to optimize
    private Cell[][] backbuffer;
}

///
struct Cell
{
    /// The character of the cell
    char character;
    /// The foreground color
    ForegroundColor foreground;
    /// The background color
    BackgroundColor background;
}

private struct Settings
{
    /// If the window buffer always should stay the same
    bool fixedSize = false;

    /// The default foreground color used with `window.write(x, y, ...);`
    ForegroundColor defaultForeground = Color.whiteDark.foreground;

    /// The default background color used with `window.write(x, y, ...);`
    BackgroundColor defaultBackground = Color.blackDark.background;
}
