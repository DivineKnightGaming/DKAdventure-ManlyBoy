package ;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.math.FlxRandom;
/**
 * Enemy
 * @author Kirill Poletaev
 */
enum EMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum EnemyStatus
{
	WANDER;
	CHARGE;
	ATTACK;
	STUN;
	STOP;
}

class DKAEnemy extends FlxSprite
{
	//public var path:FlxPath;
	private var wanderTicks:Int;
	private var chargeTicks:Int;
	private var stunTicks:Int;
	private var nodes:Array<FlxPoint>;
	//private var tilemap:FlxTilemap;
	private var hero:DKAPlayer;
	private var moveDirection:EMoveDirection;
	private static inline var MOVEMENT_SPEED:Float = 0.5;
	private static inline var ATTACK_SPEED:Int = 2;
	private var status:EnemyStatus;
	private var startX:Int;
	private var startY:Int;
	private var boundN:Int;
	private var boundE:Int;
	private var boundS:Int;
	private var boundW:Int;

	public function new(X:Int, Y:Int, hero:DKAPlayer)//tilemap:FlxTilemap, hero:FlxSprite) 
	{
		super(X,Y);
		
		startX = X;
		startY = Y;
		
		/* Finding the Boundaries for the monster. We don't want them to wander into other rooms.
		 * 
		 * forst we get the starting position of the monster. From that we will determine which room they are in.
		 * 
		 * Rooms are 160x128 pixels
		 * There is a wanderable 128x96 area monsters can wander in.
		 * 
		 * First we will get the northern boundary, then the south, then the west then the east. 
		 */
		
		if(startY < 128) //easy enough here 
		{
			boundN = 16;
			boundS = 112;
		}
		else//here we need to actually do some calculations
		{
			//boundN =  ( cast((startY/128), Int) *128) +16;//rooms are 128 pixels high. So we divide the position by 128 to get which room on the Y axis this is, then multiply by the room height, then add the wall width.
			//boundS =  ( ( cast((startY/128), Int) +1) *128) -16;//same as above except we add one to the room number and subtract the wall width
			boundN =  ( Std.int((startY/128)) *128) +16;
			//boundN = (startY - (startY % 128)) + 16;
			boundS = (boundN + 128) - 32;
		}
		
		if(startX < 160)//again, easy enough
		{
			boundW = 16;
			boundE = 144;
		}
		else//here we need to actually do some calculations
		{
			//boundW = (cast((startX/160),Int)*160)+16;//rooms are 160 pixels wide. So we divide the position by 160 to get which room on the X axis this is, then multiply by the room width, then add the wall width.
			//boundE = ((cast((startX/160),Int)+1)*160)-16;//same as above except we add one to the room number and subtract the wall width
			boundW = (startX - (startX % 160)) + 16;
			boundE = (boundW + 160) - 32;
		}
		
		//this.tilemap = tilemap;
		this.hero = hero;
		
		loadGraphic("assets/images/crab.png", true, 16, 16);
		
		animation.add("down", [1,0,1,2], 4, true);
		animation.add("up", [5,4,5,6], 4, true);
		animation.add("right", [9,8,9,10], 4, true);
		animation.add("left", [13, 12, 13, 14], 4, true);
		
		animation.add("charge_down", [0,2,0,2], 4, true);
		animation.add("charge_up", [4,6,4,6], 4, true);
		animation.add("charge_right", [8,10,8,10], 4, true);
		animation.add("charge_left", [12,14,12,14], 4, true);
		
		animation.add("attack_down", [3,1], 8, false);
		animation.add("attack_up", [7,5], 8, false);
		animation.add("attack_right", [11,9], 8, false);
		animation.add("attack_left", [15,13], 8, false);
		
		animation.add("stun", [3,7,11,15], 4, true);
		
		
		path = new FlxPath();
		
		animation.play("down");
		
		switch(Std.int(Math.random() * 4))
		{
			case 0:
				moveDirection = EMoveDirection.UP;
			case 1:
				moveDirection = EMoveDirection.DOWN;
			case 2:
				moveDirection = EMoveDirection.LEFT;
			case 3:
				moveDirection = EMoveDirection.RIGHT;
		}
		status = EnemyStatus.WANDER;
		wanderTicks = Std.int(Math.random() * 300);
		health = 1;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		if (alive)
		{
			if (status == EnemyStatus.WANDER)
			{
				switch (moveDirection)
				{
					case UP:
						y -= MOVEMENT_SPEED;
						animation.play("up");
						if(y <= boundN)
						{
							y = boundN;
							stopWander();
							wanderTicks = Std.int(Math.random() * 60);
						}
					case DOWN:
						y += MOVEMENT_SPEED;
						animation.play("down");
						if(y+height >= boundS)
						{
							y = boundS-height;
							stopWander();
							wanderTicks = Std.int(Math.random() * 60);
						}
					case LEFT:
						x -= MOVEMENT_SPEED;
						animation.play("left");
						if(x <= boundW)
						{
							x = boundW;
							stopWander();
							wanderTicks = Std.int(Math.random() * 60);
						}
					case RIGHT:
						x += MOVEMENT_SPEED;
						animation.play("right");
						if(x+width >= boundE)
						{
							x = boundE-width;
							stopWander();
							wanderTicks = Std.int(Math.random() * 60);
						}
				}
				
				if (wanderTicks > 0) {
					wanderTicks--;
				} else {
					stopWander();
					wanderTicks = Std.int(Math.random() * 60);
				}
				seePlayer();
			}
			
			if (status == EnemyStatus.ATTACK)
			{
				switch (moveDirection)
				{
					case UP:
						y -= ATTACK_SPEED;
						if(y <= boundN)
						{
							y = boundN;
							startStun();
							stunTicks = 30;
						}
					case DOWN:
						y += ATTACK_SPEED;
						if(y+height >= boundS)
						{
							y = boundS-height;
							startStun();
							stunTicks = 30;
						}
					case LEFT:
						x -= ATTACK_SPEED;
						if(x <= boundW)
						{
							x = boundW;
							startStun();
							stunTicks = 30;
						}
					case RIGHT:
						x += ATTACK_SPEED;
						if(x+width >= boundE)
						{
							x = boundE-width;
							startStun();
							stunTicks = 30;
						}
				}
				if (FlxCollision.pixelPerfectCheck(this, hero)) 
				{	
					startStun();
					stunTicks = 30;
				}
			}
			
			if (status == EnemyStatus.CHARGE)
			{
				switch (moveDirection)
				{
					case UP:
						animation.play("charge_up");
					case DOWN:
						animation.play("charge_down");
					case LEFT:
						animation.play("charge_left");
					case RIGHT:
						animation.play("charge_right");
				}
				
				if (chargeTicks > 0) {
					chargeTicks--;
				} else {
					status = EnemyStatus.ATTACK;
					switch (moveDirection)
					{
						case UP:
							animation.play("attack_up");
						case DOWN:
							animation.play("attack_down");
						case LEFT:
							animation.play("attack_left");
						case RIGHT:
							animation.play("attack_right");
					}
				}
			}
			
			if (status == EnemyStatus.STUN)
			{
				if (stunTicks > 0) {
					stunTicks--;
				} else {
					stopWander();
				}
			}
			
			if (FlxCollision.pixelPerfectCheck(this, hero)) 
			{	
				stopWander();
				hero.takeDamage(1);
			}
		}
	}
	
	public function takeDamage(damage:Int,state:DKAPlayState):Void
	{
		if (health > 0)
		{
			FlxG.sound.play("assets/sounds/sword_hit.wav", 1, false);
		}
		health--;
		if (health <= 0)
		{
			kill();
			//drop a heart.
			var drop:Int = FlxG.random.int(0, 4);

			if(drop >= 4)
			{
				var item:FlxSprite = cast(state.heartDrops.recycle(), FlxSprite);
				item.reset(x, y);
				state.heartTicks = 420;
			}
		}
	}
	
	private function seePlayer():Void
	{
		if(hero.y <= boundS && hero.y+hero.height >= boundN && hero.x <= boundE && hero.x+hero.width >= boundW)
		{ 
			switch (moveDirection)
			{
				case UP:
					if (hero.y < y && (hero.x + hero.width > x && hero.x < x + width))
					{
						animation.play("charge_up");
						status = EnemyStatus.CHARGE;
						chargeTicks = 40;
					}
				case DOWN:
					if (hero.y > y && (hero.x + hero.width > x && hero.x < x + width))
					{
						animation.play("charge_down");
						status = EnemyStatus.CHARGE;
						chargeTicks = 40;
					}
				case LEFT:
					if (hero.x < x && (hero.y + hero.height > y && hero.y < y + height))
					{
						animation.play("charge_left");
						status = EnemyStatus.CHARGE;
						chargeTicks = 40;
					}
				case RIGHT:
					if (hero.x > x && (hero.y + hero.height > y && hero.y < y + height))
					{
						animation.play("charge_right");
						status = EnemyStatus.CHARGE;
						chargeTicks = 40;
					}
			}
		}
	}
	
	public function startStun():Void
	{
		status = EnemyStatus.STUN;
		animation.play("stun");
		stunTicks = 30;
	}
	
	public function stopWander():Void
	{
		if (status == EnemyStatus.CHARGE)
		{
			startStun();
		}
		else
		{
			status = EnemyStatus.STOP;
			switch(Std.int(Math.random() * 4))
			{
				case 0:
					moveDirection = EMoveDirection.UP;
				case 1:
					moveDirection = EMoveDirection.DOWN;
				case 2:
					moveDirection = EMoveDirection.LEFT;
				case 3:
					moveDirection = EMoveDirection.RIGHT;
			}
			status = EnemyStatus.WANDER;
		}
	}
}
