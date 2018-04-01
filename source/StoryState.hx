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
class StoryState extends FlxState
{
	private var mbCam:FlxCamera;
	private var _gamePad:FlxGamepad;
	private var story:Array<String>;
	private var storyPart:Int = 0;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xffacacac;
		//FlxG.cameras.bgColor = 0xffffffff;
		
		Reg.manlyBoySp = new FlxSprite( 0, 0, Reg.manlyBoy);
		add(Reg.manlyBoySp);
		
		story = ["300 years ago, there was a small island kingdom of Belfast, several months travel by ship from any of its neighbors. This kingdom was ruled by a wicked wizard by the name of Larost.",
				"At that time, a star fell from the sky. Everyone on the island saw, heard or felt the landing of the star. But onely one person actually found it. That man was Larost.",
				"Larost grew in power and began to rule and stayed in power for over 20 years. Any who opposed him was met with harsh punishment often death. His rule led to many underground rebelions.",
				"These rebelions had little success in freeing the people of Belfast. Many who had joined in hopes of freeing their country felt dismayed and were ready to abandon all hope.",
				"One day, a small ship landed on the southern shore of the island. On board was a half starved and thirsting soldier. Found by a member of the rebelion, he was nursed back to health.",
				"Upon regaining his health, this soldier vowed to free the people of Belfast from Larost's rule. He donned his armor and sword and carved an image of a lion into his shield.",
				"This soldier then traveled to the castle of Larost to face him one on one in a battle not for his own life, but the life and liberty  of this kingdom and its people."];
		
		Reg.livesText = new FlxText(Reg.windowX+0,Reg.windowY+20,160,story[storyPart]);
		Reg.livesText.size = 8;
		Reg.livesText.alignment = "center";
		add(Reg.livesText); 
		
		Reg.text = new FlxText(Reg.windowX+12,Reg.windowY+106,160,"Press "+Reg.buttonO+" to continue.");
		Reg.text.size = 8;
		add(Reg.text); 
		
		Reg.shieldText = new FlxText(Reg.windowX+12,Reg.windowY+126,160,"Press "+Reg.buttonU+" to Skip.");
		Reg.shieldText.size = 8;
		add(Reg.shieldText); 
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		Reg.manlyBoySp.destroy();
		Reg.livesText.destroy();
		Reg.text.destroy();
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
			FlxG.sound.play(Reg.selectWav);
			storyPart++;
			if(storyPart > 6)
			{
				this.goToPlay();
			}
			else
			{
				Reg.livesText.text = story[storyPart];
			}
		}
		if (FlxG.keys.justPressed.Q ||  ( Reg.usegamepad && _gamePad.justPressed.X))
		{
			this.goToPlay();
		}
		if (FlxG.keys.anyJustPressed(["ESCAPE"]))
		{
			System.exit(0);
		}
	}	
	
	private function goToPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
}
