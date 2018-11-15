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
                Color.whiteDark.foreground, "Key: ",         Color.red.foreground, input.key, "\n",
                Color.whiteDark.foreground, "Control Key: ", Color.blue.foreground, input.controlKey, "\n",
                Color.whiteDark.foreground, "Pressed: ",     Color.green.foreground, input.pressed
            );
        }

        window.print();
    }
}
