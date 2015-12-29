import scone.core;
import std.random;
import std.stdio;


void main()
{
    sconeInit(SconeModule.Window);

    auto layer = new Layer(40, 20);

    layer.write(0, 0, fg.red, bg.white, "hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle");
    layer.print();

    while (true)
    {
        layer.write(uniform(0, 40), uniform(0, 20), fg.red, bg.white, uniform(1, 100));
        layer.print();
    }
}
