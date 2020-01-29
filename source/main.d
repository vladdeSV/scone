module main;

import scone;
import scone.os.windows.windows_console;

void main()
{

    // should be in core.init()

    auto osWindow = new WindowsConsole();

    auto window = new Window(osWindow);
    auto inputs = new Inputs(osWindow);

    app: while (true)
    {
        foreach (n, InputEvent key; inputs.inputs())
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

        window.write(Coordinate(0, 0), "testar");
        window.print();
    }
}
