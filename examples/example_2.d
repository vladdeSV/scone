import scone;
import std.stdio : writeln;

void main()
{
    bool run = true;

    while(run)
    {
        foreach(input; window.getInputs())
        {
            //NOTE: Without a ^C handler you cannot quit the program (unless you taskmanager or SIGKILL it)

            //^C (Ctrl + C) or Escape
            if(input.key == SK.c && input.hasControlKey(SCK.ctrl) || input.key == SK.escape)
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
}
