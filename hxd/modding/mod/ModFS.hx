package hxd.modding.mod;

import haxe.io.Path;
import hxd.fs.LocalFileSystem;

class ModFS extends LocalFileSystem
{
    public function new(mod:String)
    {
        super(Path.join([HeapsMod.modRoot, mod]), null);
    }
}