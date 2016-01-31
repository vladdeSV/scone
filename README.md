# scone
Simple Console Engine.

**Key input is only available on Windows. POSIX can still write out to the console!**

# Examples

#### Randomly print out on the screen
```d
import scone;
import std.random : uniform;

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

#### Print keypresses
```d
import scone;
import std.stdio : writeln;

void main()
{
    sconeInit(SconeModule.KEYBOARD); //Init, only access to the keyboard

    bool run = true;

    while(run)
    {
        foreach(input; getInputs())
        {
            //NOTE: Without a ^C handler you cannot quit the program (unless you taskmanager or SIGKILL it)

            //^C (Ctrl + C) or Escape
            if(input.key == SK.C && input.hasControlKey(SCK.CTRL) || input.key == SK.ESCAPE)
            {
                run = false;
                break;
            }

            writeln(
                input.key, ", ",
                input.controlKey, ", ",
                input.pressed, ", ",
            );
        }
    }

    sconeClose(); //close
}
```

#### Combine the both
```d
import scone;

void main()
{
    sconeInit();

    auto window = new Frame(40, UNDEF);

    bool loop = true;

    while (loop)
    {
        foreach(input; getInputs())
        {
            if(input.key == SK.ESCAPE || input.key == SK.C && input.hasControlKey(SCK.CTRL))
            {
                loop = false;
                break;
            }

            window.clear();
            window.write
            (
                0,0,
                "Key: ", input.key, "\n",
                "Control Key: ", input.controlKey, "\n",
                "Pressed: ", input.pressed
            );
        }
        window.print();
    }

    sconeClose();
}
```

