package hxd.modding.data;

typedef ModData = {
    ?title:String,
    ?description:String,
    ?id:String,
    ?version:Int,
    ?apiVersion:Int,
    ?dependencies:Array<DependencyData>,
    ?mod:String
}