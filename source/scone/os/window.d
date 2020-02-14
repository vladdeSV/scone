module scone.os.window;

import scone.frame.buffer : Buffer;
import scone.frame.coordinate : Coordinate;
import scone.frame.size : Size;
import scone.input.input_event : InputEvent;

interface Window
{
    void initializeOutput();
    void deinitializeOutput();

    void initializeInput();
    void deinitializeInput();

    Size size();
    void size(in Size size);
    void title(in string title);
    void cursorVisible(in bool visible);

    void renderBuffer(Buffer buffer);
    InputEvent[] latestInputEvents();
}

struct ResizeEvent
{
    Size newSize;
}
