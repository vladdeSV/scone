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
