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
    static var lastError:HeapsModError;

    public var code(default, null):ErrorCode;
    public var type(default, null):ErrorType;
    public var message(default, null):String;

    public function new() {}

    public function toString():String
    {
        return '$code: $message';
    }

    public static function get(code:ErrorCode, type:ErrorType, message:String):HeapsModError
    {
        var error:HeapsModError = lastError ?? new HeapsModError();
  
        error.code = code;
        error.type = type;
        error.message = message;

        lastError = error;

        return error;
    }
}