module scone.window;

struct Window
{
    this(uint width, uint height)
    {
        _cells = new Cell[][](width, height);
        _backbuffer = _cells;

        clear();
    }

    //TODO
    auto print()
    {
        clear();
        
        version(Windows)
        {
            foreach(cy, ref row; _cells)
            {
                foreach(cx, ref cell; row)
                {
                    if(cell != _backbuffer[cy][cx])
                    {
                        //TODO: writecell(cx, cy, cell);
                        _backbuffer[cy][cx] = cell;
                    }
                }
            }
        }

        version(Posix)
        {
            enum rowUnchanged = -1;
            import std.conv : to, text;

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
                    printed ~= text("\033[", 0, ";", cast(int)(_cells[sy][px].foreground), ";", cast(int)(_cells[sy][px].background + 10), "m", _cells[sy][px].character, "\033[0m");
                }

                //Set the cursor at the firstly edited cell...
                setCursor(f, to!uint(sy));
                //...and then print out the string via the terminals write function.
                std.stdio.write(printed);

                //Reset 'printed'.
                printed = null;
            }

            //Flush. Without this problems may occur.
            //stdout.flush(); //TODO: Check if needed for POSIX. I know without this it caused a lot of problems on the Windows console, but you know... this part is POSIX only
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

    private auto clear()
    {
        foreach(ref row; _cells)
        {
            row[] = Cell(' ');
        }
    }

    private Cell[][] _cells, _backbuffer;
}

struct Cell
{
    //character
    char character;
    //foreground color
    /*fg*/ uint foreground; //= fg(Color.white_dark);
    //background color
    /*bg*/ uint background; //= bg(Color.black_dark);
}