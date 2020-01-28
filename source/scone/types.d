module scone.types;

import std.typecons : Tuple;
import scone.color;
import scone.window : Buffer;

struct Coordinate
{
    size_t x, y;
}

struct Size
{
    size_t width, height;
}

struct Cell
{
    char character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}

interface Renderer
{
    public void renderBuffer(Buffer buffer);
}
