package hxd.modding.mod;

using Lambda;

typedef ModMeta = {
    ?title:String,
    ?description:String,
    ?id:String,
    ?dependencies:Array<String>,
    ?mod:String
}

class Mod
{
    public final meta:ModMeta;

    public var mod(get, never):String;
    public var id(get, never):String;

    public var fs:ModFS;

    public function new(meta:ModMeta)
    {
        this.meta = meta;
        
        fs = new ModFS(mod);
    }

    public function getMissingDependencies():Array<String>
    {
        return meta.dependencies.filter(dep -> return !HeapsMod.hasEnabledMod(dep));
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
}