module scone.output.types.cell;

import scone.output.types.color;

struct Cell
{
    dchar character = ' ';
    ForegroundColor foreground = Color.initial;
    BackgroundColor background = Color.initial;
}
