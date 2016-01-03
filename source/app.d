import scone.core;
import std.random;
import std.stdio;

void main()
{
    bool gameloop = true;
    sconeInit();

    auto layer = new Layer(80, 20);
    //auto sublayer = new Layer(layer, 0, 0, layer.w, layer.h);

    layer.write(0, 0, fg.red, bg.white, "hello there kott and blubeeries, wat are yoy doing this beautyiur beuirituyr nightrevening?? i am stiitngi ghere hanad dtyryugin to progrmamam this game enrgniergn that is for the solnosle");
    layer.print();

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

        //layer.write(uniform(0, 40), uniform(0, 20), fg.red, bg.white, uniform(1, 100));
        layer.print();
    }

    sconeClose();
}
