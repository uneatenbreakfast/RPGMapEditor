package ;

import fl.data.DataProvider;
import fl.controls.ComboBox;
import fl.motion.Color;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

class Settings_Panel extends MenuSettings
{
	private var displayManager:DisplayManager;
	private var tileManager:TileManager;
	private var listofMapNames:DataProvider = new DataProvider();
	
	private var fillcol:Color = new Color();
	
	private var warpHolder:ScrollerPane;
	private var allToggleWarps:Array<ToggleButton> = new Array<ToggleButton>();
	private var gates:Array<WarpGateInfos> = new Array<WarpGateInfos>();
	
	public function new() 
	{
		super();
		displayManager = DisplayManager.getInstance();
		tileManager = TileManager.getInstance();
				
		namemap.text = displayManager.currentmap;
		rowx.text = displayManager.rows+"";
		columnx.text = displayManager.columns+"";
		tintnum.text = displayManager.fillcolour + "";
		author_txt.text = displayManager.authorName;

		tintbgReset();		
		
		warpHolder = new ScrollerPane(symbo);
		warpHolder.x = 5;
		warpHolder.y = 472;
		addChild(warpHolder);
		
		namemap.addEventListener(FocusEvent.FOCUS_OUT, mapnameRename);
		author_txt.addEventListener(FocusEvent.FOCUS_OUT, mapnameRename);
		tintnum.addEventListener(FocusEvent.FOCUS_OUT, tintbgReset);
		
		
		add_top_btt.addEventListener(MouseEvent.CLICK, addRowCol);
		add_left_btt.addEventListener(MouseEvent.CLICK, addRowCol);
		add_right_btt.addEventListener(MouseEvent.CLICK, addRowCol);
		add_bottom_btt.addEventListener(MouseEvent.CLICK, addRowCol);
		
		remove_top_btt.addEventListener(MouseEvent.CLICK, removeRowCol);
		remove_left_btt.addEventListener(MouseEvent.CLICK, removeRowCol);
		remove_right_btt.addEventListener(MouseEvent.CLICK, removeRowCol);
		remove_bottom_btt.addEventListener(MouseEvent.CLICK, removeRowCol);
		
		getListofMapNames();
		nwarpbtt.addEventListener(MouseEvent.CLICK, newWarpgate);
	}
	private function getListofMapNames():Void {
		var loader:URLLoader = new URLLoader();
		var vrs:URLVariables = new URLVariables();
		vrs.func = "getMapList";
		
		var urlreq:URLRequest = new URLRequest("http://main.local/RPG_MapUpdater.php");
		urlreq.data = vrs;
		urlreq.method = URLRequestMethod.POST;
		loader.addEventListener(Event.COMPLETE, loadedMapList);
		loader.load(urlreq);
	}
	private function loadedMapList(e:Event):Void{
		var results:Array<String> = e.currentTarget.data.split("|");
		results.pop();
		
		var inum:Int = 0;
		for (i in results) {
			var res:Array<String> = i.split("~");
			listofMapNames.addItem({label:res[3], data:res[3]});
		}
		
		refreshGates();
	}
	
	
	private function mapnameRename(e:FocusEvent):Void {
		displayManager.authorName = author_txt.text;
		displayManager.updateMapName(namemap.text);		
	}
	private function tintbgReset(e:FocusEvent=null):Void {
		var tintNum:Int = Std.parseInt(tintnum.text);
		displayManager.updateBgTint(tintNum);
		
		fillcol.setTint(tintNum, 1);
		tintbx.transform.colorTransform = fillcol;
	}
	private function newWarpgate(e:MouseEvent):Void{		
		var w:WarpGate = new WarpGate();
		w.x = 6;
		w.y = 6;
		w.toTownName = "None";
		w.warpLocations = new Array<Point>();
		w.warpInt = displayManager.warpGates.length;
		
		tileManager.newWarpTile(w.warpInt);
		
		displayManager.warpGates.push(w);
		refreshGates();
	}

	private function refreshGates():Void {
		for (s in allToggleWarps) {
			warpHolder.removeChild(s);
		}
		gates = new Array<WarpGateInfos>();
		allToggleWarps = new Array<ToggleButton>();
		
		var selectedWarp:ToggleButton = null;
		var i:Int = 0;
		for(warpobj in displayManager.warpGates){
			var n:WarpGateInfos = new WarpGateInfos();
			n.wname.text = "Warp "+ warpobj.warpInt;
			n.w_r1.text = warpobj.y+""; //MovieClip(root).warpGates[i][0]
			n.w_c1.text = warpobj.x+""; //MovieClip(root).warpGates[i][1]
			n.wlist.dataProvider = listofMapNames;
			n.wlist.selectedIndex = getLabelIndex(warpobj.toTownName);
			n.warpobj = warpobj;
			n.addEventListener(FocusEvent.FOCUS_OUT, warpInfoUpdate);
			
			var tm:ToggleButton = new ToggleButton(n);
			tm.x = 5;
			tm.y = (i * 60) + 30;
			tm.warpobj = warpobj;
			tm.addEventListener(MouseEvent.CLICK, selectWarpGate);
			allToggleWarps.push(tm);
			
			tm.setToggleGroup(allToggleWarps);
			
			if (warpobj == displayManager.warp_selected) {
				selectedWarp = tm;
			}
			
			warpHolder.addChild(tm);
			gates.push(n);
			i++;
		}
		
		if (selectedWarp != null) {
			selectedWarp.toggle(true);
		}		
	}
	
	private function warpInfoUpdate(e:FocusEvent):Void {
		var i:WarpGateInfos = cast(e.currentTarget, WarpGateInfos);
			i.warpobj.y = i.w_r1.text;
			i.warpobj.x = i.w_c1.text;
			i.warpobj.toTownName = i.wlist.selectedItem.label;
	}
	private function getLabelIndex(townName:String):Int {
		var r:Int = 0;
		for (i in 0...listofMapNames.length) {
			if (listofMapNames.getItemAt(i).label.toString() == townName) {
				r = i;
				break;
			}
		}
		return r;
	}
	
	private function selectWarpGate(e:MouseEvent):Void {
		displayManager.warp_selected = e.currentTarget.warpobj;
	}
	
	private function addRowCol(e:MouseEvent):Void {
		var mc:SimpleButton = cast(e.currentTarget, SimpleButton);
		if (mc == add_top_btt) {
			displayManager.addExtraRowsCols(38);
		}else if (mc == add_left_btt) {
			displayManager.addExtraRowsCols(37);
		}else if (mc == add_right_btt) {
			displayManager.addExtraRowsCols(39);
		}else if (mc == add_bottom_btt) {
			displayManager.addExtraRowsCols(40);
		}

	}
	private function removeRowCol(e:MouseEvent):Void {
		var mc:SimpleButton = cast(e.currentTarget, SimpleButton);
		if (mc == remove_top_btt) {
			displayManager.trimmap(38);
		}else if (mc == remove_left_btt) {
			displayManager.trimmap(37);
		}else if (mc == remove_right_btt) {
			displayManager.trimmap(39);
		}else if (mc == remove_bottom_btt) {
			displayManager.trimmap(40);
		}
	}
	
}