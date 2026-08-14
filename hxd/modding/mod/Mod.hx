package hxd.modding.mod;

import hxd.modding.mod.Dependency.DependencyData;

#if hxscript
import hxd.modding.script.HeapsScript;
#end

using StringTools;

typedef ModMeta = {
    ?title:String,
    ?description:String,
    ?id:String,
    ?version:Int,
    ?apiVersion:Int,
    ?dependencies:Array<DependencyData>,
    ?mod:String
}

class Mod
{
    public final meta:ModMeta;

    public var mod(get, never):String;
    public var id(get, never):String;
    public var version(get, never):Int;

    #if hxscript
    public var preprocessor(get, never):String;
    public var hasPreprocessor(get, never):Bool;
    #end

    public var fs:ModFS;

    public function new(meta:ModMeta)
    {
        this.meta = meta;
        
        fs = new ModFS(mod);

        HeapsModFS.instance.fs.insert(0, fs);

        #if hxscript
        if (hasPreprocessor) HeapsScript.setPreprocessor(preprocessor, '1');
        #end
    }

    public function clearCache()
    {
        fs.clearCache();
    }

    public function dispose()
    {
        HeapsModFS.instance.fs.remove(fs);

        clearCache();

        fs.dispose();

        #if hxscript
        if (hasPreprocessor) HeapsScript.removePreprocessor(preprocessor);
        #end
    }

    public static function isCompatible(meta:ModMeta):Bool
    {
        return meta != null && (meta.apiVersion == HeapsMod.config.apiVersion || HeapsMod.config.apiVersion == null);
    }

    public function toString():String
    {
        return mod;
    }

    @:noCompletion
    inline function get_mod():String
    {
        return meta.mod;
    }

    @:noCompletion
    inline function get_id():String
    {
        return meta.id;
    }

    @:noCompletion
    inline function get_version():Int
    {
        return meta.version;
    }

    #if hxscript
    @:noCompletion
    inline function get_preprocessor():String
    {
        return ~/[^A-Za-z0-9_]/g.replace(id, '_');
    }

    @:noCompletion
    inline function get_hasPreprocessor():Bool
    {
        return id.trim() != '';
    }
    #end
}