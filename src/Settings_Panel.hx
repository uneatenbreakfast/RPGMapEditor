package ;

import fl.data.DataProvider
import fl.controls.ComboBox;
import fl.motion.Color;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;

class Settings_Panel extends MenuSettings
{
	private var displayManager:DisplayManager;
	private var dp:DataProvider = new DataProvider();
	private var gates:Array<WarpGateInfos> = new Array<WarpGateInfos>();
	private var fillcol:Color = new Color();
	
	
	public function new() 
	{
		super();
		displayManager = DisplayManager.getInstance();
		
		dp.addItem({label:"none"});
		for(i in displayManager.allMaps){//for (var i in MovieClip(root).gm_maps) {
			dp.addItem({label:i});
		}
		
		rowx.text = displayManager.rows;
		columnx.text = displayManager.columns;
		tintnum.text = displayManager.fillcolour;

		fillcol.setTint(displayManager.fillcolour, 1);
		tintbx.transform.colorTransform = fillcol;
		
		showExistingGates();
		nwarpbtt.addEventListener(MouseEvent.CLICK, newWarpgate);
	}
	private function updatests():Void{//update before closing
		displayManager.fillcolour = tintnum.text;
		for (i in gates) {
			// maybe just the objects instead to directly refer to the array of warp information
			
			MovieClip(root).warpGates[i][0] = gates[i].w_r1.text
			MovieClip(root).warpGates[i][1] = gates[i].w_c1.text
			MovieClip(root).warpGates[i][2] = gates[i].wlist.selectedItem.label;
		}
	}

	private function newWarpgate(e:MouseEvent):Void{
		updatests();
		
		var w:WarpGate = new WarpGate();
		w.x = 6;
		w.y = 6;
		w.toTownName = "None";
		w.warpLocations = new Array<Point>();
		
		//MovieClip(root).warpGates.push([6,6,"none",[0]])
		//MovieClip(root).warpGates[MovieClip(root).warpGates.length-1][3]=[];
		showExistingGates()
		//MovieClip(root).warptlist.addItem({label:MovieClip(root).warpGates.length-1})
		displayManager.warptlist.addItem({label:displayManager.warpGates.length-1})
	}

	private function showExistingGates():Void {
		var i:Int = 0;
		for(warpobj in displayManager.warpGates){
			var n:WarpGateInfos = new WarpGateInfos();
			n.x = 5
			n.y = -85+(i * 30);
			n.wname.text = "Warp "+i;
			n.w_r1.text = warpobj.y; //MovieClip(root).warpGates[i][0]
			n.w_c1.text = warpobj.x; //MovieClip(root).warpGates[i][1]
			n.wlist.dataProvider = dp;
			n.wlist.selectedIndex = findItemIndex(n.wlist, warpobj.toTownName);// MovieClip(root).warpGates[i][2])
			addChild(n);
			gates[i] = n;
			
			i++;
		}
	}
	private function findItemIndex (element:ComboBox, dataString:String):Int {
		var index:int = 0;
		for (var i = 0; i < element.length; i++) {
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