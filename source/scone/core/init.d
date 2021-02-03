module scone.core.init;

import scone.output.frame : Frame;
import scone.input.input : Input;
import scone.input.os.standard_input : StandardInput;
import scone.output.os.standard_output : StandardOutput;
import std.experimental.logger;

enum SconeModule {
  none = 0,
  frame = 1,
  input = 2,
  // todo audio = 4,
}

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
        import scone.core.dummy : DummyOutput;

        return new DummyOutput();
    }
    else version (Posix)
    {
        import scone.output.os.posix.posix_output : PosixOutput;

        return new PosixOutput();
    }
    else version (Windows)
    {
        import scone.output.os.windows.windows_output : WindowsOutput;

        return new WindowsOutput();
    }
}

StandardInput createApplicationInput()
{
    version (unittest)
    {
        import scone.core.dummy : DummyInput;

        return new DummyInput();
    }
    else version (Posix)
    {
        import scone.input.os.posix.posix_input : PosixInput;

        return new PosixInput();
    }
    else version (Windows)
    {
        import scone.os.windows.input.windows_input : WindowsInput;

        return new WindowsInput();
    }
}
