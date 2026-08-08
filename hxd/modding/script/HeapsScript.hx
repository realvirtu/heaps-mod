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

            world.addModule(new Script(file.entry));
        }

        world.start();
    }

    public static function listClasses(?base:Class<Dynamic>):Array<ScriptedClass>
    {
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
        if (cls == null) return null;

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

    public static function blacklistClass(path:String)
    {
        Config.blacklist.set(ByModule, [path]);
    }

    public static function blacklistPackage(path:String)
    {
        Config.blacklist.set(ByPackage(true), [path]);
    }

    public static function clearScripts()
    {
        world = null;
    }
}
#end