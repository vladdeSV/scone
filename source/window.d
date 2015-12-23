module scone.window;

import scone.core;
import scone.winconsole;

protected:

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

auto writeCharacter(int x, int y, char c, int attributes)
{
     version (Windows)
    {
        win_writeCharacter(x, y, c, attributes);
    }
    version (Posix)
    {
        //posix_writeCharacter(x, y, c, attributes);
    }
}

auto setCursor(int x, int y)
{
    version (Windows)
    {
        win_setCursor(x,y);
    }
    version (Posix)
    {

    }

}

auto title(string title) @property
{
    version (Windows)
    {
        win_title = title;
    }
    version (Posix)
    {

    }
}

///** Set cursor visible. */
//auto cursorVisible(bool visible) @property
//{
//    version (Windows)
//    {
//        win_cursorVisible = visible;
//    }
//    version (Posix)
//    {

//    }

//}

///** Set line wrapping. */
//auto lineWrapping(bool lw) @property
//{
//    version (Windows)
//    {
//        win_lineWrapping = lw;
//    }
//    version (Posix)
//    {

//    }
//}
