package ;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class NewMap_Panel extends NewMap_Panelmc
{
	private var displayManager:DisplayManager;
	public function new() 
	{
		super();
		
		displayManager = DisplayManager.getInstance();
		build_btt.addEventListener(MouseEvent.CLICK, buildMap);
	}
	private function buildMap(e:MouseEvent):Void {
		if (this.namemap.text != "") {
			var r:Int = Std.parseInt(this.rowx.text);
			var c:Int = Std.parseInt(this.columnx.text);
			if (r == 0 || c == 0) {
				addChild(new ErrorMessage("Rows and Columns must not be Zero", 6, 272));
			}else {
				displayManager.rebuildmap(r, c , this.namemap.text);
			}
		}else {
			addChild(new ErrorMessage("Missing map name", 6, 272));
		}
		
	}
	
}






