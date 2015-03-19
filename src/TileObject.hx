package ;
import flash.geom.Point;

/**
 * ...
 * @author Nelson
 */
class TileObject
{
	public var key:Int; 					//tiledic[classname][0] = key;
	public var xoffset:Float;				//tiledic[classname][1] = xoffset
	public var yoffset:Float;				//tiledic[classname][2] = yoffset
	public var sendToGround:Bool;			//tiledic[classname][3] = sendtoGround
	
	public var ani_hasAnimation:Bool;
	public var ani_isNotaLoop:Bool;
	public var ani_afterAnimationTile:Int;
	public var ani_syncTile:Int;
	
	public var totalFrames:Int;				//tiledic[classname][5] = totalframes;
	public var walkType:Int;				//tiledic[classname][6] = WalkType=0/None
	public var extendsStandardTile:Bool;	//tiledic[classname][7] = extends standardtile
	public var width:Float;					//tiledic[classname][8] = width
	public var height:Float;				//tiledic[classname][9] = height
	public var spriteSheet:Array<Dynamic> = new Array<Dynamic>();		//tiledic[classname][10]
	
	public var spr_useSheet:Bool;
	public var spr_startCOORD:Point;
	public var spr_endCOORD:Point;
	public var spr_SheetClass:String;
	public var spr_needToMakeTileDic:Bool;
	
	public var depthPoint:Float;			//tiledic[classname][11] = depthpoint:int=0;
	public var className:String;			//tiledic[classname][12] = classinstanceName
	
	public function new() 
	{
		
	}
	public function setSpriteSheet(useSheet:Bool, startCOORD:Point, endCOORD:Point, spriteSheetClass:String, needtoMakeTileDIC:Bool ):Void {
		spr_useSheet = useSheet;
		spr_startCOORD = startCOORD;
		spr_endCOORD = endCOORD;
		spr_SheetClass = spriteSheetClass;
		spr_needToMakeTileDic = needtoMakeTileDIC;
		
		//tiledic[classname][10][0] = useSheet;
		//tiledic[classname][10][1] = [startCOORD]
		//tiledic[classname][10][2] = [endCOORD]
		//tiledic[classname][10][3] = SpriteSheetCLASS
		//tiledic[classname][10][4] = needtomakeTileDIC?
	}
	public function setAnimationData(hasAnimation:Bool, isNOTaLoop:Bool, afterAnimationTile:Int, syncTile:Int):Void {
		ani_hasAnimation =  hasAnimation;
		ani_isNotaLoop = isNOTaLoop;
		ani_afterAnimationTile = afterAnimationTile;
		ani_syncTile = syncTile;
		//tiledic[classname][4] = [animation,true:NOTLOOP false:isLoop,AfterAnmationTile,syncTile]
		
		//tiledic[classname][4][0] = isAnimationTile 
		//tiledic[classname][4][1] = isNOTaLoop - true:NOTLOOP false:isLoop
		//tiledic[classname][4][2] = afterAnimationTile
		//tiledic[classname][4][3] = syncTile
	}
	
}