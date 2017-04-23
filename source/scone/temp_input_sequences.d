module tip;

import scone.input;

import std.array : split;
import std.conv : to, parse;
import std.file : exists, readText;
import std.string : chomp;

///
struct InputSequence
{
    this(uint[] t)
    {
        value = t;
    }

    uint[] value;
}

///use input_sequences as default keymap
void loadInputSequneces()
{
    enum file_name = "input_sequences";

    //if file `input_sequence` exists, load keymap
    if(exists(file_name))
    {
        string[] ies = split(readText(file_name), '\n');

        foreach(s; ies)
        {
            s = s.chomp;
            //if line begins with #
            if(s == "" || s[0] == '#') continue;

            string[] arguments = split(s, '\t');
            if(arguments.length != 5) continue; //something isn't right

            foreach(n, seq; arguments[1..$])
            {
                //if sequence is not defined, skip
                if(seq == "-") continue;

                SCK ck;
                switch(n)
                {
                case 2:
                    ck = SCK.shift;
                    break;
                case 3:
                    ck = SCK.ctrl;
                    break;
                case 4:
                    ck = SCK.alt;
                    break;
                default:
                    ck = SCK.none;
                    break;
                }

                auto ie = InputEvent(parse!(SK)(arguments[0]), ck, true);
                auto iseq = InputSequence(sequenceFromString(seq));

                it[iseq] = ie;
            }
        }
    }
    else
    {
        version(OSX)
        {
            //set default keymap for OSX
        }
        else
        {
            //set default keymap for Linux
        }
    }
}

///get uint[] from string in the format of "num1,num2,...,numX"
uint[] sequenceFromString(string input)
{
    string[] numbers = split(input, ',');
    uint[] sequence;
    foreach(number_as_string; numbers)
    {
        sequence ~= parse!uint(number_as_string);
    }

    return sequence;
}

///table holding all input sequences and their respective input
InputEvent[InputSequence] it;

///get InputEvent from sequence
InputEvent eventFromSequence(InputSequence iseq)
{
    if((iseq in it) !is null)
    {
        return it[iseq];
    }

    return InputEvent(SK.unknown, SCK.none, false);
}

///