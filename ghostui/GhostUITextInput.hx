package ghostui;

import flixel.math.FlxRect;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

@:access(ghostui.UITheme)
class GhostUITextInput extends BasicUI {
	public var label:FlxText;
	public var emptyLabel:FlxText;
	public var centered:Bool = false;
	@:isVar public var text(get, set):String = '';
	public var selected:Bool = false;

    public static var hasSelected:Bool = false;

    public var onSelect:FlxTypedSignal<Void->Void>;
    public var onUnselect:FlxTypedSignal<Void->Void>;
    public var onType:FlxTypedSignal<String->Void>;
    public var onBackspace:FlxTypedSignal<String->Void>;
    
    public var allowNewline:Bool = false;
    public var keyWhitelist:Array<String> = [];
    
    var colors:MouseInteractableColors;

    var base:FlxSprite;
    var baseOutline:FlxSprite;
	public function new(x:Float, y:Float, ?emptyText:String = 'Type here..', ?width:Int = 256, ?height:Int = 256, ?size:Int) {
		super(x, y);
		size ??= int(height * 0.6);

		onSelect = new FlxTypedSignal();
		onUnselect = new FlxTypedSignal();
		onType = new FlxTypedSignal();
		onBackspace = new FlxTypedSignal();

		colors = UITheme._getColors().button;

        base = new FlxSprite();
		base.makeGraphic(width, height, -1);
		base.color = colors.base;
        add(base);

        baseOutline = new FlxSprite();
        baseOutline.makeGraphic(width, height, 0x0);
		baseOutline.drawRect(0.5, 0.5, width - 1, height - 1, 0x0, {thickness: 3, color: 0xFFFFFFFF});
        add(baseOutline);

		label = new FlxText(6, 4, width - 12, '');
		label.setFormat(Config.labelFont, size, UITheme.label, LEFT);
        label.clipRect = new FlxRect(0, 0, base.width, base.height);
		add(label);

		emptyLabel = new FlxText(6, 4, width - 12, emptyText);
		emptyLabel.setFormat(Config.labelFont, size, -1, LEFT);
		emptyLabel.alpha = 0.3;
		add(emptyLabel);
	}

	var bkspcElapsed:Float = 0;
    var bkspcInterval:Int = 0;
    var __lastSelected:Bool = false;
    var __volumeUpKey:Array<FlxKey> = [];
    var __volumeDownKey:Array<FlxKey> = [];
	var __volumeMuteKey:Array<FlxKey> = [];
	override function update(elapsed:Float) {
		super.update(elapsed);
        if (FlxG.mouse.justPressed) {
            selected = FlxG.mouse.overlaps(base);
            if (selected != __lastSelected) {
                if (selected) {
                    onSelect.dispatch();
                    hasSelected = true;

                    __toggleKeyListener(true);
                } else {
                    onUnselect.dispatch();
                    hasSelected = false;

					__toggleKeyListener(true);
                }
            }
            
            __lastSelected = selected;
            if (selected)
				FlxG.sound.play(Util.getSound('buttonClick'));
        }

		emptyLabel.alpha = label.text.length > 0 ? 0 : 0.3;

		var targetColor:Int = FlxG.mouse.overlaps(base) ? colors.outline : 0xFF000000;
        if (selected) {
            targetColor = 0xFFFFFFFF;
            checkForKeys();
        }

        baseOutline.color = FlxColor.interpolate(baseOutline.color, targetColor, .2);

		if (centered) {
			label.y = base.y + (base.height - label.height) / 2;
			emptyLabel.y = base.y + (base.height - emptyLabel.height) / 2;
        }

        if (FlxG.keys.pressed.BACKSPACE) { 
            bkspcElapsed += elapsed;
        } else bkspcElapsed = 0;

		label.clipRect.setPosition(base.x - label.x, base.y - label.y);
	}

    function checkForKeys() {
        if (bkspcElapsed >= 0.35 && Std.int(bkspcElapsed) % 2 == 0)
            runBkspc();

		final keyID = FlxG.keys.firstJustPressed(); 
        if (keyID != -1) {
            final flxKey = cast(keyID, FlxKey);
            if (flxKey == BACKSPACE) {
                runBkspc();
                return;
            } else if (allowNewline && (flxKey == ENTER) && FlxG.keys.pressed.SHIFT)
                label.text += '\n';

			var keyToAdd:Array<String> = switch (flxKey) {
                case ZERO | NUMPADZERO: ['0', ')'];
				case ONE | NUMPADONE: ['1', '!'];
				case TWO | NUMPADTWO: ['2', '@'];
				case THREE | NUMPADTHREE: ['3', '#'];
                case FOUR | NUMPADFOUR: ['4', '$'];
				case FIVE | NUMPADFIVE: ['5', '%'];
				case SIX | NUMPADSIX: ['6', '^'];
				case SEVEN | NUMPADSEVEN: ['7', '&'];
                case EIGHT | NUMPADEIGHT: ['8', '*'];
				case NINE | NUMPADNINE: ['9', '('];
				case NUMPADMINUS: ['-'];
				case NUMPADSLASH: ['/'];
				case NUMPADMULTIPLY: ['*'];
				case NUMPADPLUS: ['+'];
				case NUMPADPERIOD: ['.'];

                case GRAVEACCENT: ['`', '~'];
                case BACKSLASH: ['\\', '|'];
				case MINUS: ['-', '_'];
                case QUOTE: ['\'', '"'];
                case SEMICOLON: [';', ':'];
                case SLASH: ['/', '?'];
                case PLUS: ['=', '+'];
                case COMMA: [',', '<'];
                case PERIOD: ['.', '>'];
                case SPACE: [' '];
                case SHIFT | CAPSLOCK | ENTER | WINDOWS | CONTROL | ALT | TAB | LEFT | RIGHT | UP | DOWN | BREAK | INSERT | HOME | PAGEUP | PAGEDOWN | END | MENU | PRINTSCREEN | SCROLL_LOCK | ESCAPE | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9 | F10 | F11 | F12: [''];
				default: [flxKey.toString().toLowerCase(), flxKey.toString()];
            }

            var toAdd:String = keyToAdd[0];
            if (FlxG.keys.pressed.SHIFT && keyToAdd.length > 1)
                toAdd = keyToAdd[1];

            if (keyWhitelist.length != 0) {
                if (!keyWhitelist.contains(toAdd))
                    return; // cancel key press
            }

			if (toAdd.length != 0)
				FlxG.sound.play(Util.getSound('textType'));

            onType.dispatch(toAdd);
            label.text += toAdd;
        }
    }

    function runBkspc() {
		if (label.text.length > 0) {
			onBackspace.dispatch(label.text.substr(label.text.length - 1));
			label.text = label.text.substr(0, label.text.length - 1);
			FlxG.sound.play(Util.getSound('textRemove'));
        }
    }

	function __toggleKeyListener(active:Bool = true) {
        if (active) {
			if (FlxG.sound.volumeUpKeys.length != 0)
				__volumeUpKey = FlxG.sound.volumeUpKeys;

			if (FlxG.sound.volumeDownKeys.length != 0)
				__volumeDownKey = FlxG.sound.volumeDownKeys;

            if (FlxG.sound.muteKeys.length != 0)
                __volumeMuteKey = FlxG.sound.muteKeys;
            
            FlxG.sound.volumeUpKeys = __volumeUpKey;
			FlxG.sound.volumeDownKeys = __volumeDownKey;
			FlxG.sound.muteKeys = __volumeMuteKey;
        } else {
		    FlxG.sound.volumeUpKeys = [];
		    FlxG.sound.volumeDownKeys = [];
		    FlxG.sound.muteKeys = [];

		    __volumeUpKey = FlxG.sound.volumeUpKeys;
		    __volumeDownKey = FlxG.sound.volumeDownKeys;
            __volumeMuteKey = FlxG.sound.muteKeys;
        }
    }
	
    private function set_text(value:String) return text = label.text = value;
    private function get_text() return label.text;
}