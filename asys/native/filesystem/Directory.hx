package asys.native.filesystem;

import haxe.NoData;
import haxe.exceptions.NotImplementedException;

/**
	Represents a directory.
**/
@:coreApi
class Directory {
	/** The path of this directory as it was at the moment of opening the directory */
	public final path:FilePath;

	function new() {
		path = 'stub';
	}

	/**
		Read next directory entry.
		Passes `null` to `callback` if no more entries left to read.
		Ignores `.` and `..` entries.
	**/
	public function nextEntry(callback:Callback<Null<FilePath>>):Void {
		throw new NotImplementedException();
	}

	/**
		Read next batch of directory entries.
		Passes an empty array to `callback` if no more entries left to read.
		Ignores `.` and `..` entries.
	**/
	public function nextBatch(maxBatchSize:Int, callback:Callback<Array<FilePath>>):Void {
		throw new NotImplementedException();
	}

	/**
		Close the directory.
	**/
	public function close(callback:Callback<NoData>):Void {
		throw new NotImplementedException();
	}
}