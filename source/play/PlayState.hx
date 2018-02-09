package play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import generate.GenerateState;
import play.Player;

class PlayState extends FlxState
{
	static inline var TILE_SIZE:Int = 16;
	private var player:Player;
	var map:FlxTilemap;
	
	override public function create():Void
	{
		super.create();map = new FlxTilemap();
		var csvData:String = FlxStringUtil.bitmapToCSV(GenerateState.mapData);
		map.loadMapFromCSV(csvData, "assets/images/tiles.png", TILE_SIZE, TILE_SIZE, AUTO);
		add(map);
		
		// Randomly pick room for player to start in
		var emptyTiles:Array<FlxPoint> = map.getTileCoords(0, false);
		var randomEmptyTile:FlxPoint = emptyTiles[FlxG.random.int(0, emptyTiles.length)];
		
		add(player = new Player(randomEmptyTile.x, randomEmptyTile.y));
		map.follow();
		FlxG.camera.zoom = 1.5;
		FlxG.camera.follow(player);
		
		var gutter:Int = 10;
		add(new FlxButton(gutter, gutter, "Back", back));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FlxG.collide(player, map);
	}
	
	function back():Void
	{
		FlxG.switchState(new GenerateState());
	}
}
