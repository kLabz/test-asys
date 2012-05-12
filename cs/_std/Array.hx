/* * Copyright (c) 2005, The haXe Project Contributors * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions are met: * *   - Redistributions of source code must retain the above copyright *     notice, this list of conditions and the following disclaimer. *   - Redistributions in binary form must reproduce the above copyright *     notice, this list of conditions and the following disclaimer in the *     documentation and/or other materials provided with the distribution. * * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH * DAMAGE. */import cs.NativeArray;/**	An Array is a storage for values. You can access it using indexes or	with its API. On the server side, it's often better to use a [List] which	is less memory and CPU consuming, unless you really need indexed access.**/@:classContents('	public Array(T[] native)	{		this.__a = native;		this.length = native.Length;	}')class Array<T> implements ArrayAccess<T> {	/**		The length of the Array	**/	public var length(default,null) : Int;		private var __a:NativeArray<T>;		@:functionBody('			return new Array<X>(native);	')	public static function ofNative<X>(native:NativeArray<X>):Array<X>	{		return null;	}		@:functionBody('			return new Array<Y>(new Y[size]);	')	public static function alloc<Y>(size:Int):Array<Y>	{		return null;	}		/**		Creates a new Array.	**/	public function new() : Void	{		this.length = 0;		this.__a = new NativeArray(0);	}	/**		Returns a new Array by appending [a] to [this].	**/	public function concat( a : Array<T> ) : Array<T>	{		var len = length + a.length;		var retarr = new NativeArray(len);		system.Array.Copy(__a, 0, retarr, 0, length);		system.Array.Copy(a.__a, 0, retarr, length, a.length);				return ofNative(retarr);	}		private function concatNative( a : NativeArray<T> ) : Void	{		var __a = __a;		var len = length + a.Length;		if (__a.Length >= len)		{			system.Array.Copy(a, 0, __a, length, length);		} else {			var newarr = new NativeArray(len);			system.Array.Copy(__a, 0, newarr, 0, length);			system.Array.Copy(a, 0, newarr, length, a.Length);						this.__a = newarr;		}				this.length = len;	}	/**		Returns a representation of an array with [sep] for separating each element.	**/	public function join( sep : String ) : String	{		var buf = new StringBuf();		var i = -1;				var first = true;		var length = length;		while (++i < length)		{			if (first)				first = false;			else				buf.add(sep);			buf.add(__a[i]);		}				return buf.toString();	}	/**		Removes the last element of the array and returns it.	**/	public function pop() : Null<T>	{		if (length > 0)		{			var val = __a[--length];			__a[length] = null;						return val;		} else {			return null;		}	}	/**		Adds the element [x] at the end of the array.	**/	public function push(x : T) : Int	{		if (length >= __a.Length)		{			var newLen = length * 2 + 1;			var newarr = new NativeArray(newLen);			__a.CopyTo(newarr, 0);						this.__a = newarr;		}				__a[length] = x;		return length++;	}	/**		Reverse the order of elements of the Array.	**/	public function reverse() : Void	{		var i = 0;		var l = this.length;		var a = this.__a;		var half = l >> 1;		l -= 1;		while ( i < half ) 		{			var tmp = a[i];			a[i] = a[l-i];			a[l-i] = tmp;			i += 1;		}	}	/**		Removes the first element and returns it.	**/	public function shift() : Null<T>	{		var l = this.length;		if( l == 0 )			return null;				var a = this.__a;		var x = a[0];		l -= 1;		system.Array.Copy(a, 1, a, 0, length-1);		a[l] = null;		this.length = l;				return x;	}	/**		Copies the range of the array starting at [pos] up to,		but not including, [end]. Both [pos] and [end] can be		negative to count from the end: -1 is the last item in		the array.	**/	public function slice( pos : Int, ?end : Int ) : Array<T>	{		if( pos < 0 ){			pos = this.length + pos;			if( pos < 0 )				pos = 0;		}		if( end == null )			end = this.length;		else if( end < 0 )			end = this.length + end;		if( end > this.length )			end = this.length;		var len = end - pos;		if ( len < 0 ) return new Array();				var newarr = new NativeArray(len);		system.Array.Copy(__a, pos, newarr, 0, len);				return ofNative(newarr);	}	/**		Sort the Array according to the comparison public function [f].		[f(x,y)] should return [0] if [x == y], [>0] if [x > y]		and [<0] if [x < y].	**/	public function sort( f : T -> T -> Int ) : Void	{			}	/**		Removes [len] elements starting from [pos] an returns them.	**/	public function splice( pos : Int, len : Int ) : Array<T>	{		return null;	}	/**		Returns a displayable representation of the Array content.	**/	public function toString() : String	{		return "";	}	/**		Adds the element [x] at the start of the array.	**/	public function unshift( x : T ) : Void	{			}	/**		Inserts the element [x] at the position [pos].		All elements after [pos] are moved one index ahead.	**/	public function insert( pos : Int, x : T ) : Void	{			}	/**		Removes the first occurence of [x].		Returns false if [x] was not present.		Elements are compared by using standard equality.	**/	public function remove( x : T ) : Bool	{		var found = false;		var i = -1;		while (++i < length)		{			if (!found)			{				if (__a[i] == x)					found = true;			} else {				__a[i - 1] = __a[i];			}		}				if (found)			__a[--length] = null;		return found;	}	/**		Returns a copy of the Array. The values are not		copied, only the Array structure.	**/	public function copy() : Array<T>	{		return this;	}	/**		Returns an iterator of the Array values.	**/	public function iterator() : Iterator<Null<T>>	{		return null;	}		private function __get(idx:Int):T	{		var idx:UInt = idx;		if (idx > __a.Length)			return null;				return __a[idx];	}		private function __set(idx:Int, v:T):T	{		var idx:UInt = idx;		if (idx >= __a.Length)		{			var newArr = new NativeArray<T>(idx + 1);			__a.CopyTo(newArr, 0);			this.__a = newArr;						this.length = cast (idx + 1);		}				return __a[idx] = v;	}}