package generate;
import flixel.FlxG;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;

class Cell 
{
	public static inline var MIN_SIZE = 16;
	public static inline var MAX_SIZE = 40;
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var leftChild:Cell;
	public var rightChild:Cell;
	
	private var room:Rectangle;
	
	public function new(x:Int, y:Int, width:Int, height:Int) 
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	public function split():Bool 
	{
		// Split leaf into 2 children
		if (leftChild != null || rightChild != null)
			return false; // Already split

		// Determine split direction
		// If width >25% larger than height, split vertically
		// Else if height >25% larger than width, split horizontally
		// Else split randomly
		var splitH:Bool = FlxG.random.float() > 0.5;

		if (width > height && height / width >= 0.05)
			splitH = false;
		else if (height > width && width / height >= 0.05)
			splitH = true;

		var max = (splitH ? height : width) - MIN_SIZE; // determine the maximum height or width
		if (max <= MIN_SIZE)
			return false; // the area is too small to split any more...

		// Where to split
		var split = Std.int(FlxG.random.float(MIN_SIZE, max)); // determine where we're going to split

		// Create children based on split direction
		if (splitH)
		{
			leftChild = new Cell(x, y, width, split);
			rightChild = new Cell(x, y + split, width, height - split);
		}
		else
		{
			leftChild = new Cell(x, y, split, height);
			rightChild = new Cell(x + split, y, width - split, height);
		}

		return true;
	}
	
	public function createRoom() {
		// Room can be between 6x6 tiles zqto the leaf size - 2
		var roomSize = new FlxPoint(
			FlxG.random.float(6, width - 2),
			FlxG.random.float(6, height - 2));
		// Place the room within leaf, but not against sides (would merge)
		var roomPos = new FlxPoint(
			FlxG.random.float(1, width - roomSize.x - 1),
			FlxG.random.float(1, height - roomSize.y - 1));
			
		room = new Rectangle(x + roomPos.x, y + roomPos.y, roomSize.x, roomSize.y);
	}
	
	public function getRoom():Rectangle
	{
		return room;
	}
}