package hxd.modding.mod;

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
    ?dependencies:Array<ModDependency>,
    ?mod:String
}

typedef ModDependency = {
    ?id:String,
    ?version:Int
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

        #if hxscript
        if (hasPreprocessor) HeapsScript.setPreprocessor(preprocessor, '1');
        #end
    }

    public function getMissingDependencies():Array<ModDependency>
    {
        return meta.dependencies.filter(dep -> return HeapsMod.getEnabledMod(dep.id)?.version != dep.version);
    }

    public function hasDependencies():Bool
    {
        return getMissingDependencies().length == 0;
    }

    public function clearCache()
    {
        fs.clearCache();
    }

    public function dispose()
    {
        clearCache();

        fs.dispose();

        #if hxscript
        if (hasPreprocessor) HeapsScript.removePreprocessor(preprocessor);
        #end
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