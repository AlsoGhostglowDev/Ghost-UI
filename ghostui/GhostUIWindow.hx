package ghostui;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

@:access(ghostui.UITheme)
class GhostUIWindow extends BasicUI
{
	public var label:FlxText;
	public var centered:Bool = false;
	public var selected:Bool = false;

	var colors:MouseInteractableColors;

	public var base:FlxSprite;
	public var baseOutline:FlxSprite;

	public function new(x:Float, y:Float, ?labelText:String = 'Type here..', ?width:Int = 256, ?height:Int = 256, ?labelSize:Int)
	{
		super(x, y);
		labelSize ??= int(height * 0.075);

		colors = UITheme._getColors().button;

		base = new FlxSprite();
		base.makeGraphic(width, height, -1);
		base.color = colors.base;
		add(base);

		baseOutline = new FlxSprite();
		baseOutline.makeGraphic(width, height, 0x0);
		baseOutline.drawRect(0, 0, width, height, 0x0, {thickness: 4, color: 0xFFFFFFFF});
		add(baseOutline);

		label = new FlxText(4, 4, width - 8, labelText);
		label.setFormat(Config.labelFont, labelSize, UITheme.label, LEFT);
		add(label);

		var closeButton = new GhostUIButton(-4, 4, 'x', labelSize + 2, labelSize + 2, labelSize - 2);
		closeButton.x += base.width - closeButton.width;
		add(closeButton);
		closeButton.onPress.add(dispose);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.mouse.justPressed)
		{
			selected = FlxG.mouse.overlaps(base);
			if (selected)
				FlxG.sound.play(Util.getSound('buttonClick'));
		}

		var targetColor:Int = FlxG.mouse.overlaps(base) ? colors.outline : 0xFF000000;
		if (selected)
			targetColor = 0xFFFFFFFF;

		baseOutline.color = FlxColor.interpolate(baseOutline.color, targetColor, .2);

		if (centered)
			label.y = base.y + (base.height - label.height) / 2;
	}

	public function dispose() {
		kill();
		active = false;
	}
}