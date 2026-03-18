package ghostui;

import flixel.math.FlxMath;

enum NumericType {
    INTEGER;
    FLOAT(decimals:Int);
}

@:access(ghostui.GhostUITextInput)
@:access(ghostui.GhostUIButton)
class GhostUINumericStep extends BasicUI {
    public var maxValue:Float = FlxMath.MAX_VALUE_INT;
    public var minValue:Float = FlxMath.MIN_VALUE_INT;
    public var step:Float = 1;
    public var type:NumericType = FLOAT(2);

    public var number(get, never):Float;
    public var numInput:GhostUITextInput;
    public var upButton:GhostUIButton;
    public var downButton:GhostUIButton;

    public var onChange:FlxTypedSignal<Float->Void>;
    public var onUpdate:FlxTypedSignal<Void->Void>;

	function __floorDecimal(n:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(n);

		return Math.floor(n * Math.pow(10, decimals)) / Math.pow(10, decimals);
    }

    function get_number() {
		var num:Float = Std.parseFloat(numInput.label.text);
        if (num == Math.NaN)
            num = minValue;

        switch(type) {
            case INTEGER:
                num = Std.int(num);
            case FLOAT(decimals):
                if (decimals == 0) num = Math.floor(num);
                if (decimals > 0) num = __floorDecimal(num, decimals);
        }

        return FlxMath.bound(num, minValue, maxValue);
    }

    public function new(x:Float, y:Float, width:Int, height:Int, ?defaultValue:Float, ?min:Float = 0, ?max:Float, ?textSize:Int) {
        super(x, y);

		onChange = new FlxTypedSignal();
		onUpdate = new FlxTypedSignal();

        minValue = min;
        maxValue = max ?? FlxMath.MAX_VALUE_INT;

        numInput = new GhostUITextInput(0, 0, '#', width, height, textSize);
        numInput.label.text = Std.string(defaultValue ?? minValue);
        numInput.keyWhitelist = ('0123456789.-').split('');
		add(numInput);

        numInput.onSelect.add(updateText);
		numInput.onUnselect.add(updateText);

		final buttonSize:Int = int(height / 2);
		upButton = new GhostUIButton(numInput.width, 0, '', buttonSize, buttonSize);
        upButton.onPress.add(() -> {
            numInput.text = Std.string(number + step);
			onChange.dispatch(step);
            updateText();
        });
        upButton.onPress.add(updateText);
        add(upButton);

		var upArr = upButton.add(new FlxSprite().loadGraphic('assets/images/arrow.png'));
		upArr.setGraphicSize(upButton.sprite.width * 0.8);
		upArr.updateHitbox();
		upArr.setPosition(upButton.x + (upButton.width - upArr.width) / 2, upButton.y + (upButton.height - upArr.height) / 2);

		downButton = new GhostUIButton(numInput.width, height / 2, '', buttonSize, buttonSize);
		downButton.onPress.add(() -> {
            numInput.text = Std.string(number - step);
            onChange.dispatch(-step);
            updateText();
        });
        add(downButton);

		var downArr = downButton.add(new FlxSprite().loadGraphic('assets/images/arrow.png'));
        downArr.flipY = true;
		downArr.setGraphicSize(downButton.sprite.width * 0.8);
		downArr.updateHitbox();
		downArr.setPosition(downButton.x + (downButton.width - downArr.width) / 2, downButton.y + (downButton.height - downArr.height) / 2);

		numInput.base.makeGraphic(width + Std.int(height / 2), height, -1);
        upButton.lerpOutlineColor = downButton.lerpOutlineColor = false;
        upButton.usageTimeout = downButton.usageTimeout = 0;
    }

    function updateText() {
        numInput.text = Std.string(number);
        onUpdate.dispatch();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        upButton.outline.color = downButton.outline.color = numInput.baseOutline.color;
    }
}