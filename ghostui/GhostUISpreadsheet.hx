package ghostui;

import flixel.math.FlxRect;
using haxe.EnumTools.EnumValueTools;

enum CellData {
    COORDINATE(x:Int, y:Int);
}

enum CoordinateAxis {
    VERTICAL;
    HORIZONTAL;
}

@:access(ghostui.UITheme)
@:access(ghostui.GhostUICell)
class GhostUISpreadsheet extends BasicUI {
    public var cells:Array<GhostUICell> = [];
    public var sheetWidth:Int = 0;
    public var sheetHeight:Int = 0;

    public function new(x:Float, y:Float, width:Int, height:Int, cellWidth:Int = 128, cellHeight:Int = 64) {
        super(x, y);

        this.sheetWidth = width;
        this.sheetHeight = height;

        for (x in 0...width) {
            for (y in 0...height) {
                var cell = new GhostUICell(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
                cell.parentSpreadsheet = this;
                cell.coordinates = CellData.COORDINATE(x + 1, y + 1);
				add(cell);
                cells.push(cell);
            }
        }
    }

    public function getCell(x:Int, y:Int):GhostUICell {
        for (cell in cells) {
            if (cell.getCoordinates(HORIZONTAL) == x && cell.getCoordinates(VERTICAL) == y)
                return cell;
        }
        return null;
    }

    public function forColumn(column:Int, func:GhostUICell->Void) {
        for (cell in cells) {
            if (cell.getCoordinates(HORIZONTAL) == column)
                func(cell);
        }
    }

	public function forRow(row:Int, func:GhostUICell->Void) {
        for (cell in cells) {
            if (cell.getCoordinates(VERTICAL) == row)
                func(cell);
        }
    }

    public function setCellSize(x:Int, y:Int, width:Int, height:Int) {
        final cell = getCell(x, y);
		final _oldWidth = cell.width;
		final _oldHeight = cell.height;
        cell.drawNewSize(width, height);

        if (_oldWidth != cell.cellWidth) {
            for (i in x + 1...sheetWidth + 1) {
                final cellToAdjust = getCell(i, y);
                if (cellToAdjust != null) {
                    //trace('Adjusted Cell at [${i}, ${y}] to new width: ' + cellToAdjust.cellWidth);
					cellToAdjust.cellWidth = (width - (getCell(i - 1, y).x + getCell(i - 1, y).cellWidth)) / (sheetWidth - x);
                    cellToAdjust.x = getCell(i - 1, y).x + getCell(i - 1, y).cellWidth;
					cellToAdjust.label.fieldWidth = cellToAdjust.label.x - getCell(i + 1, y)?.x ?? width - (cellToAdjust.x - cellToAdjust.label.x);
                }
            }
        }

        if (_oldHeight != cell.cellHeight) {
            final lowerCell = getCell(x, y + 1);
            if (lowerCell != null)
                lowerCell.cellHeight = lowerCell.cellHeight + (_oldHeight - cell.cellHeight);
        }
    }
}

@:access(ghostui.UITheme)
class GhostUICell extends BasicUI {
    public var bg:FlxSprite;
    public var bgOutline:FlxSprite;
    public var label:FlxText;
    public var text(default, set):String = '';
    public var coordinates:CellData = CellData.COORDINATE(0, 0);
    public var parentSpreadsheet:Null<GhostUISpreadsheet>;

	var colors:MouseInteractableColors = {};
    var canBeSelected:Bool = true;

	public var cellWidth(default, set):Float = 0;
	public var cellHeight(default, set):Float = 0;
    
    function set_text(value:String):String {
        label.text = value;
        return value;
    }

    function set_cellWidth(value:Float):Float {
		drawNewSize(value, cellHeight);
        return value;
    }

	function set_cellHeight(value:Float):Float {
        drawNewSize(cellWidth, value);
        return value;
    }

	function drawNewSize(newWidth:Float, newHeight:Float) {
        if (newWidth != cellWidth || newHeight != cellHeight) {
			@:bypassAccessor cellWidth = newWidth;
            @:bypassAccessor cellHeight = newHeight;
        }

		bg.makeGraphic(Std.int(newWidth), Std.int(newHeight), -1);
        bg.updateHitbox();
		bgOutline.makeGraphic(Std.int(newWidth), Std.int(newHeight), 0x0);
		bgOutline.drawRect(0, 0, newWidth, newHeight, 0x0, {thickness: 2, color: UITheme.buttonOutline});

		label.clipRect = new FlxRect(0, 0, bg.width, bg.height);
    }

    public function new(x:Float, y:Float, width:Int, height:Int, ?size:Int) {
        super(x, y);
		size ??= int(height * 0.6);
		colors = UITheme._getColors().button;

        bg = new FlxSprite();
        bg.makeGraphic(width, height, -1);
		bg.color = colors.base;
        add(bg);

        bgOutline = new FlxSprite();
        bgOutline.makeGraphic(width, height, 0x0);
		bgOutline.drawRect(0, 0, width, height, 0x0, {thickness: 2, color: UITheme.buttonOutline});
        add(bgOutline);

		label = new FlxText(6, 4, width - 12, '');
		label.setFormat(Config.labelFont, size, UITheme.label, LEFT);
		label.clipRect = new FlxRect(0, 0, bg.width, bg.height);
		add(label);

		@:bypassAccessor this.cellWidth = width;
		@:bypassAccessor this.cellHeight = height;
    }

    public function getCoordinates(axis:CoordinateAxis):Int {
        return switch (axis) {
            case HORIZONTAL: coordinates.getParameters()[0];
			case VERTICAL: coordinates.getParameters()[1];   
        }
    }
}