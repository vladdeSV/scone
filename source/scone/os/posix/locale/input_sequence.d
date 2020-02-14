module scone.os.posix.locale.input_sequence;

version(Posix)
{
    /**
     * Wrapper for an input sequence sent by the POSIX terminal.
     *
     * An input from the terminal is given by numbers in a sequence.
     *
     * For example, the right arrow key might send the sequence "27 91 67",
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
}
