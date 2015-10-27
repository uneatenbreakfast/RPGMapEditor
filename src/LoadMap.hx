package ;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

/**
 * ...
 * @author Nelson
 */
class LoadMap extends Maplist
{
	private var displayManager:DisplayManager;
	private var maplists:ScrollerPane;
	
	private var loadingbaranimation:LoadingBar;
	
	public function new() 
	{
		super();
		
		displayManager = DisplayManager.getInstance();
		
		maplists = new ScrollerPane(symbo);
		maplists.x = symbo.x;
		maplists.y = symbo.y;
		addChild(maplists);
		//
		loadingbaranimation = new LoadingBar();
		loadingbaranimation.x = 8.5;
		loadingbaranimation.y = 45;
		addChild(loadingbaranimation);
		
		
		//
		
		var loader:URLLoader = new URLLoader();
		var vrs:URLVariables = new URLVariables();
		vrs.func = "getMapList";
		
		var urlreq:URLRequest = new URLRequest("http://main.local/RPG_MapUpdater.php");
		urlreq.data = vrs;
		urlreq.method = URLRequestMethod.POST;
		loader.addEventListener(Event.COMPLETE, loadedMapList);
		loader.load(urlreq);
		
		trace("SENDING Map Request");
	}
	
	private function loadedMapList(e:Event):Void {
		removeChild(loadingbaranimation);
		
		
		
		var results:Array<String> = e.currentTarget.data.split("|");
		results.pop();
		
		trace("RECEIVING Map Request", results);
		
		var inum:Int = 0;
		for (i in results) {
			var res:Array<String> = i.split("~");
			
			var k:List_btt_LoadMaps = new List_btt_LoadMaps();
			k.key_txt.text = res[0];
			k.mapname_txt.text = res[3];
			k.version_txt.text = "v-" + res[2];
			k.author_txt.text = res[1];
			k.y = inum * 20;
			
			k.version_txt.mouseEnabled = false;
			k.key_txt.mouseEnabled = false;
			k.mapname_txt.mouseEnabled = false;
			k.author_txt.mouseEnabled = false;
			
			k.addEventListener(MouseEvent.CLICK, mapSel);
			maplists.addChild(k);
			
			inum++;
		}		
	}
	
	private function mapSel(e:MouseEvent):Void {
		
		var mc:List_btt_LoadMaps = cast(e.currentTarget, List_btt_LoadMaps);
		var key:Int = Std.parseInt( mc.key_txt.text );
		
		if (displayManager.save_btt_toggle.isSelected) {
			// there is unsaved changed
			var d:DialogueSave = displayManager.promptSave();	
			d.continueFunction = getMapFromDB;
			d.continueParams = [key];
			//
		}else {
			getMapFromDB(key);
		}
	}
	
	private function getMapFromDB(key:Int):Void {
		var loader:URLLoader = new URLLoader();
		var vrs:URLVariables = new URLVariables();
		vrs.func = "getMap";
		vrs.key = key;
		
		var urlreq:URLRequest = new URLRequest("http://main.local/RPG_MapUpdater.php");
		urlreq.data = vrs;
		urlreq.method = URLRequestMethod.POST;
		loader.addEventListener(Event.COMPLETE, getMapRes);
		loader.load(urlreq);
	}
	private function getMapRes(e:Event):Void {
		var data:Array<String> = e.currentTarget.data.split("@");
		displayManager.loadNewMap(data[0], data[1], data[2]);
	}
	
}