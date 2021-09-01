# scone · [![build status](https://github.com/vladdeSV/scone/workflows/build+test/badge.svg)](https://github.com/vladdeSV/scone/actions?query=workflow:build+test) [![license](https://img.shields.io/github/license/vladdeSV/scone?color=black&labelColor=24292E)](https://github.com/vladdeSV/scone/blob/develop/LICENSE)
Create cross-platform terminal applications.

## Example

```d
import scone;

void main() {
  frame.title("example");
  frame.size(33, 20);

  bool run = true;
  while(run) {
    foreach(input; input.keyboard) {
      // if CTRL+C is pressed
      if(input.key == SK.c && input.hasControlKey(SCK.ctrl)) {
        run = false;
      }
    }

    frame.write(
      12, 9,
      TextStyle().fg(Color.yellow), "Hello ", // white foreground text (chainable pattern)
      TextStyle().fg(Color.red).bg(Color.white), "World" // red foreground, white background
    );
    frame.print();
  }
}
```

![win](https://public.vladde.net/scone-example-mac-434.png)
![mac](https://public.vladde.net/scone-example-windows-434.png)

### Features
* Display text and colors
* Receive keyboard input
* Cross-platform
    * Some restrictions apply, please see [OS Limitations](https://github.com/vladdeSV/scone/wiki/OS-Limitations)

#### Simple cross-platform chart
|output|Windows|POSIX|
|:---|:---:|:---:|
|text|✓|✓|
|emoji||✓|
|ansi-color|✓|✓|
|rgb-color||✓|
|high performance output|✓||

|input|Windows|POSIX|
|:---|:---:|:---:|
|input detection|✓|✓|
|reliable|✓|*|
|control keys|✓|**|
|key release detection|✓||

\* Input is converted from arbitrary number sequences (may differ from system to system) to an input event. Basic ASCII should work no matter what system, however special keys like the up-arrow or function keys can vary drastically.
 
\*\* Only registers the last pressed control key.

### Install with [dub](https://code.dlang.org/download)

**Note**: `3.0.0` is not yet available.

```js
/// dub.json
"dependencies": {
    "scone": "~>3.0.0",
    ...
}
```

```js
/// dub.sdl
dependency "scone" version="~>3.0.0"
```
