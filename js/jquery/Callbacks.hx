/* This file is generated, do not edit! Visit http://api.jquery.com/ for API documentation. */
package js.jquery;
@:final @:native("$.Callbacks") extern class Callbacks {
	/**
		Disable a callback list from doing anything more.
	**/
	public function disable():js.jquery.Callbacks;
	/**
		Remove all of the callbacks from a list.
	**/
	public function empty():js.jquery.Callbacks;
	/**
		Determine whether or not the list has any callbacks attached. If a callback is provided as an argument, determine whether it is in a list.
	**/
	public function has(?callback:haxe.Constraints.Function):Bool;
	/**
		Determine if the callbacks list has been locked.
	**/
	public function locked():Bool;
	/**
		A multi-purpose callbacks list object that provides a powerful way to manage callback lists.
	**/
	@:selfCall
	public function new(flags:String):Void;
	/**
		Call all of the callbacks with the given arguments.
	**/
	public function fire(arguments:Dynamic):js.jquery.Callbacks;
	/**
		Call all callbacks in a list with the given context and arguments.
	**/
	public function fireWith(?context:Dynamic, ?args:Dynamic):js.jquery.Callbacks;
	/**
		Add a callback or a collection of callbacks to a callback list.
	**/
	public function add(callbacks:haxe.extern.EitherType<haxe.Constraints.Function, Array<haxe.Constraints.Function>>):js.jquery.Callbacks;
	/**
		Lock a callback list in its current state.
	**/
	public function lock():js.jquery.Callbacks;
	/**
		Determine if the callbacks list has been disabled.
	**/
	public function disabled():Bool;
	/**
		Determine if the callbacks have already been called at least once.
	**/
	public function fired():Bool;
	/**
		Remove a callback or a collection of callbacks from a callback list.
	**/
	public function remove(callbacks:haxe.extern.EitherType<haxe.Constraints.Function, Array<haxe.Constraints.Function>>):js.jquery.Callbacks;
}