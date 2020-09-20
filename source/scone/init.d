module scone.core.init;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import scone.os.standard_input : StandardInput;
import scone.os.standard_output : StandardOutput;
import std.experimental.logger;

Frame frame;
Input input;

/// can be overidden
void delegate() sconeSetup = {
    auto standardOutput = createApplicationOutput();
    frame = new Frame(standardOutput);

    auto standardInput = createApplicationInput();
    input = new Input(standardInput);
};

private shared initialized = false;

static this()
{
    if (initialized)
    {
        return;
    }

    initialized = true;
    sharedLog = new FileLogger("scone.log");

    sconeSetup();
}

StandardOutput createApplicationOutput()
{
    version (unittest)
    {
        import scone.misc.dummy_window : DummyOutput;

        return new DummyOutput();
    }
    else version (Posix)
    {
        import scone.os.posix.output.posix_output : PosixOutput;

        return new PosixOutput();
    }
    else version (Windows)
    {
        import scone.os.windows.output.windows_output : WindowsOutput;

        return new WindowsOutput();
    }
}

StandardInput createApplicationInput()
{
    version (unittest)
    {
        import scone.misc.dummy_window : DummyInput;

        return new DummyInput();
    }
    else version (Posix)
    {
        import scone.os.posix.input.posix_input : PosixInput;

        return new PosixInput();
    }
    else version (Windows)
    {
        import scone.os.windows.input.windows_input : WindowsInput;

        return new WindowsInput();
    }
}
