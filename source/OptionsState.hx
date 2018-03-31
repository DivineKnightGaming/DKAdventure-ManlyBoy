package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
//import flixel.util.FlxMath;
import flixel.FlxCamera;
import flixel.input.gamepad.FlxGamepad;
//import flixel.input.gamepad.XboxButtonID;
//import flixel.input.gamepad.OUYAButtonID;
import flash.system.System;

/**
 * A FlxState which can be used for the game's menu.
 */
class OptionsState extends FlxState
{
    private var state:UInt = 1;
	private var _gamePad:FlxGamepad;
	private var mbCam:FlxCamera;
    
	/**
	 * Function that is called up when to state is created to set it up. 
	 */    
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xff565656;
		
		Reg.manlyBoySp = new FlxSprite( 0, 0, Reg.manlyBoy);
		add(Reg.manlyBoySp);
		
		Reg.text = new FlxText(Reg.windowX+0,Reg.windowY+0,160,"Instructions");
		Reg.text.size = 16;
		Reg.text.alignment = "center";
		add(Reg.text); 
		
		Reg.text = new FlxText(Reg.windowX+0,Reg.windowY+20,160,Reg.dpad+" to move. "+Reg.buttonO+" to swing sword. "+Reg.buttonA+" to use potion");
		Reg.text.size = 8;
		Reg.text.alignment = "center";
		add(Reg.text); 
		
		Reg.sprite = new FlxSprite(Reg.windowX+0, Reg.windowY+46, Reg.potion);
		add(Reg.sprite);
		
		Reg.livesText = new FlxText(Reg.windowX+12,Reg.windowY+42,146,"Using the potion will restore your health. Caution, you only get one.");
		Reg.livesText.size = 8;
		add(Reg.livesText); 
		
		Reg.sprite = new FlxSprite(Reg.windowX+0, Reg.windowY+76, Reg.heartDrop);
		add(Reg.sprite);
		
		Reg.shieldText = new FlxText(Reg.windowX+12,Reg.windowY+76,146,"Pick these up to restore one heart to your health.");
		Reg.shieldText.size = 8;
		add(Reg.shieldText); 
		
		Reg.sprite = new FlxSprite(Reg.windowX+0, Reg.windowY+96, Reg.key);
		add(Reg.sprite);
		Reg.sprite = new FlxSprite(Reg.windowX+0, Reg.windowY+112, Reg.bossKey);
		add(Reg.sprite);
		
		Reg.powerText = new FlxText(Reg.windowX+12,Reg.windowY+100,146,"Find keys to open doors. Not all keys work on every door.");
		Reg.powerText.size = 8;
		add(Reg.powerText); 
		
		Reg.text = new FlxText(Reg.windowX+0,Reg.windowY+130,160,"Press "+Reg.buttonO+" to go back.");
		Reg.text.size = 8;
		Reg.text.alignment = "center";
		add(Reg.text); 
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		Reg.manlyBoySp.destroy();
		Reg.text.destroy();
		Reg.sprite.destroy();
		Reg.livesText.destroy();
		Reg.shieldText.destroy();
		Reg.powerText.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		_gamePad = FlxG.gamepads.lastActive;
		if (_gamePad == null)
		{
			// Make sure we don't get a crash on neko when no gamepad is active
			_gamePad = FlxG.gamepads.getByID(0);
		}
		
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE ||  ( Reg.usegamepad && _gamePad.justPressed.A))
		{
			this.goToPlay();
		}
		if (FlxG.keys.anyJustPressed(["ESCAPE"]))
		{
			SaveScores.save();
			System.exit(0);
		}
	}	
	
	private function goToPlay():Void
	{
		FlxG.switchState(new MenuState());
	}
}
