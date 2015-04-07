package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import com.greensock.TweenLite;

class ScrollerPane extends Sprite
{
	private var masker_mc:Sprite;
	private var doneSetUp:Bool = false;
	
	private var upperLimit:Int;
	private var lowerLimit:Int;
	private var scrollBar:Sprite;
	
	private var scrollDist:Int;
	private var prevHeight:Float;
	
	public function new(masker:Sprite) 
	{
		super();
		
		this.mask = masker;
		masker_mc = masker;
		
		addEventListener(MouseEvent.MOUSE_WHEEL, mwheel);
	}

	private function mwheel(e:MouseEvent):Void {
		if (!doneSetUp || (height != prevHeight)) {
			setUp();
		}
		
		if (height < masker_mc.height) {
			return;
		}
		
		TweenLite.to(scrollBar, .1, { alpha: .8 } );
		
		var delta:Int = e.delta;
		if (delta < 0) {
			// scroll up
			TweenLite.to(this, .2, { y: limitCap(y-30), onComplete: killScroll} );
		}else {
			TweenLite.to(this, .2, { y: limitCap(y+30), onComplete: killScroll} );
		}
	}
	
	private function killScroll():Void {
		TweenLite.to(scrollBar, .5, { delay: 1 , alpha: 0 } );
	}
	private function setUp():Void {
		doneSetUp = true;
		prevHeight = this.height;
		
		upperLimit = Std.int((masker_mc.y + masker_mc.height) - this.height);
		lowerLimit = Std.int(masker_mc.y);
		
		if (scrollBar != null) {
			if (this.contains(scrollBar)) {
				removeChild(scrollBar);
			}
		}
		
		scrollBar = new Sprite();
		scrollBar.x = masker_mc.width - 20;
		scrollBar.alpha = 0;
		scrollBar.graphics.beginFill(0x666666, 1);
		var pcheight:Float = (masker_mc.height / this.height) * masker_mc.height;
		scrollBar.graphics.drawRoundRect(0, 0, 10, pcheight, 10, 10);
		addChild(scrollBar);
		
		scrollDist = Std.int(masker_mc.height - pcheight);
		addEventListener(Event.ENTER_FRAME, scrollWatch);
	}
	
	private function limitCap(i:Float):Float {
		var r:Float = i;
		if (i < upperLimit) {
			r = upperLimit;
		}else if (i > lowerLimit) {
			r = lowerLimit;			
		}		
		return r;
	}
	
	private function scrollWatch(e:Event):Void {
		var pc:Float = (1-(this.y - upperLimit) / (lowerLimit - upperLimit)) * scrollDist;
		scrollBar.y = (lowerLimit-this.y)+pc;
	}
}