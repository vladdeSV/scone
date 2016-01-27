module scone.frame;

import scone.core;
import scone.window;
import std.algorithm : max, min;
import std.array : insertInPlace;
import std.conv : to, text;
import std.format : format;
import std.stdio;
import std.string : wrap, strip;
import std.traits : isArray, isSomeString;
import std.uni : isWhite;
public import scone.utility;
public import std.experimental.logger;

/**
 * Universal enum to do certain operations.
 *
 * As it is less than 1, it is used to set dynamic width and height for windows.
 * Examples:
 * --------------------
 * auto window = new Window(UNDEF, 20);
 * --------------------
 * Will probable be used sometime more in the future
 */
enum UNDEF = -1;

/**
 * Writable area
 */
struct Frame
{
    //@nogc: //In the future, make entire Window @nogc
    @disable this();
    @disable this(this);

    /**
     * Main window constructor.
     * Params:
     *   width  = Width of the main window. If less than 1, get set to the consoles width (in slots)
     *   height = Height of the main window. If less than 1, get set to the consoles height (in slots)
     *
     * If the width or height exceeds the consoles width or height, the program errors.
     *
     * Examples:
     * --------------------
     * //Creates a dynamically sized main window, where the size is determined by the console/terminal window width and height
     * Window window = new Window(); //The main window
     * --------------------
     *
     * Examples:
     * --------------------
     * //The width is less than one, meaning it get dynamically set to the consoles
     * Window window = new Window(0, 20); //Main window, with the width of the console/terminal width, and the height of 20
     * --------------------
     *
     * Standards: width = 80, height = 24
     */
    this(int width = 0, int height = 0, Slot[] border = null)
    in
    {
        auto size = windowSize;
        sconeCrash(width > size[0] || height > size[1], "Window is too small. Minimum size needs to be %sx%s slots, but window size is %sx%s", width, height, size[0], size[1]);
    }
    body
    {
        auto size = windowSize;
        if(width  < 1) width  = size[0];
        if(height < 1) height = size[1];

        m_w = width;
        m_h = height;
        m_border = border;
        m_visible = true;
        m_translucent = true;

        m_slots = new Slot[][](height, width);
        m_backbuffer = new Slot[][](height, width);

        foreach(n, ref row; m_slots)
        {
            row = m_slots[n][] = Slot(' ');
        }

        //NOTE: Can I do this in a cleaner way?
        m_canavas = new Slot[][](height - (2 * border.length), width - (2 * border.length));
        foreach(n, ref row; m_canavas)
        {
            row = m_slots[border.length + n][border.length .. width - border.length];
        }

        //Add border
        //FIXME: Remove `_reverse` below to see a problem. Optimize
        foreach_reverse(n, slot; border)
        {
            foreach(ry; 0 .. height)
            {
                foreach(rx; 0 .. width)
                {
                    if(ry == n || ry == height - n - 1 || rx == n || rx == width - n - 1)
                    {
                        m_slots[ry][rx] = slot;
                    }
                }
            }
        }
    }

    /**
     * Writes whatever is thrown into the parameters onto the window
     * Examples:
     * --------------------
     * window.write(10,15, fg.red, bg.green, 'D'); //Writes a 'D' colored RED with a GREEN background.
     * window.write(10,16, fg.red, bg.white, "scon", fg.blue, 'e'); //Writes "scone" where "scon" is YELLOW with WHITE background and "e" is RED with WHITE background.
     * window.write(10,17, bg.red, fg.blue);
     * window.write(10,17, bg.white, fg.green); //Changes the slots' color to RED and the background to WHITE.
     *
     * window.write(10,18, 'D', bg.red); //Watch out: This will print "D" with the default color and the default background-color.
     * --------------------
     * Note: Using Unicode character may not work as expected, due to different operating systems may not handle Unicode correctly.
     * Note: Writing arrays has been explicitly been disabled.
     */
    auto write(Args...)(int col, int row, Args args)
    {
        //Check if writing outside border
        if(col < 0 || row < 0 || col > w || row > h)
        {
            log(format("Warning: Cannot write at (%s, %s). x must be between 0 <-> %s, y must be between 0 <-> %s"), col, row, w, h);
            return;
        }

        Slot[] slots;
        fg foreground = fg.white;
        bg background = bg.black;

        bool unsetColors;
        foreach (arg; args)
        {
            static if(!isSomeString!(typeof(arg)) && isArray!(typeof(arg))){
                log("Can not write arrays (yet)... Sorry!");
                continue;
            }
            else static if(is(typeof(arg) == fg))
            {
                foreground = arg;
                unsetColors = true;
            }
            else static if(is(typeof(arg) == bg))
            {
                background = arg;
                unsetColors = true;
            }
            else static if(is(typeof(arg) == Slot))
            {
                slots ~= arg;
                unsetColors = false;
            }
            else
            {
                foreach(c; to!string(arg))
                {
                    slots ~= Slot(c, foreground, background);
                }
                unsetColors = false;
            }
        }

        //If the last argument(s) are/is a color, warn
        if(slots.length && unsetColors)
        {
            log("Warning: The last argument(s) in ", args, " are/is a color, which will not be set!");
        }

        if(!slots.length)
        {
            m_canavas[row][col].foreground = foreground;
            m_canavas[row][col].background = background;
        }
        else
        {
            //This part is annoying to understand. Not even I know exactly what I've written
            //Don't mess with this part. Don't touch it.

            Slot nls = Slot('\n');
            char[] chars;

            int usableWidth = to!int(w - col - m_border.length * 2);

            int charactersSinceLastWhitespace, put;
            foreach(n, slot; slots)
            {
                if(isWhite(slot.character))
                {
                    charactersSinceLastWhitespace = 0;
                }

                if(charactersSinceLastWhitespace >= usableWidth - 1)
                {
                    slots.insertInPlace(n + put, nls);
                    ++put;
                    charactersSinceLastWhitespace = 0;
                }

                ++charactersSinceLastWhitespace;
            }

            chars.length = slots.length;
            foreach(n, slot; slots)
            {
                chars[n] = slot.character;
            }

            chars = strip(wrap(chars, usableWidth, null, null, 0));

            foreach(n, c; chars)
            {
                if(c == '\n')
                {
                    slots[n] = nls;
                }
            }

            int wx, wy;
            foreach(n, slot; slots)
            {
                if(slot.character == '\n')
                {
                    ++wy;
                    wx = 0;
                    continue;
                }

                if(row + wy >= h)
                {
                    log("Warning: Cut of:\n", chars[n .. $], "\n");
                    break;
                }

                m_canavas[row + wy][col + wx] = slot;
                ++wx;
            }
        }
    }

    /** Prints all the windows in the correct order */
    auto print()
    in
    {
        //Makes sure the window isn't resized to a smaller size than the game.
        //TODO: Make a test to see how performance heavy this is (probably not that much)
        auto a = windowSize();
        sconeCrash(a[0] < w || a[1] < h, "The window is smaller than the window");
    }
    body
    {
        version(Windows)
        {
            foreach(sy, row; m_slots)
            {
                foreach(sx, slot; row)
                {
                    if(slot != m_backbuffer[sy][sx])
                    {
                        writeSlot(sx,sy, slot);
                        m_backbuffer[sy][sx] = slot;
                    }
                }
            }
        }
        else version(Posix)
        {
            //Temporary string that will be printed out for each line.
            string printed;
            //Loop through all rows.
            foreach (sy, row; m_slots)
            {
                int f = UNDEF, l;
                foreach(sx, slot; m_slots[sy])
                {
                    if(slot != m_backbuffer[sy][sx])
                    {
                        if(f == UNDEF)
                        {
                            f = to!int(sx);
                        }

                        l = to!int(sx);

                        m_backbuffer[sy][sx] = slot;
                    }
                }

                if(f == UNDEF)
                {
                    continue;
                }

                //Loop from the first changed slot to the last edited slot.
                foreach (px; f .. l + 1)
                {
                    printed ~= text("\033[", 0, ";", cast(int)m_slots[sy][px].foreground, ";", cast(int)m_slots[sy][px].background, "m", m_slots[sy][px].character, "\033[0m");
                }

                //Set the cursor at the firstly edited slot...
                setCursor(f, to!int(sy));
                //...and then print out the string.
                std.stdio.write(printed);

                //Reset 'printed'.
                printed = null;
            }
            //Flush. Without this problems may occur.
            stdout.flush(); //TODO: Check if I need this for POSIX. I know this caused a lot of problems on the Windows console, but you know... this part is POSIX only
        }
    }

    ///** Draws a rectangle of slots */
    //auto drawRectangle(int left, int top, int width, int height, Slot slot)
    //{
    //    foreach(qy; top .. top + height)
    //    {
    //        foreach(qx; left .. left + height)
    //        {
    //            this.write(qx, qy, slot);
    //        }
    //    }
    //}

    //Sets all drawable tiles to be blank
    auto clear()
    {
        foreach(ref row; m_canavas)
        {
            row[] = Slot(' ');
        }
    }

    //Prints out all tiles.
    auto flush()
    {
        foreach(ref row; m_backbuffer)
        {
            row[] = Slot(' ');
        }
    }

    @property @nogc pure nothrow
    {
        alias width = w;
        alias height = h;

        const
        {

            /** Get the width of the window */
            auto w()
            {
                return m_w;
            }
            /** Get the height of the window */
            auto h()
            {
                return m_h;
            }
        }

        /** Set the width of the window */
        auto w(int w)
        {
            return m_w = w;
        }

        /** Set the height of the window */
        auto h(int h)
        {
            return m_h = h;
        }
    }

    /**
     * Returns: slot at the specific x and y coordinates
     */
    auto getSlot(int x, int y)
    {
        return m_slots[y][x];
    }

    private:
    //Forgive me for using C++ naming style
    int m_x, m_y;
    int m_w, m_h;
    bool m_visible, m_translucent;
    Slot[] m_border;
    Slot[][] m_slots, m_canavas, m_backbuffer;
}

//Do not delete:
//hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle
