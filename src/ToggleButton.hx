package ;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
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
	private var toggleGroup:Array<ToggleButton>;
	private var mmc:MovieClip;
	
	public var valueInt:Int;
	
	
	public function new(mc:MovieClip) 
	{
		super();
		
		addChild(mc);
		this.buttonMode = true;
		hitBG = mc.hit;
		icon = mc.icon;
		mmc = mc;
		
		toggle(isSelected);
		this.addEventListener(MouseEvent.CLICK, mclick);
		this.addEventListener(MouseEvent.MOUSE_OVER, mover);
		this.addEventListener(MouseEvent.MOUSE_OUT, mout);
	}
	public function toggle(switchOn:Bool, byPassGroupCheck:Bool=false):Void {
		if (toggleGroup != null && !byPassGroupCheck) {
			if (!switchOn) {
				return;
			}
			closeOthers();
		}
		
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
	private function mover(e:MouseEvent) {
		if (!isSelected) {
			hitBG.alpha = .5;
		}
	}
	private function mout(e:MouseEvent) {
		if (!isSelected) {
			hitBG.alpha = .1;
		}
	}
	public function setToggleGroup(tg:Array<ToggleButton>):Void {
		toggleGroup = tg;
	}
	
	public function scrubCoord():Void {
		mmc.x = mmc.y = 0;
	}
	private function closeOthers():Void {
		for (i in toggleGroup) {
			if (i != this) {
				i.toggle(false, true);
			}
		}
	}
}