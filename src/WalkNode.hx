package ;

/**
 * ...
 * @author Nelson
 */
class WalkNode
{
	public var level:Int;
	public var x:Float;
	public var y:Float;
	public var neighbours:Array<WalkNode>;
	public var depth:Int;
	public var allConnectMode:Bool;

	public function new() 
	{
		neighbours = new Array<WalkNode>();
	}
	public function addNeighbour(w:WalkNode):Void {
		neighbours.push(w);
	}
	
}