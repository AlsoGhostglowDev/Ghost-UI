package ghostui;

class GhostUIYesNoWindow extends GhostUIWindow {
    public var onYes:FlxTypedSignal<Void->Void>;
    public var onNo:FlxTypedSignal<Void->Void>;

    public var questionLabel:FlxText;

    public function new(x:Float, y:Float, ?labelText:String, questionText:String, ?width:Int, ?height:Int, ?labelSize:Int) {
        super(x, y, labelText, width, height, labelSize);

        onYes = new FlxTypedSignal();
        onNo = new FlxTypedSignal();

		questionLabel = new FlxText(4, 16, width, 'Are you sure you want to delete this business?');
		questionLabel.setFormat(Config.labelFont, 22, UITheme.label);
		add(questionLabel);

		var button = new GhostUIButton(0, height - 10, 'YES', 64, 50, 22);
		button.onPress.add(onYes.dispatch);
		button.x = (width - button.width) * (1 / 5);
        button.y -= button.height;
		add(button);

		var button = new GhostUIButton(0, height - 10, 'NO', 64, 50, 22);
		button.onPress.add(onNo.dispatch);
		button.x = (width - button.width) * (4 / 5);
		button.y -= button.height;
        add(button);
    }
}