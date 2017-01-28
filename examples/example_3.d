/*
import scone;

void main()
{
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
*/