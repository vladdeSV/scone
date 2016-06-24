/**
 * All functions here give some sort of direct access to the .
 * However, I suggest you use the `class Frame`(-work, haha). If you decide that you must use these functions separately, they must be initialized with `windowInit()`
 *
 * For those who want to steal code, each function in here calls a win_*.
 * (Eg. setCursor(x,y) calles win_setCursor(x,y) on Windows)
 */

module scone.window;

import scone.core;
import scone.frame : Slot;

import scone.windows.win_console;

/**
 * Writes out a slot at (x, y)
 * Params:
 *   x    = The x position to write to
 *   y    = The y position to write to
 *   slot = The slot which will be written
 */
auto writeSlot(int x, int y, ref Slot slot)
{
    win_writeSlot(x, y, slot);
}

/** Set the cursor position */
auto setCursor(int x, int y)
{
    win_setCursor(x,y);
}

/** Set the title */
auto title(string title) @property
{
    win_title = title;
}

/** Set cursor visible. */
auto cursorVisible(bool visible) @property
{
    win_cursorVisible = visible;

}

/** Set line wrapping. */
auto lineWrapping(bool lw) @property
{
    win_lineWrapping = lw;
}

/**
 * Get the window size
 * Returns: int[2], where [0] = w, [1] = h
 */
auto windowSize() @property
{
    return win_windowSize;
}

package(scone)
{
    auto windowInit()
    {
        if(!moduleWindow)
        {
            win_initConsole();
            moduleWindow = true;
        }
    }

    auto windowClose()
    {
        if(moduleWindow)
        {
            win_exitConsole();
            moduleWindow = false;
        }
    }
}
