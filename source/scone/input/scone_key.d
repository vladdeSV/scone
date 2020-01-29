module scone.input.scone_key;

enum SK
{
    /// Unknown key (Should never appear. If it does, please report bug)
    unknown,

    /// Control-break processing
    cancel,

    /// BACKSPACE key
    backspace,

    /// DEL key
    del,

    /// TAB key
    tab,

    /// ENTER key
    enter,

    /// ESC key
    escape,

    /// SPACEBAR
    space,

    /// PAGE UP key
    page_up,

    /// PAGE DOWN key
    page_down,

    /// END key
    end,

    /// HOME key
    home,

    /// LEFT ARROW key
    left,

    /// UP ARROW key
    up,

    /// RIGHT ARROW key
    right,

    /// DOWN ARROW key
    down,

    /// 0 key
    key_0,

    /// 1 key
    key_1,

    /// 2 key
    key_2,

    /// 3 key
    key_3,

    /// 4 key
    key_4,

    /// 5 key
    key_5,

    /// 6 key
    key_6,

    /// 7 key
    key_7,

    /// 8 key
    key_8,

    /// 9 key
    key_9,

    /// A key
    a,

    /// B key
    b,

    /// C key
    c,

    /// D key
    d,

    /// E key
    e,

    /// F key
    f,

    /// G key
    g,

    /// H key
    h,

    /// I key
    i,

    /// J key
    j,

    /// K key
    k,

    /// L key
    l,

    /// M key
    m,

    /// N key
    n,

    /// O key
    o,

    /// P key
    p,

    /// Q key
    q,

    /// R key
    r,

    /// S key
    s,

    /// T key
    t,

    /// U key
    u,

    /// V key
    v,

    /// W key
    w,

    /// X key
    x,

    /// Y key
    y,

    /// Z key
    z,

    /// Numeric keypad 0 key
    numpad_0,

    /// Numeric keypad 1 key
    numpad_1,

    /// Numeric keypad 2 key
    numpad_2,

    /// Numeric keypad 3 key
    numpad_3,

    /// Numeric keypad 4 key
    numpad_4,

    /// Numeric keypad 5 key
    numpad_5,

    /// Numeric keypad 6 key
    numpad_6,

    /// Numeric keypad 7 key
    numpad_7,

    /// Numeric keypad 8 key
    numpad_8,

    /// Numeric keypad 9 key
    numpad_9,

    /// For any country/region, the '+' key
    plus,

    /// For any country/region, the '-' key
    minus,

    /// For any country/region, the '.' key
    period,

    /// For any country/region, the ',' key
    comma,

    /// Asterisk key
    asterisk,

    /// Divide key
    divide,

    /// F1 key
    f1,

    /// F2 key
    f2,

    /// F3 key
    f3,

    /// F4 key
    f4,

    /// F5 key
    f5,

    /// F6 key
    f6,

    /// F7 key
    f7,

    /// F8 key
    f8,

    /// F9 key
    f9,

    /// F10 key
    f10,

    /// F11 key
    f11,

    /// F12 key
    f12,

    /// F13 key
    f13,

    /// F14 key
    f14,

    /// F15 key
    f15,

    /// F16 key
    f16,

    /// F17 key
    f17,

    /// F18 key
    f18,

    /// F19 key
    f19,

    /// F20 key
    f20,

    /// F21 key
    f21,

    /// F22 key
    f22,

    /// F23 key
    f23,

    /// F24 key
    f24,

    /// Used for miscellaneous characters; it can vary by keyboard.
    oem_1,

    /// ditto
    oem_2,

    /// ditto
    oem_3,

    /// ditto
    oem_4,

    /// ditto
    oem_5,

    /// ditto
    oem_6,

    /// ditto
    oem_7,

    /// ditto
    oem_8,

    /// Either the angle bracket key or the backslash key on the RT 102-key keyboard
    oem_102,
}