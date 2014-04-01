
package python;

import python.BootHelper;
import python.internal.ArrayImpl;
import python.internal.StringImpl;
import python.lib.Builtin;
import python.internal.EnumImpl;
import python.internal.HxOverrides;
import python.internal.HxException;
import python.lib.Inspect;
import python.Macros;
import python.internal.AnonObject;
import StdTypes;

import python.internal.EnumImpl;
import python.Macros;
import python.internal.AnonObject;
import StdTypes;

private extern class Set <T>
{
	public inline function has (v:T):Bool
	{
		return untyped __python_in__(v, this);
	}
}

@:preCode("
import builtins as _hx_builtin

_hx_classes = dict()

class _hx_AnonObject(object):
    def __init__(self, fields):
        self.__dict__ = fields

_hx_c = _hx_AnonObject({})


_hx_c._hx_AnonObject = _hx_AnonObject

import functools as _hx_functools
import math as _hx_math
"
)
@:keep class Boot {

	@:keep static function __init__ () {
		Macros.importAs("inspect", "_hx_boot_inspect");
		Boot.inspect = untyped __python__("_hx_boot_inspect");

		Boot.builtin = untyped __python__("_hx_builtin");
	}

	static function mkSet <T>(a:Array<T>):Set<T> return Macros.callField(builtin, "set", a);

	static var keywords:Set<String> = mkSet(
    [
        "and",       "del",       "from",      "not",       "while",
        "as",        "elif",      "global",    "or",        "with",
        "assert",    "else",      "if",        "pass",      "yield",
        "break",     "except",    "import",    "print",     "float",
        "class",     "exec",      "in",        "raise",
        "continue",  "finally",   "is",        "return",
        "def",       "for",       "lambda",    "try",
        "None",      "list"
    ]);

	static function arrayJoin <T>(x:Array<T>, sep:String):String {
		return Macros.field(sep, "join")(x.map(python.Boot.toString));
	}


	static function isInstance(o:Dynamic, x:Dynamic):Bool {
		return Macros.callField(builtin, "isinstance", o, x);
	}

	static function builtinStr(o:Dynamic):String {
		return Macros.callField(builtin, "str", o);
	}

	static function builtinHasAttr(o:Dynamic, x:String):Bool {
		return Macros.callField(builtin, "hasattr", o, x);
	}

	static function builtinGetAttr(o:Dynamic, x:String):Dynamic {
		return Macros.callField(builtin, "getattr", o, x);
	}

	static function builtinLen(o:Dynamic):Int {
		return Macros.callField(builtin, "len", o);
	}
	static function builtinInt(o:Dynamic):Int {
		return Macros.callField(builtin, "int", o);
	}
	static function builtinCallable(o:Dynamic):Bool {
		return Macros.callField(builtin, "callable", o);
	}
	static function inspectGetMembers(o:Dynamic, f:String->Bool):Void {
		return Macros.callField(inspect, "getmembers", o, f);
	}

	static function inspectIsClass(o:Dynamic):Bool {
		return Macros.callField(inspect, "isclass", o);
	}
	static function inspectIsFunction(o:Dynamic):Bool {
		return Macros.callField(inspect, "isclass", o);
	}
	static function inspectIsMethod(o:Dynamic):Bool {
		return Macros.callField(inspect, "isclass", o);
	}



	static var builtin:Dynamic;
	static var inspect:Dynamic;



	@:keep static inline function isClass(o:Dynamic) : Bool {
		return o != null && (o == String || inspectIsClass(o));
        //return untyped __define_feature__("python.Boot.isClass", o._hx_class);
    }

    @:keep static function isAnonObject (o:Dynamic) {
    	return isInstance(o, AnonObject);
    }


    @:keep private static function _add_dynamic(a:Dynamic,b:Dynamic):Dynamic
    {
		if (isInstance(a, String) || isInstance(b, String)) {
			return toString1(a,"") + toString1(b,"");
		}
		return Macros.pyBinop(a, "+", b);
    }

    @:keep static function toString (o:Dynamic) {
    	return toString1(o, "");
    }

	@:keep private static function toString1(o:Dynamic,s:String):String {

		if (s == null) s = "";
		if( o == null ) return "null";

		if( s.length >= 5 ) return "<...>"; // too much deep recursion

		if (isInstance(o, String)) return o;

		if (isInstance(o, untyped __python__("bool"))) {
			if (untyped o) return "true" else return "false";
		}
		if (isInstance(o, untyped __python__("int"))) {
			return builtinStr(o);
		}
		// 1.0 should be printed as 1
		if (isInstance(o, untyped __python__("float"))) {
			try {
				if (o == builtinInt(o)) {
					return builtinStr(Math.round(o));
				} else {
					return builtinStr(o);
				}
			} catch (e:Dynamic) {
				return builtinStr(o);
			}
		}


		if (inspectIsFunction(o) || inspectIsMethod(o)) return "<function>";




		if (isInstance(o, Array))
		{
			var o1:Array<Dynamic> = o;
			var l = o1.length;

			var st = "[";
			s += "\t";
			for( i in 0...l ) {
				var prefix = "";
				if (i > 0) {
					prefix = ",";
				}
				st += prefix + toString1(o1[i],s);
			}
			st += "]";
			return st;
		}
		try {
			if (builtinHasAttr(o, "toString")) {
				return o.toString();
			}
		} catch (e:Dynamic) {

		}

		if (builtinHasAttr(o, "__class__"))
		{

			if (isInstance(o, AnonObject))
			{
				var toStr = null;
				try
				{
					var fields = fields(o);
					var fieldsStr = [for (f in fields) '$f : ${toString1(field(o,f), s+"\t")}'];
					toStr = "{ " + arrayJoin(fieldsStr, ", ") + " }";
				}
				catch (e:Dynamic) {
					return "{ ... }";
				}

				if (toStr == null)
				{
					return "{ ... }";
				}
				else
				{
					return toStr;
				}

			}
			if (isInstance(o, untyped __python__("_hx_c.Enum"))) {


				var l = builtinLen(o.params);
				var hasParams = l > 0;
				if (hasParams) {
					var paramsStr = "";
					for (i in 0...l) {
						var prefix = "";
						if (i > 0) {
							prefix = ",";
						}
						paramsStr += prefix + toString1(o.params[i],s);
					}
					return o.tag + "(" + paramsStr + ")";
				} else {
					return o.tag;
				}
			}


			if (builtinHasAttr(o, "_hx_class_name") && o.__class__.__name__ != "type") {

				var fields = getInstanceFields(o);
				var fieldsStr = [for (f in fields) '$f : ${toString1(field(o,f), s+"\t")}'];

				var toStr = o._hx_class_name + "( " + arrayJoin(fieldsStr, ", ") + " )";
				return toStr;
			}

			if (builtinHasAttr(o, "_hx_class_name") && o.__class__.__name__ == "type") {

				var fields = getClassFields(o);
				var fieldsStr = [for (f in fields) '$f : ${toString1(field(o,f), s+"\t")}'];

				var toStr = "#" + o._hx_class_name + "( " + arrayJoin(fieldsStr, ", ") + " )";
				return toStr;
			}
			if (o == String) {
				return "#String";
			}

			//if (builtinHasAttr(o, "_hx_name")) {
			//	return "#" + untyped o._hx_name;
			//}
			if (o == Array) {
				return "#Array";
			}

			if (builtinCallable(o)) {
				return "function";
			}
			try {
				if (builtinHasAttr(o, "__repr__")) {
					return untyped o.__repr__();
				}
			} catch (e:Dynamic) {}

			if (builtinHasAttr(o, "__str__")) {
				return untyped o.__str__();
			}

			if (builtinHasAttr(o, "__name__")) {
				return untyped o.__name__;
			}
			return "???";
		} else {
			try {
				inspectGetMembers(o, function (_) return true);
				return builtinStr(o);
			} catch (e:Dynamic) {
				return "???";
			}
		}
	}

	static function fields (o:Dynamic) {
		var a = [];
		if (o != null)
		{
			if (builtinHasAttr(o, "_hx_fields"))
			{

				var fields:Array<String> = o._hx_fields;
				return fields.copy();
			}
			if (isInstance(o, untyped __python__("_hx_c._hx_AnonObject")))
			{

				var d:Dynamic = builtinGetAttr(o, "__dict__");
				var keys  = d.keys();
				var handler = unhandleKeywords;
				untyped __python__("for k in keys:");
				untyped __python__("	a.append(handler(k))");
			}
			else if (builtinHasAttr(o, "__dict__"))
			{
				var a = [];
				var d:Dynamic = builtinGetAttr(o, "__dict__");
				var keys  = d.keys();
				untyped __python__("for k in keys:");
				untyped __python__("	a.append(k)");

			}
		}
		return a;
	}

	static inline function isString (o:Dynamic):Bool {
		return isInstance(o, String);
	}
	static inline function isArray (o:Dynamic):Bool {
		return isInstance(o, Array);
	}

	@:keep static function field( o : Dynamic, field : String ) : Dynamic
	{
		if (field == null) return null;

		switch (field) {
			case "length" if (isString(o)): return StringImpl.get_length(o);
			case "length" if (isArray(o)): return ArrayImpl.get_length(o);
			case "toLowerCase" if (isString(o)): return StringImpl.toLowerCase.bind(o);
			case "toUpperCase" if (isString(o)): return StringImpl.toUpperCase.bind(o);
			case "charAt" if (isString(o)): return StringImpl.charAt.bind(o);
			case "charCodeAt" if (isString(o)): return StringImpl.charCodeAt.bind(o);
			case "indexOf" if (isString(o)): return StringImpl.indexOf.bind(o);
			case "lastIndexOf" if (isString(o)): return StringImpl.lastIndexOf.bind(o);
			case "split" if (isString(o)): return StringImpl.split.bind(o);
			case "substr" if (isString(o)): return StringImpl.substr.bind(o);
			case "substring" if (isString(o)): return StringImpl.substring.bind(o);
			case "toString" if (isString(o)): return StringImpl.toString.bind(o);

			case "map" if (isArray(o)): return ArrayImpl.map.bind(o);
			case "filter" if (isArray(o)): return ArrayImpl.filter.bind(o);
			case "concat" if (isArray(o)): return ArrayImpl.concat.bind(o);
			case "copy" if (isArray(o)): return function () return ArrayImpl.copy(o);
			case "iterator" if (isArray(o)): return ArrayImpl.iterator.bind(o);
			case "insert" if (isArray(o)): return ArrayImpl.insert.bind(o);
			case "join" if (isArray(o)): return function (sep) return ArrayImpl.join(o, sep);
			case "toString" if (isArray(o)): return ArrayImpl.toString.bind(o);
			case "pop" if (isArray(o)): return ArrayImpl.pop.bind(o);
			case "push" if (isArray(o)): return ArrayImpl.push.bind(o);
			case "unshift" if (isArray(o)): return ArrayImpl.unshift.bind(o);
			case "indexOf" if (isArray(o)): return ArrayImpl.indexOf.bind(o);
			case "lastIndexOf" if (isArray(o)): return ArrayImpl.lastIndexOf.bind(o);
			case "remove" if (isArray(o)): return ArrayImpl.remove.bind(o);
			case "reverse" if (isArray(o)): return ArrayImpl.reverse.bind(o);
			case "shift" if (isArray(o)): return ArrayImpl.shift.bind(o);
			case "slice" if (isArray(o)): return ArrayImpl.slice.bind(o);
			case "sort" if (isArray(o)): return ArrayImpl.sort.bind(o);
			case "splice" if (isArray(o)): return ArrayImpl.splice.bind(o);
		}

		var field = handleKeywords(field);
		return if (builtinHasAttr(o, field)) builtinGetAttr(o, field) else null;
	}


	static function getInstanceFields( c : Class<Dynamic> ) : Array<String> {
		// dict((name, getattr(f, name)) for name in dir(c) if not name.startswith('__'))
		var f = if (builtinHasAttr(c, "_hx_fields")) {
			var x:Array<String> = untyped c._hx_fields;
			var x2:Array<String> = untyped c._hx_methods;
			x.concat(x2);
		} else {
			[];
		}

		var sc = getSuperClass(c);

		if (sc == null) {
			return f;
		} else {
			var scArr = getInstanceFields(sc);
			var scMap = [for (f in scArr) f => f];
			var res = [];
			for (f1 in f) {
				if (!scMap.exists(f1)) {
					scArr.push(f1);
				}
			}

			return scArr;
		}


		//return throw "getInstanceFields not implemented";
	}

	static function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic> untyped {
		if( c == null )
			return null;

		try {
			if (builtinHasAttr(c, "_hx_super")) {
				return untyped c._hx_super;
			}
			return untyped __python_array_get(c.__bases__,0);
		} catch (e:Dynamic) {

		}
		return null;

	}

	static function getClassFields( c : Class<Dynamic> ) : Array<String> {
		if (builtinHasAttr(c, "_hx_statics")) {
			var x:Array<String> = untyped c._hx_statics;
			return x.copy();
		} else {
			return [];
		}
	}



	static inline function handleKeywords(name:String):String
    {
        if (keywords.has(name)) {
            return "_hx_" + name;
        }
        return name;
    }

    static function unhandleKeywords(name:String):String
    {
    	if (name.substr(0,4) == "_hx_") {
    		var real = name.substr(4);
    		if (keywords.has(real)) return real;
    	}
    	return name;
    }

}