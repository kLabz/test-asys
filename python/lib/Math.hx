package python.lib;

@:native("_hx_math")
extern class Math {

	public static function isnan (f:Float):Bool;

	public static var pi:Float;

	public static function sqrt(f:Float):Float;
	public static function log(f:Float):Float;
	public static function cos(f:Float):Float;
	public static function sin(f:Float):Float;
	public static function tan(f:Float):Float;
	static function asin(v:Float):Float;
	static function acos(v:Float):Float;
	static function atan(v:Float):Float;
	static function atan2(y:Float, x:Float):Float;

	static function __init__():Void {
		python.Syntax.importAs("math", "python.lib.Math");

	}

}