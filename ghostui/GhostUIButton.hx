package ghostui;

import flixel.math.FlxMath; 

@:access(ghostui.UITheme)
class GhostUIButton extends BaseButton {
    public var label:FlxText;
    public var outline:FlxSprite;
    @:isVar public var text(get, set):String = '';
    public var usageTimeout:Float = 0.4;
    public var lerpOutlineColor:Bool = true;

    var colors:MouseInteractableColors = {};
    var targetColor:FlxColor;
    var targetLabelColor:FlxColor;

    public function new(x:Float, y:Float, ?text:String = 'Button', ?width:Int = 256, ?height:Int = 256, ?size:Int) {
        super(x, y);
		size ??= int(height * 0.6);

        colors = UITheme._getColors().button;

        sprite.makeGraphic(width, height, -1);

		outline = new FlxSprite();
        outline.makeGraphic(width, height, 0x0);
		outline.drawRect(0, 0, width, height, 0x0, {thickness: 2, color: UITheme.buttonOutline});
        add(outline);

        label = new FlxText(0, (height*0.6)/4, width, text);
        label.setFormat(Config.labelFont, size, -1, CENTER);
        add(label);

        targetColor = colors.base;
        targetLabelColor = UITheme.label;
        onPress.add(() -> {
			FlxG.sound.play(Util.getSound('buttonClick'));

            sprite.color = colors.pressed;
			outline.color = 0xFFFFFFFF;
            timeout = usageTimeout;
        });
    }

    var timeout:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);

        timeout = FlxMath.bound(timeout - elapsed, 0);
        allowPressing = timeout == 0;

        targetColor = hovered ? (FlxG.mouse.pressed ? colors.pressed : colors.hovered) : colors.base;

        label.y = sprite.y + (sprite.height - label.height) / 2;

        sprite.color = FlxColor.interpolate(sprite.color, targetColor, .3);
        label.color = FlxColor.interpolate(label.color, targetLabelColor, .3);
		if (lerpOutlineColor) {
			final targetOutlineColor:Int = FlxG.mouse.overlaps(sprite) ? colors.outline : 0xFF000000;
			outline.color = FlxColor.interpolate(outline.color, targetOutlineColor, .3);
        }
    }

    private function set_text(value:String) return text = label.text = value;
    private function get_text() return label.text;
}