package ;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxCollision;
/**
 * Enemy
 * @author Kirill Poletaev
 */

class DKASword extends FlxSprite
{

	public function new()//tilemap:FlxTilemap, hero:FlxSprite) 
	{
		super();
		//this.tilemap = tilemap;
		
		loadGraphic("assets/images/sword.png", true, 16, 16);
		
		animation.add("down", [0,4], 4, true);
		animation.add("up", [1,5], 4, true);
		animation.add("left", [2,6], 4, true);
		animation.add("right", [3,7], 4, true);
		
		animation.play("down");
		
		kill();
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
	}
}
