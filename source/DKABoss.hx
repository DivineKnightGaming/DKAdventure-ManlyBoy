package ;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxCollision;
import flixel.math.FlxRandom;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
/**
 * Enemy
 * @author Kirill Poletaev
 */
enum BMoveDirection
{
	UP;
	DOWN;
	LEFT;
	RIGHT;
}

enum BossStatus
{
	WANDER;
	ATTACK1;
	ATTACK2;
	STOP;
	INACTIVE;
	DEAD;
}

class DKABoss extends FlxSprite
{
	//public var path:FlxPath;
	private var wanderTicks:Float;
	private var attackTicks:Float;
	private var waitTicks:Float;
	private var dieTicks:Float;
	private var nodes:Array<FlxPoint>;
	//private var tilemap:FlxTilemap;
	private var hero:DKAPlayer;
	private var status:BossStatus;
	private var startX:Int;
	private var startY:Int;
	public var boundN:Int;
	public var boundE:Int;
	public var boundS:Int;
	public var boundW:Int;
	public var dialog:Array<String>;
	public var talkingToBoss:Bool = true;

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
			boundN =  ( Std.int((startY/128)) *128) +16;
			boundS = (boundN + 128) - 32;
		}
		
		if(startX < 160)//again, easy enough
		{
			boundW = 16;
			boundE = 144;
		}
		else//here we need to actually do some calculations
		{
			boundW = (startX - (startX % 160)) + 16;
			boundE = (boundW + 160) - 32;
		}
		
		//this.tilemap = tilemap;
		this.hero = hero;
		
		loadGraphic("assets/images/boss.png", true, 32, 32);
		
		animation.add("move", [1,0,2,0], 4, true);
		
		animation.add("attack_1", [0,3,4,5,4,5], 4, false);
		
		animation.add("attack_2", [0,6,7,8,7,8], 4, false);
		
		animation.add("die", [0,9,9,10,10,11,11], 4, false);
		
		path = new FlxPath();
		
		animation.play("move");
		
		status = BossStatus.INACTIVE;
		wanderTicks = 0;
		health = 5;
		
		dialog = ["You have done well to get this far.", "But you cannot defeat me.", "Not while I have the power of the star.", "Prepare to die!"];
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		if (alive && !talkingToBoss)
		{
			if(hero.x > boundW && hero.x < boundE-hero.width && hero.y < boundS-hero.height && hero.y > boundN && status == BossStatus.INACTIVE)
			{
				velocity.y = FlxG.random.sign() * 30;
				velocity.x = FlxG.random.sign() * 30;
				status = BossStatus.WANDER;
				wanderTicks = 90;
			}
			if (status == BossStatus.WANDER)
			{
				
				if (x < boundW || x > boundE-width)
				{
					if (x <= boundW)
					{
						x = boundW;
					}
					else if (x >= boundE)
					{	
						x = boundE-width;
					}
					velocity.x = -velocity.x;
				}
				if(y > boundS-height || y < boundN)
				{
					if(y >= boundS - height)
					{
						y = boundS - height;
					}
					else if(y <= boundN)
					{
						y = boundN;
					}
					
					velocity.y = -velocity.y;
				}
				
				if (wanderTicks > 0) {
					wanderTicks--;
				} else {
					velocity.y = 0;
					velocity.x = 0;
					status = BossStatus.STOP;
					if(y <= boundN+height/2)
					{
						status = BossStatus.ATTACK1;						
					}
					else if (y >= boundN+height/2 && y <= boundN+height)
					{
						var attack = FlxG.random.int(0, 1);
						if(attack == 0)
						{
							status = BossStatus.ATTACK1;
						}
						else
						{
							status = BossStatus.ATTACK2;
						}
					}
					else
					{
						status = BossStatus.ATTACK2;
					}
				}
			}
			if(attackTicks > 0)
			{
				//attackTicks -= FlxG.elapsed;
				attackTicks--;
				if((status == BossStatus.ATTACK1 || status == BossStatus.ATTACK2) && attackTicks <= 0)
				{
					attackTicks = 0;
					shootFireballs();
				}
			}
			
			if (status == BossStatus.ATTACK1 && attackTicks == 0 && waitTicks == 0)
			{
				waitTicks = 0;
				animation.play("attack_1");
				//attackTicks = .2;
				attackTicks = 20;
			}
			
			if (status == BossStatus.ATTACK2 && attackTicks == 0 && waitTicks == 0)
			{
				waitTicks = 0;
				animation.play("attack_2");
				//attackTicks = .2;
				attackTicks = 20;
			}
			
			if(waitTicks > 0)
			{
				//waitTicks -= FlxG.elapsed;
				waitTicks--;
				if(waitTicks <= 0)
				{
					status = BossStatus.WANDER;
					animation.play("move");
					wanderTicks = 90;
					velocity.y = FlxG.random.sign() * 30;
					velocity.x = FlxG.random.sign() * 30;
				}
			}
			
			if (FlxCollision.pixelPerfectCheck(this, hero)) 
			{	
				hero.takeDamage(1);
			}
			
			if(dieTicks > 0)
			{
				dieTicks -= FlxG.elapsed;
				if(dieTicks <= 0)
				{
					kill();
				}
			}
		
			if (hero.playerSword.alive && FlxCollision.pixelPerfectCheck(cast(hero.playerSword, FlxSprite), cast(this, FlxSprite)))
			{
				takeDamage(1);
			}
		}
		
		for (i in 0...cast(FlxG.state, DKAPlayState).fireballs.length) 
		{
			var fire = cast(FlxG.state, DKAPlayState).fireballs.members[i];
			
			if (cast(fire, FlxSprite).alive && FlxCollision.pixelPerfectCheck(cast(fire, FlxSprite), cast(hero, FlxSprite)))
			{
				cast(fire, FlxSprite).kill();
				FlxG.sound.play("assets/sounds/fire_hit.wav", 1, false);
				hero.takeDamage(1);
			}
			
			if(cast(fire, FlxSprite).alive && (cast(fire, FlxSprite).x < boundW-cast(fire, FlxSprite).width || cast(fire, FlxSprite).x > boundE+cast(fire, FlxSprite).width || cast(fire, FlxSprite).y > boundS+cast(fire, FlxSprite).height || cast(fire, FlxSprite).y < boundN-cast(fire, FlxSprite).height))
			{
				cast(fire, FlxSprite).kill();
			}
		}
	}
	
	public function shootFireballs():Void
	{
		if (status == BossStatus.ATTACK1 && waitTicks == 0)
		{
			FlxG.sound.play("assets/sounds/fire_shoot.wav", 1, false);
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width / 2 - bullet.width / 2, y + height / 2 - bullet.height / 2);
			bullet.animation.add("fire", [3,7], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.y = 65;
			
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width / 2 - bullet.width / 2, y + height / 2 - bullet.height / 2);
			bullet.animation.add("fire", [3,7], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.y = 65;
			bullet.velocity.x = -45;
			
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width / 2 - bullet.width / 2, y + height / 2 - bullet.height / 2);
			bullet.animation.add("fire", [3,7], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.y = 65;
			bullet.velocity.x = 45;
		}
		if (status == BossStatus.ATTACK2 && waitTicks == 0)
		{
			FlxG.sound.play("assets/sounds/fire_shoot.wav", 1, false);
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width - bullet.width, y);
			bullet.animation.add("fire", [0,4], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.x = 65;
			
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width - bullet.width,  y);
			bullet.animation.add("fire", [1,5], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.x = -65;
			
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width - bullet.width,  y);
			bullet.animation.add("fire", [2,6], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.y = -65;
			
			var bullet:FlxSprite = cast(cast(FlxG.state, DKAPlayState).fireballs.recycle(), FlxSprite);
			bullet.loadGraphic(Reg.fireball, true, 16, 16);
			bullet.reset(x + width - bullet.width,  y);
			bullet.animation.add("fire", [3,7], 4, true);	
			bullet.animation.play("fire");
			bullet.velocity.y = 65;
		}
		//waitTicks = .3;
		waitTicks = 60;
	}
	
	public function takeDamage(damage:Int):Void
	{
		if(FlxFlicker.isFlickering(cast(this, FlxSprite)) == false)
		{
			if (health > 0)
			{
				FlxFlicker.flicker(cast(this, FlxSprite));
				FlxG.sound.play("assets/sounds/sword_hit.wav", 1, false);
			}
			health--;
			if (health <= 0)
			{
				status = BossStatus.DEAD;
				velocity.y = 0;
				velocity.x = 0;
				animation.play("die");
				FlxFlicker.flicker(cast(this, FlxSprite),3);
				dieTicks = 1;
			}
		}
	}
}
