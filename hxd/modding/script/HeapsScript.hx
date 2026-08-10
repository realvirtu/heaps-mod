package hxd.modding.script;

#if hxscript
import hxscript.types.ScriptedClass;
import hxscript.Config;
import hxscript.Environment;

using Lambda;

class HeapsScript
{
    public static var extensions:Array<String> = [];

    static var world(default, null):Environment;

    public static function loadScripts()
    {
        if (!HeapsMod.initialized) return;

        clearScripts();

        world = new Environment();

        for (file in Res.loader.dir(''))
        {
            if (!extensions.contains(file.entry.extension)) continue;

            world.addModule(new HeapsModule(file.entry));
        }

        world.start();
    }

    public static function listClasses(?base:Class<Dynamic>):Array<ScriptedClass>
    {
        if (!HeapsMod.initialized) return [];

        var result:Array<ScriptedClass> = [];

        for (module in world.modules)
        {
            for (type in module.types)
            {
                if (type is ScriptedClass)
                {
                    var cls:ScriptedClass = cast type;
                    var native:Dynamic = cls.instanceClass;

                    while (native != null)
                    {
                        native = Type.getSuperClass(native);

                        if (native == null || native == base) break;
                    }

                    if (native != base) continue;

                    result.push(cls);
                }
            }
        }

        return result;
    }

    public static function initClass(cls:ScriptedClass, args:Array<Dynamic>):Dynamic
    {
        if (!HeapsMod.initialized || cls == null) return null;

        try
        {
            return cls.typeCreateInstance(args);
        }
        catch (e)
        {
            HeapsMod.error(ERROR, SCRIPT_PROGRAM_ERROR, e.message);

            return null;
        }
    }

    public static function initClassByName(name:String, args:Array<Dynamic>):Dynamic
    {
        return initClass(listClasses().find(cls -> return cls.name == name), args);
    }

    public static function addGlobalImport(path:String, ?alias:String)
    {
        if (!HeapsMod.initialized) return;

        alias ??= path.substring(path.lastIndexOf('.') + 1);

        Config.globalImports.set(path, IAsName(alias));
    }

    public static function setPreprocessor(name:String, value:String)
    {
        if (!HeapsMod.initialized) return;
        
        Config.preprocessorValues.set(name, value);
    }

    public static function removePreprocessor(name:String)
    {
        if (!HeapsMod.initialized) return;

        Config.preprocessorValues.remove(name);
    }

    public static function blacklistClass(path:String)
    {
        if (!HeapsMod.initialized) return;

        Config.blacklist.get(ByModule).push(path);
    }

    public static function blacklistPackage(path:String, recursive:Bool = true)
    {
        if (!HeapsMod.initialized) return;

        Config.blacklist.get(ByPackage(recursive)).push(path);
    }

    public static function clearScripts()
    {
        world = null;
    }
}
#end