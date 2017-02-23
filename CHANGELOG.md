# Change Log

## v2.0.1-pre.1
_23 February 2016_

 * POSIX: Basic keyboard input (tested on macOS)
 * Defualt documentation generated in `docs/`
 * Updated README.md to suit v2.0.0
 * Minor bug-fixes

## v2.0.0-pre.0
_19 February 2017_

 * `sconeOpen();`/`sconeClose();` is now run by default.
 * No more `class Frame();`. Replaced by `struct Window`, accessed by `static Window window;`
 * `window` acts as a gateway to the console/terminal.
 * Improvement to `struct window`, modifying it is done from here.
 * Removed half-broken UI library. Need to come up with something better.
 * Tons of code refactoring.

## v1.1.0
_2 July 2016_

 * Simplified initialization. renamed `sconeInit(SconeModule module)` to `sconeOpen()`.
 * Added UI library, makes it easier for input boxes, such as name fields.
 * Add localization support.

## v1.0.1
_1 July 2016_

 * Cleaned up code.


## v1.0.0
_20 June 2016_

 * Initial release.
