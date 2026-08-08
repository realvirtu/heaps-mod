package hxd.modding.script;

#if hxscript
import hxd.fs.FileEntry;
import hxscript.Script;

class HeapsModScript extends Script
{
    public static var extensions:Array<String> = [];

    static var scripts(default, null):Array<Script> = [];

    public function new(entry:FileEntry)
    {
        super(entry.getText(), entry.name);

        scripts.push(this);

        start();
    }

    public static function loadScripts()
    {
        if (!HeapsMod.initialized) return;

        clearScripts();

        for (file in Res.loader.dir(''))
        {
            if (!extensions.contains(file.entry.extension)) continue;

            scripts.push(new HeapsModScript(file.entry));
        }
    }

    public static function clearScripts()
    {
        scripts = [];
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