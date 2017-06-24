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
}

///All keys which scone can handle
enum SK
{
	///Unknown key (Should never appear. If it does, please report bug)
	unknown,

	///BACKSPACE key
	backspace,

	///TAB key
	tab,

	///CLEAR key
	clear,

	///ENTER key
	enter,

	///SHIFT key
	shift,

	///CTRL key
	control,

	///ALT key
	alt,

	///PAUSE key
	pause,

	///CAPS LOCK key
	capslock,

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

	///SELECT key
	select,

	///PRINT key
	print,

	///EXECUTE key
	execute,

	///PRINT SCREEN key
	print_screen,

	///INS key
	insert,

	///DEL key
	del,

	///HELP key
	help,

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

	///Left Windows key (Natural keyboard)
	windows_left,

	///Right Windows key (Natural keyboard)
	windows_right,

	///Applications key (Natural keyboard)
	apps,

	///Computer Sleep key
	sleep,

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

	///Multiply key
	multiply,

	///Add key
	add,

	///Separator key
	separator,

	///Subtract key
	subtract,

	///Decimal key
	decimal,

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

	///NUM LOCK key
	numlock,

	///SCROLL LOCK key
	scroll_lock,

	///Left SHIFT key
	shift_left,

	///Right SHIFT key
	shift_right,

	///Left CONTROL key
	control_left,

	///Right CONTROL key
	control_right,

	///Left MENU key
	menu_left,

	///Right MENU key
	menu_right,

	///Browser Back key
	browser_back,

	///Browser Forward key
	browser_forward,

	///Browser Refresh key
	browser_refresh,

	///Browser Stop key
	browser_stop,

	///Browser Search key
	browser_search,

	///Browser Favorites key
	browser_favorites,

	///Browser Start and Home key
	browser_home,

	///Volume Mute key
	volume_mute,

	///Volume Down key
	volume_down,

	///Volume Up key
	volume_up,

	///Next Track key
	media_next,

	///Previous Track key
	media_prev,

	///Stop Media key
	media_stop,

	///Play/Pause Media key
	media_play_pause,

	///Start Mail key
	launch_mail,

	///Select Media key
	launch_media_select,

	///Start Application 1 key
	launch_app_1,

	///Start Application 2 key
	launch_app_2,

	//Add OEM to name?
	///For any country/region, the '+' key
	plus,

	///For any country/region, the ',' key
	comma,

	///For any country/region, the '-' key
	minus,

	///For any country/region, the '.' key
	period,

	///Used to pass Unicode characters as if they were keystrokes. The PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
	packet,

	///Erase EOF key
	ereof,

	///Play key
	play,

	///Zoom key
	zoom,

	///Clear key
	oem_clear,

	///Attn key
	attn,

	///CrSel key
	crsel,

	///ExSel key
	exsel,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_1,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_2,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_3,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_4,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_5,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_6,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_7,

	///Used for miscellaneous characters; it can vary by keyboard.
	oem_8,

	///Either the angle bracket key or the backslash key on the RT 102-key
	///keyboard
	oem_102,

	///Control-break processing
	cancel,
}

/**
 * Control keys.
 * Reason to why these are in a separate enum is because it must not be confused
 * with their SK.* counter part.
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
			if(arguments.length != 5) continue; //something isn't right

			auto key = parse!(SK)(arguments[0]);

			foreach(n, seq; arguments[1..$])
			{
				//if sequence is not defined, skip
				if(seq == "-") continue;

				SCK ck;
				switch(n)
				{
				case 1:
					ck = SCK.shift;
					break;
				case 2:
					ck = SCK.ctrl;
					break;
				case 3:
					ck = SCK.alt;
					break;
				default:
					ck = SCK.none;
					break;
				}

				auto ie = InputEvent(key, ck, true);
				auto iseq = InputSequence(sequenceFromString(seq));

				inputSequences[iseq] = ie;
			}
		}
	}

	///table holding all input sequences and their respective input
	private InputEvent[InputSequence] inputSequences;

	///get uint[] from string in the format of "num1,num2,...,numX"
	private uint[] sequenceFromString(string input) pure
	{
		string[] numbers = split(input, ',');
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
"
# de-facto standard
escape	27	-	-	-
del	127	-	-	-
enter	13	-	-	-

# macbook pro (15-inch mid 2012), macOS v10.12.5
a	97	65	1	239, 163, 191
b	98	66	2	226, 128, 186
c	99	67	3	195, 167
d	100	68	4	226, 136, 130
e	101	69	5	195, 169
f	102	70	6	198, 146
g	103	71	7	194, 184
h	105	73	8	-
i	105	73	9	196, 177
j	106	74	10	226, 136, 154
k	107	75	11	194, 170
l	108	76	12	239, 172, 129
m	109	77	13	226, 128, 153
n	110	78	14	226, 128, 152
o	111	79	15	197, 147
p	112	80	16	207, 128
q	113	81	17	226, 128, 162
r	114	82	18	194, 174
s	115	83	19	195, 159
t	116	84	20	226, 128, 160
u	117	85	21	195, 188
v	118	86	22	226, 128, 185
w	119	87	23	206, 169
x	120	88	24	226, 137, 136
y	121	89	25	194, 181
z	122	90	26	195, 183
left	27, 91, 68	27, 91, 49, 59, 50, 68	-	27, 98
up	27, 91, 65	-	-	-
right	27, 91, 67	27, 91, 49, 59, 50, 67	-	27, 102
down	27, 91, 66	-	-	-
key_0	48	61	-	226, 137, 136
key_1	49	33	-	194, 169
key_2	50	34	-	64
key_3	51	35	-	194, 163
key_4	52	226, 130, 172	-	36
key_5	53	37	-	226, 136, 158
key_6	55	47	124	-
key_7	55	47	-	124
key_8	56	40	-	91
key_9	57	41	-	93
tab	9	27, 91, 90	-	-
clear	-	-	-	-
enter	-	-	-	-
shift	-	-	-	-
control	-	-	-	-
alt	-	-	-	-
pause	-	-	-	-
space	32	-	0	194, 160
page_up	-	-	-	-
page_down	-	-	-	-
end	-	-	-	-
home	-	-	-	-
del	-	-	-	-
numpad_0	-	-	-	-
numpad_1	-	-	-	-
numpad_2	-	-	-	-
numpad_3	-	-	-	-
numpad_4	-	-	-	-
numpad_5	-	-	-	-
numpad_6	-	-	-	-
numpad_7	-	-	-	-
numpad_8	-	-	-	-
numpad_9	-	-	-	-
multiply	-	-	-	-
add	-	-	-	-
separator	-	-	-	-
subtract	46	-	-	-
decimal	44	59	-	226, 128, 154
divide	-	-	-	-
f1	27, 79, 80	-	-	27, 91, 49, 55, 126
f2	27, 79, 81	-	-	27, 91, 49, 56, 126
f3	27, 79, 82	-	-	27, 91, 49, 57, 126
f4	27, 79, 83	-	-	27, 91, 50, 48, 126
f5	27, 91, 49, 53, 126	-	-	27, 91, 50, 49, 126
f6	27, 91, 49, 55, 126	-	-	27, 91, 50, 51, 126
f7	27, 91, 49, 56, 126	-	-	27, 91, 50, 52, 126
f8	27, 91, 49, 57, 126	-	-	27, 91, 50, 53, 126
f9	-	-	-	-
f10	27, 91, 50, 49, 126	-	-	27, 91, 50, 56, 126
f11	-	-	-	27, 91, 50, 57, 126
f12	27, 91, 50, 52, 126	-	-	27, 91, 51, 49, 126
plus	43	63	-	194, 177
comma	44	59	-	226, 128, 154
minus	45	95	31	226, 128, 147
period	46	58	-	226, 128, 166
oem_1	195, 165	195, 133	29	203, 153 ";
