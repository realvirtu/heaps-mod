package hxd.modding;

import haxe.io.Path;
import haxe.Json;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;
import hxd.modding.mod.Mod;

using Lambda;

class HeapsModFS extends LocalFileSystem
{
    public final ignoredFiles:Array<String> = [
        '.git',
        '.vscode'
    ];

    public final baseFS:FileSystem;

    public function new(baseFS:FileSystem)
    {
        super(HeapsMod.modRoot, null);

        this.baseFS = baseFS;
    }

    //
    // MODDING
    //

    override function get(path:String):LocalEntry
    {
        // Don't check mods for "path" if it's ignored
        if (!ignoredFiles.contains(path))
        {
            var mods:Array<Mod> = HeapsMod.getEnabledMods();

            for (i in 0...mods.length)
            {
                var mod:Mod = mods[mods.length - i - 1];

                if (mod.fs.exists(path)) return mod.fs.get(path);
            }
        }

        return cast baseFS.get(path);
    }

    override function exists(path:String):Bool
    {
        // Don't check mods for "path" if it's ignored
        if (ignoredFiles.contains(path)) return baseFS.exists(path);

        if (HeapsMod.getEnabledMods().exists(mod -> return mod.fs.exists(path))) return true;

        return baseFS.exists(path);
    }

    //
    // META
    //

    public function getMeta(mod:String):ModMeta
    {
        if (!hasMeta(mod)) return null;

        var text:String = super.get(getMetaPath(mod)).getText();
        var meta:ModMeta = try { Json.parse(text); } catch (e) null;

        meta ??= {};
        meta.mod = mod;
        
        meta.title ??= '';
        meta.description ??= '';
        meta.id ??= '';

        return meta;
    }

    public function hasMeta(mod:String):Bool
    {
        return super.exists(getMetaPath(mod));
    }

    public function getMetaPath(mod:String):String
    {
        return Path.join([mod, HeapsMod.metaFile]);
    }
}