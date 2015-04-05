package ;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;

/**
 * ...
 * @author Nelson
 */
class ToggleButton extends MovieClip
{
	public var isSelected:Bool = false;
	
	private var icon:MovieClip;
	private var hitBG:MovieClip;
	
	public function new(mc:MovieClip) 
	{
		super();
		
		addChild(mc);
		this.buttonMode = true;
		hitBG = mc.hit;
		icon = mc.icon;
		
		toggle(isSelected);
		this.addEventListener(MouseEvent.CLICK, mclick);
	}
	public function toggle(switchOn:Bool):Void {
		isSelected = switchOn;
		if (switchOn) {
			hitBG.alpha = 1;
		}else {
			hitBG.alpha = 0.1;
		}
	}
	private function mclick(e:MouseEvent) {
		toggle(!isSelected);
	}
	
}