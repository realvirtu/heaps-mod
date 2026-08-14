package hxd.modding;

import hxd.modding.data.ModData;
import hxd.modding.mod.DependencyUtil;
import hxd.modding.mod.ModUtil;
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

    static var onError(default, null):HeapsModError->Void;
    static var mods(default, null):Array<Mod>;

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

        onError = config.onError;
        mods = [];

        HeapsMod.config = config;

        #if hxscript
        HeapsScript.extensions = config.scriptExts ?? DEFAULT_SCRIPT_EXTS;
        #end

        Res.loader = new Loader(new HeapsModFS(Res.loader.fs));

        error(INFO, HEAPSMOD_INITIALIZED, 'HeapsMod initialized');

        enableMods(config.mods);
    }

    public static function enableMod(mod:String)
    {
        enableMods([mod]);
    }

    public static function disableMod(mod:String)
    {
        disableMods([mod]);
    }

    public static function enableMods(dirs:Array<String>)
    {
        if (!initialized) return;
        
        for (mod in dirs)
        {
            var meta:ModData = ModUtil.getMeta(mod, false);
            var missing:Array<String> = DependencyUtil.getMissingDependencies(meta);

            if (missing.length > 0 && !config.skipDependencies)
            {
                var skipErrors:Bool = config.skipDependencyErrors;

                error(skipErrors ? WARNING : ERROR, MOD_MISSING_DEPENDENCIES, 'Mod $mod has missing dependencies: $missing');

                if (!skipErrors) continue;
            }

            if (meta == null || hasEnabledMod(mod)) continue;

            mods.push(new Mod(meta));

            error(INFO, MOD_ENABLED, 'Enabled mod $mod');
        }

        #if hxscript
        HeapsScript.loadScripts();
        #end
    }

    public static function disableMods(dirs:Array<String>)
    {
        if (!initialized) return;

        for (mod in dirs)
        {
            var mod:Mod = getEnabledMod(mod);
            mod.dispose();

            mods.remove(mod);

            error(INFO, MOD_DISABLED, 'Disabled mod $mod');
        }

        enableMods(getEnabledMods().map(mod -> return mod.mod));
    }

    public static function scan():Array<ModData>
    {
        if (!initialized) return [];

        var result:Array<ModData> = [];

        for (mod in Res.loader.dir(''))
        {
            var meta:ModData = ModUtil.getMeta(mod.name);

            if (meta == null)
            {
                if (mod.entry.isDirectory) error(WARNING, MOD_MISSING_META, 'Mod ${mod.name} lacks metadata');

                continue;
            }
            
            result.push(meta);
        }

        return DependencyUtil.sortByDependencies(result);
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
        if (onError != null) onError(HeapsModError.get(code, type, message));
    }

    public static function clearCache()
    {
        if (!initialized) return;

        for (mod in mods)
            mod.clearCache();

        HeapsModFS.modFS.clearCache();
    }
}