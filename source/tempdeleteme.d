import scone;
import scone.core.init;

shared static this() {
  sconeSetup = {
    auto stdin = createApplicationInput();
    input = new Input(stdin);
  };
}

void main() {
  bool run = true;

  while(run) {
    auto foo = input.keyboard;

    if(foo.length)
    {
      import std.stdio : writeln;
      writeln(foo, "\r");
    }

    foreach(input; foo) {
      // if CTRL+C is pressed
      if(input.key == SK.c && input.hasControlKey(SCK.ctrl)) {
        run = false;
      }

      if(input.key == SK.a) {
        run = false;
      }
    }
  }
}
