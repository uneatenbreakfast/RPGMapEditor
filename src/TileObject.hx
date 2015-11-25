package ;
import flash.geom.Point;
import flash.utils.Object;
import haxe.remoting.AMFConnection.registerClassAlias;
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
	public var className:String;	
	
	public var isWalkable:Bool;				//tiledic[classname][12][0] 
	public var isSpecialWalkType:Bool;		//tiledic[classname][12][1] 
	public var walkGLevel:Int;				//tiledic[classname][12][2] = WalkType=0/None
	public var walkNode_L:Array<Int>;		//tiledic[classname][12][3]
	public var walkNode_M:Array<Int>;		//tiledic[classname][12][4]
	public var walkNode_R:Array<Int>;		//tiledic[classname][12][5]
	
	
	
	public function new() 
	{
		registerClassAlias("TileObject", TileObject);
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
	
	public static function makeTileObject(ob:Object):TileObject {
		
		var t:TileObject = new TileObject();
		t.key = ob.key;
		t.xoffset = ob.xoffset;
		t.yoffset = ob.yoffset;
		t.sendToGround = ob.sendToGround;
		
		t.ani_hasAnimation = ob.ani_hasAnimation;
		t.ani_isNotaLoop = ob.ani_isNotaLoop;
		t.ani_afterAnimationTile = ob.ani_afterAnimationTile;
		t.ani_syncTile = ob.ani_syncTile;
		
		t.totalFrames = ob.totalFrames;
		t.isWalkable = ob.isWalkable;
		t.isSpecialWalkType = ob.isSpecialWalkType;
		t.walkGLevel = ob.walkGLevel;
		t.walkNode_L = ob.walkNode_L;
		t.walkNode_M = ob.walkNode_M;
		t.walkNode_R = ob.walkNode_R;
		
		t.extendsStandardTile = ob.extendsStandardTile;
		t.width = ob.width;
		t.height = ob.height;
		t.spriteSheet = ob.spriteSheet;
			
		t.spr_useSheet = ob.spr_useSheet;
		t.spr_startCOORD = ob.spr_startCOORD;
		t.spr_endCOORD = ob.spr_endCOORD;
		t.spr_SheetClass = ob.spr_SheetClass;
		t.spr_needToMakeTileDic = ob.spr_needToMakeTileDic;
			
		t.depthPoint = ob.depthPoint;
		t.className = ob.className;
		
		return t;
	}
	
}