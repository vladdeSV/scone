module main;

import scone;
import scone.os.windows.windows_console;

void main()
{

    // should be in core.init()

    auto windowsConsole = new WindowsConsole();
    auto window = new Window(windowsConsole.size, windowsConsole);

    window.write(Coordinate(0, 0), "testar");
    window.print();

}
