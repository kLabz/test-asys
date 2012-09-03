package java.internal;
import java.internal.Runtime;

/**
 * These classes are automatically generated by the compiler. They are only
 * here so there is an option for e.g. defining them as externs if you are compiling
 * in modules (untested)
 *
 * @author waneck
 */
@:abstract @:nativegen @:native("haxe.lang.Function") @:keep private class Function
{
	function new(arity:Int, type:Int)
	{

	}
}

@:nativegen @:native("haxe.lang.VarArgsBase") @:keep private class VarArgsBase extends Function
{
	public function __hx_invokeDynamic(dynArgs:Array<Dynamic>):Dynamic
	{
		throw "Abstract implementation";
		return null;
	}
}

@:nativegen @:native('haxe.lang.VarArgsFunction') @:keep class VarArgsFunction extends VarArgsBase
{
	private var fun:Array<Dynamic>->Dynamic;

	public function new(fun)
	{
		super(-1, -1);
		this.fun = fun;
	}

	override public function __hx_invokeDynamic(dynArgs:Array<Dynamic>):Dynamic
	{
		return fun(dynArgs);
	}
}

@:nativegen @:native('haxe.lang.Closure') @:keep class Closure extends VarArgsBase
{
	private var obj:Dynamic;
	private var field:String;

	public function new(obj:Dynamic, field)
	{
		super(-1, -1);
		this.obj = obj;
		this.field = field;
	}

	override public function __hx_invokeDynamic(dynArgs:Array<Dynamic>):Dynamic
	{
		return Runtime.callField(obj, field, dynArgs);
	}
}