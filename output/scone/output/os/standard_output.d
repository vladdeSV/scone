module scone.output.os.standard_output;

import scone.output.types.buffer : Buffer;
import scone.output.types.coordinate : Coordinate;
import scone.output.types.size : Size;

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
