module scone.layer;

import scone.window;
import scone.utility;
import std.conv : to;
import std.array : insertInPlace;
import std.string : wrap;
import std.uni : isWhite;

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

    this(Layer parent, int x, int y, int width, int height, Slot[] border = null)
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
    }

    /**
     * Bugs: entering a shit loads of spaces causes range violation. caused in the forced wrap part (because not inserting a newline thing)
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

            chars.length = slots.length;
            foreach(n, slot; slots)
            {
                chars[n] = slot.character;
            }


            int charactersSinceLastWhitespace, put;
            foreach(n, c; chars)
            {
                if(isWhite(c))
                {
                    charactersSinceLastWhitespace = 0;
                }

                if(charactersSinceLastWhitespace >= w - col - 1)
                {
                    chars.insertInPlace(n + put, ' ');
                    ++put;
                    charactersSinceLastWhitespace = 0;
                }

                ++charactersSinceLastWhitespace;
            }

            chars = wrap(chars, w - col, null, null, 0)[0 .. $ - 1];

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

                    m_slots[y][x] = sublayerSlots[y][x];
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

    auto clear()
    {
        foreach(ref row; m_slots)
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
}
