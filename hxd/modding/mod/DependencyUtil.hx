package hxd.modding.mod;

import hxd.modding.data.ModData;

using Lambda;

class DependencyUtil
{
    public static function getDependencies(meta:ModData):Array<String>
    {
        if (meta == null) return [];
        
        return meta.dependencies.map(dep -> return dep.id);
    }

    public static function getMissingDependencies(meta:ModData):Array<String>
    {
        if (meta == null) return [];

        return meta.dependencies.filter(dep -> return HeapsMod.getEnabledModVersion(dep.id) != dep.version).map(dep -> return dep.id);
    }

    public static function sortByDependencies(mods:Array<ModData>):Array<ModData>
    {
        var result:Array<ModData> = [];
        var checked:Array<String> = [];

        function add(id:String)
        {
            var meta:ModData = mods.find(mod -> return mod.id == id);

            if (!ModUtil.isCompatible(meta) || result.contains(meta)) return;

            checked.push(id);

            if (!HeapsMod.config.skipDependencies)
            {
                for (dep in meta.dependencies)
                {
                    var skipErrors:Bool = HeapsMod.config.skipDependencyErrors;

                    if (dep.id == meta.id)
                    {
                        HeapsMod.error(skipErrors ? WARNING : ERROR, MOD_DEPENDENCY_ERROR, 'Mod ${meta.id} cannot depend on itself');

                        if (skipErrors) continue;
                        
                        return;
                    }

                    if (checked.contains(dep.id))
                    {
                        HeapsMod.error(skipErrors ? WARNING : ERROR, MOD_DEPENDENCY_ERROR, 'Mods cannot depend on each other');

                        if (skipErrors) continue;

                        return;
                    }

                    add(dep.id);
                }
            }

            result.push(meta);
        }

        for (mod in mods) add(mod.id);

        return result;
    }
}