# HeapsMod

HeapsMod is a modding framework designed specifically for the [Heaps](https://heaps.io) game engine.

## Installation

- Run `haxelib git heaps-mod https://github.com/realvirtu/heaps-mod`.
- Add `-lib heaps-mod` to your hxml.

## Usage

```haxe
import hxd.modding.HeapsMod;

HeapsMod.init();

HeapsMod.enableMod("testmod");
HeapsMod.enableMod("testmod2");
HeapsMod.enableMod("testmod3");
```