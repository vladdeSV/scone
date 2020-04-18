module scone.os.posix.locale.input_map;

version (Posix)
{
    import scone.input.input_event : InputEvent;
    import scone.os.posix.locale.input_sequence;
    import std.array : split;
    import std.conv : to, parse;
    import std.file : exists, readText;
    import std.string : chomp;
    import scone.input.scone_key : SK;
    import scone.input.scone_control_key : SCK;

    class InputMap
    {
        this(string tsv)
        {
            inputEventSequences = loadInputSequneces(tsv);
        }

        InputEvent[] inputEventsFromSequence(uint[] sequence)
        {
            // todo: this should check for multiple keypresses, according to Github issue #13
            auto inputEvents = [eventFromSequence(InputSequence(sequence))];

            return inputEvents;
        }

        /// Load and use the file 'input_sequences.scone' as default keymap
        private InputEvent[InputSequence] loadInputSequneces(string tsv)
        {
            string[] ies = tsv.split('\n');

            InputEvent[InputSequence] map;

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
                    // log(warning, "input sequence of incorrect. exprected 3 arguments, got %i", arguments.length);
                    continue;
                }

                auto key = parse!(SK)(arguments[0]);
                auto controlKey = parse!(SCK)(arguments[1]);
                auto seq = arguments[2];

                if (seq == "-")
                {
                    continue;
                }

                auto ie = InputEvent(key, controlKey, true);
                auto iseq = InputSequence(sequenceFromString(seq));
                //ie._keySequences = iseq;

                if ((iseq in map) !is null)
                {
                    auto storedInputEvent = map[iseq];

                    if (ie.key != storedInputEvent.key
                            || ie.controlKey != storedInputEvent.controlKey)
                    {
                        // log(notice, "Replacing ", storedInputEvent, " with ", ie);
                    }
                }

                map[iseq] = ie;
            }

            return map;
        }

        private void createInputSequence(InputEvent ie, InputSequence iseq)
        {
            inputEventSequences[iseq] = ie;
        }

        private InputEvent eventFromSequence(InputSequence sequence)
        {
            // check for input sequence in map
            if ((sequence in inputEventSequences) !is null)
            {
                return inputEventSequences[sequence];
            }

            // if not found, return unknown input
            auto unknownInputEvent = InputEvent(SK.unknown, SCK.none, true);
            //unknownInputEvent._keySequences = sequence;
            return unknownInputEvent;
        }

        /// Get uint[], from string in the format of "num1,num2,...,numX"
        private uint[] sequenceFromString(string input) pure
        {
            string[] numbers = split(input, ",");
            uint[] sequence;
            foreach (number_as_string; numbers)
            {
                sequence ~= parse!uint(number_as_string);
            }

            return sequence;
        }

        /// Table holding all input sequences and their respective input
        private InputEvent[InputSequence] inputEventSequences;
    }
}
