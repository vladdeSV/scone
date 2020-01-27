module scone.window;

import std.typecons : Tuple;

/+ Settings +/
struct SconeSettings {
    static WindowSettings windowSettings();
    static InputSettings inputSettings();
}

struct WindowSettings {
    Color defaultForegroundColor;
    Color defaultBackgroundColor;
}

struct InputSettings {
    //locale
}

/+ Window +/

alias Coordinate = Tuple!(size_t, "x", size_t, "y");
alias Size = Tuple!(size_t, "width", size_t, "height");

class Window
{
    void write(X, Y, Args...)(X tx, Y ty, Args args) if (isNumeric!X && isNumeric!Y && args.length >= 1);
    void write(Args...)(Coordinate coordinate, Args args) if (args.length >= 1);
    void print();

    void title(in string title);
    void cursorVisibility(in bool visible);

    void position(X, Y)(in X tx, in Y ty) if (isNumeric!X && isNumeric!Y);
    void position(in Coordinate coordinate);

    Size size();
    void resize(in Size size);
    void resize(in size_t width, in size_t height);
}

/+ Input +/

class Input {
    InputEvent[] inputs();
}

abstract class InputEvent {
    auto key();
    auto pressed();
    auto controlKey();
    //auto hasControlKey(SCK ck);
}