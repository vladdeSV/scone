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
                fg(Color.white_dark), "Key: ", fg(Color.red), input.key, "\n",
                fg(Color.white_dark), "Control Key: ", fg(Color.blue), input.controlKey, "\n",
                fg(Color.white_dark), "Pressed: ", fg(Color.green), input.pressed
            );
        }

        window.print();
    }
}