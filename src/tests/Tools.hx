package tests;

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;

function assert(value:Bool, message:String = "") {
    if (!value)
        throw new Assertion(message);
}

macro function thrown(fn:()->Void, exception:Expr) {
    return macro {
        var isThrown = false;
        try fn() catch (e:TException) isThrown = true;
        assert(isThrown);
    };
}

macro function notThrown<TEx : haxe.Exception>(fn:()->Void, exception:ExprOf<TEx>) {
    final extype = TypeTools.toComplexType(Context.typeof(exception));
    return macro {
        var isThrown = false;
        try fn() catch (e:$extype) isThrown = true;
        assert(!isThrown);
    };
}