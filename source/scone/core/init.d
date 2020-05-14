module scone.core.init;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import std.experimental.logger;

import scone.os.output : Output;
import scone.os.input : Input_ = Input;

//todo: scone settings
// - use default scone exit handler on ctrl+c
// - automatically resize window buffer
// - default cell colors

Frame frame;
Input input;
private shared initialized = false;

static this()
{
    if (initialized)
    {
        return;
    }

    initialized = true;

    sharedLog = new FileLogger("scone.log");

    auto output = createApplicationOutput();
    frame = new Frame(output);

    auto input_ = createApplicationInput();
    input = new Input(input_);
}

private Output createApplicationOutput()
{
    version (unittest)
    {
        assert(0, "not implemented");
    }
    else version (Posix)
    {
        import scone.os.posix.output.posix_output : PosixOutput;

        return new PosixOutput();
    }
    else version (Windows)
    {
        assert(0, "not implemented");
    }
}

private Input_ createApplicationInput()
{
    version (unittest)
    {
        assert(0, "not implemented");
    }
    else version (Posix)
    {
        import scone.os.posix.input.posix_input : PosixInput;

        return new PosixInput();
    }
    else version (Windows)
    {
        assert(0, "not implemented");
    }
}
