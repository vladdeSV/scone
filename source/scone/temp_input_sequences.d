module tip;


import scone.input;

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
    import std.file : exists, readText;
    import std.array : split;
    import std.conv : to, parse;

    import std.stdio;

    if(exists("input_sequences"))
    {
        string[] ies = split(readText("input_sequences"), '\n');

        foreach(s; ies)
        {
            string[] aaa = split(s,'\t');
            if(!(aaa.length > 2)) continue; //something isn't right
            
            InputEvent ie = InputEvent(parse!(SK)(aaa[0]), parse!(SCK)(aaa[1]), true);

            uint[] seq;
            foreach(number_as_string; aaa[2 .. $])
            {
                seq ~= parse!uint(number_as_string);
            }

            InputSequence iseq = InputSequence(seq);

            it[iseq] = ie;
        }

    }
    
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