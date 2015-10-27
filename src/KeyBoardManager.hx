package ;

import flash.events.KeyboardEvent;
import flash.Lib;
import flash.system.System;

/**
 * ...
 * @author Nelson
 */
class KeyBoardManager
{
	private var mainStage:Main;
	private static var thisSingleton:KeyBoardManager;
	public function new() 
	{
		mainStage = Main.getInstance();
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, kdown);
	}
	public static function getInstance():KeyBoardManager {
		if (thisSingleton == null) {
			thisSingleton = new KeyBoardManager();
		}
		return thisSingleton;
	}
	private function kdown(e:KeyboardEvent):Void {
		var key:UInt = e.keyCode;
		switch(key) {
			case 27: //esc
				//NativeApplication.nativeApplication.exit();
		}
	}
	
}