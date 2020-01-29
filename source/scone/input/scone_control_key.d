module scone.input.scone_control_key;

enum SCK
{
    /// No control key is being pressed
    none = 0,

    /// CAPS LOCK light is activated
    capslock = 1,

    /// NUM LOCK is activated
    numlock = 2,

    /// SCROLL LOCK is activated
    scrolllock = 4,

    /// SHIFT key is pressed
    shift = 8,

    /// The key is enhanced (?)
    enhanced = 16,

    /// Left or right ALT key is pressed
    alt = 32,

    /// Left or right CTRL key is pressed
    ctrl = 64,
}