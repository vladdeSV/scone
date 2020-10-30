module scone.output.os.standard_output;

import scone.output.buffer : Buffer;
import scone.output.types.coordinate : Coordinate;
import scone.output.types.size : Size;
import scone.input.keyboard_event : KeyboardEvent;

interface StandardOutput
{
    void initializeOutput();
    void deinitializeOutput();

    Size size();
    void size(in Size size);
    void title(in string title);
    void cursorVisible(in bool visible);

    void renderBuffer(Buffer buffer);
}
