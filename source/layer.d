module scone.layer;

import scone.window;
import std.conv : to;
import std.array;
import std.string : wrap;
import std.uni : isWhite;

version(Windows) public import scone.winconsole : Color;
//version(Posix) public import scone.posixterminal : Color;

struct Slot
{
    char character;
    int attributes;
    //TODO: Will hold more properties
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

        foreach(n, ref row; m_slots)
        {
            row = m_slots[n][] = Slot(' ');
        }

        m_backbuffer = m_slots;

        //NOTE: Can I do this in a cleaner way?
        m_canavas = new Slot[][](height - (2 * border.length), width - (2 * border.length));
        foreach(n, ref row; m_canavas)
        {
            row = m_slots[border.length + n][border.length .. width - border.length];
        }
    }

    auto write(Args...)(int col, int row, Args args)
    {

        foreach(arg; args)
        {
            static if(is(typeof(change) == Slot))
            {
                m_canavas[y][x] = arg;
            }
        }

        //string output;

        //foreach(arg; args)
        //{
        //    output ~= to!string(arg);
        //}

        ////Wrap string and remove last character (which is a '\n')
        //output = wrap(output, w - col, null, null, 0)[0 .. $ - 1];

        ////Make sure the string is force wrapped if needed
        //int charactersSinceLastWhitespace, put;
        //foreach(n, c; output)
        //{
        //    if(isWhite(c))
        //    {
        //        charactersSinceLastWhitespace = 0;
        //    }

        //    if(charactersSinceLastWhitespace >= w - col - 1)
        //    {
        //        output.insertInPlace(n + put, "\n");
        //        ++put;
        //        charactersSinceLastWhitespace = 0;
        //    }

        //    ++charactersSinceLastWhitespace;
        //}

        //int wx, wy;
        //foreach(c; output)
        //{
        //    if(c =='\n')
        //    {
        //        ++wy;
        //        wx = 0;
        //    }

        //    //TODO: Split into arrays and set slices

        //    if(wy >= h - row)
        //    {
        //        break;
        //    }

        //    m_canavas[row + wy][col + wx] = c;
        //    ++wx;
        //}
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
                if(m_slots[sy][sx] != m_backbuffer[sy][sx])
                {
                    writeSlot(sx,sy, slot);
                }
            }
        }

        m_backbuffer = m_slots;
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
