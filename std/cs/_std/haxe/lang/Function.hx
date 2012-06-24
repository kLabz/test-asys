package haxe.lang;

/**
 These classes are automatically generated by the compiler. They are only
 here so there is an option for e.g. defining them as externs if you are compiling
 in modules (untested).
**/
 
@:abstract @:nativegen @:native("haxe.lang.Function") private class Function 
{
	function new(arity:Int, type:Int)
	{
		
	}
}

@:nativegen @:native("haxe.lang.VarArgsBase") private class VarArgsBase extends Function
{
	public function __hx_invokeDynamic(dynArgs:Array<Dynamic>):Dynamic
	{
		throw "Abstract implementation";
	}
}

@:nativegen class VarArgsFunction extends VarArgsBase
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

@:nativegen class Closure extends VarArgsBase
{
	private var obj:Dynamic;
	private var field:String;
	private var hash:Int;
	
	public function new(obj, field, hash)
	{
		super(-1, -1);
		this.obj = obj;
		this.field = field;
		this.hash = hash;
	}
	
	override public function __hx_invokeDynamic(dynArgs:Array<Dynamic>):Dynamic 
	{
		return Runtime.callField(obj, field, hash, dynArgs);
	}
}