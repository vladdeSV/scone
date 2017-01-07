module scone.os.independent;

import scone.os.windows;
import scone.os.posix;

struct OS
{
    static:

    auto init()
    {
        version(Windows)
        {
            win_init();
        }

        version(Posix)
        {
            posix_init();
        }
    }

    auto deinit()
    {
        cursorVisible = true;
        setCursor(0,0);

        version(Windows)
        {

        }

        version(Posix)
        {
            posix_deinit();
        }
    }

    auto windowSize()
    {
        version(Windows)
        {
            return win_windowSize();
        }

        version(Posix)
        {
            return posix_windowSize();
        }
    }

    auto cursorVisible(bool visible) @property
    {
        version(Windows)
        {
            win_cursorVisible(visible);
        }

        version(Posix)
        {
            posix_cursorVisible(visible);
        }
    }

    auto setCursor(uint x, uint y)
    {
        version(Windows)
        {
            return win_setCursor(x, y);
        }

        version(Posix)
        {
            return posix_setCursor(x, y);
        }
    }

    void title(string title) @property
    {
        version(Windows)
        {
            win_title(title);
        }

        version(Posix)
        {
            posix_title(title);
        }
    }
}