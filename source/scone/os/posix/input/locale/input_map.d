module scone.os.posix.input.locale.input_map;

version (Posix)
{
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.os.posix.input.keypress_tree : KeypressTree, Keypress;
    import scone.os.posix.input.locale.input_sequence : InputSequence;
    import std.experimental.logger : sharedLog;

    class InputMap
    {
        this(string tsv)
        {
            this.keypressTree = new KeypressTree();
            loadKeypressTree(this.keypressTree, tsv);
        }

        Keypress[] inputEventsFromSequence(uint[] sequence)
        {
            return this.keypressTree.find(sequence);
        }

        private void loadKeypressTree(KeypressTree tree, string tsv)
        {
            import std.file : exists, readText;
            import std.string : chomp;
            import std.array : split;
            import std.conv : parse;

            string[] ies = tsv.split('\n');

            // Loop all input sequences, and store them
            foreach (s; ies)
            {
                s = s.chomp;
                // if line is empty or begins with #
                if (s == "" || s[0] == '#')
                {
                    continue;
                }

                string[] arguments = split(s, '\t');
                if (arguments.length != 3)
                {
                    sharedLog.warning("Reading input sequences CSV found %i arguments, exprected 3", arguments.length);
                    
                    continue;
                }

                auto key = parse!(SK)(arguments[0]);
                auto controlKey = parse!(SCK)(arguments[1]);
                auto seq = arguments[2];

                if (seq == "-")
                {
                    continue;
                }

                bool inserted = tree.insert(sequenceFromString(seq), Keypress(key, controlKey));
                if(!inserted)
                {
                    sharedLog.error("Could not map sequence ", seq, " to keypress ", key, "+", controlKey);
                }
            }
        }

        /// get uint[], from string in the format of "num1,num2,...,numX"
        private uint[] sequenceFromString(string input) pure
        {
            import std.array : split;
            import std.conv : parse;

            string[] numbers = split(input, ",");
            uint[] sequence;
            foreach (number_as_string; numbers)
            {
                sequence ~= parse!uint(number_as_string);
            }

            return sequence;
        }

        private KeypressTree keypressTree;
    }
}
