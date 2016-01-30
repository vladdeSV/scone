# scone
Simple Console Engine.

**Key input is only available on Windows. POSIX can still write out to the console!**

# Example
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
