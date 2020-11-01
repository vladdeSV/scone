import scone;

void main()
{
    frame.title("👮🏿‍♀️");
    frame.size(20, 10);

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

        // corners
        frame.write(19, 0, Color.red.background, " ");
        frame.write(19, 9, Color.red.background, " ");
        frame.write(0, 9, Color.red.background, " ");

        // emoji
        frame.write(0, 3, Color.black.background, "....");
        frame.write(0, 4, Color.black.background, "🍞...");
        frame.write(0, 5, Color.redDark.background, "abcdefghijklmno_åäö");
        frame.write(0, 5, Color.redDark.background, "🇸🇪");
        frame.write(0, 6, Color.black.background, "👮🏿‍♀️");

        // last key
        if (lastInput != KeyboardEvent())
        {
            frame.write(0, 8, lastInput.key, ", ", lastInput.controlKey, " ", lastInput.pressed ? "pressed" : "released");
        }

        frame.print();
    }
}
