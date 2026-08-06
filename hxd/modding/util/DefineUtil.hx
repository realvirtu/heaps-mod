package hxd.modding.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class DefineUtil
{
    public static macro function defined(id:String):ExprOf<Bool>
    {
        return macro $v{Context.defined(id)};
    }

    public static macro function definedValue(id:String):ExprOf<String>
    {
        return macro $v{Context.definedValue(id)};
    }
}