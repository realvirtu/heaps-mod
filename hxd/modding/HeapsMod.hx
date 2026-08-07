package hxd.modding;

import hxd.modding.mod.Mod;
import hxd.res.Loader;

using Lambda;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?metaFile:String,
    ?mods:Array<String>,
    ?ignoredFiles:Array<String>
}

class HeapsMod
{
    public static var initialized(default, null):Bool;

    public static var modRoot(default, null):String;
    public static var metaFile(default, null):String;

    static var fs(default, null):HeapsModFS;
    static var mods(default, null):Array<Mod>;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) throw 'HeapsMod has already been initialized';

        initialized = true;

        config ??= {};

        modRoot = config.modRoot ?? 'mods';
        metaFile = config.metaFile ?? 'meta.json';

        fs = new HeapsModFS(Res.loader.fs);
        mods = [];

        for (file in config.ignoredFiles ?? []) fs.ignoredFiles.push(file);

        Res.loader = new Loader(fs);

        // Loads the mods specified in the config
        for (mod in config.mods ?? []) enableMod(mod);
    }

    public static function enableMod(mod:String):Mod
    {
        if (!initialized || !fs.hasMeta(mod) || hasEnabledMod(mod)) return null;

        var mod:Mod = new Mod(fs.getMeta(mod));

        mods.push(mod);

        return mod;
    }

    public static function disableMod(mod:String)
    {
        if (!hasEnabledMod(mod)) return;

        var mod:Mod = getEnabledMod(mod);

        mods.remove(mod);
        mod.dispose();
    }

    public static function scan():Array<ModMeta>
    {
        if (!initialized) return [];

        var result:Array<ModMeta> = [];

        for (mod in Res.loader.dir(''))
        {
            if (!fs.hasMeta(mod.name)) continue;

            result.push(fs.getMeta(mod.name));
        }

        return result;
    }

    public static function getEnabledMods():Array<Mod>
    {
        if (!initialized) return [];

        return mods.copy();
    }

    public static function getEnabledMod(mod:String):Mod
    {
        if (!initialized) return null;

        return getEnabledMods().find(m -> return m.mod == mod);
    }

    public static function hasEnabledMod(mod:String):Bool
    {
        if (!initialized) return false;

        return getEnabledMod(mod) != null;
    }

    public static function disable()
    {
        if (!initialized) return;

        clearCache();

        initialized = false;

        modRoot = null;
        metaFile = null;

        mods = null;

        // Dispose the modding filesystem
        // Reuse the original filesystem
        Res.loader = new Loader(fs.baseFS);

        fs.dispose();
        fs = null;
    }

    public static function clearCache()
    {
        if (!initialized) return;

        for (mod in mods)
            mod.clearCache();

        fs.clearCache();
    }
}