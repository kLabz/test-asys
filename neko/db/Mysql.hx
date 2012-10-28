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
package neko.db;
#if !spod_macro

import neko.db.Connection;

private class D {

	static function load(fun,args) : Dynamic {
		return neko.Lib.load(lib,fun,args);
	}

	static var lib = try { neko.Lib.load("mysql5","connect",1); "mysql5"; } catch( e : Dynamic ) "mysql";
	public static var connect = load("connect",1);
	public static var select_db = load("select_db",2);
	public static var request = load("request",2);
	public static var close = load("close",1);
	public static var escape = load("escape",2);
	public static var result_get_length = load("result_get_length",1);
	public static var result_get_nfields = load("result_get_nfields",1);
	public static var result_next = load("result_next",1);
	public static var result_get = load("result_get",2);
	public static var result_get_int = load("result_get_int",2);
	public static var result_get_float = load("result_get_float",2);
	public static var result_set_conv_date = load("result_set_conv_date",2);
	public static var result_fields_names = neko.Lib.loadLazy(lib,"result_get_fields_names",1);

}

private class MysqlResultSet implements ResultSet {

	public var length(getLength,null) : Int;
	public var nfields(getNFields,null) : Int;
	private var __r : Void;
	private var cache : Dynamic;

	public function new(r) {
		__r = r;
	}

	private function getLength() {
		return D.result_get_length(__r);
	}

	private function getNFields() {
		return D.result_get_nfields(__r);
	}

	public function hasNext() {
		if( cache == null )
			cache = next();
		return (cache != null);
	}

	public function next() : Dynamic {
		var c = cache;
		if( c != null ) {
			cache = null;
			return c;
		}
		c = D.result_next(__r);
		if( c == null )
			return null;
		untyped {
			var f = __dollar__objfields(c);
			var i = 0;
			var l = __dollar__asize(f);
			while( i < l ) {
				var v = __dollar__objget(c,f[i]);
				if( __dollar__typeof(v) == __dollar__tstring )
					__dollar__objset(c,f[i],new String(v));
				i = i + 1;
			}
		}
		return c;
	}

	public function results() : List<Dynamic> {
		var l = new List();
		while( hasNext() )
			l.add(next());
		return l;
	}

	public function getResult( n : Int ) {
		return new String(D.result_get(__r,n));
	}

	public function getIntResult( n : Int ) : Int {
		return D.result_get_int(__r,n);
	}

	public function getFloatResult( n : Int ) : Float {
		return D.result_get_float(__r,n);
	}

	public function getFieldsNames() : Array<String> {
		var a = D.result_fields_names(__r);
		untyped {
			var i = 0;
			var l = __dollar__asize(a);
			while( i < l ) {
				a[i] = new String(a[i]);
				i += 1;
			}
			a = Array.new1(cast a,l);
		}
		return a;
	}

}

private class MysqlConnection implements Connection {

	private var __c : Void;

	public function new(c) {
		__c = c;
	}

	public function request( s : String ) : ResultSet {
		try {
			var r = D.request(this.__c,untyped s.__s);
			D.result_set_conv_date(r,function(d) { return untyped Date.new1(d); });
			return new MysqlResultSet(r);
		} catch( e : Dynamic ) {
			untyped if( __dollar__typeof(e) == __dollar__tobject && __dollar__typeof(e.msg) == __dollar__tstring )
				e = e.msg;
			untyped __dollar__rethrow(e);
			return null;
		}
	}

	public function close() {
		D.close(__c);
	}

	public function escape( s : String ) {
		return new String(D.escape(__c,untyped s.__s));
	}

	public function quote( s : String ) {
		return "'"+escape(s)+"'";
	}

	public function addValue( s : StringBuf, v : Dynamic ) {
		var t = untyped __dollar__typeof(v);
		if( untyped (t == __dollar__tint || t == __dollar__tnull) )
			s.add(v);
		else if( untyped t == __dollar__tbool )
			s.addChar(if( v ) "1".code else "0".code);
		else {
			s.addChar("'".code);
			s.add(escape(Std.string(v)));
			s.addChar("'".code);
		}
	}

	public function lastInsertId() {
		return request("SELECT LAST_INSERT_ID()").getIntResult(0);
	}

	public function dbName() {
		return "MySQL";
	}

	public function startTransaction() {
		request("START TRANSACTION");
	}

	public function commit() {
		request("COMMIT");
	}

	public function rollback() {
		request("ROLLBACK");
	}

	private static var __use_date = Date;
}

class Mysql {

	public static function connect( params : {
		host : String,
		port : Int,
		user : String,
		pass : String,
		socket : String,
		database : String
	} ) : neko.db.Connection {
		var o = untyped {
			host : params.host.__s,
			port : params.port,
			user : params.user.__s,
			pass : params.pass.__s,
			socket : if( params.socket == null ) null else params.socket.__s
		};
		var c = D.connect(o);
		try {
			D.select_db(c,untyped params.database.__s);
		} catch( e : Dynamic ) {
			D.close(c);
			neko.Lib.rethrow(e);
		}
		return new MysqlConnection(c);
	}

}

#end