import scone.core;
import std.random;
import std.stdio;


void main()
{
    sconeInit(SconeModule.Window);

    auto layer = new Layer(40, 20);

    layer.write(00, 0, fg.red, bg.white, "hello there kott and blubeeries, what are yoy doing this beautyiur beuirituyr nightrevening??");

    layer.print();

    readln();
}
