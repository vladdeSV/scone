//hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle
import scone.core;
import std.random;
import std.stdio;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Layer(40,UNDEF);
    auto layer = new Layer(window, 0,0, UNDEF, UNDEF, [ Slot('*', fg.red, bg.white), Slot(' ') ]);

    while (gameloop)
    {
        foreach(input; getInputs())
        {
            if(input.key == Key.SK_ESCAPE || input.key == Key.SK_C && input.hasControlKey(ControlKey.CTRL))
            {
                gameloop = false;
                break;
            }

            layer.clear();
            layer.write(0,0, "Key: ", input.key, "\nPressed: ", input.keyDown, "\nRepeated: ", input.repeated);
        }
        layer.print();
    }

    sconeClose();
}
