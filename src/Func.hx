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
		for (z in 0...arrayx.length) {
			if (arrayx[z] == item) {
				r = true;
				break;
			} else if (z == arrayx.length-1) {
				r = false;
				break;
			}
		}
		return r;
	}
}