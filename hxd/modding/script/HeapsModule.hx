package hxd.modding.script;

#if hxscript
import hxd.fs.FileEntry;
import hxscript.Module;

class HeapsModule extends Module
{
    public function new(entry:FileEntry)
    {
        onParsingError = e -> HeapsMod.error(ERROR, SCRIPT_PARSE_ERROR, e.message);
        onProgramError = e -> HeapsMod.error(ERROR, SCRIPT_PROGRAM_ERROR, e.message);
        onTypeError = (e, _) -> HeapsMod.error(ERROR, SCRIPT_TYPE_ERROR, e.message);

        super(entry.getText(), entry.name, [], entry.path);

        HeapsMod.error(INFO, SCRIPT_INIT, 'Loaded script ${entry.name}');
    }
}
#end