module scone.core.init;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import scone.os.input : Input_ = Input;
import scone.os.output : Output;
import std.experimental.logger;

void delegate() sconeSetup;
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

    if(sconeSetup is null)
    {
        sconeSetup = {
            auto output = createApplicationOutput();
            frame = new Frame(output);

            auto input_ = createApplicationInput();
            input = new Input(input_);
        };
    }

    sconeSetup();
}

Output createApplicationOutput()
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

Input_ createApplicationInput()
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
