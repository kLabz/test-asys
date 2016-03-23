/*
 * Copyright (C)2005-2015 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package haxe.ds;
class IntMap<T> implements haxe.Constraints.IMap<Int,T> {

	private var h : Dynamic;
	private var k : Dynamic;

	public inline function new() : Void {
		h = {};
		k = {};
	}

	public inline function set( key : Int, value : T ) : Void untyped {
		 h[key] = value;
		 k[key] = true;
	}

	public inline function get( key : Int ) : Null<T> untyped {
		return h[key];
	}

	public inline function exists( key : Int ) : Bool untyped {
		return k[key] != null;
	}

	public function remove( key : Int ) : Bool untyped {
		if ( k[key] == null) return false;
		k[key] = null;
		h[key] = null;
		return true;
	}

	public function keys() : Iterator<Int> untyped {
		var cur = next(k,null);
		return {
			next : function() {
				var ret = cur; 
				cur = untyped next(k, cur);
				return ret;
			},
			hasNext : function() return cur != null
		}
	}

	public function iterator() : Iterator<T> {
		var ref = h;
		var it = keys();
		return untyped {
			hasNext : function() { return keys.hasNext(); },
			next : function() { var i = keys.next(); return h[i]; }
		};
	}

	public function toString() : String {
		var s = new StringBuf();
		s.add("{");
		var it = keys();
		for( i in it ) {
			s.add(i);
			s.add(" => ");
			s.add(Std.string(get(i)));
			if( it.hasNext() )
				s.add(", ");
		}
		s.add("}");
		return s.toString();
	}

}

