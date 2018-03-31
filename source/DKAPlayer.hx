package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.input.gamepad.FlxGamepad;
//import flixel.input.gamepad.XboxButtonID;
//import flixel.input.gamepad.OUYAButtonID;
import flixel.effects.FlxFlicker;

/**
 * ...
 * @author .:BuzzJeux:.
 */
enum DKAMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

class DKAPlayer extends FlxSprite
{
	/**
	 * How big the tiles of the tilemap are.
	 */
	private static inline var TILE_SIZE:Int = 16;
	private var _gamePad:FlxGamepad;
	/**
	 * How many pixels to move each frame. Has to be a divider of TILE_SIZE 
	 * to work as expected (move one block at a time), because we use the
	 * modulo-operator to check whether the next block has been reached.
	 */
	private static inline var MOVEMENT_SPEED:Int = 1;
	
	/**
	 * Flag used to check if char is moving.
	 */ 
	public var moveToNextTile:Bool;
	public var attacking:Bool;
	private var attackingTicks:Int;
	public var invincible:Bool;
	private var invincibleTicks:Int;
	public var playerSword:DKASword;
	public var potions:Int = 1;
	public var talkingToBoss:Bool = false;
	/**
	 * Var used to hold moving direction.
	 */ 
	private var moveDirection:DKAMoveDirection;
	
	public function new(X:Int, Y:Int, sword:DKASword)
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		// Make the player graphic.
		//makeGraphic(TILE_SIZE, TILE_SIZE, 0xffc04040);
		loadGraphic(Reg.soldier, true, 16, 16);
		
		animation.add("walkdown", [1, 0, 1, 2], 4, true);
		animation.add("walkup", [4, 3, 4, 5], 4, true);
		animation.add("walkleft", [7, 6, 7, 8], 4, true);
		animation.add("walkright", [10, 9, 10, 11], 4, true);
		
		animation.add("idledown", [1], 4, true);
		animation.add("idleup", [4], 4, true);
		animation.add("idleleft", [7], 4, true);
		animation.add("idleright", [10], 4, true);
		
		animation.add("attackdown", [14, 14, 14, 14, 14, 14], 4, true);
		animation.add("attackup", [17, 17, 17, 17, 17, 17], 4, true);
		animation.add("attackleft", [20, 20, 20, 20, 20, 20], 4, true);
		animation.add("attackright", [23, 23, 23, 23, 23, 23], 4, true);
		
		animation.play("idleup");
		moveDirection = DKAMoveDirection.UP;
		
		health = 8;
		
		playerSword = sword;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);  
		
		_gamePad = FlxG.gamepads.lastActive;
		if (_gamePad == null)
		{
			// Make sure we don't get a crash on neko when no gamepad is active
			_gamePad = FlxG.gamepads.getByID(0);
		}
		
		// Move the player to the next block
		if (moveToNextTile && !attacking)
		{
			switch (moveDirection)
			{
				case UP:
					y -= MOVEMENT_SPEED;
					animation.play("walkup");
				case DOWN:
					y += MOVEMENT_SPEED;
					animation.play("walkdown");
				case LEFT:
					x -= MOVEMENT_SPEED;
					animation.play("walkleft");
				case RIGHT:
					x += MOVEMENT_SPEED;
					animation.play("walkright");
			}
		}
		
		
		// Check for WASD or arrow key presses and move accordingly
		if (!talkingToBoss)
		{
			if (FlxG.keys.anyPressed(["DOWN", "S"]) ||  ( Reg.usegamepad && _gamePad.pressed.DPAD_DOWN))
			{
				moveTo(DKAMoveDirection.DOWN);
			}
			else if (FlxG.keys.anyPressed(["UP", "W"]) ||  ( Reg.usegamepad && _gamePad.pressed.DPAD_UP))
			{
				moveTo(DKAMoveDirection.UP);
			}
			else if (FlxG.keys.anyPressed(["LEFT", "A"]) ||  ( Reg.usegamepad && _gamePad.pressed.DPAD_LEFT))
			{
				moveTo(DKAMoveDirection.LEFT);
			}
			else if (FlxG.keys.anyPressed(["RIGHT", "D"]) || ( Reg.usegamepad && _gamePad.pressed.DPAD_RIGHT))
			{
				moveTo(DKAMoveDirection.RIGHT);
			}
			else
			{
				stopMove();
			}
		}
		else 
		{
			stopMove();
		}
		
		if((FlxG.keys.justPressed.SPACE ||  ( Reg.usegamepad && _gamePad.justPressed.A)) && !talkingToBoss)
		{
			//Space bar was pressed!  FIRE A BULLET
			playerSword.revive();
			attacking = true;
			attackingTicks = 20;
			moveToNextTile = false;
			FlxG.sound.play("assets/sounds/swing_sword.wav", 1, false);
			switch (moveDirection)
			{
				case UP:
					playerSword.revive();
					playerSword.x = x+4;
					playerSword.y = y-height+4;
					playerSword.animation.play("up");
					animation.play("attackup");
				case DOWN:
					playerSword.revive();
					playerSword.x = x-4;
					playerSword.y = y+height-4;
					playerSword.animation.play("down");
					animation.play("attackdown");
				case LEFT:
					playerSword.revive();
					playerSword.x = x-width+4;
					playerSword.y = y+4;
					playerSword.animation.play("left");
					animation.play("attackleft");
				case RIGHT:
					playerSword.revive();
					playerSword.x = x+width-4;
					playerSword.y = y+4;
					playerSword.animation.play("right");
					animation.play("attackright");
			}
			//bullet.velocity.y = -300;
		}
		if((FlxG.keys.justPressed.Z ||  ( Reg.usegamepad && _gamePad.justPressed.B)) && potions > 0 && !talkingToBoss)
		{
			potions = 0;
			health = 8;
			FlxG.sound.play(Reg.lifeWav);
		}
		if (attacking)
		{
			if (attackingTicks > 0) {
				attackingTicks--;
			} else {
				playerSword.kill();
				playerSword.x = -100;
				playerSword.y = -100;
				attacking = false;
				stopMove();
			}
		}
		if (invincible)
		{
			if (invincibleTicks > 0) {
				invincibleTicks--;
			} else {
				invincible = false;
			}
		}
	}
	
	public function takeDamage(damage:Int):Void
	{
		if (!invincible)
		{
			health--;
			FlxG.sound.play("assets/sounds/player_hit.wav", 1, false);
		}
		if (health <= 0)
		{
			FlxG.switchState(new LoseState());
		}
		else
		{
			FlxFlicker.flicker(this,.25); 
			invincibleTicks = 15;
			invincible = true;
		}
	}
	
	public function moveTo(Direction:DKAMoveDirection):Void
	{
		// Only change direction if not already moving
		if (!moveToNextTile)
		{
			moveDirection = Direction;
			moveToNextTile = true;
		}
	}
	
	public function stopMove(move:Bool=false):Void
	{
		// Only change direction if not already moving
		if(!attacking)
		{
			moveToNextTile = false;
			switch (moveDirection)
			{
				case UP:
					animation.play("idleup");
				case DOWN:
					animation.play("idledown");
				case LEFT:
					animation.play("idleleft");
				case RIGHT:
					animation.play("idleright");
			}
			if (move)
			{
				switch (moveDirection)
				{
					case UP:
						y++;
					case DOWN:
						y--;
					case LEFT:
						x++;
					case RIGHT:
						x--;
				}
			}
		}
	}
}
