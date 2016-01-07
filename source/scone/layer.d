module scone.layer;

import scone.window;
import scone.utility;
import std.format : format;
import std.conv : to;
import std.array : insertInPlace;
import std.string : wrap, strip;
import std.uni : isWhite;
import std.traits : isArray;
import std.experimental.logger;

/**
 * Universal enum to do certain operations.
 *
 * As it is less than 1, it is used to set dynamic width and height for layers.
 * Examples:
 * --------------------
 * auto layer = new Layer(UNDEF, 20);
 * --------------------
 *
 */
enum UNDEF = -1;

/**
 * Slot structure
 *
 * Examples:
 * --------------------
 * Slot slot1 = Slot('d', fg.red, bg.white); //'d' character with RED foreground color and WHITE background color
 * Slot slot2 = Slot('g'); //'g' character with WHITE foreground color and BLACK background color
 *
 * auto layer = new Layer();
 * layer.write(0,0, slot1);
 * layer.write(0,1, slot2);
 * --------------------
 *
 */
struct Slot
{
    char character;
    fg foreground = fg.white;
    bg background = bg.black;
}

/**
 * Layer class
 */
class Layer
{
    //@nogc: //In the future, make entire Layer @nogc


    /**
     * Main layer constructor.
     * Params:
     *   width  = Width of the main layer. If less than 1, get set to the consoles width (in slots)
     *   height = Height of the main layer. If less than 1, get set to the consoles height (in slots)
     *
     * If the width or height exceeds the consoles width or height, the program errors.
     *
     * Examples:
     * --------------------
     * //Creates a dynamically sized main layer, where the size is determined by the console/terminal window width and height
     * Layer window = new Layer(); //The main layer
     * --------------------
     *
     * Examples:
     * --------------------
     * //The width is less than one, meaning it get dynamically set to the consoles
     * Layer window = new Layer(0, 20); //Main layer, with the width of the console/terminal width, and the height of 20
     * --------------------
     *
     * Standards: width = 80, height = 24
     */
    this(int width = 0, int height = 0/*, Slot[] border = null*/)
    {
        auto size = windowSize;

        if(width > size[0] || height > size[1])
            assert(0, format("\n\nWindow is too small. Minimum size needs to be %sx%s slots, but window size is %sx%s\n", width, height, size[0], size[1]));

        if(width  < 1) width  = size[0];
        if(height < 1) height = size[1];

        init(null, 0, 0, width, height/*, border*/);
    }

    /**
     * Sublayer constructor.
     * Params:
     *   parent = Parent layer.
     *   x =      X position inside the parent
     *   y =      Y position inside the parent
     *   width =  Width of the sublayer. If less than 1, set to parent width.
     *   height = Height of the sublayer If less than 1, set to parent width.
     *   border = Array of `Slot`, where the first slot represents the outmost border row, and the last represents the innermost.
     *
     * Examples:
     * --------------------
     * Layer window = new Layer(); //Main layer
     * //Creates a sublayer to `window`
     * Layer layer = new Layer(window, 1, 1, 20, 10); //Creates a sub-layer at position (1, 1) inside `window`, and with the width = 20, height = 10
     * --------------------
     *
     * Errors on: If (width - border.length) is smaller than 0, or if (height - border.length) is smaller than 0.
     */
    this(Layer parent, int x, int y, int width = 0, int height = 0, Slot[] border = null)
    in
    {
        assert(parent !is null, "\n\nLayer parent can not be null!\n");
        assert(width  - border.length*2 > 0, "\n\nThe border is too thick for the width. There are no available slots in the layer.\n");
        assert(height - border.length*2 > 0, "\n\nThe border is too thick for the height. There are no available slots in the layer.\n");
    }
    body
    {
        if(width < 1)  width  = parent.w;
        if(height < 1) height = parent.h;

        parent.addLayer(this);
        init(parent, x, y, width, height, border);
    }

    /**
     * Writes whatever is thrown into the parameters onto the layer
     * Examples:
     * --------------------
     * layer.write(10,15, fg.red, bg.green, 'D'); //Writes a 'D' colored RED with a GREEN background.
     * layer.write(10,16, fg.red, bg.white, "scon", fg.blue, 'e'); //Writes "scone" where "scon" is YELLOW with WHITE background and "e" is RED with WHITE background.
     * layer.write(10,17, bg.red, fg.blue);
     * layer.write(10,17, bg.white, fg.green); //Changes the slots' color to RED and the background to WHITE.
     *
     * layer.write(10,18, 'D', bg.red); //Watch out: This will print "D" with the default color and the default background-color.
     *
     * --------------------
     * Note: Using Unicode character may not work as expected, due to different operating systems may not handle Unicode correctly.
     * Note: Expect unexpected behavior when sending in arrays.
     * Throws: RangeViolation if string is unwrap-able.
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

            Slot nls = Slot('\n');
            char[] chars;

            int usableWidth = w - col - m_border.length * 2;

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

    /** Draws a rectangle of slots */
    auto drawRectangle(int left, int top, int width, int height, Slot slot)
    {
        foreach(qy; top .. top + height)
        {
            foreach(qx; left .. left + height)
            {
                write(qx, qy, slot);
            }
        }
    }

    /** Grabs all slots of the layer and all sub-layers merged as one layer */
    Slot[][] snap()
    {
        foreach(sublayer; m_sublayers)
        {
            if(!sublayer.m_visible)
            {
                continue;
            }

            auto sublayerSlots = sublayer.snap();

            foreach(ly, row; sublayerSlots)
            {
                foreach(lx, slot; row)
                {
                    if(sublayer.x + lx < x || sublayer.x + lx > x + w || sublayer.y + ly < y || sublayer.y + ly > y + h)
                    {
                        continue;
                    }
                    m_slots[sublayer.y + ly][sublayer.x + lx] = slot;
                }
            }
        }

        return m_slots;
    }

    /** Prints all the layers in the correct order */
    auto print()
    {
        snap();

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
            /** Get the x position of the layer */
            auto x()
            {
                return m_x;
            }

            /** Get the y position of the layer */
            auto y()
            {
                return m_y;
            }

            /** Get the z level of the layer */
            auto z()
            {
                if(m_parent !is null)
                {
                    //Loop through all sub layers.
                    foreach (n, change; m_parent.m_sublayers)
                    {
                        if(this is change)
                        {
                            //If this layer matches a layer in the parent's list of m_sublayers, then get the position.
                            return n;
                        }
                    }

                }
                //The layer is the main window
                return UNDEF;
            }

            /** Get the width of the layer */
            auto w()
            {
                return m_w;
            }
            /** Get the height of the layer */
            auto h()
            {
                return m_h;
            }
        }

        /** Set the x position of the layer */
        auto x(int x) @property
        {
            return m_x = x;
        }

        /** Set the y position of the layer */
        auto y(int y) @property
        {
            return m_y = y;
        }

        /** Set the width of the layer */
        auto w(int w) @property
        {
            return m_w = w;
        }

        /** Set the height of the layer */
        auto h(int h) @property
        {
            return m_h = h;
        }

        const
        {
            /**
             * Returns: slot at the specific x and y coordinates
             */
            auto getSlot(int x, int y)
            {
                return m_slots[y][x];
            }
        }
    }

        /** Moves a layer to the front */
    auto moveLayerToFront(Layer layer)
    {
        moveLayer(layer, cast(int)m_sublayers.length);
    }

    /** Moves a layer to the back */
    auto moveLayerToBack(Layer layer)
    {
        moveLayer(layer, -cast(int)m_sublayers.length);
    }

    /** Moves a layer forward `amount` amount of times */
    auto moveLayerForward(Layer layer, int amount = 1)
    {
        moveLayer(layer, amount);
    }

    /** Moves a layer backwards `amount` amount of times */
    auto moveLayerBackward(Layer layer, int amount = 1)
    {
        moveLayer(layer, -amount);
    }

    /** Moves a layer forwards or backwards. If amount > 0, then move forwards, else move backwards */
    auto moveLayer(Layer layer, int amount)
    in
    {
        assert(layer.m_parent is this, "\n\nSublayer must be moved via parent");
    }
    body
    {
        //If we're not supposed to move anything, just staph
        if(!amount)
            return;
        //If we're moving this a positive amount, it's forward. Otherwise backwards.
        bool forwards;
        if(amount > 0) //If we're moving a positive amount...
        {
            //...then we're moving forward.
            forwards = true;
        }
        else
        {
            amount = -amount; //If we're moving backwards, then the amount is negative. And the fancy stuff below assumes the amount is positive, so we simply invert the negative.
        }
        //Get our current position in our parent's list of sub layers
        int currentPosition = layer.z;
        //In case the layer wasn't found, just staph. This should never happen.
        if(currentPosition == UNDEF)
        {
            assert(0, "Something has gone wrong, real bad. A sublayer does not have a parent");
        }
        //Depending on if we want to move backwards or forwards, do different things.
        if(forwards)
        {
            //Check of amount goes of bounds. If so, get the length of m_sublayers
            auto to = min(m_sublayers.length - 1, currentPosition + amount);
            //Create a slice with layer at the end and the others sub layers before, and then set the slice in parent.m_sublayers[].
            m_sublayers[currentPosition .. to + 1] = m_sublayers[currentPosition + 1 .. to + 1] ~ layer;
        }
        else
        {
            //Check if amount goes of bounds. If so, simply set to 0.
            auto from = max(0, currentPosition - amount);
            //Create a slice with layer at the start, and the others after.
            Layer[] mv = layer ~ m_sublayers[from .. currentPosition];
            //Override the slice in parent.m_sublayers[].
            m_sublayers[from .. currentPosition + 1] = mv;
        }
    }

    private:
    //Forgive me for using C++ naming style
    Layer m_parent;
    Layer[] m_sublayers;
    int m_x, m_y;
    int m_w, m_h;
    bool m_visible, m_translucent;
    Slot[] m_border;
    Slot[][] m_slots, m_canavas, m_backbuffer;

    auto init(Layer parent, int x, int y, int width, int height, Slot[] border = null)
    {
        m_parent = parent;
        m_x = x;
        m_y = y;
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

    auto addLayer(Layer sublayer)
    {
        m_sublayers ~= sublayer;
    }
}
