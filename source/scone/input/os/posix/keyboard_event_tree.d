module scone.input.os.posix.keyboard_event_tree;

version (Posix)
{
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.input.keyboard_event : KeyboardEvent;
    import std.typecons : Nullable;

    // todo this logic for inserting values has some problems
    // i believe it does not safeguard a node from having both children and a value
    // also, getting multiple inputs from a sequence is not 100% reliable. it should work for known sequences, but i would not consider this reliable yet.
    class KeyboardEventTree
    {
        public KeyboardEvent[] find(uint[] sequence)
        {
            assert(sequence.length);

            // special case for escape key until i figure out this logic
            if (sequence == [27])
            {
                return [KeyboardEvent(SK.escape, SCK.none)];
            }

            KeyboardEvent[] keypresses = [];
            auto node = this.root;

            foreach (n, number; sequence)
            {
                const bool hasNodeChild = (number in node.children) !is null;

                if (node.value.isNull() && !hasNodeChild)
                {
                    if (!(keypresses.length && keypresses[$ - 1].key == SK.unknown))
                    {
                        keypresses ~= KeyboardEvent(SK.unknown, SCK.none);
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

        public bool insert(in uint[] sequence, KeyboardEvent data)
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

                    node.children[number] = new KeyboardEventNode();
                }

                node = node.children[number];
            }

            node.value = data;

            return true;
        }

        private KeyboardEventNode root = new KeyboardEventNode();
    }

    unittest
    {
        auto tree = new KeyboardEventTree();
        tree.insert([27], KeyboardEvent(SK.escape, SCK.none));
        tree.insert([27, 91, 67], KeyboardEvent(SK.right, SCK.none));
        tree.insert([27, 91, 66], KeyboardEvent(SK.down, SCK.none));
        tree.insert([48], KeyboardEvent(SK.key_0, SCK.none));
        tree.insert([49], KeyboardEvent(SK.key_1, SCK.none));

        KeyboardEvent[] find;

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

    private class KeyboardEventNode
    {
        KeyboardEventNode[uint] children;
        Nullable!KeyboardEvent value;
    }
}
