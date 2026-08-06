package hxd.modding;

import hxd.res.Loader;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?mods:Array<String>
}

class HeapsMod
{
    public static var modRoot(default, null):String;

    static var mods:Array<String> = [];
    static var loader:Loader;

    public static function init(config:HeapsModConfig)
    {
        modRoot = config.modRoot ?? 'mods';
        mods = config.mods ?? [];

        if (loader == null)
            Res.loader = loader = new Loader(new HeapsModFS(Res.loader.fs));
    }

    public static function getEnabledMods():Array<String>
    {
        return mods.copy();
    }
}