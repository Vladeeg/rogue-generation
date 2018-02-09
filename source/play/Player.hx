package play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Player extends FlxSprite 
{
	private static inline var SPEED:Float = 250;
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		makeGraphic(12, 12, FlxColor.BLUE);
		drag.x = SPEED * 4;
		drag.y = SPEED * 4;
		maxVelocity.x = SPEED;
		maxVelocity.y = SPEED;
	}
	
	public override function update(elapsed:Float):Void 
	{
		control();
		super.update(elapsed);
	}
	
	private function control():Void
	{
		var gamepad = FlxG.gamepads.lastActive;
		var xAxis:Float = 0;
		var yAxis:Float = 0;
		var hypoAxis:Float = 0;
		var sin:Float;
		var cos:Float;
		acceleration.x = acceleration.y = 0;
		
		if (gamepad != null) {
			xAxis = gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
			yAxis = gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
		} else {
			if (FlxG.keys.pressed.UP) {
				yAxis = -1;
				if (FlxG.keys.pressed.DOWN) {
					yAxis = 0;
				}
			} 
			if (FlxG.keys.pressed.DOWN) {
				yAxis = 1;
				if (FlxG.keys.pressed.UP) {
					yAxis = 0;
				}
			}
			if (FlxG.keys.pressed.LEFT) {
				xAxis = -1;
				if (FlxG.keys.pressed.RIGHT) {
					xAxis = 0;
				}
			} 
			if (FlxG.keys.pressed.RIGHT) {
				xAxis = 1;
				if (FlxG.keys.pressed.LEFT) {
					xAxis = 0;
				}
			}
		}
			hypoAxis = Math.sqrt(xAxis * xAxis + yAxis * yAxis);
			sin = (hypoAxis != 0 ? yAxis / hypoAxis : 0);
			cos = (hypoAxis != 0 ? xAxis / hypoAxis : 0);
			maxVelocity.x = SPEED * Math.abs(cos) * Math.abs(xAxis);
			maxVelocity.y = SPEED * Math.abs(sin) * Math.abs(yAxis);
			if (xAxis > 0) {
				acceleration.x = drag.x;
			} else if (xAxis < 0) {
				acceleration.x = -drag.x;
			}
			if (yAxis > 0) {
				acceleration.y = drag.y;
			} else if (yAxis < 0) {
				acceleration.y = -drag.y;
			}
	}
}