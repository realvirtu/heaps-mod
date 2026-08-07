package hxd.modding;

import haxe.io.Path;
import hxd.fs.FileSystem;
import hxd.fs.LocalFileSystem;

class HeapsModFS extends LocalFileSystem
{
    static final EXCLUDES:Array<String> = [
        '.git',
        '.vscode',
        'meta.json'
    ];

    public final baseFS:FileSystem;

    public function new(baseFS:FileSystem)
    {
        super(HeapsMod.modRoot, null);

        this.baseFS = baseFS;
    }

    override function get(path:String):LocalEntry
    {
        var file:String = path;

        if (!EXCLUDES.contains(Path.withoutDirectory(file)))
        {
            for (mod in HeapsMod.getEnabledMods())
            {
                if (!exists(HeapsMod.getModPath(mod, path))) continue;

                file = HeapsMod.getModPath(mod, path);
            }
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