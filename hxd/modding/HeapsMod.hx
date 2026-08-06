package hxd.modding;

import hxd.res.Loader;

typedef HeapsModConfig = {
    ?modRoot:String,
    ?mods:Array<String>
}

class HeapsMod
{
    public static var modRoot(default, null):String;

    static var mods(default, null):Array<String> = [];
    static var initialized(default, null):Bool;

    public static function init(?config:HeapsModConfig)
    {
        if (initialized) throw 'HeapsMod has already been initialized';

        initialized = true;

        config ??= {};

        modRoot = config.modRoot ?? 'mods';
        mods = config.mods ?? [];

        Res.loader = new Loader(new HeapsModFS(Res.loader.fs));
    }

    public static function enableMod(mod:String)
    {
        if (mods.contains(mod)) return;

        mods.push(mod);
    }

    public static function disableMod(mod:String)
    {
        if (!mods.contains(mod)) return;
        
        mods.remove(mod);
    }

    public static function getEnabledMods():Array<String>
    {
        return mods.copy();
    }
}