
package python.internal;

import python.lib.Builtin;

@:keep
@:native("HxString")
class StringImpl {

	public static function split (s:String, d:String) {
		return if (d == "") Builtin.list(s) else (s:Dynamic).split(d);
	}

	public static function charCodeAt(s:String, index:Int) {
		return if (s == null || s.length == 0 || index < 0 || index >= s.length) null else untyped ord(untyped __python_array_get__(s, index));
	}
	public static inline function charAt(s:String, index:Int) {
		return if (index < 0 || index >= s.length) "" else untyped __python_array_get__(s,index);
	}
	public static inline function lastIndexOf(s:String, str:String, ?startIndex:Int):Int {
		if (startIndex == null) {
			return (untyped s.rfind)(str, 0, s.length);
		} else {

			var i = (untyped s.rfind)(str, 0, startIndex+1);
			var startLeft = i == -1 ? Math.max(0,startIndex+1-str.length) : i+1;
			var check = (untyped s.find)(str, startLeft, s.length);
			if (check > i && check <= startIndex) {
				return check;
			} else {
				return i;
			}
		}
	}

	public static function toUpperCase (s:String) {
		return s.toUpperCase();
	}
	public static function toLowerCase (s:String) {
		return s.toLowerCase();
	}

	public static inline function fromCharCode( code : Int ) : String {
		#if doc_gen
		return "";
		#else
		var c = code;
		return (untyped (''.join)(Builtin.map(Builtin.chr, cast [c])):String); // TODO: check cast
		#end
	}

}