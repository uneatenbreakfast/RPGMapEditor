package ;

import flash.Lib;
import flash.display.Sprite;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author Nelson
 */

class Main extends Sprite 
{
	private static var thisMain:Main;
	
	public static function getInstance():Main {
		return thisMain;
	}
	
	public function new() 
	{
		super();
		thisMain = this;
				
		var keyboardManager:KeyBoardManager = KeyBoardManager.getInstance();
		var displayManager:DisplayManager = DisplayManager.getInstance();
		
		var tileManager:TileManager = TileManager.getInstance();
		tileManager.init();
		
		this.addChild(displayManager);
		
		
	}
	static function main() 
	{
		Lib.current.addChild(new Main());
	}
}