package hxd.modding;

import hxd.fs.FileEntry;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;
import hxd.fs.MultiFileSystem;

using Lambda;
using StringTools;

class HeapsModFS extends MultiFileSystem
{
    public static var instance:HeapsModFS;
    public static var modFS:LocalFileSystem;
    public static var baseFS:FileSystem;

    public function new(fs:FileSystem)
    {
        instance = this;
        modFS = new LocalFileSystem(HeapsMod.config.modRoot, null);
        baseFS = fs;

        super([modFS, baseFS]);
    }

    override function dir(path:String):Array<FileEntry>
    {
        var result:Array<FileEntry> = [];

        for (fs in fs)
        {
            for (entry in try fs.dir(path) catch (e) [])
            {
                if (result.exists(file -> return file.path == entry.path)) continue;

                result.push(entry);
            }
        }

        return result;
    }
}