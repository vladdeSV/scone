module main;

import scone;

void main()
{
    app: while (true)
    {
        /+
        foreach (n, InputEvent key; input.inputs())
        {
            if (!key.pressed)
            {
                continue;
            }

            if (key.key == SK.a)
            {
                break app;
            }
        }
        +/

        frame.write(Coordinate(0, 0),  frame.size);
        frame.write(Coordinate(23, 6), Color.red.foreground, "andra");
        frame.print();
    }
}
