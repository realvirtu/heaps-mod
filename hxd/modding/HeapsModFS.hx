package hxd.modding;

import haxe.io.Path;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;

class HeapsModFS extends LocalFileSystem
{
    public final baseFS:FileSystem;

    public function new(baseFS:FileSystem)
    {
        super(HeapsMod.modRoot, null);

        this.baseFS = baseFS;
    }

    override function get(path:String):LocalEntry
    {
        var file:String = path;

        for (mod in HeapsMod.getEnabledMods())
        {
            if (!super.exists(buildModPath(mod, path))) continue;

            file = buildModPath(mod, path);
        }

        if (super.exists(file)) return super.get(file);

        return cast baseFS.get(file);
    }

    override function exists(path:String):Bool
    {
        for (mod in HeapsMod.getEnabledMods())
        {
            if (!super.exists(buildModPath(mod, path))) continue;

            return true;
        }
        
        return baseFS.exists(path);
    }

    function buildModPath(mod:String, path:String):String
    {
        return Path.join([mod, path]);
    }
}