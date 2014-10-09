/*
 * Copyright (C)2005-2012 Haxe Foundation
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

@:coreApi class StringMap<T> implements haxe.Constraints.IMap<String,T> {
	// reserved words that are not allowed in Dictionary include all non-static members of Dictionary
	private static var reservedWords:Array<String> = ["constructor", "hasOwnProperty", "isPrototypeOf", "propertyIsEnumerable", "setPropertyIsEnumerable", "toLocaleString", "toString", "valueOf", "toJSON"];
	private static var reservedWordIndexers:Array<ReservedWordIndexer> = [new ReservedWordIndexer(0), new ReservedWordIndexer(1), new ReservedWordIndexer(2), new ReservedWordIndexer(3), new ReservedWordIndexer(4), new ReservedWordIndexer(5), new ReservedWordIndexer(6), new ReservedWordIndexer(7), new ReservedWordIndexer(8)];
	private static inline var reservedWordCount:Int = 9;
	
	private var h : flash.utils.Dictionary;

	public function new() : Void {
		h = new flash.utils.Dictionary();
	}

	private inline function reservedWordIndex(key:String):Int {
		var i:Int = reservedWordCount - 1;
		while (i >= 0) {
			if ( reservedWords[i] == key ) {
				break;
			}
			i--;
		}
		return i;
	}
	public inline function set( key : String, value : T ) : Void {
		var i:Int = reservedWordIndex(key);
		if ( i >= 0 ) {
			untyped h[reservedWordIndexers[i]] = value;
		} else {
			untyped h[key] = value;
		}
	}

	public inline function get( key : String ) : Null<T> {
		var rv:Null<T>;
		var i:Int = reservedWordIndex(key);
		if ( i >= 0 ) {
			rv = untyped h[reservedWordIndexers[i]];
		} else {
			rv = untyped h[key];
		}
		return rv == null ? null : rv;
	}

	public inline function exists( key : String ) : Bool {
		var i:Int = reservedWordIndex(key);
		if ( i >= 0 ) {
			return untyped __in__(reservedWordIndexers[i], h);
		} else {
			return untyped __in__(key, h);
		}
	}

	public inline function remove( key : String ) : Bool {
		var i:Int = reservedWordIndex(key);
		if ( i >= 0 ) {
			if ( !(untyped __in__(reservedWordIndexers[i], h)) ) {
				return false;
			} else {
				untyped __delete__(h, reservedWordIndexers[i]);
				return true;
			}
		} else {
			if ( !(untyped __in__(key, h)) ) {
				return false;
			} else {
				untyped __delete__(h, key);
				return true;
			}
		}
	}

	public function keys() : Iterator<String> {
		var rv = untyped (__keys__(h));
		var len:Int = untyped rv.length;
		var i:Int = 0;
		var reservedWordsCount:Int = reservedWords.length;
		while (i < len) {
			if ( Std.is(untyped rv[i], ReservedWordIndexer) ) {
				var indexer:ReservedWordIndexer = untyped rv[i];
				untyped rv[i] = reservedWords[indexer.i];
			}
			i++;
		}
		return rv.iterator();
	}

	public function iterator() : Iterator<T> {
		return untyped {
			ref : h,
			it : keys(),
			hasNext : function() { return __this__.it.hasNext(); },
			next : function() { var i : Dynamic = __this__.it.next(); return __this__.ref[i]; }
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

@:allow(haxe.ds.StringMap)
class ReservedWordIndexer {
	private var i:Int;
	private function new(i:Int):Void {
		this.i = i;
	}
}
