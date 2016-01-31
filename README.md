# scone
Simple Console Engine.

**Key input is only available on Windows. POSIX can still write out to the console!**

# Examples
```d
import scone;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Frame(40, UNDEF);

    while (gameloop)
    {
        auto a = getInputs();
        foreach(input; a)
        {
            if(input.key == SK_ESCAPE || input.key == SK_C && input.hasControlKey(ControlKey.CTRL))
            {
                gameloop = false;
                break;
            }

            window.clear();
            window.write(0,0, "Key: ", input.key, "\nPressed: ", input.pressed);
        }
        window.print();
    }

    sconeClose();
}
```

```d
import scone;
import std.random;

void main()
{
    sconeInit(SconeModule.WINDOW); //Init, only access to the window

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
```
