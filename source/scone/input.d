module scone.input;

import scone.misc.utility : hasFlag;
import scone.os;

/**
 * Key event structure
 * Contains general information about a key press
 */
struct InputEvent
{
	/**
	 * Initialize an InputEvent
	 */
	this(SK key, SCK controlKey, bool pressed)
	{
		_key = key;
		_controlKey = controlKey;
		_pressed = pressed;
	}

	/**
	 * Get the key
	 * Returns: SK (enum) of the key being pressed
	 */
	auto key() @property
	{
		return _key;
	}

	/**
	 * Check if the button is pressed or released.
	 * Returns: bool, true if pressed, false if not
	 */
	auto pressed() @property
	{
		return _pressed;
	}

	/**
	 * Check if the InputEvent has a "control key" pressed.
	 * Returns: true, if all control keys entered are pressed
	 *
	 * Example:
	 * --------------------
	 * foreach(input; getInputs())
	 * {
	 *     if(input.hasControlKey(ControlKey.CTRL | ControlKey.ALT |
	 *        ControlKey.SHIFT))
	 *     {
	 *         //do something if CTRL, ALT and SHIFT are held down...
	 *     }
	 * }
	 * --------------------
	 */
	auto hasControlKey(SCK ck)
	{
		return hasFlag(controlKey, ck);
	}

	/**
	 * Get control all keys. Used to check if ONLY specific control keys are
	 * activated.
	 * Returns: SCK (enum)
	 * Example:
	 * ---
	 * foreach(input; getInputs())
	 * {
	 *     if(input.controlKey == ControlKey.CTRL | ControlKey.SHIFT)
	 *     {
	 *         //do something if only CTRL and SHIFT are held down...
	 *     }
	 * }
	 * ---
	 */
	auto controlKey() @property
	{
		return _controlKey;
	}

	private SK _key;
	private SCK _controlKey;
	private bool _pressed;

	version(Posix)
	{
		/**
		* Note: POSIX only.
		* Get the ASCII-code sequence returned from the keypress on POSIX systems.
		* Returns: uint[]
		*/
		auto keySequences() @property
		{
			return _keySequences;
		}

		package(scone) uint[] _keySequences;
	}
}

///All keys which scone can handle
///NOTE: Limited support for POSIX
enum SK
{
	///Unknown key (Should never appear. If it does, please report bug)
	unknown,

	///Control-break processing
	cancel,

	///BACKSPACE key
	backspace,

	///DEL key
	del,

	///TAB key
	tab,

	///ENTER key
	enter,

	///ESC key
	escape,

	///SPACEBAR
	space,

	///PAGE UP key
	page_up,

	///PAGE DOWN key
	page_down,

	///END key
	end,

	///HOME key
	home,

	///LEFT ARROW key
	left,

	///UP ARROW key
	up,

	///RIGHT ARROW key
	right,

	///DOWN ARROW key
	down,

	///0 key
	key_0,

	///1 key
	key_1,

	///2 key
	key_2,

	///3 key
	key_3,

	///4 key
	key_4,

	///5 key
	key_5,

	///6 key
	key_6,

	///7 key
	key_7,

	///8 key
	key_8,

	///9 key
	key_9,

	///A key
	a,

	///B key
	b,

	///C key
	c,

	///D key
	d,

	///E key
	e,

	///F key
	f,

	///G key
	g,

	///H key
	h,

	///I key
	i,

	///J key
	j,

	///K key
	k,

	///L key
	l,

	///M key
	m,

	///N key
	n,

	///O key
	o,

	///P key
	p,

	///Q key
	q,

	///R key
	r,

	///S key
	s,

	///T key
	t,

	///U key
	u,

	///V key
	v,

	///W key
	w,

	///X key
	x,

	///Y key
	y,

	///Z key
	z,

	///Numeric keypad 0 key
	numpad_0,

	///Numeric keypad 1 key
	numpad_1,

	///Numeric keypad 2 key
	numpad_2,

	///Numeric keypad 3 key
	numpad_3,

	///Numeric keypad 4 key
	numpad_4,

	///Numeric keypad 5 key
	numpad_5,

	///Numeric keypad 6 key
	numpad_6,

	///Numeric keypad 7 key
	numpad_7,

	///Numeric keypad 8 key
	numpad_8,

	///Numeric keypad 9 key
	numpad_9,

	///For any country/region, the '+' key
	plus,

	///For any country/region, the '-' key
	minus,

	///For any country/region, the '.' key
	period,

	///For any country/region, the ',' key
	comma,

	///Asterisk key
	asterisk,

	///Divide key
	divide,

	///F1 key
	f1,

	///F2 key
	f2,

	///F3 key
	f3,

	///F4 key
	f4,

	///F5 key
	f5,

	///F6 key
	f6,

	///F7 key
	f7,

	///F8 key
	f8,

	///F9 key
	f9,

	///F10 key
	f10,

	///F11 key
	f11,

	///F12 key
	f12,

	///F13 key
	f13,

	///F14 key
	f14,

	///F15 key
	f15,

	///F16 key
	f16,

	///F17 key
	f17,

	///F18 key
	f18,

	///F19 key
	f19,

	///F20 key
	f20,

	///F21 key
	f21,

	///F22 key
	f22,

	///F23 key
	f23,

	///F24 key
	f24,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_1,

	///ditto
	oem_2,

	///ditto
	oem_3,

	///ditto
	oem_4,

	///ditto
	oem_5,

	///ditto
	oem_6,

	///ditto
	oem_7,

	///ditto
	oem_8,

	///Either the angle bracket key or the backslash key on the RT 102-key keyboard
	oem_102,
}

/**
 * Control keys
 */
enum SCK
{
	///No control key is being pressed
	none = 0,

	///CAPS LOCK light is activated
	capslock = 1,

	///NUM LOCK is activated
	numlock = 2,

	///SCROLL LOCK is activated
	scrolllock = 4,

	///SHIFT key is pressed
	shift = 8,

	///The key is enhanced (?)
	enhanced = 16,

	///Left or right ALT key is pressed
	alt = 32,

	///Left or right CTRL key is pressed
	ctrl = 64,
}

///when on posix, a list of keypresses is loaded and used
version(Posix)
{
	import std.array : split;
	import std.conv : to, parse;
	import std.file : exists, readText;
	import std.string : chomp;

	/**
	 * Wrapper for an input sequence sent by the POSIX terminal
	 * An input from the terminal is given by numbers in sequence
	 *
	 * For example, the right arrow key might send "27, 91, 67",
	 * and will be stored as [27, 91, 67]
	 */
	struct InputSequence
	{
		this(uint[] t)
		{
			value = t;
		}

		uint[] value;
		alias value this;
	}

	///get InputEvent from sequence
	InputEvent eventFromSequence(InputSequence iseq)
	{
		//check for input sequence in map
		if((iseq in inputSequences) !is null)
		{
			return inputSequences[iseq];
		}

		//if not found, return unknown input
		return InputEvent(SK.unknown, SCK.none, false);
	}

	///use input_sequences as default keymap
	void loadInputSequneces()
	{
		enum file_name = "input_sequences.scone";

		string[] ies = _inputSequences.split('\n');

		//if file `input_sequence` exists, load keymap
		//this overrides existing keybinds
		if(exists(file_name))
		{
			ies ~= file_name.readText.split('\n');
		}

		foreach(s; ies)
		{
			s = s.chomp;
			//if line begins with #
			if(s == "" || s[0] == '#') continue;

			string[] arguments = split(s, '\t');
			if(arguments.length != 3) continue; //something isn't right

			auto key = parse!(SK)(arguments[0]);
			auto sck = parse!(SCK)(arguments[1]);
			auto seq = arguments[2];
			//if sequence is not defined, skip
			if(seq == "-") continue;

			auto ie = InputEvent(key, sck, true);
			auto iseq = InputSequence(sequenceFromString(seq));

			inputSequences[iseq] = ie;
		}
	}

	///table holding all input sequences and their respective input
	private InputEvent[InputSequence] inputSequences;

	///get uint[] from string in the format of "num1,num2,...,numX"
	private uint[] sequenceFromString(string input) pure
	{
		string[] numbers = split(input, ",");
		uint[] sequence;
		foreach(number_as_string; numbers)
		{
			sequence ~= parse!uint(number_as_string);
		}

		return sequence;
	}
}

///default keybindings. tested on mac
private enum _inputSequences =
"# macOS Sierra v10.12.5, MacBook Pro (15-inch, Mid 2012)
a	none	97
b	none	98
c	none	99
d	none	100
e	none	101
f	none	102
g	none	103
h	none	104
i	none	105
j	none	106
k	none	107
l	none	108
m	none	109
n	none	110
o	none	111
p	none	112
q	none	113
r	none	114
s	none	115
t	none	116
u	none	117
v	none	118
w	none	119
x	none	120
y	none	121
z	none	122
tab	none	9
page_up	none	-
page_down	none	-
end	none	-
home	none	-
left	none	27,91,68
up	none	27,91,65
right	none	27,91,67
down	none	27,91,66
key_0	none	48
key_1	none	49
key_2	none	50
key_3	none	51
key_4	none	52
key_5	none	53
key_6	none	54
key_7	none	55
key_8	none	56
key_9	none	57
numpad_0	none	48
numpad_1	none	49
numpad_2	none	50
numpad_3	none	51
numpad_4	none	52
numpad_5	none	53
numpad_6	none	54
numpad_7	none	55
numpad_8	none	56
numpad_9	none	57
plus	none	43
minus	none	45
period	none	46
comma	none	44
asterisk	none	42
divide	none	47
f1	none	27,79,80
f2	none	27,79,81
f3	none	27,79,82
f4	none	27,79,83
f5	none	27,91,49,53,126
f6	none	27,91,49,55,126
f7	none	27,91,49,56,126
f8	none	27,91,49,57,126
f9	none	27,91,50,48,126
f10	none	27,91,50,49,126
f11	none	27,91,50,51,126
f12	none	27,91,50,52,126
f13	none	-
f14	none	-
f15	none	-
f16	none	-
f17	none	-
f18	none	-
f19	none	-
f20	none	-
f21	none	-
f22	none	-
f23	none	-
f24	none	-
oem_1	none	195,165
oem_2	none	-
oem_3	none	-
oem_4	none	-
oem_5	none	-
oem_6	none	-
oem_7	none	-
oem_8	none	-
oem_102	none	-
a	shift	65
b	shift	66
c	shift	67
d	shift	68
e	shift	69
f	shift	70
g	shift	71
h	shift	72
i	shift	73
j	shift	74
k	shift	75
l	shift	76
m	shift	77
n	shift	78
o	shift	79
p	shift	80
q	shift	81
r	shift	82
s	shift	83
t	shift	84
u	shift	85
v	shift	86
w	shift	87
x	shift	88
y	shift	89
z	shift	90
tab	shift	27,91,90
page_up	shift	27,91,53,126
page_down	shift	27,91,54,126
end	shift	27,91,70
home	shift	27,91,72
left	shift	27,91,49,59,50,68
up	shift	-
right	shift	27,91,49,59,50,67
down	shift	-
key_0	shift	61
key_1	shift	33
key_2	shift	34
key_3	shift	35
key_4	shift	36
key_4	shift	226,130,172
key_5	shift	37
key_6	shift	38
key_7	shift	47
key_8	shift	40
key_9	shift	41
numpad_0	shift	-
numpad_1	shift	-
numpad_2	shift	-
numpad_3	shift	-
numpad_4	shift	-
numpad_5	shift	-
numpad_6	shift	-
numpad_7	shift	-
numpad_8	shift	-
numpad_9	shift	-
plus	shift	-
minus	shift	-
period	shift	58
comma	shift	59
asterisk	shift	-
divide	shift	-
f1	shift	-
f2	shift	-
f3	shift	-
f4	shift	-
f5	shift	-
f6	shift	-
f7	shift	-
f8	shift	-
f9	shift	-
f10	shift	-
f11	shift	-
f12	shift	27,91,51,52,126
f13	shift	-
f14	shift	-
f15	shift	-
f16	shift	-
f17	shift	-
f18	shift	-
f19	shift	-
f20	shift	-
f21	shift	-
f22	shift	-
f23	shift	-
f24	shift	-
oem_1	shift	-
oem_2	shift	-
oem_3	shift	-
oem_4	shift	-
oem_5	shift	-
oem_6	shift	-
oem_7	shift	-
oem_8	shift	-
oem_102	shift	-
a	ctrl	1
b	ctrl	2
c	ctrl	3
d	ctrl	4
e	ctrl	5
f	ctrl	6
g	ctrl	7
h	ctrl	8
i	ctrl	9
j	ctrl	10
k	ctrl	11
l	ctrl	12
m	ctrl	-
n	ctrl	14
o	ctrl	15
p	ctrl	16
q	ctrl	17
r	ctrl	18
s	ctrl	19
t	ctrl	20
u	ctrl	21
v	ctrl	22
w	ctrl	23
x	ctrl	24
y	ctrl	25
z	ctrl	26
tab	ctrl	-
page_up	ctrl	-
page_down	ctrl	-
end	ctrl	-
home	ctrl	-
left	ctrl	-
up	ctrl	-
right	ctrl	-
down	ctrl	-
key_0	ctrl	-
key_1	ctrl	-
key_2	ctrl	-
key_3	ctrl	-
key_4	ctrl	-
key_5	ctrl	-
key_6	ctrl	-
key_7	ctrl	-
key_8	ctrl	-
key_9	ctrl	-
numpad_0	ctrl	-
numpad_1	ctrl	-
numpad_2	ctrl	-
numpad_3	ctrl	-
numpad_4	ctrl	-
numpad_5	ctrl	-
numpad_6	ctrl	-
numpad_7	ctrl	-
numpad_8	ctrl	-
numpad_9	ctrl	-
plus	ctrl	-
minus	ctrl	-
period	ctrl	-
comma	ctrl	-
asterisk	ctrl	-
divide	ctrl	-
f1	ctrl	-
f2	ctrl	-
f3	ctrl	-
f4	ctrl	-
f5	ctrl	-
f6	ctrl	-
f7	ctrl	-
f8	ctrl	-
f9	ctrl	-
f10	ctrl	-
f11	ctrl	-
f12	ctrl	-
f13	ctrl	-
f14	ctrl	-
f15	ctrl	-
f16	ctrl	-
f17	ctrl	-
f18	ctrl	-
f19	ctrl	-
f20	ctrl	-
f21	ctrl	-
f22	ctrl	-
f23	ctrl	-
f24	ctrl	-
oem_1	ctrl	-
oem_2	ctrl	-
oem_3	ctrl	-
oem_4	ctrl	-
oem_5	ctrl	-
oem_6	ctrl	-
oem_7	ctrl	-
oem_8	ctrl	-
oem_102	ctrl	-
a	alt	239,163,191
b	alt	226,128,186
c	alt	195,167
d	alt	226,136,130
e	alt	195,169
f	alt	198,146
g	alt	194,184
h	alt	203,155
i	alt	196,177
j	alt	226,136,154
k	alt	194,170
l	alt	239,172,129
m	alt	226,128,153
n	alt	226,128,152
o	alt	197,147
p	alt	207,128
q	alt	226,128,162
r	alt	194,174
s	alt	195,159
t	alt	226,128,160
u	alt	195,188
v	alt	226,128,185
w	alt	206,169
x	alt	226,137,136
y	alt	194,181
z	alt	195,183
tab	alt	-
page_up	alt	-
page_down	alt	-
end	alt	-
home	alt	-
left	alt	27,98
up	alt	-
right	alt	27,102
down	alt	-
key_0	alt	226,137,136
key_1	alt	194,169
key_2	alt	64
key_3	alt	194,163
key_4	alt	36
key_5	alt	226,136,158
key_6	alt	194,167
key_7	alt	124
key_8	alt	91
key_9	alt	93
numpad_0	alt	-
numpad_1	alt	-
numpad_2	alt	-
numpad_3	alt	-
numpad_4	alt	-
numpad_5	alt	-
numpad_6	alt	-
numpad_7	alt	-
numpad_8	alt	-
numpad_9	alt	-
plus	alt	-
minus	alt	-
period	alt	226,128,166
comma	alt	226,128,154
asterisk	alt	-
divide	alt	-
f1	alt	27,91,49,55,126
f2	alt	27,91,49,56,126
f3	alt	27,91,49,57,126
f4	alt	27,91,50,48,126
f5	alt	27,91,50,49,126
f6	alt	27,91,50,51,126
f7	alt	27,91,50,52,126
f8	alt	27,91,50,53,126
f9	alt	27,91,50,54,126
f10	alt	27,91,50,56,126
f11	alt	27,91,50,57,126
f12	alt	27,91,51,49,126
f13	alt	-
f14	alt	-
f15	alt	-
f16	alt	-
f17	alt	-
f18	alt	-
f19	alt	-
f20	alt	-
f21	alt	-
f22	alt	-
f23	alt	-
f24	alt	-
oem_1	alt	203,153
oem_2	alt	-
oem_3	alt	-
oem_4	alt	-
oem_5	alt	-
oem_6	alt	-
oem_7	alt	-
oem_8	alt	-
oem_102	alt	-

# Ubuntu 16.10 sv_SE
a	none	97
b	none	98
c	none	99
d	none	100
e	none	101
f	none	102
g	none	103
h	none	104
i	none	105
j	none	106
k	none	107
l	none	108
m	none	109
n	none	110
o	none	111
p	none	112
q	none	113
r	none	114
s	none	115
t	none	116
u	none	117
v	none	118
w	none	119
x	none	120
y	none	121
z	none	122
tab	none	9
page_up	none	27,91,53,126
page_down	none	27,91,54,126
end	none	27,91,70
home	none	27,91,72
left	none	27,91,68
up	none	27,91,65
right	none	27,91,67
down	none	27,91,66
key_0	none	48
key_1	none	49
key_2	none	50
key_3	none	51
key_4	none	52
key_5	none	53
key_6	none	54
key_7	none	55
key_8	none	56
key_9	none	57
numpad_0	none	48
numpad_1	none	-
numpad_2	none	-
numpad_3	none	-
numpad_4	none	-
numpad_5	none	-
numpad_6	none	-
numpad_7	none	-
numpad_8	none	-
numpad_9	none	-
plus	none	43
minus	none	45
period	none	46
comma	none	44
asterisk	none	42
divide	none	47
f1	none	-
f2	none	27,79,81
f3	none	27,79,82
f4	none	27,79,83
f5	none	27,91,49,53,126
f6	none	27,91,49,55,126
f7	none	27,91,49,56,126
f8	none	27,91,49,57,126
f9	none	27,91,50,48,126
f10	none	27,91,50,49,126
f11	none	-
f12	none	27,91,50,52,126
f13	none	-
f14	none	-
f15	none	-
f16	none	-
f17	none	-
f18	none	-
f19	none	-
f20	none	-
f21	none	-
f22	none	-
f23	none	-
f24	none	-
oem_1	none	195,165
oem_2	none	195,164
oem_3	none	195,182
oem_4	none	-
oem_5	none	-
oem_6	none	-
oem_7	none	-
oem_8	none	-
oem_102	none	-
a	shift	65
b	shift	66
c	shift	67
d	shift	68
e	shift	69
f	shift	70
g	shift	71
h	shift	72
i	shift	73
j	shift	74
k	shift	75
l	shift	76
m	shift	77
n	shift	78
o	shift	79
p	shift	80
q	shift	81
r	shift	82
s	shift	83
t	shift	84
u	shift	85
v	shift	86
w	shift	87
x	shift	88
y	shift	89
z	shift	90
tab	shift	27,91,90
page_up	shift	-
page_down	shift	-
end	shift	-
home	shift	-
left	shift	27,91,49,59,50,68
up	shift	27,91,49,59,50,65
right	shift	27,91,49,59,50,67
down	shift	27,91,49,59,50,66
key_0	shift	61
key_1	shift	33
key_2	shift	34
key_3	shift	35
key_4	shift	194,164
key_5	shift	37
key_6	shift	38
key_7	shift	47
key_8	shift	40
key_9	shift	41
numpad_0	shift	-
numpad_1	shift	-
numpad_2	shift	-
numpad_3	shift	-
numpad_4	shift	-
numpad_5	shift	-
numpad_6	shift	-
numpad_7	shift	-
numpad_8	shift	-
numpad_9	shift	-
plus	shift	-
minus	shift	-
period	shift	58
comma	shift	59
asterisk	shift	-
divide	shift	-
f1	shift	27,91,49,59,50,80
f2	shift	27,91,49,59,50,81
f3	shift	27,91,49,59,50,82
f4	shift	27,91,49,59,50,83
f5	shift	27,91,49,53,59,50,126
f6	shift	27,91,49,55,59,50,126
f7	shift	27,91,49,56,59,50,126
f8	shift	27,91,49,57,59,50,126
f9	shift	27,91,50,48,59,50,126
f10	shift	-
f11	shift	27,91,50,51,59,50,126
f12	shift	27,91,50,52,59,50,126
f13	shift	-
f14	shift	-
f15	shift	-
f16	shift	-
f17	shift	-
f18	shift	-
f19	shift	-
f20	shift	-
f21	shift	-
f22	shift	-
f23	shift	-
f24	shift	-
oem_1	shift	195,133
oem_2	shift	195,132
oem_3	shift	195,150
oem_4	shift	-
oem_5	shift	-
oem_6	shift	-
oem_7	shift	-
oem_8	shift	-
oem_102	shift	-
a	ctrl	1
b	ctrl	2
c	ctrl	3
d	ctrl	4
e	ctrl	5
f	ctrl	6
g	ctrl	7
h	ctrl	8
i	ctrl	9
j	ctrl	10
k	ctrl	11
l	ctrl	12
m	ctrl	-
n	ctrl	14
o	ctrl	15
p	ctrl	16
q	ctrl	17
r	ctrl	18
s	ctrl	19
t	ctrl	20
u	ctrl	21
v	ctrl	22
w	ctrl	23
x	ctrl	24
y	ctrl	25
z	ctrl	26
tab	ctrl	-
page_up	ctrl	27,91,53,59,53,126
page_down	ctrl	27,91,54,59,53,126
end	ctrl	27,91,49,59,53,70
home	ctrl	27,91,49,59,53,72
left	ctrl	27,91,49,59,53,68
up	ctrl	27,91,49,59,53,65
right	ctrl	27,91,49,59,53,67
down	ctrl	27,91,49,59,53,66
key_0	ctrl	-
key_1	ctrl	-
key_2	ctrl	-
key_3	ctrl	-
key_4	ctrl	28
key_5	ctrl	29
key_6	ctrl	30
key_7	ctrl	31
key_8	ctrl	-
key_9	ctrl	-
numpad_0	ctrl	-
numpad_1	ctrl	-
numpad_2	ctrl	-
numpad_3	ctrl	-
numpad_4	ctrl	-
numpad_5	ctrl	-
numpad_6	ctrl	-
numpad_7	ctrl	-
numpad_8	ctrl	-
numpad_9	ctrl	-
plus	ctrl	-
minus	ctrl	-
period	ctrl	-
comma	ctrl	-
asterisk	ctrl	-
divide	ctrl	-
f1	ctrl	27,91,49,59,53,80
f2	ctrl	27,91,49,59,53,81
f3	ctrl	27,91,49,59,53,82
f4	ctrl	27,91,49,59,53,83
f5	ctrl	27,91,49,53,59,53,126
f6	ctrl	27,91,49,55,59,53,126
f7	ctrl	27,91,49,56,59,53,126
f8	ctrl	27,91,49,57,59,53,126
f9	ctrl	27,91,50,48,59,53,126
f10	ctrl	27,91,50,49,59,53,126
f11	ctrl	27,91,50,51,59,53,126
f12	ctrl	27,91,50,52,59,53,126
f13	ctrl	-
f14	ctrl	-
f15	ctrl	-
f16	ctrl	-
f17	ctrl	-
f18	ctrl	-
f19	ctrl	-
f20	ctrl	-
f21	ctrl	-
f22	ctrl	-
f23	ctrl	-
f24	ctrl	-
oem_1	ctrl	-
oem_2	ctrl	-
oem_3	ctrl	-
oem_4	ctrl	-
oem_5	ctrl	-
oem_6	ctrl	-
oem_7	ctrl	-
oem_8	ctrl	-
oem_102	ctrl	-
a	alt	27,97
b	alt	27,98
c	alt	27,99
d	alt	27,100
e	alt	27,101
f	alt	27,102
g	alt	27,103
h	alt	27,104
i	alt	27,105
j	alt	27,106
k	alt	27,107
l	alt	27,108
m	alt	27,109
n	alt	27,110
o	alt	27,111
p	alt	27,112
q	alt	27,113
r	alt	27,114
s	alt	27,115
t	alt	27,116
u	alt	27,117
v	alt	27,118
w	alt	27,119
x	alt	27,120
y	alt	27,121
z	alt	27,122
tab	alt	-
page_up	alt	27,91,53,59,51,126
page_down	alt	27,91,54,59,51,126
end	alt	27,91,49,59,51,70
home	alt	27,91,49,59,51,72
left	alt	27,91,49,59,51,68
up	alt	27,91,49,59,51,65
right	alt	27,91,49,59,51,67
down	alt	27,91,49,59,51,66
key_0	alt	27,48
key_1	alt	27,49
key_2	alt	27,50
key_3	alt	27,51
key_4	alt	27,52
key_5	alt	27,53
key_6	alt	27,54
key_7	alt	27,55
key_8	alt	27,56
key_9	alt	27,57
numpad_0	alt	-
numpad_1	alt	-
numpad_2	alt	-
numpad_3	alt	-
numpad_4	alt	-
numpad_5	alt	-
numpad_6	alt	-
numpad_7	alt	-
numpad_8	alt	-
numpad_9	alt	-
plus	alt	-
minus	alt	-
period	alt	27,46
comma	alt	27,44
asterisk	alt	-
divide	alt	-
f1	alt	-
f2	alt	-
f3	alt	-
f4	alt	39
f5	alt	27,91,49,53,59,51,126
f6	alt	27,91,49,55,59,51,126
f7	alt	-
f8	alt	-
f9	alt	27,91,50,48,59,51,126
f10	alt	-
f11	alt	27,91,50,51,59,51,126
f12	alt	27,91,50,52,59,51,126
f13	alt	-
f14	alt	-
f15	alt	-
f16	alt	-
f17	alt	-
f18	alt	-
f19	alt	-
f20	alt	-
f21	alt	-
f22	alt	-
f23	alt	-
f24	alt	-
oem_1	alt	27,195,165
oem_2	alt	27,195,164
oem_3	alt	27,195,182
oem_4	alt	-
oem_5	alt	-
oem_6	alt	-
oem_7	alt	-
oem_8	alt	-
oem_102	alt	-

# de-facto standard. adding these last will override redirects of there keys
escape	none	27
del	none	127
enter	none	13";
