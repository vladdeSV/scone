module scone.core.types.cell;

import scone.core.types.color;

struct Cell
{
    dchar character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}
