package flash.ui;

extern class Mouse {
	@:require(flash10) static var cursor : MouseCursor;
	@:require(flash10_1) static var supportsCursor(default,null) : Bool;
	@:require(flash11) static var supportsNativeCursor(default,null) : Bool;
	static function hide() : Void;
	@:require(flash10_2) static function registerCursor(name : String, cursor : MouseCursorData) : Void;
	static function show() : Void;
	@:require(flash11) static function unregisterCursor(name : String) : Void;
}
