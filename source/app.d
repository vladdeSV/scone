import std.stdio;

import scone.core;
import winconsole;

void main()
{
    sconeInit("testing", 50, 25);

    foreach(n, c; "hello!")
    {
	   winWriteCharacter(10 + n, 5, c);
    }

    readln();
}
