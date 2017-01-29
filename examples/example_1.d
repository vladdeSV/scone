import scone;
import std.random : uniform;

void main()
{
    window.size(80,24);
    window.title = "Example 1";

    foreach(n; 0 .. 80 * 24 * 10) //loop through n amount of times
    {
        window.write
        (
            uniform(0, 80),                        /* x */
            uniform(0, 24),                        /* y */

            //Keep in mind: This is an example.
            //You should use, for example:
            //`fg(Color.red)` or `bg(Color.white)`
            fg(cast(Color) uniform(0,16)),         /* foreground */
            bg(cast(Color) uniform(0,16)),         /* background */

            cast(char)(uniform(0, 256))            /* character  */
        );

        window.print();                            /* print out everything on the screen */
    }

    OS.deinit(); //make this run automatically
}