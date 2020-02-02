module scone.frame.cell;

import scone.frame.color;

struct Cell
{
    dchar character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}
