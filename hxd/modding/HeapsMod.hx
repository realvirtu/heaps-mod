package hxd.modding;

import haxe.io.Path;
import haxe.Json;
import hxd.res.Loader;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?metaFile:String,
    ?mods:Array<String>,
    ?ignoredFiles:Array<String>
}

class HeapsMod
{
    public static var modRoot(default, null):String;

    static var initialized(default, null):Bool;

    static var metaFile(default, null):String;
    static var mods(default, null):Array<String>;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) throw 'HeapsMod has already been initialized';

        initialized = true;

        config ??= {};

        modRoot = config.modRoot ?? 'mods';
        metaFile = config.metaFile ?? 'meta.json';
        mods = config.mods ?? [];

        // Loads the HeapsMod filesystem
        var fs:HeapsModFS = new HeapsModFS(Res.loader.fs);
        var ignoredFiles:Array<String> = config.ignoredFiles ?? [];

        for (file in ignoredFiles.concat([metaFile])) fs.ignoredFiles.push(file);

        Res.loader = new Loader(fs);
    }

    public static function disable()
    {
        if (!initialized) return;

        initialized = false;

        modRoot = null;
        metaFile = null;
        mods = null;

        cleanCache();

        // If possible, replace the current filesystem with the original
        if (Res.loader.fs is HeapsModFS)
            Res.loader = new Loader(cast(Res.loader.fs, HeapsModFS).baseFS);
    }

    public static function enableMod(mod:String)
    {
        if (!initialized || mods.contains(mod) || !hasModMeta(mod)) return;

        mods.push(mod);
    }

    public static function disableMod(mod:String)
    {
        if (!initialized || !mods.contains(mod)) return;

        mods.remove(mod);
    }

    public static function getEnabledMods():Array<String>
    {
        if (!initialized) return [];

        return mods.copy();
    }

    public static function scan():Array<HeapsModMeta>
    {
        var result:Array<HeapsModMeta> = [];

        if (!initialized) return result;

        for (file in Res.loader.dir(''))
        {
            if (!hasModMeta(file.name)) continue;

            result.push(getModMeta(file.name));
        }

        return result;
    }

    public static function cleanCache()
    {
        if (!(Res.loader.fs is HeapsModFS)) return;

        Res.loader.cleanCache();
    }

    public static function getModMeta(mod:String):HeapsModMeta
    {
        if (!initialized || !hasModMeta(mod)) return null;

        var text:String = Res.load(getModPath(mod, metaFile)).toText();
        var meta:HeapsModMeta = try { Json.parse(text); };

        meta ??= {}
        meta.mod = mod;

        meta.title ??= '';
        meta.description ??= '';
        meta.id ??= '';

        return meta;
    }

    public static function hasModMeta(mod:String):Bool
    {
        if (!initialized) return false;

        return Res.loader.exists(getModPath(mod, metaFile));
    }

    public static function getModPath(mod:String, path:String):String
    {
        return Path.join([mod, path]);
    }
}