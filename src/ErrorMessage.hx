package ;

import com.greensock.TweenLite;

class ErrorMessage extends ErrorMessage_mc
{

	public function new(msg:String, xx:Int, yy:Int) 
	{
		super();
		
		this.x = xx;
		this.y = yy;
		this.txt.text = msg;
		
		var n:ErrorMessage = this;
		
		TweenLite.to( this, 3.0, { alpha:0, delay:3, onComplete: function() {
				n.parent.removeChild(n);
			}} );
	}
	
}