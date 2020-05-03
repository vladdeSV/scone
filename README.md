<h1 align="center">🍞 scone</h1>
<h4 align="center">Create cross-platform console/terminal applications with ease</h4>
<p align="center">
  <a href="https://code.dlang.org/packages/scone">
    <img src="https://img.shields.io/dub/v/scone.svg">
  </a>
  <a href="https://github.com/vladdeSV/scone/blob/develop/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg">
  </a>
  <a href="https://travis-ci.org/vladdeSV/scone/">
    <img src="https://travis-ci.org/vladdeSV/scone.svg?branch=v3">
  </a>
  <a href="https://github.com/vladdeSV/scone/issues">
    <img src="https://img.shields.io/github/issues/vladdeSV/scone.svg">
  </a>
</p>

v3 of scone is currently under development (not fully featured). Do not use this in production.

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

To get the hang of **scone** you take a look at the [wiki](https://github.com/vladdeSV/scone/wiki), or you could dive straight into the rather [simple examples](https://github.com/vladdeSV/scone/tree/develop/examples)

### Features
* Display text and colors
* Recieve keyboard input
* Cross-platform
    * Some restrictions apply, please see [OS Limitations](https://github.com/vladdeSV/scone/wiki/OS-Limitations)

#### Simple cross-platform chart
|output|Windows|POSIX|
|:---|:---:|:---:|
|text|✓|✓|
|emoji||✓|
|ansi-color|✓|✓|
|high performance output|✓||
|reliable resize|✓||

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
