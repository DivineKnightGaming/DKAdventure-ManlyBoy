package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
//import flixel.math.FlxMath;
import flash.Lib;
import flixel.FlxCamera;
import flixel.util.FlxCollision;
import flixel.math.FlxRandom;
import flixel.input.gamepad.FlxGamepad;
//import flixel.input.gamepad.XboxButtonID;
//import flixel.input.gamepad.OUYAButtonID;
import flash.system.System;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	public var player:DKAPlayer;
	public var playerSword:DKASword;
	public var boss:DKABoss;
	private var _level:DKATiledLevel;
	private var hudCam:FlxCamera;
	private var playerCam:FlxCamera;
	public var enemies:FlxGroup;
	public var doors:FlxGroup;
	public var heartDrops:FlxGroup;
	private var mbCam:FlxCamera;
	private var _gamePad:FlxGamepad;
	public var keys:Int = 0;
	public var masterKey:Bool = false;
	public var key1Collected:Bool = false;
	public var key2Collected:Bool = false;
	public var key3Collected:Bool = false;
	public var key1Dropped:Bool = false;
	public var key2Dropped:Bool = false;
	public var key3Dropped:Bool = false;
	public var masterDropped:Bool = false;
	public var fireballs:FlxGroup;
	public var keyDrop:FlxSprite;
	public var bossKeyDrop:FlxSprite;
	public var treasure:FlxSprite;
	public var fightingBoss:Bool = false;
	public var talkingToBoss:Bool = false;
	public var heartTicks:Int = 0;
	public var bossTalk:Int = 0;
	public var gameWon:Bool = false;
	public var winTicks:Int = 0;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xffacacac;
		
		// Load the level's tilemaps
		_level = new DKATiledLevel("assets/data/dungeon.tmx", this);
		
		// Add tilemaps
		add(_level.backgroundLayer);
		
		// Add tilemaps
		add(_level.foregroundTiles);
		
		Reg.manlyBoySp = new FlxSprite( 0, 1000, Reg.manlyBoy);
		add(Reg.manlyBoySp);
		mbCam = new FlxCamera(0, 0, 320, 180);
		mbCam.setScrollBoundsRect(0, 1000, 320, 180);
		mbCam.follow(Reg.manlyBoySp);
		FlxG.cameras.add(mbCam);
		
		enemies = new FlxGroup();
		add(enemies);
		playerSword = new DKASword();
		add(playerSword);
		
		var numenemyBullets:Int = 8;
		fireballs = new FlxGroup(numenemyBullets);
		
		// Create 8 bullets for the player to recycle
		for(i in 0...numenemyBullets)			
		{
			// Instantiate a new sprite offscreen
			Reg.sprite = new FlxSprite( -100, -100, Reg.fireball);		
			Reg.sprite.loadGraphic(Reg.fireball, true, 8, 8);
			Reg.sprite.animation.add("fire_right", [0,4], 4, true);	
			Reg.sprite.animation.add("fire_left", [1,5], 4, true);	
			Reg.sprite.animation.add("fire_up", [2,6], 4, true);	
			Reg.sprite.animation.add("fire_down", [3,7], 4, true);	
			Reg.sprite.exists = false;
			// Add it to the group of player bullets
			fireballs.add(Reg.sprite);			
		}
		
		add(fireballs);
		
		doors = new FlxGroup(7);
		Reg.sprite = new FlxSprite( 64, 256, "assets/images/door_monster_n.png");
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( 144, 176, "assets/images/door_key_e.png");
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( 224, 240, "assets/images/door_key_s.png");
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( 224, 368, "assets/images/door_key_s.png");
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( 224, 128, "assets/images/door_master_n.png");
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( -100, -100, "assets/images/door_monster_s.png");//224, 112
		doors.add(Reg.sprite);
		Reg.sprite = new FlxSprite( -100, -100, "assets/images/door_monster_w.png");//160, 48
		doors.add(Reg.sprite);
		
		add(doors);
		
		
		heartDrops = new FlxGroup(4);
		
		// Create 8 bullets for the player to recycle
		for(i in 0...4)			
		{
			// Instantiate a new sprite offscreen
			Reg.sprite = new FlxSprite( -100, -100, Reg.heartDrop);		
			Reg.sprite.exists = false;
			// Add it to the group of player bullets
			heartDrops.add(Reg.sprite);			
		}
		
		add(heartDrops);
		
		// Load player and objects of the Tiled map
		_level.loadObjects(this);

		//FlxG.camera.follow(player, FlxCamera.STYLE_SCREEN_BY_SCREEN);
		playerCam = new FlxCamera(Reg.windowX*Reg.gameZoom, Reg.windowY*Reg.gameZoom, 160, 128);
		playerCam.setScrollBoundsRect(0, 0, 640, 640);
		playerCam.follow(player, SCREEN_BY_SCREEN, 1);
		FlxG.cameras.add(playerCam);
		//playerCam.style = FlxCamera.STYLE_LOCKON;
		//playerCam.style = FlxCamera.STYLE_SCREEN_BY_SCREEN;
		
		Reg.hudSp = new FlxSprite(0, 640, Reg.hud);
		add(Reg.hudSp);
		
		Reg.health1Sp = new FlxSprite(4, 640, Reg.heartFull);
		add(Reg.health1Sp);
		Reg.health2Sp = new FlxSprite(20, 640, Reg.heartFull);
		add(Reg.health2Sp);
		Reg.health3Sp = new FlxSprite(36, 640, Reg.heartFull);
		add(Reg.health3Sp);
		Reg.health4Sp = new FlxSprite(52, 640, Reg.heartFull);
		add(Reg.health4Sp);
		
		Reg.potionSp = new FlxSprite(68, 640, Reg.potion);
		add(Reg.potionSp);
		
		Reg.potionsTxt = new FlxText(84,640,100,"x1");
		Reg.potionsTxt.size = 8;
		add(Reg.potionsTxt); 
		
		Reg.keySp = new FlxSprite(100, 640, Reg.key);
		add(Reg.keySp);
		
		Reg.keysTxt = new FlxText(116,640,100,"x0");
		Reg.keysTxt.size = 8;
		add(Reg.keysTxt); 
		
		hudCam = new FlxCamera(Reg.windowX*Reg.gameZoom, (Reg.windowY+128)*Reg.gameZoom, 160, 24);
		hudCam.follow(Reg.hudSp);
		FlxG.cameras.add(hudCam);
		
		keyDrop = new FlxSprite( -100, -100, "assets/images/key.png");//160, 48
		add(keyDrop);
		keyDrop.kill();
		bossKeyDrop = new FlxSprite( -100, -100, "assets/images/bossKey.png");//160, 48
		add(bossKeyDrop);
		bossKeyDrop.kill();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (gameWon)
		{
			player.stopMove();
			if (winTicks > 0)
			{
				winTicks--;
			}
			else
			{
				FlxG.switchState(new WinState());
			}
		}
		else
		{
			Reg.potionsTxt.text = "x"+player.potions;
			
			switch(player.health)
			{
				case 1:
					Reg.health1Sp.loadGraphic(Reg.heartHalf);
					Reg.health2Sp.loadGraphic(Reg.heartEmpty);
					Reg.health3Sp.loadGraphic(Reg.heartEmpty);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 2:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartEmpty);
					Reg.health3Sp.loadGraphic(Reg.heartEmpty);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 3:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartHalf);
					Reg.health3Sp.loadGraphic(Reg.heartEmpty);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 4:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartFull);
					Reg.health3Sp.loadGraphic(Reg.heartEmpty);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 5:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartFull);
					Reg.health3Sp.loadGraphic(Reg.heartHalf);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 6:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartFull);
					Reg.health3Sp.loadGraphic(Reg.heartFull);
					Reg.health4Sp.loadGraphic(Reg.heartEmpty);
				case 7:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartFull);
					Reg.health3Sp.loadGraphic(Reg.heartFull);
					Reg.health4Sp.loadGraphic(Reg.heartHalf);
				case 8:
					Reg.health1Sp.loadGraphic(Reg.heartFull);
					Reg.health2Sp.loadGraphic(Reg.heartFull);
					Reg.health3Sp.loadGraphic(Reg.heartFull);
					Reg.health4Sp.loadGraphic(Reg.heartFull);
			}
			
			_gamePad = FlxG.gamepads.lastActive;
			if (_gamePad == null)
			{
				// Make sure we don't get a crash on neko when no gamepad is active
				_gamePad = FlxG.gamepads.getByID(0);
			}
			
			// Collide with foreground tile layer
			if (_level.collideWithLevel(player))
			{
				// Resetting the movement flag if the player hits the wall 
				// is crucial, otherwise you can get stuck in the wall
				player.moveToNextTile = false;
				if (player.x % 16 == 15 || player.x % 16 == 14|| player.x % 16 == 13)
				{
					player.x++;
				}
				else if (player.x % 16 == 1 || player.x % 16 == 2 || player.x % 16 == 3)
				{
					player.x--;
				}
				if (player.y % 16 == 15 || player.y % 16 == 14 || player.y % 16 == 13)
				{
					player.y++;
				}
				else if (player.y % 16 == 1 || player.y % 16 == 2 || player.y % 16 == 3)
				{
					player.y--;
				}
				
			}
			for (i in 0...enemies.length) 
			{
				var enemy = cast(enemies.members[i], DKAEnemy);
				if (_level.collideWithLevel(enemy))
				{
					// Resetting the movement flag if the player hits the wall 
					// is crucial, otherwise you can get stuck in the wall
					enemy.stopWander();
				}
				if (FlxCollision.pixelPerfectCheck(enemy, player.playerSword) && enemy.alive) 
				{	
					enemy.takeDamage(1,this);
				}
			}
			
			//trace(heartDrops.countLiving());
			for (i in 0...heartDrops.length) 
			{
				var lifeitem = heartDrops.members[i];
				
				if (cast(lifeitem, FlxSprite).alive && FlxCollision.pixelPerfectCheck(cast(lifeitem, FlxSprite), player))
				{
					cast(lifeitem, FlxSprite).kill();
					cast(lifeitem, FlxSprite).x = -100;
					if(player.health < 8)
					{
						player.health++;
					}
					FlxG.sound.play(Reg.lifeWav);
				}
				if(heartTicks > 0)
				{
					heartTicks--;
				}
				else
				{
					cast(lifeitem, FlxSprite).kill();
					cast(lifeitem, FlxSprite).x = -100;
				}
			}
			if(player.x > boss.boundW && player.x < boss.boundE-player.width && player.y < boss.boundS-player.height && player.y > boss.boundN && boss.alive)
			{
				if(!fightingBoss && !talkingToBoss)
				{
					FlxG.sound.play("assets/sounds/doorClosed.wav", 1, false);	
					//224, 112
					cast(doors.members[5],FlxSprite).x = 224;
					cast(doors.members[5],FlxSprite).y = 112;
					//160, 48
					cast(doors.members[6],FlxSprite).x = 160;
					cast(doors.members[6],FlxSprite).y = 48;
					talkingToBoss = true;
					player.talkingToBoss = true;
					boss.talkingToBoss = true;
			
					Reg.dialogSp = new FlxSprite(boss.boundW-16, boss.boundN-16, Reg.dialogImg);
					add(Reg.dialogSp);
					
					Reg.dialogTxt = new FlxText(boss.boundW-12, boss.boundN-12,160,boss.dialog[bossTalk]);
					Reg.dialogTxt.size = 8;
					add(Reg.dialogTxt); 
				}
			}
			if (talkingToBoss)
			{
				if (FlxG.keys.justPressed.SPACE ||  ( Reg.usegamepad && _gamePad.justPressed.A))
				{
					bossTalk++;
				}
				if (bossTalk < boss.dialog.length)
				{
					Reg.dialogTxt.text = boss.dialog[bossTalk];
				}
				else
				{
					Reg.dialogSp.x = -200;
					Reg.dialogTxt.x = -200;
					fightingBoss = true;
					talkingToBoss = false;
					player.talkingToBoss = false;
					boss.talkingToBoss = false;
				}
			}
			if (!boss.alive && fightingBoss == true)
			{
				//trace("Play Sound");
				FlxG.sound.play("assets/sounds/doorOpen.wav", 1, false);	
				cast(doors.members[5], FlxSprite).kill();
				cast(doors.members[6], FlxSprite).kill();
				fightingBoss = false;
			}
			for (i in 0...doors.length)
			{
				var door = cast(doors.members[i], FlxSprite);
				if (FlxCollision.pixelPerfectCheck(door, player) && door.alive) 
				{	
					player.stopMove(true);
					if ((i == 1 || i == 2 || i == 3) && door.alive && keys > 0)
					{
						FlxG.sound.play("assets/sounds/doorOpen.wav", 1, false);
						keys--;
						Reg.keysTxt.text = "x" + keys;
						door.kill();
					}
					if (i == 4 && door.alive && masterKey)
					{
						FlxG.sound.play("assets/sounds/doorOpen.wav", 1, false);
						door.kill();
					}
				}
			}
			if (FlxCollision.pixelPerfectCheck(keyDrop, player) && keyDrop.alive)
			{
				FlxG.sound.play("assets/sounds/keyPickup.wav", 1, false);	
				keyDrop.kill();
				keyDrop.x = -100;
				keyDrop.y = -100;
				keys++;
				Reg.keysTxt.text = "x" + keys;
				switch(keyDrop.x)
				{
					case 80:
						key1Collected = true;
					case 288:
						key2Collected = true;
					case 272:
						key3Collected = true;
				}
			}
			if (FlxCollision.pixelPerfectCheck(bossKeyDrop, player) && bossKeyDrop.alive)
			{
				
				FlxG.sound.play("assets/sounds/keyPickup.wav", 1, false);	
				masterKey = true;
				bossKeyDrop.x = 136;
				bossKeyDrop.y = 640;
			}
			switch(enemies.countLiving())
			{
				case 16:
					if(cast(doors.members[0], FlxSprite).alive)
					{
						FlxG.sound.play("assets/sounds/doorOpen.wav", 1, false);
						cast(doors.members[0], FlxSprite).kill();
					}
				case 12:
					//drop key
					if (!key1Collected && !key1Dropped)
					{
						FlxG.sound.play("assets/sounds/keyDrop.wav", 1, false);	
						keyDrop = new FlxSprite( 16, 224, "assets/images/key.png");//160, 48
						add(keyDrop);
						key1Collected = false;
						key1Dropped = true;
					}
				case 8:
					//drop key
					if (!key2Collected && !key2Dropped)
					{
						FlxG.sound.play("assets/sounds/keyDrop.wav", 1, false);	
						keyDrop = new FlxSprite( 288, 144, "assets/images/key.png");//160, 48
						add(keyDrop);
						key2Collected = true;
						key2Dropped = true;
					}
				case 4:
					//drop key
					if (!key3Collected && !key3Dropped)
					{
						FlxG.sound.play("assets/sounds/keyDrop.wav", 1, false);	
						keyDrop = new FlxSprite( 272, 336, "assets/images/key.png");//160, 48
						add(keyDrop);
						key3Collected = false;
						key3Dropped = true;
					}
				case 0:
					//drop master
					if (!masterKey && !masterDropped)
					{
						FlxG.sound.play("assets/sounds/keyDrop.wav", 1, false);	
						bossKeyDrop = new FlxSprite( 240, 432, "assets/images/bossKey.png");//160, 48
						add(bossKeyDrop);
						masterDropped = true;
					}
			}
			if (FlxCollision.pixelPerfectCheck(treasure, player))
			{
				winTicks = 60;
				gameWon = true;
				FlxG.sound.play("assets/sounds/treasureGrab.wav", 1, false);	
			}
		}
		if (FlxG.keys.anyJustPressed(["ESCAPE"]))
		{
			System.exit(0);
		}
	}	
}
