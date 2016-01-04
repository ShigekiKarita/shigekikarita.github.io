import std.meta : AliasSeq;
import std.traits : Unqual;
import std.typecons : Tuple, tuple;


auto toListTypes(Ts...)()
{
    alias TypeList = AliasSeq!Ts;
    string s;
    foreach(t; TypeList)
    {
        s ~= Unqual!t.stringof ~ "[],";
    }
    return s[0..$-1];
}

unittest
{
    enum result = toListTypes!(int, double, string)();
    static assert(result == "int[],double[],string[]");
}

auto _unzip(Ts...)(Tuple!(Ts)[] zipped)
{
    mixin("Tuple!(" ~ toListTypes!Ts ~ ") result;");
    const n = zipped.length;

    foreach (j, T; AliasSeq!Ts)
    {
        result[j].length = n;
        foreach (i; 0 .. n)
        {
            result[j][i] = zipped[i][j];
        }
    }
    return result;
}

unittest
{
    import std.range : array, zip;
    immutable a = [1, 2, 3];
    immutable b = ["a", "b", "c"];
    immutable c = [0.1, 0.2, 0.3];
    static assert(_unzip(zip(a, b, c).array) == tuple(a, b, c));
}



import std.meta : allSatisfy;
import std.range : isInputRange, isInfinite;
struct Unzip(Ranges ...)
    if (Ranges.length && allSatisfy!(isInputRange, Ranges))
{
    import std.range;
    import std.format : format; //for generic mixins
    import std.typecons : Tuple;
    alias R = Ranges;
    Zip!R zipped;

    this (Zip!R z)
    {
        zipped = z;
    }

    /**
       Range まとめ

       // InputRange
       デフォルトコンストラクタ
       bool empty        // 要素が残っていないか
       ElementType front // 先頭要素
       void popFront()   // 前から二番目の要素を先頭に

       // OutputRange
       void put(ElementType) // 要素を格納

       // ForwardRange : InputRange
       Range save // 現在のレンジを保存(コピー)

       // BidirectionalRange : ForwardRange
       ElementType back // 末尾要素
       void popBack()   // 後ろから二番目の要素を末尾に

       // RandomAccessRange
       opIndex()

       // InfiniteRange
       enum bool empty = false; // コンパイル時
     */

    static if (allSatisfy!(isInfinite, R))
    {
        enum bool empty = false;
    }
    else
    {
        @property bool empty()
        {
            return zipped[0].empty;
        }
    }


}

/// Ditto
import std.range : Zip;
auto unzip(Ranges...)(Zip!Ranges ranges)
{
    return Unzip!Ranges(ranges);
}

unittest
{
    import std.range;
    import std.algorithm;
    auto a = [1, 2, 3]; //.map!"a";
    auto b = ["a", "b", "c"]; //.map!"a";
    auto c = [0.1, 0.2, 0.3]; //.map!"a";
    auto u = unzip(zip(a,b,c));
    assert(u == tuple(a, b, c));
}
