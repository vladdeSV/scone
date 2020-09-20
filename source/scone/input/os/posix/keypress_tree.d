module scone.input.os.posix.keypress_tree;

version (Posix)
{
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import std.typecons : Nullable;

    // todo this logic for inserting values has some problems
    // i believe it does not safeguard a node from having both children and a value
    // also, getting multiple inputs from a sequence is not 100% reliable. it should work for known sequences, but i would not consider this reliable yet.
    class KeypressTree
    {
        public Keypress[] find(uint[] sequence)
        {
            assert(sequence.length);

            // special case for escape key until i figure out this logic
            if (sequence == [27])
            {
                return [Keypress(SK.escape, SCK.none)];
            }

            Keypress[] keypresses = [];
            auto node = this.root;

            foreach (n, number; sequence)
            {
                const bool hasNodeChild = (number in node.children) !is null;

                if (node.value.isNull() && !hasNodeChild)
                {
                    if (!(keypresses.length && keypresses[$ - 1].key == SK.unknown))
                    {
                        keypresses ~= Keypress(SK.unknown, SCK.none);
                    }

                    node = this.root;
                    continue;
                }

                if (hasNodeChild)
                {
                    node = node.children[number];
                }

                if (!node.value.isNull())
                {
                    keypresses ~= node.value.get();
                    node = this.root;
                    continue;
                }
            }

            return keypresses;
        }

        public bool insert(in uint[] sequence, Keypress data)
        {
            // special case for escape key until i figure out this logic
            if (sequence == [27])
            {
                return true;
            }

            auto node = this.root;

            foreach (number; sequence)
            {
                if ((number in node.children) is null)
                {
                    if (!node.value.isNull())
                    {
                        return false;
                    }

                    node.children[number] = new KeypressNode();
                }

                node = node.children[number];
            }

            node.value = data;

            return true;
        }

        private KeypressNode root = new KeypressNode();
    }

    unittest
    {
        auto tree = new KeypressTree();
        tree.insert([27], Keypress(SK.escape, SCK.none));
        tree.insert([27, 91, 67], Keypress(SK.right, SCK.none));
        tree.insert([27, 91, 66], Keypress(SK.down, SCK.none));
        tree.insert([48], Keypress(SK.key_0, SCK.none));
        tree.insert([49], Keypress(SK.key_1, SCK.none));

        Keypress[] find;

        find = tree.find([1]);
        assert(find.length == 1);
        assert(SK.unknown == find[0].key);

        find = tree.find([48]);
        assert(find.length == 1);
        assert(SK.key_0 == find[0].key);

        find = tree.find([27]);
        assert(find.length == 1);
        assert(SK.escape == find[0].key);

        find = tree.find([27, 91, 67]);
        assert(find.length == 1);
        assert(SK.right == find[0].key);

        find = tree.find([27, 91, 66]);
        assert(find.length == 1);
        assert(SK.down == find[0].key);

        find = tree.find([48, 49]);
        assert(find.length == 2);
        assert(SK.key_0 == find[0].key);
        assert(SK.key_1 == find[1].key);

        find = tree.find([27, 91, 67, 27, 91, 66]);
        assert(find.length == 2);
        assert(SK.right == find[0].key);
        assert(SK.down == find[1].key);

        find = tree.find([27, 6, 67, 27, 91, 66]);
        assert(find.length == 2);
        assert(SK.unknown == find[0].key);
        assert(SK.down == find[1].key);
    }

    /// todo move to own file. it is being used in multiple places
    struct Keypress
    {
        SK key;
        SCK controlKey;
    }

    private class KeypressNode
    {
        KeypressNode[uint] children;
        Nullable!Keypress value;
    }
}
