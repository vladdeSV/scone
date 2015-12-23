import std.stdio;

import scone.core;
import scone.winconsole;

void main()
{
    sconeInit(SconeModule.WINDOW);

    foreach(n, c; "hello!")
    {
	   win_writeCharacter(10 + n, 5, c, Color.fg_white | Color.bg_black);
    }

    readln();
}
