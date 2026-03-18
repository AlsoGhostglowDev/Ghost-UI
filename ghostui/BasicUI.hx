package ghostui;

class BasicUI extends FlxSpriteGroup {
    public var followAntialiasing(default, set):Bool = true;
    public var useAntialiasing(get, never):Bool;

    // backend usage
	static var aFollowedObject:Dynamic;
    static var aFollowedField:String;

    function set_followAntialiasing(value:Bool):Bool {
        get_useAntialiasing();
        return followAntialiasing = value;
    }

    function get_useAntialiasing() {
        var objectAntialiased:Bool = false;
        if (followAntialiasing && aFollowedObject != null && aFollowedField != null)
            objectAntialiased = Reflect.field(aFollowedObject, aFollowedField);

		var antialias = (followAntialiasing && objectAntialiased) || !followAntialiasing;
        antialiasing = antialias;

        return antialias;
    }

    public static function followAntialiasingValue(obj:Dynamic, field:String) {
        aFollowedObject = obj;
        aFollowedField = field;
    }
}