module scone.os.window;

import scone.frame.buffer : Buffer;
import scone.frame.coordinate : Coordinate;
import scone.frame.size : Size;
import scone.input.input_event : InputEvent;

interface Window
{
    Size size();
    void size(in Size size);
    void title(in dstring title);
    void clear();
    void cursorVisible(in bool visible);

    void renderBuffer(Buffer buffer);
    InputEvent[] latestInputEvents();
    void initializeInput();
}
