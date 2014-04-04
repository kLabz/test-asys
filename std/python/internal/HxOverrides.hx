package python.internal;

import python.Syntax;

import python.Syntax.untypedPython in py;

@:keep
@:native("HxOverrides")
class HxOverrides {
	static public function iterator(x) {
		if (Std.is(x, Array)) {
			return Syntax.untypedPython(" _hx_c.python_internal_ArrayImpl.iterator(x)");
		} else {
			return Syntax.untypedPython("x.iterator()");
		}
	}

	static public function shift(x) {
		if (Std.is(x, Array)) {
			return Syntax.untypedPython(" _hx_c.python_internal_ArrayImpl.shift(x)");
		} else {
			return Syntax.untypedPython("x.shift()");
		}
	}

	static public function hx_rshift(val:Int, n:Int) {
		return Syntax.binop(Syntax.binop(val, "%", Syntax.untypedPython("0x100000000")), ">>", n);
	}

	static public function hx_modf(a:Float, b:Float) {
		return Syntax.untypedPython("float('nan') if (b == 0.0) else a % b if a > 0 else -(-a % b)");
	}

	static public function hx_array_get<T>(a:Dynamic, i:Int):Dynamic {
		if (Std.is(a, Array)) {
			var a : Array<Dynamic> = a;
			return if (i < a.length && i > -1) Syntax.arrayAccess(a, i) else null;
		} else {
			return Syntax.arrayAccess(a, i);
		}
	}

	static public function hx_array_set(a:Dynamic, i:Int, v:Dynamic) {
		if (Std.is(a, Array)) {
			var a:Array<Dynamic> = a;
			var l = a.length;
			while (l < i) {
				a.push(null);
				l+=1;
			}
			if (l == i) {
				a.push(v);
			} else {
				Syntax.assign(Syntax.arrayAccess(a, i), v);
			}
			return v;
		} else {
			Syntax.assign(Syntax.arrayAccess(a, i), v);
			return v;
		}
	}

	static public function hx_toUpperCase(x) {
		if (Std.is(x, String)) {
			return (x:String).toUpperCase();
		} else {
			return x.toUpperCase();
		}
	}

	static public function hx_toLowerCase(x) {
		if (Std.is(x, String)) {
			return (x:String).toLowerCase();
		} else {
			return x.toLowerCase();
		}
	}
}