import scone;
import std.random : uniform;

void main()
{
    window.resize(80,24);
    window.title = "Example 1";

    foreach(n; 0 .. 80 * 24 * 10) //loop through n amount of times
    {
        /* Normally you want to clear the screen before printing again, to remove artifacts */
        // window.clear();

        /* Randomly choose a position in the window */
        auto x = uniform(0, window.w);
        auto y = uniform(0, window.h);

        /*
         * Get random color, but more simply putColor
         * Example:
         * ---
         * auto foreground = Color.green.fg;
         * auto background = Color.white.bg;
         * ---
         */
        auto foregroundColor = cast(Color)(uniform(0,16)).fg;
        auto backgroundColor = cast(Color)(uniform(0,16)).bg;

        /* A random character to be displayed */
        auto character = cast(char)(uniform(32, 128));

        /* The `windo.write(x, y, args...)` method only stages changes to the screen. Nothing will actually be displayed until... */
        window.write(x, y, foregroundColor, backgroundColor, character);

        /* ...the print method is called */
        window.print();
    }
}
