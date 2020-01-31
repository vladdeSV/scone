module scone.os.os_window;

import scone.window.buffer : Buffer;
import scone.input.input_event : InputEvent;
import scone.window.types.size : Size;
import scone.window.types.coordinate : Coordinate;

interface OSWindow
{
    public Size windowSize();
    public void windowSize(Size size);
    public void cursorPosition(Coordinate coordinate);
    public void windowTitle(dstring title);
    public void clearWindow();

    public void renderBuffer(Buffer buffer);
    public InputEvent[] latestInputEvents();

}
