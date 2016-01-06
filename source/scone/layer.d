module scone.layer;

import scone.window;
import scone.utility;
import std.conv : to;
import std.array : insertInPlace;
import std.string : wrap, strip;
import std.uni : isWhite;
import std.experimental.logger;

struct Slot
{
    char character;
    fg foreground = fg.white;
    bg background = bg.black;
}

class Layer
{
    //@nogc: //In the future, make entire Layer @nogc

    this(int width, int height, Slot[] border = null)
    {
        this(null, 0, 0, width, height, border);
    }

    this(Layer parent, int x, int y, int width, int height, Slot[] border = null) /*if (parent !is null) //For future use */
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

        if(m_parent !is null)
        {
            m_parent.addLayer(this);
        }
    }

    /**
     *
     */
    auto write(Args...)(int col, int row, Args args)
    {
        //TODO: Check if col or row are > 0 and < borders

        Slot[] slots;
        fg foreground = fg.white;
        bg background = bg.black;

        foreach (arg; args)
        {
            static if(is(typeof(arg) == fg))
            {
                foreground = arg;
            }
            else static if(is(typeof(arg) == bg))
            {
                background = arg;
            }
            else static if(is(typeof(arg) == Slot))
            {
                slots ~= arg;
            }
            else
            {
                foreach(c; to!string(arg))
                {
                    slots ~= Slot(c, foreground, background);
                }
            }
        }

        if(!slots.length)
        {
            m_canavas[row][col].foreground = foreground;
            m_canavas[row][col].background = background;
        }
        else
        {
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

            //TODO: while(findInArray(chars, "  ")) { replaceInArray(chars, "  ", " "); }
            //I the code above to replace all selected code below
            //////////////////////////////////////////////////////////////////////////////////
            //bool sf;
            //Slot[] tempSlots;
            //char[] tempChars;

            //for(int i; i < chars.length - 1;)
            //{
            //    if(!(chars[i] == ' ' && sf))
            //    {
            //        if(chars[i] == ' ')
            //        {
            //            sf = true;
            //        }
            //        else
            //        {
            //            sf = false;
            //        }
            //        tempChars ~= chars[i];
            //        tempSlots ~= slots[i];
            //    }
            //    ++i;
            //}

            //chars = tempChars;
            //slots = tempSlots;

            ////Ugly check to see if first or last characters are spaces.
            //if(slots[0] == Slot(' '))
            //{
            //    slots = slots[1 .. $];
            //}
            //if(slots[$ - 1] == Slot(' '))
            //{
            //    slots = slots[0 .. $ - 1];
            //}
            //////////////////////////////////////////////////////////////////////////////////


            chars = strip(wrap(chars, usableWidth, null, null, 0));

            foreach(n, c; chars)
            {
                if(c == '\n')
                {
                    slots[n] = nls;
                }
            }

            int wx, wy;
            foreach(slot; slots)
            {
                if(slot.character == '\n')
                {
                    ++wy;
                    wx = 0;
                    continue;
                }

                if(row + wy >= h)
                {
                    break;
                }

                //log(slots.length, ", ", col + wx, ", ", slot);

                m_canavas[row + wy][col + wx] = slot;
                ++wx;
            }
        }
    }

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

    @property
    {
        const
        {
            auto x()
            {
                return m_x;
            }

            auto y()
            {
                return m_y;
            }

            auto w()
            {
                return m_w;
            }

            auto h()
            {
                return m_h;
            }
        }
    }

    alias width = w;
    alias height = h;

private:
    //Forgive me for using C++ naming style
    Layer m_parent;
    Layer[] m_sublayers;
    int m_x, m_y;
    int m_w, m_h;
    bool m_visible, m_translucent;
    Slot[] m_border;
    Slot[][] m_slots, m_canavas, m_backbuffer;

    auto addLayer(Layer sublayer)
    {
        m_sublayers ~= sublayer;
    }
}
