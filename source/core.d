module scone.core;

import winconsole;

auto sconeInit(string name, int w, int h)
{
    version(Windows)
    {
        initWin(name, w, h);
    }
    version(Posix)
    {
        //initPosix(name, w, h);
    }
}
