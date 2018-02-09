package generate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import play.PlayState;

class GenerateState extends FlxState
{

	public static var cells:Array<Cell>;
	public static var rooms:Array<Rectangle>;
	public static var mapSprite:FlxSprite;
	public static var mapData:BitmapData;
	public static var mapHeight:Int;
	public static var mapWidth:Int;
	public static var TILE_SIZE = 16;
	
	override public function create():Void {	
		mapHeight = Std.int(FlxG.height);
		mapWidth = Std.int(FlxG.width);
		mapSprite = new FlxSprite(0, 0);
		mapSprite.makeGraphic(mapWidth, mapHeight, FlxColor.BLACK);
		//mapSprite.scale.set(8, 8);
		mapSprite.screenCenter();
		add(mapSprite);
		
		// Setup UI
		var gutter:Int = 10;
		add(new FlxButton(gutter, gutter, "Generate", generate));
		add(new FlxButton(gutter * 2 + 80, gutter, "Play (Space)", play));
		
		if (mapData == null)
			generate();
		else
			updateSprite();
	}
	
	public static function generate()
	{	
		mapData = new BitmapData(mapWidth, mapHeight, false, FlxColor.BLACK);
		var cellX = FlxG.random.int(Cell.MAX_SIZE, mapWidth - Cell.MAX_SIZE);
		var cellY = FlxG.random.int(Cell.MAX_SIZE, mapHeight - Cell.MAX_SIZE);
		var cellWidth:Int = mapWidth - cellX;
		var cellHeight:Int = mapHeight - cellY;
		
		cells = [];
		rooms = [];
		cells.push(new Cell(cellX, cellY, cellWidth, cellHeight));
	
		if (FlxG.random.bool()) {
			cellWidth = FlxG.random.int(Cell.MIN_SIZE * 2, cellWidth);
			cellHeight = cellY;
			cells.push(new Cell(cellX, 0, cellWidth, cellHeight));
			
			cellWidth = cellX;
			var randY:Int = Std.int(mapHeight * 0.5);
			cellY = FlxG.random.int(0, randY);
			cellHeight = FlxG.random.int(Cell.MIN_SIZE * 2, mapHeight - randY);
			cells.push(new Cell(0, cellY, cellWidth, cellHeight));
		} else {
			cellWidth = cellX;
			cellHeight = FlxG.random.int(Cell.MIN_SIZE * 2, cellHeight);
			cells.push(new Cell(0, cellY, cellWidth, cellHeight));
			
			cellHeight = cellY;
			var randX:Int = Std.int(mapWidth * 0.5);
			cellX = FlxG.random.int(0, randX);
			cellWidth = FlxG.random.int(Cell.MIN_SIZE * 2, randX);
			cells.push(new Cell(cellX, 0, cellWidth, cellHeight));
		}
		
		var canSplit:Bool = true;
		var didSplit:Bool = false;
		while (canSplit) {
			canSplit = false;
			didSplit = false;
			for (c in cells) {
				didSplit = c.split();
				canSplit = canSplit || didSplit;
				if (didSplit) {
					cells.push(c.leftChild);
					cells.push(c.rightChild);
					cells.remove(c);
				}
			}
		}
		
		drawRooms();
		updateSprite();
		//return(mapSprite);
	}
	
	private static function drawRooms():Void
	{
		for (c in cells) {
			c.createRoom();
			rooms.push(c.getRoom());
			mapData.fillRect(c.getRoom(), FlxColor.WHITE);
		}
		drawHallways();
	}
	
	private static function makeFullGraph():Array<Array<Int>> 
	{
		var graph:Array<Array<Int>> = [for (x in 0...rooms.length) [for (y in 0...rooms.length) 0]];
		for (i in 0...rooms.length) {
			for (j in 0...rooms.length) {
				graph[i][j] = Std.int(Math.abs(rooms[i].x - rooms[j].x) + Math.abs(rooms[i].y - rooms[j].y));
			}
		}
		trace("made graph\n");
		return graph;
	}
	
	private static function minimalTree(graph:Array<Array<Int>>):Array<Array<Int>> 
	{
		var tree:Array<Array<Int>> = [for (x in 0...rooms.length) [for (y in 0...rooms.length) 0]];
		var vertices:Array<Int> = [for (x in 0...rooms.length) x];
		var distances:Array<Int> = [];
		var prevs:Array<Int> = [];
		
		for (v in vertices) {
			distances.push(graph[0][v]);
			prevs.push(0);
		}
		vertices.remove(0);
		
		while (vertices.length > 0) {
			var u:Int = vertices[0];
			for (v in vertices) {
				if (distances[v] < distances[u]) {
					u = v;
				}
			}
			vertices.remove(u);
			tree[u][prevs[u]] = distances[u];
			tree[prevs[u]][u] = distances[u];
			trace(vertices);
			for (v in vertices) {
				if (graph[u][v] < distances[v]) {
					distances[v] = graph[u][v];
					prevs[v] = u;
				}
			}
		}
		trace("made tree\n");
		return tree;
	}
	
	private static function positionOfMin(arr:Array<Int>):Int
	{
		//trace("was in search of min\n");
		var min:Int = 0;
		for (i in arr) {
			if (arr[i] < arr[min]) {
				min = i;
			}
		}
		return min;
	}
	
	private static function drawHallways():Void
	{
		var tree = minimalTree(makeFullGraph());
		var x1:Int;
		var x2:Int;
		var y1:Int;
		var y2:Int;
		for (i in 0...tree.length) {
			for (j in i...tree.length) {
				if (tree[i][j] != 0) {
					x1 = Std.int(rooms[i].x) + FlxG.random.int(0, Std.int(rooms[i].width));
					y1 = Std.int(rooms[i].y) + FlxG.random.int(0, Std.int(rooms[i].height));
					x2 = Std.int(rooms[j].x) + FlxG.random.int(0, Std.int(rooms[j].width));
					y2 = Std.int(rooms[j].y) + FlxG.random.int(0, Std.int(rooms[j].height));

					if (x1 < x2) {
						if (y1 < y2) {
							mapData.fillRect(new Rectangle(x1, y1, Math.abs(x1 - x2), 1), FlxColor.WHITE);
							mapData.fillRect(new Rectangle(x2, y1, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
						} else {
							mapData.fillRect(new Rectangle(x1, y2, Math.abs(x1 - x2), 1), FlxColor.WHITE);
							mapData.fillRect(new Rectangle(x1, y2, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
						}
					} else {
						if (y1 < y2) {
							mapData.fillRect(new Rectangle(x2, y1, Math.abs(x1 - x2), 1), FlxColor.WHITE);
							mapData.fillRect(new Rectangle(x2, y1, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
						} else {
							mapData.fillRect(new Rectangle(x2, y2, Math.abs(x1 - x2), 1), FlxColor.WHITE);
							mapData.fillRect(new Rectangle(x1, y2, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
						}
					}
				}
			}
		}
		/*
			x1 = Std.int(rooms[i].x) + FlxG.random.int(0, Std.int(rooms[i].width));
			y1 = Std.int(rooms[i].y) + FlxG.random.int(0, Std.int(rooms[i].height));
			x2 = Std.int(rooms[i + 1].x) + FlxG.random.int(0, Std.int(rooms[i + 1].width));
			y2 = Std.int(rooms[i + 1].y) + FlxG.random.int(0, Std.int(rooms[i + 1].height));

			if (x1 < x2) {
				if (y1 < y2) {
					mapData.fillRect(new Rectangle(x1, y1, Math.abs(x1 - x2), 1), FlxColor.WHITE);
					mapData.fillRect(new Rectangle(x2, y1, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
				} else {
					mapData.fillRect(new Rectangle(x1, y2, Math.abs(x1 - x2), 1), FlxColor.WHITE);
					mapData.fillRect(new Rectangle(x1, y2, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
				}
			} else {
				if (y1 < y2) {
					mapData.fillRect(new Rectangle(x2, y1, Math.abs(x1 - x2), 1), FlxColor.WHITE);
					mapData.fillRect(new Rectangle(x2, y1, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
				} else {
					mapData.fillRect(new Rectangle(x2, y2, Math.abs(x1 - x2), 1), FlxColor.WHITE);
					mapData.fillRect(new Rectangle(x1, y2, 1, Math.abs(y1 - y2)), FlxColor.WHITE);
				}
			}
		}*/
	}
	
	private static function updateSprite()
	{
		mapSprite.pixels = mapData.clone();
		mapSprite.dirty = true;
	}
	function play():Void
	{
		FlxG.switchState(new PlayState());
	}
}