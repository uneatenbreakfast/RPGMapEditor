package ;

/**
 * ...
 * @author Nelson
 */
class Func
{

	public function new() 
	{
		
	}
	
	public static function isiteminarray (arrayx:Array<Dynamic>, item:Dynamic):Bool {
		var r:Bool = false;
		for (z in arrayx) {
			if (z == item) {
				r = true;
				break;
			} 
		}
		return r;
	}
	
	public static function randInt(maxNum:Int):Int {
		return Std.int(Math.random() * maxNum);
	}
}