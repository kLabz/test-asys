package asys.native.filesystem;

import haxe.io.Bytes;
import haxe.EntryPoint;
import php.*;
import php.Const.*;
import php.Global.*;
import php.Syntax.*;
import php.NativeArray;

private typedef NativeFilePath = php.NativeString;

@:coreApi abstract FilePath(NativeFilePath) to String to NativeString {
	public static var SEPARATOR(get,never):String;
	static inline function get_SEPARATOR():String {
		return DIRECTORY_SEPARATOR;
	}

	@:allow(asys.native.filesystem)
	inline function new(s:String) {
		this = s == null || strlen(s) == 1 ? s : rtrim(s, DIRECTORY_SEPARATOR == '/' ? '/' : '\\/');
	}

	@:from public static inline function fromString(path:String):FilePath {
		return new FilePath(path);
	}

	public function toString():String {
		return this;
	}

	public function isAbsolute():Bool {
		if(this == '')
			return false;
		if(this[0] == '/')
			return true;
		if(SEPARATOR == '\\') {
			if(this[0] == '\\')
				return true;
			//This is not 100% valid. `Z:some\path` is "a relative path from the current directory of the Z: drive"
			//but PHP doesn't have a function to get current directory of another drive so we keep the check like this
			//to be consisten with `FilePath.absolute` method.
			if(preg_match('/^[a-zA-Z]:/', this))
				return true;
		}
		return false;
	}

	public function absolute():FilePath {
		inline function cwd():String {
			var result = getcwd();
			if(result == false)
				throw new FsException(CustomError('Unable to get current working directory'), this);
			return result;
		}
		var fullPath = if(this == '') {
			cwd();
		} else if(this[0] == '/') {
			this;
		} else if(SEPARATOR == '\\') {
			if(this[0] == '\\') {
				this;
			//This is not 100% valid. `Z:some\path` is "a relative path from the current directory of the Z: drive"
			//but PHP doesn't have a function to get current directory of another drive
			} else if(preg_match('/^[a-zA-Z]:/', this)) {
				this;
			} else {
				rtrim(cwd() + SEPARATOR + this, '\\/');
			}
		} else {
			rtrim(cwd() + SEPARATOR + this, '/');
		}

		var parts:NativeIndexedArray<String> = if(SEPARATOR == '\\') {
			(preg_split('#\\|/#', fullPath):NativeArray);
		} else {
			explode('/', fullPath);
		}
		var i = 1;
		var result = new NativeIndexedArray();
		while(i < count(parts)) {
			switch parts[i] {
				case '.' | '':
				case '..':
					array_pop(result);
				case part:
					result.push(part);
			}
			i++;
		}
		array_unshift(result, parts[0]);
		return implode(SEPARATOR, result);
	}

	public function parent():Null<FilePath> {
		var path = if(this == '.') {
			Sys.getCwd();
		} else {
			switch dirname(this) {
				case '.':
					var abs = absolute();
					var path = dirname(abs);
					path == abs ? null : path;
				case '':
					dirname(Sys.getCwd());
				case path:
					path == this ? null : path;
			}
		}
		return new FilePath(path);
	}
}