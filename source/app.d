import std.stdio;

import scone.core;
import std.random;

void main()
{
    sconeInit(SconeModule.Window);

    auto layer = new Layer(40, 20);

    foreach(n, c; "hello!")
    {
        //write(10 + n, 6, Slot(c, Color.fg_red));
    }

    layer.print();

    readln();
}
