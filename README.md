Note: This README covers the upcoming 3.0 release. View the latest 2.1.3 docs [here](https://github.com/vladdeSV/scone/tree/v2.1.3).

# 🍞 scone
Create cross-platform console/terminal applications with ease

![develop](https://github.com/vladdeSV/scone/workflows/CI/badge.svg)
![license](https://img.shields.io/github/license/vladdeSV/scone?color=black)

## Super simple example

<table>
  <tr>
    <td width="50%">

```d
import scone;

void main() {
  frame.title("example");
  frame.size(33, 20);

  bool run = true;
  while(run) {
    foreach(input; input.latest) {
      // if CTRL+C is pressed
      if(input.key == SK.c && input.hasControlKey(SCK.ctrl)) {
        run = false;
      }
    }

    frame.write(
      12, 9,
      Color.yellow.foreground, "Hello ",
      Color.red.foreground, Color.white.background, "World"
    );
    frame.print();
  }
}
```
</td>
    <td width="50%" >
      <br>
      <p align="center"><img height="300" src="https://camo.githubusercontent.com/ad4e79f4b7aa7a2568fa064aaa823945b51be223/68747470733a2f2f692e696d6775722e636f6d2f59383049755a792e706e67"></p>
      <p align="center"><img height="300" src="https://camo.githubusercontent.com/7965e13de89ce8c39fddf008dde099a2be4867c4/68747470733a2f2f692e696d6775722e636f6d2f4c304d555064452e706e67"></p>
    </td>
  </tr>
</table>

### Cross-platform input/output demo
<p align="left">
  <img height="300" src="http://i.imgur.com/b35uwpa.gif">
  <span>&nbsp&nbsp&nbsp&nbsp</span>
  <img height="300" src="http://i.imgur.com/7Yi1h89.gif">
</p>

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
|high performance output|✓||

|input|Windows|POSIX|
|:---|:---:|:---:|
|input detection|✓|✓|
|reliable|✓|*|
|control keys|✓|**|
|key release detection|✓||

 *=Input is converted from arbitrary number sequences (may differ from system to system) to an input event. Basic ASCII should work no matter what system, however special keys like the up-arrow or function keys can vary drastically.
 
 **=Can only register the last pressed control key.

### Install with [dub](https://code.dlang.org/download)

```js
/// dub.json
"dependencies": {
    "scone": "~develop", // do not use in production yet. unfinished
    ...
}
```

```js
/// dub.sdl
dependency "scone" version="~develop", // do not use in production yet. unfinished
```
