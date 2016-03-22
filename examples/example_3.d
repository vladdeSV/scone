import scone;

void main()
{
    sconeInit();

    auto frame = new Frame(80, undef);

    bool loop = true;

    while (loop)
    {
        foreach(input; getInputs())
        {
            if(input.key == SK.escape || input.key == SK.c && input.hasControlKey(SCK.ctrl))
            {
                loop = false;
                break;
            }

            frame.clear();
            frame.write
            (
                0,0,
                "Key: ", input.key, "\n",
                "Control Key: ", input.controlKey, "\n",
                "Pressed: ", input.pressed
            );
        }
        frame.print();
    }

    sconeClose();
}
