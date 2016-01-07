//hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle
import scone.core;
import std.random;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Layer(40,24);
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
            layer.write(0,0, "Key: ", input.key, ", VK: ", win_getWindowsVirtualKey(input.getVK()), "\nPressed: ", input.keyDown, "\nRepeated: ", input.repeatedAmount, "\nControl key: ", input.controlKey);
        }
        layer.print();
    }

    sconeClose();
}
