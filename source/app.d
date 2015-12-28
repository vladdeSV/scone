import std.stdio;

import scone.core;
import std.random;

import scone.winconsole;

void main()
{
    sconeInit(SconeModule.Window);

    auto layer = new Layer(40, 20);

    foreach(n, c; "hello!")
    {
        layer.write(10, 6 + n, Slot(c, Color.red, Color.white));
    }

    layer.print();

    readln();
}
