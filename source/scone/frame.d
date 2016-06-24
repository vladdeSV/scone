module scone.frame;

import scone.core;
import scone.window;
import scone.utility;
import scone.color;
import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.stdio;
import std.string;
import std.traits;
import std.uni;

/**
 * Writable area
 */
class Frame
{
    alias width  = w;
    alias height = h;

    //@nogc: //In the future, make entire Frame @nogc

    /**
     * Main frame constructor.
     * Params:
     *   width  = Width of the main frame. If less than 1, get set to the consoles width (in slots)
     *   height = Height of the main frame. If less than 1, get set to the consoles height (in slots)
     *
     * Examples:
     * --------------------
     * //Creates a dynamically sized main frame, where the size is determined by the  window width and height
     * auto window = new Frame(); //The main frame
     *
     * //The width is less than one, meaning it get dynamically set to the consoles
     * auto window = new Frame(0, 20); //Main frame, with the width of the  width, and the height of 20
     * --------------------
     *
     * Standards: width = 80, height = 24
     *
     * If the width or height exceeds the consoles width or height, the program errors.
     */
    this(in int width = 0, in int height = 0)
    in
    {
        auto size = windowSize;
        sconeAssert(width <= size[0] && height <= size[1], "Frame is too small. Minimum size needs to be %sx%s slots, but frame size is %sx%s", width, height, size[0], size[1]);
    }
    body
    {
        auto size = windowSize;
        if(width  < 1){ _w = size[0]; } else { _w = width; }
        if(height < 1){ _h = size[1]; } else { _h = height;}

        _slots = new Slot[][](_h, _w);
        _backbuffer = new Slot[][](_h, _w);

        foreach(n, ref row; _slots)
        {
            row = _slots[n][] = Slot(' ');
        }
    }

    /**
     * Writes whatever is thrown into the parameters onto the frame
     * Examples:
     * --------------------
     * window.write(10,15, fg(Color.red), bg(Color.green), 'D'); //Writes a 'D' colored RED with a GREEN background.
     * window.write(10,16, fg(Color.red), bg(Color.white), "scon", fg(Color.blue), 'e'); //Writes "scone" where "scon" is YELLOW with WHITE background and "e" is RED with WHITE background.
     * window.write(10,17, bg(Color.red), fg(Color.blue));
     * window.write(10,17, bg(Color.white), fg(Color.green)); //Changes the slots' color to RED and the background to WHITE.
     *
     * window.write(10,18, 'D', bg(Color.red)); //Watch out: This will print "D" with the default color and the default background-color.
     * --------------------
     * Note: Using Unicode character may not work as expected, due to different operating systems may not handle Unicode correctly.
     */
    auto write(Args...)(in int col, in int row, Args args)
    {
        //Check if writing outside border
        if(col < 0 || row < 0 || col > w || row > h)
        {
            log.logf("Warning: Cannot write at (%s, %s). x must be between 0 <-> %s, y must be between 0 <-> %s", col, row, w, h);
            return;
        }

        Slot[] slots;
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

        //If the last argument is a color, warn
        if(slots.length && unsetColors)
        {
            log.logf("Warning: The last argument in %s is a color, which will not be set!", args);
        }

        if(!slots.length)
        {
            _slots[row][col].foreground = foreground;
            _slots[row][col].background = background;
        }
        else
        {
            int wx, wy;
            foreach(ref slot; slots)
            {
                if(col + wx >= w || slot.character == '\n')
                {
                    wx = 0;
                    ++wy;
                    continue;
                }
                else
                {
                    _slots[row + wy][col + wx] = slot;
                    ++wx;
                }
            }
        }
    }

    /** Prints the current frame to the console */
    auto print()
    foreach(sy, ref row; _slots)
    {
        foreach(sx, ref slot; row)
        {
            if(slot != _backbuffer[sy][sx])
            {
                writeSlot(sx,sy, slot);
                _backbuffer[sy][sx] = slot;
            }
        }
    }

    ///Sets all tiles to blank
    auto clear()
    {
        foreach(ref row; _slots)
        {
            row[] = Slot(' ');
        }
    }

    ///Causes next `print()` to write out all tiles.
    auto flush()
    {
        foreach(ref row; _backbuffer)
        {
            row[] = Slot(' ');
        }
    }

    const
    {
        /** Get the width of the frame */
        auto w() @property
        {
            return _w;
        }

        /** Get the height of the frame */
        auto h() @property
        {
            return _h;
        }

        /** Returns: Slot at the specific x and y coordinates */
        auto getSlot(in int x, in int y)
        {
            return _slots[y][x];
        }
    }

    private:
    //Forgive me for using C++ naming style
    int _w, _h;
    Slot[][] _slots, _backbuffer;
}

/**
 * Slot structure
 *
 * Examples:
 * --------------------
 * Slot slot1 = Slot('d', fg(Color.red), bg(Color.white)); //'d' character with RED foreground color and WHITE background color
 * Slot slot2 = Slot('g');
 *
 * auto window = new Frame();
 * window.write(0,0, slot1);
 * window.write(0,1, slot2);
 * --------------------
 *
 */
struct Slot
{
    char character;
    fg foreground = fg(Color.white_dark);
    bg background = bg(Color.black_dark);
}


//Do not delete:
//hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle
