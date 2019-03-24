module scone.os;

public import scone.os.posix;
public import scone.os.windows;

import std.system;

// Alias OS to respective system
static if (os == std.system.OS.win32 || os == std.system.OS.win64)
{
    alias OS = WindowsOS;
}
else
{
    alias OS = PosixOS;
}

interface OSInterface
{
static:

    /// Initializes console/terminal to best settings when using scone
    package(scone) void init();

    /// De-initializes console/terminal
    package(scone) void deinit();

    /// Get the size of the window
    /// Returns: int[2], where [0] is width, and [1] is height
    uint[2] size();

    /// Set the size of the window
    void resize(in uint width, in uint height);

    /// Reposition the window on screen, where x=0, y=0 is the top-left corner
    void reposition(in uint x, in uint y);

    /// Set if the cursor visiblity
    bool cursorVisible(in bool visible);

    /// Set the cursor at position
    void setCursor(in uint x, in uint y);

    /// Set the title of the window
    void title(in string title);

    /// Get array of inputs since last call
    package(scone) void retreiveInputs();
}
