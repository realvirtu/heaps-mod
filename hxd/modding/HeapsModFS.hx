package hxd.modding;

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
            if (!exists(HeapsMod.getModPath(mod, path))) continue;

            file = HeapsMod.getModPath(mod, path);
        }

        if (super.exists(file)) return super.get(file);

        return cast baseFS.get(file);
    }

    override function exists(path:String):Bool
    {
        for (mod in HeapsMod.getEnabledMods())
        {
            if (!super.exists(HeapsMod.getModPath(mod, path))) continue;

            return true;
        }

        return super.exists(path) || baseFS.exists(path);
    }
}