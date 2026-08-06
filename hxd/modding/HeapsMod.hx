package hxd.modding;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?mods:Array<String>
}

class HeapsMod
{
    public static var modRoot:String;

    static var mods:Array<String> = [];
    static var loader:Loader;

    public static function init(config:HeapsModConfig)
    {
        modRoot = config.modRoot ?? 'mods';
        mods = config.mods ?? [];

        if (loader == null)
            Res.loader = loader = new Loader();
    }

    public static function getActiveMods():Array<String>
    {
        return mods.copy();
    }
}