package hxd.modding;

import hxd.modding.mod.Mod;
import hxd.modding.HeapsModError;
import hxd.res.Loader;

#if hxscript
import hxd.modding.script.HeapsScript;
#end

using Lambda;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?metaFile:String,
    ?mods:Array<String>,
    ?scriptExts:Array<String>,
    ?skipDependencies:Bool,
    ?skipDependencyErrors:Bool,
    ?onError:HeapsModError->Void
}

class HeapsMod
{
    static final DEFAULT_MOD_ROOT:String = 'mods';
    static final DEFAULT_META_FILE:String = 'meta.json';
    static final DEFAULT_SCRIPT_EXTS:Array<String> = ['hxc'];

    public static var initialized(default, null):Bool;

    public static var modRoot(default, null):String;
    public static var metaFile(default, null):String;
    public static var skipDependencies(default, null):Bool;
    public static var skipDependencyErrors(default, null):Bool;

    static var fs(default, null):HeapsModFS;
    static var mods(default, null):Array<Mod>;

    static var onError(default, null):HeapsModError->Void;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) return;

        initialized = true;

        config ??= {};

        modRoot = config.modRoot ?? DEFAULT_MOD_ROOT;
        metaFile = config.metaFile ?? DEFAULT_META_FILE;
        skipDependencies = config.skipDependencies ?? false;
        skipDependencyErrors = config.skipDependencyErrors ?? false;

        mods = [];
        onError = config.onError;

        #if hxscript
        HeapsScript.extensions = config.scriptExts ?? DEFAULT_SCRIPT_EXTS;
        #end

        Res.loader = new Loader(fs = new HeapsModFS(Res.loader.fs));

        for (mod in config.mods ?? []) enableMod(mod);

        error(DEBUG, INITIALIZED, 'HeapsMod initialized');
    }

    public static function enableMod(mod:String):Mod
    {
        if (!initialized || !fs.hasMeta(mod) || hasEnabledMod(mod)) return null;

        var mod:Mod = new Mod(fs.getMeta(mod));
        
        if (!mod.hasDependencies() && !skipDependencies)
        {
            error(ERROR, MOD_MISSING_DEPENDENCIES, 'Mod $mod has missing dependencies: ${mod.getMissingDependencies()}');

            if (!skipDependencyErrors)
            {
                mod.dispose();

                return null;
            }
        }
        
        mods.push(mod);

        error(DEBUG, MOD_ENABLED, 'Enabled mod $mod');

        #if hxscript
        HeapsScript.loadScripts();
        #end

        return mod;
    }

    public static function disableMod(mod:String)
    {
        if (!hasEnabledMod(mod)) return;

        var mod:Mod = getEnabledMod(mod);

        mods.remove(mod);
        mod.dispose();

        error(DEBUG, MOD_DISABLED, 'Disabled mod $mod');

        #if hxscript
        HeapsScript.loadScripts();
        #end
    }

    public static function scan():Array<ModMeta>
    {
        if (!initialized) return [];

        var result:Array<ModMeta> = [];
        var mods:Array<ModMeta> = [];

        for (mod in Res.loader.dir(''))
        {
            if (!fs.hasMeta(mod.name))
            {
                if (mod.entry.isDirectory) error(WARNING, MOD_MISSING_META, 'Mod ${mod.name} lacks metadata');
                continue;
            }

            mods.push(fs.getMeta(mod.name));
        }

        var current:Array<String> = [];

        function add(id:String)
        {
            var meta:ModMeta = mods.find(mod -> return mod.id == id);

            if (meta == null || result.contains(meta)) return;

            current.push(id);

            if (!skipDependencies)
            {
                for (dep in meta.dependencies)
                {
                    if (dep == id)
                    {
                        error(ERROR, MOD_DEPENDENCY_ERROR, 'Mod ${meta.mod} cannot depend on itself');

                        if (!skipDependencyErrors) return;

                        continue;
                    }

                    if (current.contains(dep))
                    {
                        error(ERROR, MOD_DEPENDENCY_ERROR, 'Mods cannot depend on each other');

                        if (!skipDependencyErrors) return;

                        continue;
                    }

                    add(dep);
                }
            }

            result.push(meta);
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

    public static function error(code:ErrorCode, type:ErrorType, message:String)
    {
        if (onError != null) onError(new HeapsModError(code, type, message));
    }

    public static function clearCache()
    {
        if (!initialized) return;

        for (mod in mods)
            mod.clearCache();

        fs.clearCache();
    }
}