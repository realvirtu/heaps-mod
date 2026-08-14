package hxd.modding.mod;

import haxe.io.Path;
import haxe.Json;
import hxd.modding.data.ModData;

class ModUtil
{
    public static function getMeta(mod:String, skipWarnings:Bool = true):ModData
    {
        var meta:ModData = null;

        try
        {
            var text:String = HeapsModFS.modFS.get(Path.join([mod, HeapsMod.config.metaFile])).getText();

            meta = Json.parse(text);
            meta ??= {};
            
            meta.title ??= '';
            meta.description ??= '';
            meta.dependencies ??= [];

            meta.mod = mod;
        }
        catch (e) return null;
        
        if (!skipWarnings)
        {
            if (meta.id == null) HeapsMod.error(WARNING, MOD_MISSING_ID, 'Mod $mod is missing "id"');
            if (meta.version == null) HeapsMod.error(WARNING, MOD_MISSING_MOD_VERSION, 'Mod $mod is missing "version"');
            if (meta.apiVersion == null) HeapsMod.error(WARNING, MOD_MISSING_API_VERSION, 'Mod $mod is missing "apiVersion"');
        }

        return meta;
    }

    public static function isCompatible(meta:ModData):Bool
    {
        return meta != null && (meta.apiVersion == HeapsMod.config.apiVersion || HeapsMod.config.apiVersion == null);
    }
}