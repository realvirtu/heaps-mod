package hxd.modding.script;

#if hxscript
import hxd.fs.FileEntry;
import hxscript.types.ScriptedClass;
import hxscript.Environment;
import hxscript.Module;

using Lambda;

class HeapsModScript extends Module
{
    public static var extensions:Array<String> = [];

    static var world(default, null):Environment;

    public function new(entry:FileEntry)
    {
        onParsingError = e -> HeapsMod.error(ERROR, SCRIPT_PARSE_ERROR, e.message);
        onProgramError = e -> HeapsMod.error(ERROR, SCRIPT_PROGRAM_ERROR, e.message);
        onTypeError = (e, _) -> HeapsMod.error(ERROR, SCRIPT_TYPE_ERROR, e.message);

        super(entry.getText(), entry.name, [], entry.path);

        HeapsMod.error(DEBUG, SCRIPT_INIT, 'Loaded script ${entry.name}');
    }

    public static function loadScripts()
    {
        if (!HeapsMod.initialized) return;

        clearScripts();

        world = new Environment();

        for (file in Res.loader.dir(''))
        {
            if (!extensions.contains(file.entry.extension)) continue;

            world.addModule(new HeapsModScript(file.entry));
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

    public static function clearScripts()
    {
        world = null;
    }
}
#else
class HeapsModScript
{
    public function new()
    {
        trace('hxscript is required!');
    }
}
#end