import scone;

void main()
{
    frame.title("👮🏿‍♀️");
    frame.size(40, 12);

    bool run = true;
    auto lastInput = KeyboardEvent();
    
    while (run)
    {
        foreach (input; input.keyboard)
        {
            // if CTRL+C is pressed
            if (input.key == SK.c && input.hasControlKey(SCK.ctrl))
            {
                run = false;
            }

            lastInput = input;
        }


        // light and dark color stripes
        frame.write(0, 0, Color.blue.background, "        ", Color.initial.background, Color.red.foreground, " light");
        frame.write(0, 1, Color.blueDark.background, "        ", Color.initial.background, Color.redDark.foreground, " dark");
        frame.write(4, 0, Color.initial.background, "1", Color.same.background, "1", Color.blackDark.background, "1");

        // corners
        frame.write(39, 0, Color.red.background, " ");
        frame.write(39, 11, Color.red.background, " ");
        frame.write(0, 11, Color.red.background, " ");

        // emoji
        frame.write(0, 3, "1", Color.black.background, "234");
        frame.write(0, 4, "🍞", Color.black.background, "234");
        frame.write(0, 5, Color.redDark.background, "abcdefghijklmn_åäö");
        frame.write(0, 5, Color.redDark.background, "🇸🇪");
        frame.write(0, 6, Color.black.background, Color.blue.foreground, "👮🏿‍♀️");
        frame.write(0, 7, Color.black.background, "👮🏿‍♀️");
        frame.write(1, 7, ".");

        // last key
        if (lastInput != KeyboardEvent())
        {
            frame.write(0, 9, lastInput.key, ", ", lastInput.controlKey, " ", lastInput.pressed ? "pressed" : "released");
        }

        frame.print();
    }
}
