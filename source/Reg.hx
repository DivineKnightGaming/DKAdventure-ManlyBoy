package;

import flixel.util.FlxSave;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
//import flixel.effects.FlxSpriteFilter;
import flixel.group.FlxGroup;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;
	public static var highScore:Int = 0;
	
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];
	
	public static var gameZoom:Int = 4;
	
	public static var text:FlxText;
	public static var controlsText:FlxText;
	public static var sprite:FlxSprite;
	public static var button:FlxButton;
	
	public static var manlyBoy="assets/images/manly_boy.png";
	public static var manlyBoySp:FlxSprite;
	
	public static var windowX = 80;
	public static var windowY = 18;
	
	public static var dkLogo="assets/images/dklogo_bw_sm.png";
	public static var dkLogoSp:FlxSprite;
	
	public static var dkAdventureLogo="assets/images/dkadventure.png";
	
	public static var soldier="assets/images/soldier.png";
	public static var soldierSp:FlxSprite;
	
	public static var crab="assets/images/crab.png";
	public static var crabSp:FlxSprite;
	
	public static var heartFull="assets/images/heart_full.png";
	public static var heartHalf="assets/images/heart_half.png";
	public static var heartEmpty="assets/images/heart_empty.png";
	public static var heartDrop="assets/images/heart_drop.png";
	public static var key="assets/images/key.png";
	public static var bossKey="assets/images/bossKey.png";
	public static var potion="assets/images/potion.png";
	public static var jewel = "assets/images/jewel.png";
	public static var fireball = "assets/images/fireball.png";
	public static var keysTxt:FlxText;
	public static var potionsTxt:FlxText;
	public static var keySp:FlxSprite;
	public static var bossKeySp:FlxSprite;
	public static var potionSp:FlxSprite;
	public static var health1Sp:FlxSprite;
	public static var health2Sp:FlxSprite;
	public static var health3Sp:FlxSprite;
	public static var health4Sp:FlxSprite;
	
	public static var doors:Array<String> = ["assets/images/door_key_e.png", "assets/images/door_key_w.png", "assets/images/door_key_n.png", "assets/images/door_key_s.png",
											"assets/images/door_monster_e.png", "assets/images/door_monster_w.png", "assets/images/door_monster_n.png", "assets/images/door_monster_s.png",
											"assets/images/door_master_e.png","assets/images/door_master_w.png","assets/images/door_master_n.png","assets/images/door_master_s.png",];
	
	public static var hud="assets/images/blankhud.png";
	public static var dialogImg="assets/images/dialog.png";
	public static var hudSp:FlxSprite;
	public static var dialogSp:FlxSprite;
	public static var dialogTxt:FlxText;
	
	public static var fullScreen:Bool = false;
	
	
	/*public static var buttonO="A";
	public static var buttonU="X";
	public static var buttonY="Start";
	public static var buttonA="B";*/
	
	public static var controls="Keyboard";
	public static var dpad="Arrows";
	public static var buttonO="Space";
	public static var buttonU="Q";
	public static var buttonY="G";
	public static var buttonA="Z";
	public static var usegamepad:Bool = true;
		
	
}
