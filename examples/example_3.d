import scone;

void main()
{
    sconeInit();

    auto frame = new Frame(40, UNDEF);

    bool loop = true;

    while (loop)
    {
        foreach(input; getInputs())
        {
            if(input.key == SK.Escape || input.key == SK.C && input.hasControlKey(SCK.Ctrl))
            {
                loop = false;
                break;
            }

            window.clear();
            window.write
            (
                0,0,
                "Key: ", input.key, "\n",
                "Control Key: ", input.controlKey, "\n",
                "Pressed: ", input.pressed
            );
        }
        window.print();
    }

    sconeClose();
}
