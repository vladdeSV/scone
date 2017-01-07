module scone.window;

struct Window
{
    this(uint width, uint height)
    {
        _width = width;
        _height = height;

        _cells = new Cell[][](width, height);
        _backbuffer = _cells;

        clear();
    }

    //TODO
    auto print()
    {
        version(Windows)
        {
            foreach(cy, ref row; _cells)
            {
                foreach(cx, ref cell; row)
                {
                    if(cell != _backbuffer[cy][cx])
                    {
                        //TODO: writeSlot(cx, cy, cell);
                        _backbuffer[cy][cx] = cell;
                    }
                }
            }
        }

        version(Posix)
        {

        }
    }

    auto clear()
    {
        foreach(ref row; _cells)
        {
            row[] = Cell(' ');
        }
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