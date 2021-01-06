module scone.output.helpers.cli;

import scone.output.text_style : TextStyle;
import scone.output.types.color : Color;
import scone.output.helpers.ansi_color_helper : ansiColorString;

///
string cli(TextStyle style)
{
    return ansiColorString(style.foreground, style.background);
}
///
unittest
{
    assert(TextStyle().cli() == ansiColorString(Color.same, Color.same));
}
