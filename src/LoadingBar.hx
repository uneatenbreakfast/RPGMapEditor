package ;

import flash.events.Event;
import flash.display.MovieClip;

class LoadingBar extends Loadingbar_mc
{
	private var w:Int		= 0;
	private var n:Int   	= 0;
	private var nwid:Int 	= 4;
	private var cur:Int  	= 0;
	private var mc:MovieClip;

	public function new() 
	{
		super();
		
		w = Std.int(this.width);
		mc = new MovieClip();
		mc.mask = coverclip;
		addChild(mc);

		addEventListener(Event.ENTER_FRAME, ee);
		
	}
	private function ee(e:Event):Void{
		if(++cur % 3 != 0){
			return;
		}
		
		if(n * nwid < w){
			var lb:Loadingblock_mc = new Loadingblock_mc();
			lb.x = n * 4;
			lb.y = 5;
			mc.addChild(lb);
			n++;
		}else{
			removeEventListener(Event.ENTER_FRAME, ee);
		}
		
		
	}
	
}