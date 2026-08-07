package hxd.modding.mod;

typedef ModMeta = {
    ?title:String,
    ?description:String,
    ?id:String,
    ?mod:String
}

class Mod
{
    public final mod:String;

    public var meta(default, null):ModMeta;

    public var fs:ModFS;

    public function new(meta:ModMeta)
    {
        this.mod = meta.mod;
        this.meta = meta;
        
        fs = new ModFS(mod);
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
}