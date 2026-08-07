package hxd.modding;

import haxe.io.Path;
import haxe.Json;
import hxd.res.Loader;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?mods:Array<String>
}

class HeapsMod
{
    public static var modRoot(default, null):String;

    static var initialized(default, null):Bool;

    static var mods(default, null):Array<String>;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) throw 'HeapsMod has already been initialized';

        initialized = true;

        config ??= {};

        modRoot = config.modRoot ?? 'mods';
        mods = config.mods ?? [];

        Res.loader = new Loader(new HeapsModFS(Res.loader.fs));
    }

    public static function disable()
    {
        if (!initialized) return;

        initialized = false;

        modRoot = null;
        mods = null;

        if (Res.loader.fs is HeapsModFS)
            Res.loader = new Loader(cast(Res.loader.fs, HeapsModFS).baseFS);
    }

    public static function enableMod(mod:String)
    {
        if (!initialized || mods.contains(mod)) return;

        if (!hasModMeta(mod)) throw '$mod is NOT a valid mod';

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

    public static function getModPath(mod:String, path:String):String
    {
        return Path.join([mod, path]);
    }

    static function getModMeta(mod:String):HeapsModMeta
    {
        if (!initialized || !hasModMeta(mod)) return null;

        var text:String = Res.load(getModPath(mod, 'meta.json')).toText();
        var meta:HeapsModMeta = try { Json.parse(text); };

        meta ??= {}
        meta.mod = mod;

        meta.title ??= '';
        meta.description ??= '';
        meta.id ??= '';

        return meta;
    }

    static function hasModMeta(mod:String):Bool
    {
        return Res.loader.exists(getModPath(mod, 'meta.json'));
    }
}