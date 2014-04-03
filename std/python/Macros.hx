package python;

#if macro
import haxe.macro.Expr;

import haxe.macro.Context;

import haxe.macro.ExprTools;
#end



class Macros {
    #if macro
    static var self = macro python.Macros;
    #end

	@:noUsing macro public static function importModule (module:String):haxe.macro.Expr {
		return macro $self.untypedPython($v{"import " + module});
	}

	@:noUsing macro public static function importAs (module:String, className : String):haxe.macro.Expr
    {

        var n = className.split(".").join("_");

        var e = "import " + module + " as " + n;
        var e1 = "_hx_c."+n+" = "+n;



	    return macro{
            $self.untypedPython($v{e});
            $self.untypedPython($v{e1});
        }
    }

    @:noUsing macro public static function isIn <T>(a:Expr, b:Expr):haxe.macro.Expr
    {
        return macro untyped __python_in__($a, $b);
    }

    @:noUsing macro public static function pyBinop <T>(a:Expr, op:String, b:Expr):haxe.macro.Expr
    {
        return macro untyped __python_binop__($a, $v{op}, $b);
    }


    @:noUsing
    #if (!macro) macro #end
    public static function untypedPython <T>(b:String):haxe.macro.ExprOf<Dynamic>
    {
        return macro untyped __python__($v{b});
    }

    @:noUsing macro public static function arrayAccess <T>(x:Expr, rest:Array<Expr>):haxe.macro.ExprOf<Dynamic>
    {
        return macro untyped __python_array_get__($a{[x].concat(rest)});
    }

    @:noUsing macro public static function pyFor <T>(v:Expr, it:Expr, b:Expr):haxe.macro.Expr
    {
        var id = switch (v.expr) {
            case EConst(CIdent(x)):x;
            case _ : Context.error("unexpected " + ExprTools.toString(v) + ": const ident expected", v.pos);
        }



        var res = macro @:pos(it.pos) {
            var $id = $it.getNativeIterator().__next__();
            $it;
            $b;
        }
        return macro (untyped __python_for__)($res);
    }

    @:noUsing macro public static function importFromAs (from:String, module:String, className : String):haxe.macro.Expr {

        var n = className.split(".").join("_");

        var e = "from " + from + " import " + module + " as " + n;
        var e1 = "_hx_c."+n+" = " + n;
	    return macro {
            $self.untypedPython($v{e});
            $self.untypedPython($v{e1});
        }
    }

    @:noUsing macro public static function callField (o:Expr, field:ExprOf<String>, params:Array<Expr>):haxe.macro.Expr {

        var field = python.Macros.field(o, field);
        var params = [field].concat(params);

        return macro untyped __call__($a{params});
    }

    @:noUsing
    #if !macro macro #end
    public static function field (o:Expr, field:ExprOf<String>):haxe.macro.Expr
    {
        return macro untyped __field__($o, $field);
    }

    @:noUsing
    #if !macro macro #end
    public static function callNamed (e:Expr, args:Expr):haxe.macro.Expr {
        var fArgs = switch (Context.typeof(e)) {
            case TFun(args, ret): args;
            case _ : haxe.macro.Context.error("e must be of type function", e.pos);
        }
        switch (args.expr) {
            case EObjectDecl(fields):
                for (f in fields) {
                    var found = false;
                    for (a in fArgs) {
                        found = a.name == f.field;
                        if (found) break;
                    }
                    if (!found) {
                        haxe.macro.Context.error("field " + f.field + " is not a valid argument (valid names " + [for (a in fArgs) a.name].join(",") + ")", args.pos);
                    }
                }
                // TODO check at least if fields are valid (maybe if types match);
            case _ : haxe.macro.Context.error("args must be an ObjectDeclaration like { name : 1 }", args.pos);
        }
        return macro @:pos(e.pos) untyped __named__($e, $args);
    }


}