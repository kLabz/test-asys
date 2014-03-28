package python.internal;

@:keep
@:native("HxOverrides")
class HxOverrides {
	static public function iterator(x) {
		if (Std.is(x, Array)) {
			return untyped __python__(" _hx_c.python_internal_ArrayImpl.iterator(x)");
		} else {
			return untyped __python__("x.iterator()");
		}
	}

	static public function shift(x) {
		if (Std.is(x, Array)) {
			return untyped __python__(" _hx_c.python_internal_ArrayImpl.shift(x)");
		} else {
			return untyped __python__("x.shift()");
		}
	}

	static public function filter(x, f) {
		if (Std.is(x, Array)) {
			return untyped __python__(" _hx_c.python_internal_ArrayImpl.filter(x, f)");
		} else {
			return untyped __python__("x.filter(f)");
		}
	}

	static public function map(x, f) {
		if (Std.is(x, Array)) {
			return untyped __python__(" _hx_c.python_internal_ArrayImpl.map(x, f)");
		} else {
			return untyped __python__("x.map(f)");
		}
	}

	static public function length(x) {
		if (Std.is(x, Array) || Std.is(x, String)) {
			return untyped __python__(" _hx_builtin.len(x)");
		} else {
			return untyped __python__("x.length");
		}
	}
}