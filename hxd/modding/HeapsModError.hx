package hxd.modding;

enum ErrorCode
{
    DEBUG;
    WARNING;
    ERROR;
}

enum ErrorType
{
    // DEBUG
    INITIALIZED;
    DISABLED;
    MOD_ENABLED;
    MOD_DISABLED;

    // WARNING
    MOD_MISSING_META;
    MOD_MISSING_ID;
    
    // ERROR
    MOD_DEPENDENCY_ERROR;
    MOD_MISSING_DEPENDENCIES;
}

class HeapsModError
{
    public var code(default, null):ErrorCode;
    public var type(default, null):ErrorType;
    public var message(default, null):String;

    public function new(code:ErrorCode, type:ErrorType, message:String)
    {
        this.code = code;
        this.type = type;
        this.message = message;
    }

    public function toString():String
    {
        return '$code: $message';
    }
}