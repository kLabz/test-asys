
package python.io;

import haxe.io.Eof;
import haxe.io.Input;

import python.io.IInput;
import python.io.IoTools;
import python.io.NativeInput;
import python.lib.Builtin;
import python.lib.Bytearray;
import python.lib.io.RawIOBase;
import python.lib.io.IOBase.SeekSet;
import python.lib.io.TextIOBase;


class NativeTextInput extends NativeInput<TextIOBase> implements IInput {

	public function new (stream:TextIOBase) {
		super(stream);
	}

	override public function readByte():Int
	{
		var ret = stream.read(1);

		if (ret.length == 0) throwEof();

		return ret.charCodeAt(0);
	}

	override public function seek( p : Int, pos : sys.io.FileSeek ) : Void
	{
		wasEof = false;
		IoTools.seekInTextMode(stream, tell, p, pos);
	}

	override function readinto (b:Bytearray):Int {
		return stream.buffer.readinto(b);
	}

}