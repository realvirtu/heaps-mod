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

        if (!mod.hasDependencies()) throw '${mod.mod} is missing dependencies ${mod.getMissingDependencies()}';

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
        var mods:Array<ModMeta> = [];

        for (mod in Res.loader.dir(''))
        {
            if (!fs.hasMeta(mod.name)) continue;

            mods.push(fs.getMeta(mod.name));
        }

        var current:Array<String> = [];

        function add(id:String)
        {
            var meta:ModMeta = mods.find(mod -> return mod.id == id);

            if (meta == null || result.contains(meta)) return;

            current.push(id);

            for (dep in meta.dependencies)
            {
                if (dep == meta.id) throw '$id cannot depend on itself';
                if (current.contains(dep)) throw 'Mods cannot depend on each other';

                add(dep);
            }

            result.push(meta);

            trace(meta.mod);
        }

        for (meta in mods)
        {
            current = [];

            add(meta.id);
        }

        return result;
    }

    public static function getEnabledMods():Array<Mod>
    {
        if (!initialized) return [];

        return mods.copy();
    }

    public static function getEnabledMod(id:String):Mod
    {
        if (!initialized) return null;

        return getEnabledMods().find(m -> return m.mod == id || m.id == id);
    }

    public static function hasEnabledMod(id:String):Bool
    {
        if (!initialized) return false;

        return getEnabledMod(id) != null;
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