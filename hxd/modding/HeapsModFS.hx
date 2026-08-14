package hxd.modding;

import hxd.fs.FileEntry;
import haxe.io.Path;
import haxe.Json;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;
import hxd.modding.mod.Mod;

using Lambda;
using StringTools;

class HeapsModFS extends LocalFileSystem
{
    public final baseFS:FileSystem;

    public function new(baseFS:FileSystem)
    {
        super(HeapsMod.config.modRoot, null);

        this.baseFS = baseFS;
    }

    //
    // MODDING
    //

    override function dir(path:String):Array<FileEntry>
    {
        var result:Array<FileEntry> = baseFS.dir(path);
        
        for (entry in super.dir(path))
        {
            if (result.exists(file -> return file.path == entry.path)) continue;

            result.push(entry);
        }

        for (mod in HeapsMod.getEnabledMods())
        {
            for (entry in mod.fs.dir(path))
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

    override function get(path:String):LocalEntry
    {
        var mods:Array<Mod> = HeapsMod.getEnabledMods();

        for (i in 0...mods.length)
        {
            var mod:Mod = mods[mods.length - i - 1];

            if (mod.fs.exists(path)) return mod.fs.get(path);
        }

        return cast baseFS.get(path);
    }

    override function exists(path:String):Bool
    {
        if (HeapsMod.getEnabledMods().exists(mod -> return mod.fs.exists(path))) return true;

        return baseFS.exists(path);
    }

    //
    // META
    //

    public function getMeta(mod:String):ModMeta
    {
        var meta:ModMeta = null;

        try
        {
            var text:String = super.get(getMetaPath(mod)).getText();

            meta = Json.parse(text);

            meta ??= {};
            meta.mod = mod;
            
            meta.title ??= '';
            meta.description ??= '';
            meta.dependencies ??= [];
        }
        catch (e)
        {
            return null;
        }
        
        if (meta.id == null) HeapsMod.error(WARNING, MOD_MISSING_ID, 'Mod $mod is missing "id"');
        if (meta.version == null) HeapsMod.error(WARNING, MOD_MISSING_MOD_VERSION, 'Mod $mod is missing "version"');
        if (meta.apiVersion == null) HeapsMod.error(WARNING, MOD_MISSING_API_VERSION, 'Mod $mod is missing "apiVersion"');

        return meta;
    }

    public function hasMeta(mod:String):Bool
    {
        return super.exists(getMetaPath(mod));
    }

    public function getMetaPath(mod:String):String
    {
        return Path.join([mod, HeapsMod.config.metaFile]);
    }
}