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
import cs.Lib;
import cs.internal.HxObject;
import cs.internal.Runtime;
import cs.system.reflection.*;
using StringTools;

@:keep enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass( c : Class<Dynamic> );
	TEnum( e : Enum<Dynamic> );
	TUnknown;
}

@:keep @:coreApi class Type {

	@:functionCode('
		if (o == null || o is haxe.lang.DynamicObject || o is System.Type)
			return null;

		return o.GetType();
	')
	public static function getClass<T>( o : T ) : Class<T> untyped
	{
		return null;
	}

	@:functionCode('
		if (o is System.Enum || o is haxe.lang.Enum)
			return o.GetType();
		return null;
	')
	public static function getEnum( o : EnumValue ) : Enum<Dynamic> untyped
	{
		return null;
	}

	public static function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic>
	{
		var t:cs.system.Type = Lib.toNativeType(c);
		var base = t.BaseType;
		if (base == null || (base + "") == ("haxe.lang.HxObject") || (base + "") == ("System.Object"))
		{
			return null;
		}

		return Lib.fromNativeType(base);
	}

	public static function getClassName( c : Class<Dynamic> ) : String {
		var ret:String = cast Lib.toNativeType(c);
#if no_root
		if (ret.length > 10 && StringTools.startsWith(ret, "haxe.root."))
			ret = ret.substr(10);
#end

		return switch(ret)
		{
			case "System.Int32": "Int";
			case "System.Double": "Float";
			case "System.String": "String";
			case "System.Object": "Dynamic";
			case "System.Type": "Class";
			default: ret.split("`")[0];
		}
	}

	public static function getEnumName( e : Enum<Dynamic> ) : String
	{
		var ret:String = cast Lib.toNativeType(untyped e);
#if no_root
		if (ret.length > 10 && StringTools.startsWith(ret, "haxe.root."))
			ret = ret.substr(10);
#end
		if (ret.length == 14 && ret == "System.Boolean")
			return "Bool";
		return ret;
	}

	public static function resolveClass( name : String ) : Class<Dynamic>
	{
#if no_root
		if (name.indexOf(".") == -1)
			name = "haxe.root." + name;
#end
		var t:cs.system.Type = cs.system.Type._GetType(name);
#if !CF
		if (t == null)
		{
			var all = cs.system.AppDomain.CurrentDomain.GetAssemblies().GetEnumerator();
			while (all.MoveNext())
			{
				var t2:cs.system.reflection.Assembly = all.Current;
				t = t2.GetType(name);
				if (t != null)
					break;
			}
		}
#end
		if (t == null)
		{
			switch(name)
			{
				case #if no_root "haxe.root.Int" #else "Int" #end: return cast Int;
				case #if no_root "haxe.root.Float" #else "Float" #end: return cast Float;
				case #if no_root "haxe.root.Class" #else "Class" #end: return cast Class;
				case #if no_root "haxe.root.Dynamic" #else "Dynamic" #end: return cast Dynamic;
				case #if no_root "haxe.root.String" #else "String" #end: return cast String;
				default: return null;
			}
		} else if (t.IsInterface && cast(untyped __typeof__(IGenericObject), cs.system.Type).IsAssignableFrom(t)) {
			t = null;
			var i = 0;
			var ts = "";
			while (t == null && i < 18)
			{
				i++;
				ts += (i == 1 ? "" : ",") + "System.Object";
				t = cs.system.Type._GetType(name + "`" + i + "[" + ts + "]");
			}

			return Lib.fromNativeType(t);
		} else {
			return Lib.fromNativeType(t);
		}
	}

	@:functionCode('
		if (name == "Bool") return typeof(bool);
		System.Type t = resolveClass(name);
		if (t != null && (t.BaseType.Equals(typeof(System.Enum)) || (typeof(haxe.lang.Enum)).IsAssignableFrom(t)))
			return t;
		return null;
	')
	public static function resolveEnum( name : String ) : Enum<Dynamic> untyped
	{
		return null;
		// if (ret != null && (ret.BaseType.Equals(cs.Lib.toNativeType(cs.system.Enum)) || ret.IsAssignableFrom(cs.Lib.toNativeType(haxe.
	}

	public static function createInstance<T>( cl : Class<T>, args : Array<Dynamic> ) : T
	{
		if (untyped cl == String)
			return args[0];
		var t:cs.system.Type = Lib.toNativeType(cl);
		if (t.IsInterface)
		{
			//may be generic
			t = Lib.toNativeType(resolveClass(getClassName(cl)));
		}
		var ctors = t.GetConstructors();
		return Runtime.callMethod(null, cast ctors, ctors.Length, args);
	}

	public static function createEmptyInstance<T>( cl : Class<T> ) : T
	{
		var t:cs.system.Type = Lib.toNativeType(cl);
		if (t.IsInterface)
		{
			//may be generic
			t = Lib.toNativeType(resolveClass(getClassName(cl)));
		}

		if (Reflect.hasField(cl, "__hx_createEmpty"))
			return untyped cl.__hx_createEmpty();
		if (untyped cl == String)
			return cast "";
		var t:cs.system.Type = Lib.toNativeType(cl);

		var ctors = t.GetConstructors();
		for (c in 0...ctors.Length)
		{
			if (ctors[c].GetParameters().Length == 0)
			{
				var arr = new cs.NativeArray(1);
				arr[0] = ctors[c];
				return Runtime.callMethod(null, cast arr, arr.Length, []);
			}
		}
		return cs.system.Activator.CreateInstance(t);
	}

	@:functionCode('
		if (@params == null || @params[0] == null)
		{
			object ret = haxe.lang.Runtime.slowGetField(e, constr, true);
			if (ret is haxe.lang.Function)
				throw haxe.lang.HaxeException.wrap("Constructor " + constr + " needs parameters");
			return (T) ret;
		} else {
			return (T) haxe.lang.Runtime.slowCallField(e, constr, @params);
		}
	')
	public static function createEnum<T>( e : Enum<T>, constr : String, ?params : Array<Dynamic> ) : T
	{
		return null;
	}

	public static function createEnumIndex<T>( e : Enum<T>, index : Int, ?params : Array<Dynamic> ) : T {
		var constr = getEnumConstructs(e);
		return createEnum(e, constr[index], params);
	}

	public static function getInstanceFields( c : Class<Dynamic> ) : Array<String>
	{
		if (c == String)
			return cs.internal.StringExt.StringRefl.fields;

		var c = cs.Lib.toNativeType(c);
		var ret = [];
		var mis = c.GetMembers(new cs.Flags(BindingFlags.Public) | BindingFlags.Instance | BindingFlags.FlattenHierarchy);
		for (i in 0...mis.Length)
		{
			var i = mis[i];
			if (Std.is(i, PropertyInfo))
				continue;
			var n = i.Name;
			if (!n.startsWith('__hx_') && n.fastCodeAt(0) != '.'.code)
			{
				switch(n)
				{
					case 'Equals' | 'ToString' | 'GetHashCode' | 'GetType':
					case _:
						ret.push(n);
				}
			}
		}
		return ret;
	}

	@:functionCode('
		Array<object> ret = new Array<object>();

		if (c == typeof(string))
		{
			ret.push("fromCharCode");
			return ret;
		}

        System.Reflection.MemberInfo[] mis = c.GetMembers(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
        for (int i = 0; i < mis.Length; i++)
        {
            string n = mis[i].Name;
			if (!n.StartsWith("__hx_"))
				ret.push(mis[i].Name);
        }

        return ret;
	')
	public static function getClassFields( c : Class<Dynamic> ) : Array<String> {
		return null;
	}

	public static function getEnumConstructs( e : Enum<Dynamic> ) : Array<String> {
		if (Reflect.hasField(e, "constructs"))
			return untyped e.constructs.copy();
		return cs.Lib.array(cs.system.Enum.GetNames(untyped e));
	}

	@:functionCode('
		if (v == null) return ValueType.TNull;

        System.Type t = v as System.Type;
        if (t != null)
        {
            //class type
            return ValueType.TObject;
        }

        t = v.GetType();
        if (t.IsEnum)
            return ValueType.TEnum(t);
        if (t.IsValueType)
        {
            System.IConvertible vc = v as System.IConvertible;
            if (vc != null)
            {
                switch (vc.GetTypeCode())
                {
                    case System.TypeCode.Boolean: return ValueType.TBool;
                    case System.TypeCode.Double:
						double d = vc.ToDouble(null);
						if (d >= int.MinValue && d <= int.MaxValue && d == vc.ToInt32(null))
							return ValueType.TInt;
						else
							return ValueType.TFloat;
                    case System.TypeCode.Int32:
                        return ValueType.TInt;
                    default:
                        return ValueType.TClass(t);
                }
            } else {
                return ValueType.TClass(t);
            }
        }

        if (v is haxe.lang.IHxObject)
        {
            if (v is haxe.lang.DynamicObject)
                return ValueType.TObject;
            else if (v is haxe.lang.Enum)
                return ValueType.TEnum(t);
            return ValueType.TClass(t);
        } else if (v is haxe.lang.Function) {
            return ValueType.TFunction;
        } else {
            return ValueType.TClass(t);
        }
	')
	public static function typeof( v : Dynamic ) : ValueType
	{
		return null;
	}

	@:functionCode('
			if (a is haxe.lang.Enum)
				return a.Equals(b);
			else
				return haxe.lang.Runtime.eq(a, b);
	')
	public static function enumEq<T>( a : T, b : T ) : Bool
	{
		return untyped a.Equals(b);
	}

	@:functionCode('
		if (e is System.Enum)
			return e + "";
		else
			return ((haxe.lang.Enum) e).getTag();
	')
	public static function enumConstructor( e : EnumValue ) : String untyped
	{
		return e.tag;
	}

	@:functionCode('
		return ( e is System.Enum ) ? new Array<object>() : ((haxe.lang.Enum) e).getParams();
	')
	public static function enumParameters( e : EnumValue ) : Array<Dynamic> untyped
	{
		return null;
	}

	@:functionCode('
		if (e is System.Enum)
		{
			System.Array values = System.Enum.GetValues(e.GetType());
			return System.Array.IndexOf(values, e);
		} else {
			return ((haxe.lang.Enum) e).index;
		}
	')
	public static function enumIndex( e : EnumValue ) : Int  untyped
	{
		return e.index;
	}

	public static function allEnums<T>( e : Enum<T> ) : Array<T>
	{
		var ctors = getEnumConstructs(e);
		var ret = [];
		for (ctor in ctors)
		{
			var v = Reflect.field(e, ctor);
			if (Std.is(v, e))
				ret.push(v);
		}

		return ret;
	}

}
