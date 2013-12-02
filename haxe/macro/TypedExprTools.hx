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

package haxe.macro;

import haxe.macro.Context;
import haxe.macro.Type;

class TypedExprTools {
	#if macro
	
	static function with(e:TypedExpr, ?edef:TypedExprDef, ?t:Type) {
		return {
			expr: edef == null ? e.expr : edef,
			pos: e.pos,
			t: t == null ? e.t : t
		}
	}
	
	/**
		Transforms the sub-expressions of [e] by calling [f] on each of them.
		
		See `haxe.macro.ExprTools.map` for details on expression mapping in
		general. This function works the same way, but with a different data
		structure.
	**/
	static public function map(e:TypedExpr, f:TypedExpr -> TypedExpr):TypedExpr {
		return switch(e.expr) {
			case TConst(_) | TLocal(_) | TBreak | TContinue | TTypeExpr(_): e;
			case TArray(e1, e2): with(e, TArray(f(e1), f(e2)));
			case TBinop(op, e1, e2): with(e, TBinop(op, f(e1), f(e2)));
			case TFor(v, e1, e2): with(e, TFor(v, f(e1), f(e2)));
			case TWhile(e1, e2, flag): with(e, TWhile(f(e1), f(e2), flag));
			case TThrow(e1): with(e, TThrow(f(e1)));
			case TEnumParameter(e1, ef, i): with(e, TEnumParameter(f(e1), ef, i));
			case TField(e1, fa): with(e, TField(f(e1), fa));
			case TParenthesis(e1): with(e, TParenthesis(e1));
			case TUnop(op, pre, e1): with(e, TUnop(op, pre, f(e1)));
			case TArrayDecl(el): with(e, TArrayDecl(el.map(f)));
			case TNew(t, pl, el): with(e, TNew(t, pl, el.map(f)));
			case TBlock(el): with(e, TBlock(el.map(f)));
			case TObjectDecl(fl): with(e, TObjectDecl(fl.map(function(field) return { name: field.name, expr: f(field.expr) })));
			case TCall(e1, el): with(e, TCall(f(e1), el.map(f)));
			case TVars(v,eo): with(e, TVars(v, eo == null ? null : f(eo)));
			case TFunction(fu): with(e, TFunction({ t: fu.t, args: fu.args, expr: f(fu.expr)}));
			case TIf(e1, e2, e3): with(e, TIf(f(e1), f(e2), f(e3)));
			case TSwitch(e1, cases, e2): with(e, TSwitch(e1, cases.map(function(c) return { values: c.values, expr: f(c.expr) }), e2 == null ? null : f(e2)));
			case TPatMatch: throw false;
			case TTry(e1, catches): with(e, TTry(f(e1), catches.map(function(c) return { v:c.v, expr: f(c.expr) })));
			case TReturn(e1): with(e, TReturn(e1 == null ? null : f(e1)));
			case TCast(e1, mt): with(e, TCast(f(e1), mt));
			case TMeta(m, e1): with(e, TMeta(m, f(e1)));
		}
	}
	
	/**
		Transforms the sub-expressions of [e] by calling [f] on each of them.
		Additionally, types are mapped using `ft` and variables are mapped using
		`fv`.
		
		See `haxe.macro.ExprTools.map` for details on expression mapping in
		general. This function works the same way, but with a different data
		structure.
	**/
	static public function mapWithType(e:TypedExpr, f:TypedExpr -> TypedExpr, ft:Type -> Type, fv:TVar -> TVar):TypedExpr {
		return switch(e.expr) {
			case TConst(_) | TBreak | TContinue | TTypeExpr(_): with(e, ft(e.t));
			case TLocal(v): with(e, TLocal(fv(v)), ft(e.t));
			case TArray(e1, e2): with(e, TArray(f(e1), f(e2)), ft(e.t));
			case TBinop(op, e1, e2): with(e, TBinop(op, f(e1), f(e2)), ft(e.t));
			case TFor(v, e1, e2): with(e, TFor(fv(v), f(e1), f(e2)), ft(e.t));
			case TWhile(e1, e2, flag): with(e, TWhile(f(e1), f(e2), flag), ft(e.t));
			case TThrow(e1): with(e, TThrow(f(e1)), ft(e.t));
			case TEnumParameter(e1, ef, i): with(e, TEnumParameter(f(e1), ef, i), ft(e.t));
			case TField(e1, fa): with(e, TField(f(e1), fa), ft(e.t));
			case TParenthesis(e1): with(e, TParenthesis(e1), ft(e.t));
			case TUnop(op, pre, e1): with(e, TUnop(op, pre, f(e1)), ft(e.t));
			case TArrayDecl(el): with(e, TArrayDecl(el.map(f)), ft(e.t));
			case TNew(t, pl, el): with(e, TNew(t, pl, el.map(f)), ft(e.t));
			case TBlock(el): with(e, TBlock(el.map(f)), ft(e.t));
			case TObjectDecl(fl): with(e, TObjectDecl(fl.map(function(field) return { name: field.name, expr: f(field.expr) })), ft(e.t));
			case TCall(e1, el): with(e, TCall(f(e1), el.map(f)), ft(e.t));
			case TVars(v,eo): with(e, TVars(fv(v), eo == null ? null : f(eo)), ft(e.t));
			case TFunction(fu): with(e, TFunction({ t: ft(fu.t), args: fu.args.map(function(arg) return { v: fv(arg.v), value: arg.value }), expr: f(fu.expr)}), ft(e.t));
			case TIf(e1, e2, e3): with(e, TIf(f(e1), f(e2), f(e3)), ft(e.t));
			case TSwitch(e1, cases, e2): with(e, TSwitch(e1, cases.map(function(c) return { values: c.values, expr: f(c.expr) }), e2 == null ? null : f(e2)), ft(e.t));
			case TPatMatch: throw false;
			case TTry(e1, catches): with(e, TTry(f(e1), catches.map(function(c) return { v:fv(c.v), expr: f(c.expr) })), ft(e.t));
			case TReturn(e1): with(e, TReturn(e1 == null ? null : f(e1)), ft(e.t));
			case TCast(e1, mt): with(e, TCast(f(e1), mt), ft(e.t));
			case TMeta(m, e1): with(e, TMeta(m, f(e1)), ft(e.t));
		}
	}
	
	static public function toString(t:TypedExpr, ?pretty = false):String {
		return Context.load("s_expr", 2)(t, pretty);
	}
	#end
}