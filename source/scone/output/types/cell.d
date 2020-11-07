module scone.output.types.cell;

import scone.output.types.color : Color;
import scone.output.text_style : TextStyle;

struct Cell
{
    dchar character = ' ';
    TextStyle style = TextStyle(Color.initial, Color.initial);
}
