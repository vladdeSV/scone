module scone.os.window;

import scone.frame.buffer : Buffer;
import scone.input.input_event : InputEvent;
import scone.frame.size : Size;
import scone.frame.coordinate : Coordinate;

interface Window
{
    Size size();
    void size(Size size);
    void title(dstring title);
    void clear();

    void renderBuffer(Buffer buffer);
    InputEvent[] latestInputEvents();
    void initializeInput();
}
