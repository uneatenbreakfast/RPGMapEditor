package ;

import fl.data.DataProvider;
import fl.controls.ComboBox;
import fl.motion.Color;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;

class Settings_Panel extends MenuSettings
{
	private var displayManager:DisplayManager;
	private var dp:DataProvider = new DataProvider();
	
	private var fillcol:Color = new Color();
	
	private var warpHolder:ScrollerPane;
	private var allToggleWarps:Array<ToggleButton> = new Array<ToggleButton>();
	private var gates:Array<WarpGateInfos> = new Array<WarpGateInfos>();
	
	public function new() 
	{
		super();
		displayManager = DisplayManager.getInstance();
		
		dp.addItem({label:"none"});
		for(i in displayManager.allMaps){//for (var i in MovieClip(root).gm_maps) {
			dp.addItem({label:i});
		}
		
		namemap.text = displayManager.currentmap;
		rowx.text = displayManager.rows+"";
		columnx.text = displayManager.columns+"";
		tintnum.text = displayManager.fillcolour+"";

		fillcol.setTint(displayManager.fillcolour, 1);
		tintbx.transform.colorTransform = fillcol;
		
		warpHolder = new ScrollerPane(symbo);
		warpHolder.x = 5;
		warpHolder.y = 472;
		addChild(warpHolder);
		
		refreshGates();
		nwarpbtt.addEventListener(MouseEvent.CLICK, newWarpgate);
	}
	private function updatests():Void{//update before closing
		displayManager.fillcolour = Std.parseInt(tintnum.text);
		for (i in gates) {
			// maybe just the objects instead to directly refer to the array of warp information
			
			/*MovieClip(root).warpGates[i][0] = gates[i].w_r1.text
			MovieClip(root).warpGates[i][1] = gates[i].w_c1.text
			MovieClip(root).warpGates[i][2] = gates[i].wlist.selectedItem.label;*/
			i.warpobj.y = i.w_r1.text;
			i.warpobj.x = i.w_c1.text;
			i.warpobj.toTownName = i.wlist.selectedItem.label;			
		}
	}

	private function newWarpgate(e:MouseEvent):Void{
		updatests();
		
		var w:WarpGate = new WarpGate();
		w.x = 6;
		w.y = 6;
		w.toTownName = "None";
		w.warpLocations = new Array<Point>();
		w.warpInt = displayManager.warpGates.length;
		
		//MovieClip(root).warpGates.push([6,6,"none",[0]])
		//MovieClip(root).warpGates[MovieClip(root).warpGates.length-1][3]=[];
		//MovieClip(root).warptlist.addItem({label:MovieClip(root).warpGates.length-1})
		displayManager.warpGates.push(w);
		refreshGates();
	}

	private function refreshGates():Void {
		for (s in allToggleWarps) {
			warpHolder.removeChild(s);
		}
		gates = new Array<WarpGateInfos>();
		allToggleWarps = new Array<ToggleButton>();
		
		var i:Int = 0;
		for(warpobj in displayManager.warpGates){
			var n:WarpGateInfos = new WarpGateInfos();
			n.wname.text = "Warp "+ warpobj.warpInt;
			n.w_r1.text = warpobj.y+""; //MovieClip(root).warpGates[i][0]
			n.w_c1.text = warpobj.x+""; //MovieClip(root).warpGates[i][1]
			n.wlist.dataProvider = dp;
			//n.wlist.selectedIndex = findItemIndex(n.wlist, warpobj.toTownName);// MovieClip(root).warpGates[i][2])
			n.warpobj = warpobj;
			
			var tm:ToggleButton = new ToggleButton(n);
			tm.x = 5;
			tm.y = (i * 60) + 30;
			
			allToggleWarps.push(tm);
			
			tm.setToggleGroup(allToggleWarps);
			
			warpHolder.addChild(tm);
			gates.push(n);
			i++;
		}
	}
	private function findItemIndex (element:ComboBox, dataString:String):Int {
		var index:Int = 0;
		for (i in 0...element.length) {
			if (element.getItemAt(i).label.toString() == dataString) {
				index = i;
				break;
			}
			else {
			}
		}
		return index;
	}
	
}