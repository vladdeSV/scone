import scone;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Layer(40,UNDEF);
    auto layer = new Layer(window, 10, 5, 25, 10, [ Slot('*', fg.red, bg.white), Slot('#', fg.white, bg.red), Slot(' ') ]);

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
