module scone.window;

import color;
import os_independent;

import std.stdio : write, writef, writeln, writefln;

///
struct Window
{
    this(uint width, uint height)
    {
        OSIndependent.init();

        cursorVisible = false;

        _cells = new Cell[][](height, width);
        _backbuffer = new Cell[][](height, width);
        foreach(n; 0 .. height)
        {
            _cells[n][] = Cell(' ');
        }

        clear();
    }

    ~this()
    {
        OSIndependent.deinit();
        OSIndependent.cursorVisible = true;
        OSIndependent.setCursor(0,0);
    }

    //TODO
    auto print()
    {
        version(Windows)
        {
            import win_console : win_writeCell;

            foreach(cy, ref row; _cells)
            {
                foreach(cx, ref cell; row)
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
            import posix_terminal : posix_setCursor;

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
                posix_setCursor(f, sy);

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
        OSIndependent.title(title);
    }

    auto cursorVisible(bool visible) @property
    {
        OSIndependent.cursorVisible(visible);
    }

    void windowSize(uint width, uint height)
    {
        
    }

    auto windowSize()
    {
        return OSIndependent.windowSize();
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