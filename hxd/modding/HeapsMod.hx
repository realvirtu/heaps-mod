package hxd.modding;

import hxd.modding.mod.Dependency;
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
    ?apiVersion:Int,
    ?skipDependencies:Bool,
    ?skipDependencyErrors:Bool,
    ?onError:HeapsModError->Void,
    ?mods:Array<String>,
    #if hxscript
    ?scriptExts:Array<String>,
    #end
}

class HeapsMod
{
    static final DEFAULT_MOD_ROOT:String = 'mods';
    static final DEFAULT_META_FILE:String = 'meta.json';
    
    #if hxscript
    static final DEFAULT_SCRIPT_EXTS:Array<String> = ['hxc'];
    #end

    public static var initialized(default, null):Bool;
    public static var config(default, null):HeapsModConfig;

    static var mods(default, null):Array<Mod>;
    static var onError(default, null):HeapsModError->Void;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) return;

        initialized = true;

        config ??= {};
        config.modRoot ??= DEFAULT_MOD_ROOT;
        config.metaFile ??= DEFAULT_META_FILE;
        config.skipDependencies ??= false;
        config.skipDependencyErrors ??= false;
        config.mods ??= [];

        #if hxscript
        HeapsScript.extensions = config.scriptExts ?? DEFAULT_SCRIPT_EXTS;
        #end

        HeapsMod.config = config;

        mods = [];
        onError = config.onError;

        Res.loader = new Loader(new HeapsModFS(Res.loader.fs));

        for (mod in config.mods) enableMod(mod);

        error(INFO, HEAPSMOD_INITIALIZED, 'HeapsMod initialized');
    }

    public static function enableMod(mod:String)
    {
        var meta:ModMeta = Mod.getMeta(mod, false);
        var missing:Array<String> = Dependency.getMissingDependencies(meta);

        if (missing.length > 0 && !config.skipDependencies)
        {
            error(ERROR, MOD_MISSING_DEPENDENCIES, 'Mod $mod has missing dependencies: $missing');

            if (!config.skipDependencyErrors) return;
        }

        if (!initialized || meta == null || hasEnabledMod(mod)) return;

        mods.push(new Mod(meta));

        error(INFO, MOD_ENABLED, 'Enabled mod $mod');

        #if hxscript
        HeapsScript.loadScripts();
        #end
    }

    public static function disableMod(mod:String)
    {
        if (!hasEnabledMod(mod)) return;

        var mod:Mod = getEnabledMod(mod);

        mod.dispose();
        mods.remove(mod);

        error(INFO, MOD_DISABLED, 'Disabled mod $mod');

        #if hxscript
        HeapsScript.loadScripts();
        #end
    }

    public static function scan():Array<ModMeta>
    {
        if (!initialized) return [];

        var result:Array<ModMeta> = [];

        for (mod in Res.loader.dir(''))
        {
            var meta:ModMeta = Mod.getMeta(mod.name);

            if (meta == null)
            {
                if (mod.entry.isDirectory) error(WARNING, MOD_MISSING_META, 'Mod ${mod.name} lacks metadata');

                continue;
            }
            
            result.push(meta);
        }

        return Dependency.sortByDependencies(result);
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

    public static function getEnabledModVersion(id:String):Null<Int>
    {
        if (!initialized) return null;

        return getEnabledMod(id)?.version;
    }

    public static function hasEnabledMod(id:String):Bool
    {
        if (!initialized) return false;

        return getEnabledMod(id) != null;
    }

    public static function disable()
    {
        if (!initialized) return;

        #if hxscript
        HeapsScript.clearScripts();
        #end

        clearCache();

        initialized = false;

        mods = null;

        // Dispose the modding filesystem
        // Reuse the original filesystem
        Res.loader = new Loader(HeapsModFS.baseFS);

        HeapsModFS.instance.fs.remove(HeapsModFS.baseFS);

        HeapsModFS.instance.dispose();
        HeapsModFS.instance = null;

        error(INFO, HEAPSMOD_DISABLED, 'HeapsMod disabled');
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

        HeapsModFS.modFS.clearCache();
    }
}