module scone.frame.types.cell;

import scone.frame.types.color;

struct Cell
{
    dchar character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}
