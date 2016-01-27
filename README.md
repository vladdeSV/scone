# scone
Simple Console Engine.

**Currently only working on Windows. Key input is not functioning on POSIX (yet)**

# Example
```d
import scone;

void main()
{
    bool gameloop = true;

    sconeInit();

    auto window = new Frame(40, UNDEF, [ Slot('*', fg.red, bg.white), Slot('#', fg.white, bg.red), Slot(' ') ]);

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
            window.write(0,0, "Key: ", input.key, "\nPressed: ", input.keyDown);
        }
        window.print();
    }

    sconeClose();
}
```
