//A bit messy example

import scone;

void main()
{
    sconeOpen();

    auto frame = new Frame();

    bool run = true;

    auto loginLabel  = new UILabel("loginLabel", 1, 1, "Login"); loginLabel.color(Color.yellow);
    auto nameInput   = new UITextInput("nameInput", 1,3, "[Username]", InputType.ascii);
    auto passInput   = new UITextInput("passInput", 1,4, "[Password]", InputType.alphabetical | InputType.numeric | InputType.password);
    auto loginOption = new UIOption ("loginOption", 1,6, "Login", { run = !login(nameInput.text, passInput.text); });

    UI ui = UI(frame, [loginLabel, nameInput, passInput, loginOption]);

    while(run)
    {
        frame.clear();

        foreach(input; getInputs())
        {
            if(!input.pressed)
            {
                continue;
            }

            if(input.key == SK.c && input.hasControlKey(SCK.ctrl))
            {
                run = false;
            }

            ui.update(input);
        }

        ui.display();
        frame.print();
    }

    sconeClose();
}

bool login(string name, string pass)
{
    return name == "foo" && pass == "bar";
}

