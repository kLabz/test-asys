
package python.lib;

extern class Msvcrt {

	public static function getch ():String;

	static function __init__ ():Void
	{
		try {
			python.Macros.importAs("msvcrt", "python.lib.Msvcrt");
		} catch (e:Dynamic) {}
	}

}