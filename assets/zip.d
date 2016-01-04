import std.meta;
import std.range;

struct Zip(Ranges...)
    if (Ranges.length && allSatisfy!(isInputRange, Ranges))
{
    import std.format : format; //for generic mixins
    import std.typecons : Tuple;

    alias R = Ranges;
    R ranges;
    alias ElementType = Tuple!(staticMap!(.ElementType, R));
    StoppingPolicy stoppingPolicy = StoppingPolicy.shortest;

/**
   Builds an object. Usually this is invoked indirectly by using the
   $(LREF zip) function.
 */
    this(R rs, StoppingPolicy s = StoppingPolicy.shortest)
    {
        ranges[] = rs[];
        stoppingPolicy = s;
    }

/**
   Returns $(D true) if the range is at end. The test depends on the
   stopping policy.
*/
    static if (allSatisfy!(isInfinite, R))
    {
        // BUG:  Doesn't propagate infiniteness if only some ranges are infinite
        //       and s == StoppingPolicy.longest.  This isn't fixable in the
        //       current design since StoppingPolicy is known only at runtime.
        enum bool empty = false;
    }
    else
    {
        @property bool empty()
        {
            import std.exception : enforce;

            final switch (stoppingPolicy)
            {
            case StoppingPolicy.shortest:
                foreach (i, Unused; R)
                {
                    if (ranges[i].empty) return true;
                }
                return false;
            case StoppingPolicy.longest:
                static if (anySatisfy!(isInfinite, R))
                {
                    return false;
                }
                else
                {
                    foreach (i, Unused; R)
                    {
                        if (!ranges[i].empty) return false;
                    }
                    return true;
                }
            case StoppingPolicy.requireSameLength:
                foreach (i, Unused; R[1 .. $])
                {
                    enforce(ranges[0].empty ==
                            ranges[i + 1].empty,
                            "Inequal-length ranges passed to Zip");
                }
                return ranges[0].empty;
            }
            assert(false);
        }
    }

    static if (allSatisfy!(isForwardRange, R))
    {
        @property Zip save()
        {
            //Zip(ranges[0].save, ranges[1].save, ..., stoppingPolicy)
            return mixin (q{Zip(%(ranges[%s]%|, %), stoppingPolicy)}.format(iota(0, R.length)));
        }
    }

    private .ElementType!(R[i]) tryGetInit(size_t i)()
    {
        alias E = .ElementType!(R[i]);
        static if (!is(typeof({static E i;})))
            throw new Exception("Range with non-default constructable elements exhausted.");
        else
            return E.init;
    }

/**
   Returns the current iterated element.
*/
    @property ElementType front()
    {
        @property tryGetFront(size_t i)(){return ranges[i].empty ? tryGetInit!i() : ranges[i].front;}
        //ElementType(tryGetFront!0, tryGetFront!1, ...)
        return mixin(q{ElementType(%(tryGetFront!%s, %))}.format(iota(0, R.length)));
    }

/**
   Sets the front of all iterated ranges.
*/
    static if (allSatisfy!(hasAssignableElements, R))
    {
        @property void front(ElementType v)
        {
            foreach (i, Unused; R)
            {
                if (!ranges[i].empty)
                {
                    ranges[i].front = v[i];
                }
            }
        }
    }

/**
   Moves out the front.
*/
    static if (allSatisfy!(hasMobileElements, R))
    {
        ElementType moveFront()
        {
            @property tryMoveFront(size_t i)(){return ranges[i].empty ? tryGetInit!i() : .moveFront(ranges[i]);}
            //ElementType(tryMoveFront!0, tryMoveFront!1, ...)
            return mixin(q{ElementType(%(tryMoveFront!%s, %))}.format(iota(0, R.length)));
        }
    }

/**
   Returns the rightmost element.
*/
    static if (allSatisfy!(isBidirectionalRange, R))
    {
        @property ElementType back()
        {
            //TODO: Fixme! BackElement != back of all ranges in case of jagged-ness

            @property tryGetBack(size_t i)(){return ranges[i].empty ? tryGetInit!i() : ranges[i].back;}
            //ElementType(tryGetBack!0, tryGetBack!1, ...)
            return mixin(q{ElementType(%(tryGetBack!%s, %))}.format(iota(0, R.length)));
        }

/**
   Moves out the back.
*/
        static if (allSatisfy!(hasMobileElements, R))
        {
            ElementType moveBack()
            {
                //TODO: Fixme! BackElement != back of all ranges in case of jagged-ness

                @property tryMoveBack(size_t i)(){return ranges[i].empty ? tryGetInit!i() : .moveFront(ranges[i]);}
                //ElementType(tryMoveBack!0, tryMoveBack!1, ...)
                return mixin(q{ElementType(%(tryMoveBack!%s, %))}.format(iota(0, R.length)));
            }
        }

/**
   Returns the current iterated element.
*/
        static if (allSatisfy!(hasAssignableElements, R))
        {
            @property void back(ElementType v)
            {
                //TODO: Fixme! BackElement != back of all ranges in case of jagged-ness.
                //Not sure the call is even legal for StoppingPolicy.longest

                foreach (i, Unused; R)
                {
                    if (!ranges[i].empty)
                    {
                        ranges[i].back = v[i];
                    }
                }
            }
        }
    }

/**
   Advances to the next element in all controlled ranges.
*/
    void popFront()
    {
        import std.exception : enforce;

        final switch (stoppingPolicy)
        {
        case StoppingPolicy.shortest:
            foreach (i, Unused; R)
            {
                assert(!ranges[i].empty);
                ranges[i].popFront();
            }
            break;
        case StoppingPolicy.longest:
            foreach (i, Unused; R)
            {
                if (!ranges[i].empty) ranges[i].popFront();
            }
            break;
        case StoppingPolicy.requireSameLength:
            foreach (i, Unused; R)
            {
                enforce(!ranges[i].empty, "Invalid Zip object");
                ranges[i].popFront();
            }
            break;
        }
    }

/**
   Calls $(D popBack) for all controlled ranges.
*/
    static if (allSatisfy!(isBidirectionalRange, R))
    {
        void popBack()
        {
            //TODO: Fixme! In case of jaggedness, this is wrong.
            import std.exception : enforce;

            final switch (stoppingPolicy)
            {
            case StoppingPolicy.shortest:
                foreach (i, Unused; R)
                {
                    assert(!ranges[i].empty);
                    ranges[i].popBack();
                }
                break;
            case StoppingPolicy.longest:
                foreach (i, Unused; R)
                {
                    if (!ranges[i].empty) ranges[i].popBack();
                }
                break;
            case StoppingPolicy.requireSameLength:
                foreach (i, Unused; R)
                {
                    enforce(!ranges[i].empty, "Invalid Zip object");
                    ranges[i].popBack();
                }
                break;
            }
        }
    }

/**
   Returns the length of this range. Defined only if all ranges define
   $(D length).
*/
    static if (allSatisfy!(hasLength, R))
    {
        @property auto length()
        {
            static if (Ranges.length == 1)
                return ranges[0].length;
            else
            {
                if (stoppingPolicy == StoppingPolicy.requireSameLength)
                    return ranges[0].length;

                //[min|max](ranges[0].length, ranges[1].length, ...)
                import std.algorithm : min, max;
                if (stoppingPolicy == StoppingPolicy.shortest)
                    return mixin(q{min(%(ranges[%s].length%|, %))}.format(iota(0, R.length)));
                else
                    return mixin(q{max(%(ranges[%s].length%|, %))}.format(iota(0, R.length)));
            }
        }

        alias opDollar = length;
    }

/**
   Returns a slice of the range. Defined only if all range define
   slicing.
*/
    static if (allSatisfy!(hasSlicing, R))
    {
        auto opSlice(size_t from, size_t to)
        {
            //Slicing an infinite range yields the type Take!R
            //For finite ranges, the type Take!R aliases to R
            alias ZipResult = Zip!(staticMap!(Take, R));

            //ZipResult(ranges[0][from .. to], ranges[1][from .. to], ..., stoppingPolicy)
            return mixin (q{ZipResult(%(ranges[%s][from .. to]%|, %), stoppingPolicy)}.format(iota(0, R.length)));
        }
    }

/**
   Returns the $(D n)th element in the composite range. Defined if all
   ranges offer random access.
*/
    static if (allSatisfy!(isRandomAccessRange, R))
    {
        ElementType opIndex(size_t n)
        {
            //TODO: Fixme! This may create an out of bounds access
            //for StoppingPolicy.longest

            //ElementType(ranges[0][n], ranges[1][n], ...)
            return mixin (q{ElementType(%(ranges[%s][n]%|, %))}.format(iota(0, R.length)));
        }

/**
   Assigns to the $(D n)th element in the composite range. Defined if
   all ranges offer random access.
*/
        static if (allSatisfy!(hasAssignableElements, R))
        {
            void opIndexAssign(ElementType v, size_t n)
            {
                //TODO: Fixme! Not sure the call is even legal for StoppingPolicy.longest
                foreach (i, Range; R)
                {
                    ranges[i][n] = v[i];
                }
            }
        }

/**
   Destructively reads the $(D n)th element in the composite
   range. Defined if all ranges offer random access.
*/
        static if (allSatisfy!(hasMobileElements, R))
        {
            ElementType moveAt(size_t n)
            {
                //TODO: Fixme! This may create an out of bounds access
                //for StoppingPolicy.longest

                //ElementType(.moveAt(ranges[0], n), .moveAt(ranges[1], n), ..., )
                return mixin (q{ElementType(%(.moveAt(ranges[%s], n)%|, %))}.format(iota(0, R.length)));
            }
        }
    }
}

/// Ditto
auto zip(Ranges...)(Ranges ranges)
    if (Ranges.length && allSatisfy!(isInputRange, Ranges))
{
    return Zip!Ranges(ranges);
}

///
pure unittest
{
    import std.algorithm : sort;
    int[] a = [ 1, 2, 3 ];
    string[] b = [ "a", "b", "c" ];
    sort!((c, d) => c[0] > d[0])(zip(a, b));
    assert(a == [ 3, 2, 1 ]);
    assert(b == [ "c", "b", "a" ]);
}

///
unittest
{
   int[] a = [ 1, 2, 3 ];
   string[] b = [ "a", "b", "c" ];

   size_t idx = 0;
   foreach (e; zip(a, b))
   {
       assert(e[0] == a[idx]);
       assert(e[1] == b[idx]);
       ++idx;
   }
}

/// Ditto
auto zip(Ranges...)(StoppingPolicy sp, Ranges ranges)
    if (Ranges.length && allSatisfy!(isInputRange, Ranges))
{
    return Zip!Ranges(ranges, sp);
}

/**
   Dictates how iteration in a $(D Zip) should stop. By default stop at
   the end of the shortest of all ranges.
*/
enum StoppingPolicy
{
    /// Stop when the shortest range is exhausted
    shortest,
    /// Stop when the longest range is exhausted
    longest,
    /// Require that all ranges are equal
    requireSameLength,
}

unittest
{
    import std.internal.test.dummyrange;
    import std.algorithm : swap, sort, filter, equal, map;

    import std.exception : assertThrown, assertNotThrown;
    import std.typecons : tuple;

    int[] a = [ 1, 2, 3 ];
    float[] b = [ 1.0, 2.0, 3.0 ];
    foreach (e; zip(a, b))
    {
        assert(e[0] == e[1]);
    }

    swap(a[0], a[1]);
    auto z = zip(a, b);
    //swap(z.front(), z.back());
    sort!("a[0] < b[0]")(zip(a, b));
    assert(a == [1, 2, 3]);
    assert(b == [2.0, 1.0, 3.0]);

    z = zip(StoppingPolicy.requireSameLength, a, b);
    assertNotThrown(z.popBack());
    assertNotThrown(z.popBack());
    assertNotThrown(z.popBack());
    assert(z.empty);
    assertThrown(z.popBack());

    a = [ 1, 2, 3 ];
    b = [ 1.0, 2.0, 3.0 ];
    sort!("a[0] > b[0]")(zip(StoppingPolicy.requireSameLength, a, b));
    assert(a == [3, 2, 1]);
    assert(b == [3.0, 2.0, 1.0]);

    a = [];
    b = [];
    assert(zip(StoppingPolicy.requireSameLength, a, b).empty);

    // Test infiniteness propagation.
    static assert(isInfinite!(typeof(zip(repeat(1), repeat(1)))));

    // Test stopping policies with both value and reference.
    auto a1 = [1, 2];
    auto a2 = [1, 2, 3];
    auto stuff = tuple(tuple(a1, a2),
            tuple(filter!"a"(a1), filter!"a"(a2)));

    alias FOO = Zip!(immutable(int)[], immutable(float)[]);

    foreach(t; stuff.expand) {
        auto arr1 = t[0];
        auto arr2 = t[1];
        auto zShortest = zip(arr1, arr2);
        assert(equal(map!"a[0]"(zShortest), [1, 2]));
        assert(equal(map!"a[1]"(zShortest), [1, 2]));

        try {
            auto zSame = zip(StoppingPolicy.requireSameLength, arr1, arr2);
            foreach(elem; zSame) {}
            assert(0);
        } catch (Throwable) { /* It's supposed to throw.*/ }

        auto zLongest = zip(StoppingPolicy.longest, arr1, arr2);
        assert(!zLongest.ranges[0].empty);
        assert(!zLongest.ranges[1].empty);

        zLongest.popFront();
        zLongest.popFront();
        assert(!zLongest.empty);
        assert(zLongest.ranges[0].empty);
        assert(!zLongest.ranges[1].empty);

        zLongest.popFront();
        assert(zLongest.empty);
    }

    // BUG 8900
    assert(zip([1, 2], repeat('a')).array == [tuple(1, 'a'), tuple(2, 'a')]);
    assert(zip(repeat('a'), [1, 2]).array == [tuple('a', 1), tuple('a', 2)]);

    // Doesn't work yet.  Issues w/ emplace.
    // static assert(is(Zip!(immutable int[], immutable float[])));


    // These unittests pass, but make the compiler consume an absurd amount
    // of RAM and time.  Therefore, they should only be run if explicitly
    // uncommented when making changes to Zip.  Also, running them using
    // make -fwin32.mak unittest makes the compiler completely run out of RAM.
    // You need to test just this module.
    /+
     foreach(DummyType1; AllDummyRanges) {
         DummyType1 d1;
         foreach(DummyType2; AllDummyRanges) {
             DummyType2 d2;
             auto r = zip(d1, d2);
             assert(equal(map!"a[0]"(r), [1,2,3,4,5,6,7,8,9,10]));
             assert(equal(map!"a[1]"(r), [1,2,3,4,5,6,7,8,9,10]));
             static if (isForwardRange!DummyType1 && isForwardRange!DummyType2) {
                 static assert(isForwardRange!(typeof(r)));
             }
             static if (isBidirectionalRange!DummyType1 &&
                     isBidirectionalRange!DummyType2) {
                 static assert(isBidirectionalRange!(typeof(r)));
             }
             static if (isRandomAccessRange!DummyType1 &&
                     isRandomAccessRange!DummyType2) {
                 static assert(isRandomAccessRange!(typeof(r)));
             }
         }
     }
    +/
}

pure unittest
{
    import std.algorithm : sort;

    auto a = [5,4,3,2,1];
    auto b = [3,1,2,5,6];
    auto z = zip(a, b);

    sort!"a[0] < b[0]"(z);

    assert(a == [1, 2, 3, 4, 5]);
    assert(b == [6, 5, 2, 1, 3]);
}

@safe pure unittest
{
    import std.typecons : tuple;
    import std.algorithm : equal;

    auto LL = iota(1L, 1000L);
    auto z = zip(LL, [4]);

    assert(equal(z, [tuple(1L,4)]));

    auto LL2 = iota(0L, 500L);
    auto z2 = zip([7], LL2);
    assert(equal(z2, [tuple(7, 0L)]));
}

// Text for Issue 11196
@safe pure unittest
{
    import std.exception : assertThrown;

    static struct S { @disable this(); }
    assert(zip((S[5]).init[]).length == 5);
    assert(zip(StoppingPolicy.longest, cast(S[]) null, new int[1]).length == 1);
    assertThrown(zip(StoppingPolicy.longest, cast(S[]) null, new int[1]).front);
}

@safe pure unittest //12007
{
    static struct R
    {
        enum empty = false;
        void popFront(){}
        int front(){return 1;} @property
        R save(){return this;} @property
        void opAssign(R) @disable;
    }
    R r;
    auto z = zip(r, r);
    auto zz = z.save;
}
