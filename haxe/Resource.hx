/*
 * Copyright (C)2005-2013 Haxe Foundation
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
package haxe;

/**
	Resource can be used to access resources that were added through the
	-resource file@name command line parameter.

	Depending on their type they can be obtained as String through
	getString(name), or as binary data through getBytes(name).

	A list of all available resource names can be obtained from listNames().
**/
class Resource {

	#if (java || cs)
	@:keep static var content : Array<String>;
	#elseif python
	static var content : python.lib.Types.Dict<String, String>;
	#else
	static var content : Array<{ name : String, data : String, str : String }>;
	#end

	#if cs
	static var paths : haxe.ds.StringMap<String>;

	#if cs @:keep #end private static function getPaths():haxe.ds.StringMap<String>
	{
		if (paths != null)
			return paths;
		var p = new haxe.ds.StringMap();
		var all = cs.Lib.toNativeType(haxe.Resource).Assembly.GetManifestResourceNames();
		for (i in 0...all.Length)
		{
			var path = all[i];
			var name = path.substr(path.indexOf("Resources.") + 10);
			p.set(name, path);
		}

		return paths = p;
	}
	#end

	/**
		Lists all available resource names. The resource name is the name part
		of the -resource file@name command line parameter.
	**/
	public static function listNames() : Array<String> {
		var names = new Array();
		#if (java || cs)
		for ( x in content )
			names.push(x);
		#elseif python
		for ( k in content.keys().iter())
			names.push(k);
		#else
		for ( x in content )
			names.push(x.name);
		#end
		return names;
	}

	/**
		Retrieves the resource identified by `name` as a String.

		If `name` does not match any resource name, null is returned.
	**/
	public static function getString( name : String ) : String {
		#if java
		var stream = cast(Resource, java.lang.Class<Dynamic>).getResourceAsStream("/" + name);
		if (stream == null)
			return null;
		var stream = new java.io.NativeInput(stream);
		return stream.readAll().toString();
		#elseif cs
		var path = getPaths().get(name);
		var str = cs.Lib.toNativeType(haxe.Resource).Assembly.GetManifestResourceStream(path);
		if (str != null)
			return new cs.io.NativeInput(str).readAll().toString();
		return null;
		#elseif python
		for( k in content.keys().iter() )
			if( k == name ) {
				var b : haxe.io.Bytes = haxe.crypto.Base64.decode(content.get(k, null));
				return b.toString();

			}
		return null;
		#else
		for( x in content )
			if( x.name == name ) {
				#if neko
				return new String(x.data);
				#else
				if( x.str != null ) return x.str;
				var b : haxe.io.Bytes = haxe.crypto.Base64.decode(x.data);
				return b.toString();
				#end
			}
		return null;
		#end
	}

	/**
		Retrieves the resource identified by `name` as an instance of
		haxe.io.Bytes.

		If `name` does not match any resource name, null is returned.
	**/
	public static function getBytes( name : String ) : haxe.io.Bytes {
		#if java
		var stream = cast(Resource, java.lang.Class<Dynamic>).getResourceAsStream("/" + name);
		if (stream == null)
			return null;
		var stream = new java.io.NativeInput(stream);
		return stream.readAll();
		#elseif cs
		var path = getPaths().get(name);
		var str = cs.Lib.toNativeType(haxe.Resource).Assembly.GetManifestResourceStream(path);
		if (str != null)
			return new cs.io.NativeInput(str).readAll();
		return null;
		#elseif python
		for( k in content.keys().iter() )
			if( k == name ) {
				var b : haxe.io.Bytes = haxe.crypto.Base64.decode(content.get(k, null));
				return b;

			}
		return null;
		#else
		for( x in content )
			if( x.name == name ) {
				#if neko
				return haxe.io.Bytes.ofData(cast x.data);
				#else
				if( x.str != null ) return haxe.io.Bytes.ofString(x.str);
				return haxe.crypto.Base64.decode(x.data);
				#end
			}
		return null;
		#end
	}

	static function __init__() {
		#if neko
		var tmp = untyped __resources__();
		content = untyped Array.new1(tmp,__dollar__asize(tmp));
		#elseif php
		content = null;
		#elseif as3
		null;
		#elseif (java || cs)
		//do nothing
		#elseif python
		content = untyped _hx_resources__();
		#else
		content = untyped __resources__();
		#end
	}

}
