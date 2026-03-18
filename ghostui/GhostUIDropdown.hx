package ghostui;

@:access(ghostui.UITheme)
class GhostUIDropdown extends GhostUIButton {
    public var name(default, set):String;
    public var show(default, set):Bool = false;

    var toggleButton:GhostUIButton;
    var toggleArrow:FlxSprite;

    var buttonWidth:Int;
    var buttonHeight:Int;
    var __dropdownList:Array<String> = [];
    var __dropdownButtons:Array<DropdownButton> = [];

    public function new(x:Float, y:Float, name:String, width:Int, height:Int, ?show:Bool = false) {
        super(x, y, name, width, height);

		colors = {
			base: 0xFF202020,
			hovered: 0xFF313131,
			pressed: 0xFF707070
		};

        this.name = name;
        this.show = show;
        buttonWidth = width;
        buttonHeight = height;
        pressTarget = sprite;
        onPress.add(toggleShow);

        toggleButton = new GhostUIButton(width, 0, '', height, height);
		@:privateAccess {
			toggleButton.colors.base = 0xFFFFFFFF;
			toggleButton.colors.hovered = 0xFFC5C5C5;
			toggleButton.colors.pressed = 0xFF8B8B8B;
		}
        toggleButton.onPress.add(toggleShow);
        add(toggleButton);

        toggleButton.sprite.loadGraphic('assets/images/arrow.png');
        toggleButton.sprite.setGraphicSize(height * 0.8);
        toggleButton.sprite.updateHitbox();
        toggleButton.sprite.setPosition(
            toggleButton.x + (toggleButton.width - toggleButton.sprite.width) / 2,
		    toggleButton.y + (toggleButton.height - toggleButton.sprite.height) / 2
        );
		toggleButton.sprite.flipY = !show;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justReleased && !FlxG.mouse.overlaps(this) && show)
            show = false;
    }

    public function addButton(label:String, ?onPress:Void->Void) {
        var button = new DropdownButton(this, 0, (__dropdownList.length + 1) * buttonHeight, label);
        button.visible = button.allowPressing = show;
        if (onPress != null) button.onPress.add(onPress);
        add(button);

        __dropdownList.push(label);
        __dropdownButtons.push(button);
    }

    function toggleShow() {
        show = !show;
        toggleButton.sprite.flipY = !show;
    }

    private function set_name(value:String) {
        return name = label.text = value;
    }

    private function set_show(value:Bool) {
        allowPressing = value;
        for (button in __dropdownButtons) {
            button.visible = button.allowPressing = value;
        }

        return show = value;
    }
}

@:access(ghostui.GhostUIDropdown)
class DropdownButton extends GhostUIButton {
    public var parent:GhostUIDropdown;
    public static var defaultColors = {
        button: {
			base: 0xFF292929,
			hovered: 0xFF525252,
			pressed: 0xFF707070
        }
    };

    public function new(parent:GhostUIDropdown, ?x:Float, ?y:Float, ?label:String = '_dropdown_', ?colors:MouseInteractableColors) {
        super(x, y, label, parent.buttonWidth, parent.buttonHeight);
        this.parent = parent;

        this.colors = colors ?? defaultColors.button;

        this.label.alignment = LEFT;
        this.label.x += 4; this.label.fieldWidth -= 8;
    }
}