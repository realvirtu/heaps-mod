# HeapsMod

HeapsMod is a modding framework designed specifically for the [Heaps](https://heaps.io) game engine.

## Installation

- Run `haxelib git heaps-mod https://github.com/realvirtu/heaps-mod`.
- Add `-lib heaps-mod` to your hxml.

## Usage

```haxe
import hxd.modding.HeapsMod;

HeapsMod.init();

// Enable mods
HeapsMod.enableMod("testmod");
HeapsMod.enableMod("testmod2");
HeapsMod.enableMod("testmod3");

// Same as above, but safer as dependency checks are done
for (meta in HeapsMod.scan())
{
    HeapsMod.enableMod(meta.mod);
}
```

## Scripting (Optional)

### Installation

- Run `haxelib install hxscript`.
- Add `-lib hxscript` to your hxml.

### Usage

```haxe
import hxd.modding.script.HeapsScript;

// Should be done before loading mods

HeapsScript.addGlobalImport("package.Class");

HeapsScript.blacklistClass("dangerous.package.DangerousClass");
HeapsScript.blacklistPackage("dangerous.package");

// Should be done after loading mods

// Outputs all scripted classes
trace(HeapsScript.listClasses());

// Outputs all scripted classes that extend MyClass
trace(HeapsScript.listClasses(MyClass));
```