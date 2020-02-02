module scone.os.window;

import scone.frame.buffer : Buffer;
import scone.input.input_event : InputEvent;
import scone.frame.types.size : Size;
import scone.frame.types.coordinate : Coordinate;

interface Window
{
    Size size();
    void size(Size size);
    void cursorPosition(Coordinate coordinate);
    void title(dstring title);
    void clear();

    void renderBuffer(Buffer buffer);
    InputEvent[] latestInputEvents();
}
