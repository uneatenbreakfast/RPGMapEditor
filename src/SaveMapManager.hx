package ;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.net.URLRequestMethod;
/**
 * ...
 * @author Nelson
 */
class SaveMapManager
{
	private static var thisManager:SaveMapManager;
	private var displayManager:DisplayManager;
	

	private var fileString:String = "H:\\WorkSpace\\RPG\\src\\maps.as";


	
	private var currentmap:String = "";
	
	private var saveBusy:Bool = false;

	public function new() 
	{
		//dskTopFile = dskTopFile.resolvePath(fileString);
		displayManager = DisplayManager.getInstance();
	}
	public static function getInstance():SaveMapManager {
		if (thisManager == null) {
			thisManager = new SaveMapManager();
		}
		return thisManager;
	}
	
	public function saveMap(authorName:String, mapName:String, version:Int, mapdata:String):Void {
		
		var loader:URLLoader = new URLLoader();
		var vrs:URLVariables = new URLVariables();
		vrs.func 	= "updateMap";
		vrs.mapname = mapName;
		vrs.mapdata = mapdata;
		vrs.version = version;
		vrs.author	= authorName;
		
		var urlreq:URLRequest = new URLRequest("http://main.local/RPG_MapUpdater.php");
		urlreq.data = vrs;
		urlreq.method = URLRequestMethod.POST;

		loader.load(urlreq);
	}

	
	public function outputmap(e:MouseEvent):Void {
		saveBusy = true;
		displayManager.addChild(new SaveDialogue());
		//savefile();
	}
	function savefile():Void{	
		/*var stufftobewritten:String = "package { \n	import flash.utils.Dictionary; \n	import omni; \n \n	public class maps { \n \n		public static  var gm_maps:Dictionary=new Dictionary(); \n";
		//------
		
		var bringback:String = currentmap;
		gm_maps[currentmap] = maps.gm_maps[currentmap] = outputSTR();

		for(maploop in maps.gm_maps){
			
			currentmap = maploop;
			curmap.text = "Current Map : "+currentmap;
			
			//trace("buid:",gm_maps[currentmap] );
			buildmap( gm_maps[currentmap] );
			
			stufftobewritten += "gm_maps[\""+currentmap+"\"]=\"";
			
			var strmap:String = outputSTR();
			stufftobewritten += strmap;
			stufftobewritten += "\"; \n\n";
			
			MYSQL_updateMap(currentmap, strmap);
		}
		//------
		stufftobewritten += "	} \n}";

		dskTopFileStream.openAsync (dskTopFile, FileMode.WRITE);
		dskTopFileStream.writeUTFBytes (stufftobewritten);
		dskTopFileStream.close ();	
		
		currentmap = bringback;
		curmap.text = "Current Map : "+currentmap;
		buildmap( maps.gm_maps[currentmap] );*/
		trace("FIX UP SAVE TO FILE()");
	}
	

	
}