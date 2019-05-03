module scone.os.os;

import scone.os;
import std.system;

// Alias OS to respective system
static if (std.system.os == std.system.OS.win32 || std.system.os == std.system.OS.win64)
{
    alias os = WindowsOS;
}
else
{
    alias os = PosixOS;
}

interface OS
{
    static:

    /// Get the size of the window
    uint[2] size();

    /// Set the size of the window
    void resize(in uint width, in uint height);

    /// Reposition the window on screen in pixels, where x=0, y=0 is the top-left corner
    void reposition(in uint x, in uint y);

    /// Set if the cursor visiblity
    bool cursorVisible(in bool visible);

    /// Set the cursor at position
    void setCursor(in uint x, in uint y);

    /// Set the title of the window
    void title(in string title);

    package(scone)
    {
        /// Initializes console/terminal to best settings when using scone
        void init();

        /// De-initializes console/terminal
        void deinit();

        /// Get array of inputs since last call
        void retreiveInputs();
    }
}
