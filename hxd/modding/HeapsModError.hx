package hxd.modding;

enum ErrorCode
{
    INFO;
    WARNING;
    ERROR;
}

enum ErrorType
{
    // INFO
    HEAPSMOD_INITIALIZED;
    HEAPSMOD_DISABLED;
    MOD_ENABLED;
    MOD_DISABLED;
    SCRIPT_INIT;

    // WARNING
    MOD_MISSING_META;
    MOD_MISSING_ID;
    MOD_MISSING_MOD_VERSION;
    MOD_MISSING_API_VERSION;
    
    // ERROR
    MOD_DEPENDENCY_ERROR;
    MOD_MISSING_DEPENDENCIES;
    SCRIPT_PARSE_ERROR;
    SCRIPT_PROGRAM_ERROR;
    SCRIPT_TYPE_ERROR;
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