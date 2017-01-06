module scone.console.frame;

import scone.console.color;

class Frame
{
    this(uint width, uint height)
    {
        _slots = new Slot[][](width, height);
        _backbuffer = new bool[][](width, height);

        foreach(n; 0 .. height)
        {
            _slots[n][] = Slot(' ');
            _backbuffer[n][] = false;
        }

        //TODO: set window size
    }

    alias width  = w;
    alias height = h;

    /** Get the width of the frame */
    auto w() const @property
    {
        return _width;
    }

    /** Get the height of the frame */
    auto h() const @property
    {
        return _height;
    }

    private uint _width, _height;
    private Slot[][] _slots;
    private bool[][] _backbuffer;
}

/**
 * Slot structure
 */
struct Slot
{
    //character
    char character;
    //foreground color
    fg foreground = fg(Color.white_dark);
    //background color
    bg background = bg(Color.black_dark);
}
