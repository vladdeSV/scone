import scone.core;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Layer(UNDEF, UNDEF);
    auto layer = new Layer(window, 2, 2, 40, 20, [ Slot('*', fg.red, bg.white), Slot('#', fg.white, bg.red), Slot(' ') ]);
    auto sublayer = new Layer(layer, 1, 1, 20, 10, [ Slot('g') ]);
    auto sublayer2 = new Layer(sublayer, 5, 1, 4, 4, [ Slot('o') ]);

    while (gameloop)
    {
        auto a = getInputs();
        foreach(input; a)
        {
            if(input.key == SK_ESCAPE || input.key == SK_C && input.hasControlKey(ControlKey.CTRL))
            {
                gameloop = false;
                break;
            }

            layer.clear();
            layer.write(0,0, "Key: ", input.key, "\nPressed: ", input.keyDown);
        }
        window.print();
    }

    sconeClose();
}
