package hxd.modding;

import hxd.fs.FileEntry;
import haxe.io.Path;
import haxe.Json;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;
import hxd.fs.MultiFileSystem;
import hxd.modding.mod.Mod;

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

        for (i in 0...fs.length)
        {
            var fs:FileSystem = fs[fs.length - i - 1];

            for (entry in try fs.dir(path) catch (e) [])
            {
                var ogEntry:FileEntry = result.find(file -> return file.path == entry.path);

                if (ogEntry != null)
                {
                    result.insert(result.indexOf(ogEntry), entry);
                    result.remove(ogEntry);

                    continue;
                }

                result.push(entry);
            }
        }

        return result;
    }

    public function getMeta(mod:String):ModMeta
    {
        var meta:ModMeta = null;

        try
        {
            var text:String = modFS.get(getMetaPath(mod)).getText();

            meta = Json.parse(text);

            meta ??= {};
            meta.mod = mod;
            
            meta.title ??= '';
            meta.description ??= '';
            meta.dependencies ??= [];
        }
        catch (e) return null;
        
        if (meta.id == null) HeapsMod.error(WARNING, MOD_MISSING_ID, 'Mod $mod is missing "id"');
        if (meta.version == null) HeapsMod.error(WARNING, MOD_MISSING_MOD_VERSION, 'Mod $mod is missing "version"');
        if (meta.apiVersion == null) HeapsMod.error(WARNING, MOD_MISSING_API_VERSION, 'Mod $mod is missing "apiVersion"');

        return meta;
    }

    public function hasMeta(mod:String):Bool
    {
        return modFS.exists(getMetaPath(mod));
    }

    public function getMetaPath(mod:String):String
    {
        return Path.join([mod, HeapsMod.config.metaFile]);
    }
}