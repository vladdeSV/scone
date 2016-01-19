module scone.window;

package(scone):

import scone.layer : Slot;
import scone.utility;

version(Windows) import scone.windows.winconsole;
version(Posix)   import scone.posix.posixterminal;

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
            //posix_initTerminal();
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
            ////Thank you dav1d, from #d
            ////write("\033[?7h \033[0m \033[?25%change \033c"); //Set line-wrapping on, default colors, cursor visible and clear the screen.
            //posix_exitTerminal();
        }

        moduleWindow = false;
    }
}

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
