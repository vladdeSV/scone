/**
 * All functions here give some sort of direct access to the console/terminal.
 * However, I suggest you use the `class Frame`(-work, haha). If you decide that you must use these functions separately, they must be initialized with `windowInit()`
 *
 * For those who want to steal code, each function in here calls a win_* or posix_* counterpart.
 * (Eg. setCursor(x,y) calles win_setCursor(x,y) on Windows, posix_setCursor(x,y) on POSIX)
 */

module scone.window;

import scone.core;
import scone.frame : Slot;

version(Windows) import scone.windows.win_console;
version(Posix)   import scone.posix.posix_terminal;

/**
 * Writes out a slot at (x, y)
 * Params:
 *   x    = The x position to write to
 *   y    = The y position to write to
 *   slot = The slot which will be written
 */
auto writeSlot(int x, int y, ref Slot slot)
{
     version (Windows)
    {
        win_writeSlot(x, y, slot);
    }
    version (Posix)
    {
        //posix_writeSlot(x, y, slot);
    }
}

/** Set the cursor position */
auto setCursor(int x, int y)
{
    version (Windows)
    {
        win_setCursor(x,y);
    }
    version (Posix)
    {
        posix_setCursor(x,y);
    }

}

/** Set the title */
public auto title(string title) @property
{
    version (Windows)
    {
        win_title = title;
    }
    version (Posix)
    {
        posix_title = title;
    }
}

/** Set cursor visible. */
auto cursorVisible(bool visible) @property
{
    version (Windows)
    {
        win_cursorVisible = visible;
    }
    version (Posix)
    {
        posix_cursorVisible = visible;
    }

}

/** Set line wrapping. */
auto lineWrapping(bool lw) @property
{
    version (Windows)
    {
        //win_lineWrapping = lw;
    }
    version (Posix)
    {
        posix_lineWrapping = lw;
    }
}

/**
 * Get the window size
 * Returns: int[2], where [0] = w, [1] = h
 */
auto windowSize() @property
{
    version (Windows)
    {
        return win_windowSize;
    }
    version (Posix)
    {
        return posix_windowSize;
    }
}

package(scone)
{
    auto windowInit()
    {
        if(!moduleWindow)
        {
            version (Windows)
            {
                win_initConsole();
            }
            version (Posix)
            {
                posix_initTerminal();
            }

            moduleWindow = true;
        }
    }

    auto windowClose()
    {
        if(moduleWindow)
        {
            version(Windows)
            {
                win_exitConsole();
            }
            version(Posix)
            {
                posix_exitTerminal();
            }

            moduleWindow = false;
        }
    }
}
