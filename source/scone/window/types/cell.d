module scone.window.types.cell;

import scone.window.types.color;

struct Cell
{
    char character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}
