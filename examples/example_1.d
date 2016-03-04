import scone;
import std.random : uniform;

void main()
{
    sconeInit(SconeModule.window); //Init, only access to the window

    auto frame = new Frame(); //Create a new "frame" with dynamic width and height

    foreach(n; 0 .. frame.w * frame.h * 10) /* loop through n amount of times */
    {
        frame.write(
            uniform(0, frame.width),   /* x */
            uniform(0, frame.height),  /* y */
            cast(fg) uniform(1, 17),   /* foreground */
            cast(bg) uniform(1, 17),   /* background */
            cast(char) uniform(0, 256) /* character  */
        );

        frame.print(); /* print out everything on the screen */
    }

    sconeClose(); //close
}
