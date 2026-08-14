package hxd.modding.mod;

import hxd.modding.mod.Mod.ModMeta;

using Lambda;

typedef DependencyData = {
    ?id:String,
    ?version:Int
}

class Dependency
{
    public static function getDependencies(meta:ModMeta):Array<String>
    {
        return meta.dependencies.map(dep -> return dep.id);
    }

    public static function getMissingDependencies(meta:ModMeta):Array<String>
    {
        return meta.dependencies.filter(dep -> return HeapsMod.getEnabledModVersion(dep.id) != dep.version).map(dep -> return dep.id);
    }

    public static function sortByDependencies(mods:Array<ModMeta>):Array<ModMeta>
    {
        var result:Array<ModMeta> = [];
        var checked:Array<String> = [];

        function add(id:String)
        {
            var meta:ModMeta = mods.find(mod -> return mod.id == id);

            if (!Mod.isCompatible(meta) || result.contains(meta)) return;

            checked.push(id);

            if (!HeapsMod.config.skipDependencies)
            {
                for (dep in meta.dependencies)
                {
                    if (dep.id == meta.id)
                    {
                        HeapsMod.error(ERROR, MOD_DEPENDENCY_ERROR, 'Mod ${meta.id} cannot depend on itself');

                        if (HeapsMod.config.skipDependencyErrors) continue;
                        
                        return;
                    }

                    if (checked.contains(dep.id))
                    {
                        HeapsMod.error(ERROR, MOD_DEPENDENCY_ERROR, 'Mods cannot depend on each other');

                        if (HeapsMod.config.skipDependencyErrors) continue;

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