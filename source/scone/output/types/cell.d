module scone.output.types.cell;

import scone.output.types.color : Color;
import scone.output.text_style : TextStyle;
import std.typecons : Nullable;

struct Cell
{
    dchar character = ' ';
    TextStyle style = TextStyle(Nullable!Color(Color.initial), Nullable!Color(Color.initial));
}
