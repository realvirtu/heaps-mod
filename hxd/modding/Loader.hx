package hxd.modding;

import haxe.io.Path;
import hxd.fs.LocalFileSystem;
import hxd.modding.util.DefineUtil;
import hxd.res.Any;

class Loader extends hxd.res.Loader
{
    var baseDir(default, null):String;

    public function new()
    {
        super(new LocalFileSystem('', null));

        baseDir = DefineUtil.definedValue('resourcePath') ?? 'res';
    }

    override function load(path:String):Any
    {
        var file:String = buildBasePath(path);

        for (mod in HeapsMod.getActiveMods())
        {
            if (fs.exists(buildModPath(mod, path)))
                file = buildModPath(mod, path);
        }

        return super.load(file);
    }

    override function exists(path:String):Bool
    {
        for (mod in HeapsMod.getActiveMods())
        {
            if (fs.exists(buildModPath(mod, path)))
                return true;
        }
        return fs.exists(buildBasePath(path));
    }

    function buildModPath(mod:String, path:String):String
    {
        return Path.join([HeapsMod.modRoot, mod, path]);
    }

    function buildBasePath(path:String):String
    {
        return Path.join([baseDir, path]);
    }
}