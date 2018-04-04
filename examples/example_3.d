import scone;

void main()
{
    bool loop = true;
    window.title = "Example 3";
    window.resize(40,10);

    while(loop)
    {
        foreach(input; window.getInputs())
        {
            if((input.key == SK.c && input.hasControlKey(SCK.ctrl)) || input.key == SK.escape)
            {
                loop = false;
                break;
            }

            window.clear();

            window.write
            (
                0,0,
                Color.white_dark.fg, "Key: ",         Color.red.fg, input.key, "\n",
                Color.white_dark.fg, "Control Key: ", Color.blue.fg, input.controlKey, "\n",
                Color.white_dark.fg, "Pressed: ",     Color.green.fg, input.pressed
            );
        }

        window.print();
    }
}
