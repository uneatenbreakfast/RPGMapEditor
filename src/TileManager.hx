package ;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Object;
import com.efnx.FpsBox;
import flash.display.Bitmap;
import flash.display.BitmapData;
import fl.motion.Color;
import flash.geom.ColorTransform;
import flash.filters.*;
import admin.MyLoader;
import Maps;
import flash.system.Worker;
import flash.system.WorkerDomain;

class TileManager extends Sprite
{
	public inline static var tileHeight = 50;
	public inline static var tileWidth = 50;
	
	private var stageManager:Main;
	private var displayManager:DisplayManager;
	public static var thisManager:TileManager;
	//
	//private var spriteSheetSprites:Array<Dynamic> = new Array<Dynamic>();
	public var spriteSheetSprites:Map<String, BitmapData> = new Map<String, BitmapData>();
	//
	private var pressKeys:Object = {};

	
	private var activelayer:Int = 0;
	//private var activelaybut:MovieClip = bg0;
	private var tileDisplay:Array<Dynamic> = new Array<Dynamic>();
	private var prePlace:String = "";
	private var placer:Sprite = new Sprite();

	private var cam_point:Point = new Point(0,0);
	private var lastviewpoint:Point = new Point(0, 0);

	private var mySpriteSheet:ShowSpriteSheets;
	//
	public var tilebitdata:Map<Int, BitmapData> = new Map<Int, BitmapData>();//tilebitdata[key] = BitmapData
	public var tilenum:Map<Int, TileObject> = new Map<Int, TileObject>();//tilenum[key] = [class/string,xoffset,yoffset,sendtoGround,[animation,nonLoop],]
	public var tiledic:Map<String, TileObject> = new Map<String,  TileObject>();

	public var spriteSheets:Array<String> = new Array<String>(); //spriteSheets.push("tl_grasslands")
	//public var tilesets:Array<Dynamic> = new Array<Dynamic>();
	public var tilesetArr:Array<Dynamic> = new Array<Dynamic>();
	private var spriteSheetWalkables:Array<Dynamic> = new Array<Dynamic>();
	public var tilesets:Map<String, Array<Int>>;
	
	public var partofSheet:Array<Int> = new Array<Int>();
	public var looseTiles:Array<Int> = new Array<Int>();
	
	private var largerthanView:Array<Dynamic> = [];
	private var saveBusy:Bool = false;
	
	// LOAD THE TILESET
	private var TileSetL:MyLoader;
	// LOAD THE TILESET

	public function new() :Void
	{			
		super();
		displayManager = DisplayManager.getInstance();
	}		
	public static function getInstance():TileManager {
		if (thisManager == null) {
			thisManager = new TileManager();
		}
		return thisManager;
	}
	
	public function init():Void {
		// load the SWF file
		var req4:URLRequest = new URLRequest("TileSets.swf");
		TileSetL = new MyLoader(req4, "TileSet");
		TileSetL.addEventListener("LoadDone", Engine); // Once loaded; initiate the bitmap creation Engine
	}

	
	private function Engine(evC:Event):Void {
		//for (i in Maps.gm_maps) {
			//gm_maps[i] = Maps.gm_maps[i];
		//}

		//tiledic = MovieClip(TileSetL.loader.content).tiledic;
		//spriteSheetWalkables = MovieClip(TileSetL.loader.content).spriteSheetWalkables;
		//spriteSheets = MovieClip(TileSetL.loader.content).spriteSheets;		
		
		 // create the background worker
		 /*
	   var workerBytes:MovieClip = TileSetL.loader.content;
	   var bgWorker:Worker = WorkerDomain.current.createWorker(workerBytes);
	   bgWorker.addEventListener(Event.WORKER_STATE, function() { trace("HI"); } );
	   bgWorker.start();
	   */
	   
		
		var tileMovieClip:MovieClip = cast(TileSetL.loader.content , MovieClip);		
		var tileDicArr:Array<Dynamic> = cast (tileMovieClip.tiledic, Array<Dynamic> );
		var tileKeysArr:Array<Dynamic> = cast (tileMovieClip.tileKeysArr, Array<Dynamic> );
		
		// Tilesets
		var tilesetsDic = cast (tileMovieClip.tilesets, Array<Dynamic> );
		tilesetArr = cast (tileMovieClip.tilesetArr, Array<Dynamic> );
		tilesets = new Map<String, Array<Int>>();
		for (i in tilesetArr) {
			tilesets.set(i, tilesetsDic[i] );
		}
				
		// create the tiledic in Map for Haxe
		for (i in tileKeysArr) {
			var t:TileObject = new TileObject();
			//tiledic[i] = tileDicArr[i];
			tiledic[i] = t;
			
			t.key 					= tileDicArr[i][0];
			t.xoffset 				= tileDicArr[i][1];
			t.yoffset				= tileDicArr[i][2];
			t.sendToGround			= tileDicArr[i][3];
			
			t.setAnimationData(tileDicArr[i][4][0], tileDicArr[i][4][1], tileDicArr[i][4][2], tileDicArr[i][4][3]);
			t.totalFrames			= tileDicArr[i][5];
			t.walkType				= tileDicArr[i][6];
			t.extendsStandardTile	= tileDicArr[i][7];
			t.width					= tileDicArr[i][8];
			t.height				= tileDicArr[i][9];
			
			t.depthPoint			= tileDicArr[i][11];	
			t.className 			= i;
		
			
			t.setSpriteSheet(tileDicArr[i][10][0], new Point(), new Point(), "", false);
			if (t.spr_useSheet) {
				t.setSpriteSheet(true, new Point(tileDicArr[i][10][1][0], tileDicArr[i][10][1][1]), new Point(tileDicArr[i][10][2][0], tileDicArr[i][10][2][1]), tileDicArr[i][10][3], tileDicArr[i][10][4]);
			}
		}
				
		var spritesheettilesMade:Array<TileObject> = new Array<TileObject>();
		
		
		//tiledic[classname][0] = key;
		//tiledic[classname][1] = xoffset
		//tiledic[classname][2] = yoffset
		//tiledic[classname][3] = sendtoGround
		//tiledic[classname][4] = [animation,true:NOTLOOP false:isLoop,AfterAnmationTile,syncTile]
		//tiledic[classname][5] = totalframes
		//tiledic[classname][6] = WalkType=0/None
		//tiledic[classname][7] = extends standardtile
		//tiledic[classname][8] = width
		//tiledic[classname][9] = height
		//tiledic[classname][10][0] = useSheet;
		//tiledic[classname][10][1] = [startCOORD]
		//tiledic[classname][10][2] = [endCOORD]
		//tiledic[classname][10][3] = SpriteSheetCLASS
		//tiledic[classname][10][4] = needtomakeTileDIC?
		//tiledic[classname][11] = depthpoint:int=0;
		//tiledic[classname][12] = classinstanceName
		
		for (tileRow in tiledic) {//used to be et
			if (tileRow.spr_useSheet) { //if (tileRow[10][0]) {
				if(!tileRow.spr_needToMakeTileDic){ //if (!tileRow[10][4]) {
					// uses SpriteSheet
					var num:Int = tileRow.key;//  tileRow[0];
					var sheetrows:Int = Std.int(tileRow.height); //tileRow[9]; 
					var sheetcols:Int = Std.int(tileRow.width); // tileRow[8];
					var sendtoBack:Bool = tileRow.sendToGround; //  tileRow[3];
					var depthadd:Int = Std.int(tileRow.depthPoint); // tileRow[11];
					var className:String = tileRow.className;	// tileRow[12];
					
					spriteSheets.push(className);
										
					var spname:String = className;
					if(spriteSheetSprites[spname] == null){
						//spriteSheetSprites[spname] = [];

						var cF = Type.resolveClass(className);						
						var tie = Type.createEmptyInstance(cF);
						spriteSheetSprites[spname] = new BitmapData(sheetcols * 50, sheetrows * 50, true, 0x000000);
						var mtx:Matrix = new Matrix();

						spriteSheetSprites[spname].draw(tie,mtx);
					}				
					//trace("--",num);
					for (rrs in 0...sheetrows) {
						for (clms in 0...sheetcols) {
							//trace("paint",num,et);
							
							var _walktype:Int = 0;
						
							if(spriteSheetWalkables[num]){
								_walktype = spriteSheetWalkables[num];
							}
							
							//tiledic["SpriteSheet" + num] = [num, 0, 0, sendtoBack, [false, false], 0, _walktype, false, 0, 0, [true, [clms, rrs], [clms, rrs], et, true], depthadd];
							var t:TileObject = new TileObject();
							t.key = num;
							t.xoffset = 0;
							t.yoffset = 0;
							t.sendToGround = sendtoBack;
							t.setAnimationData(false, false, 0,0);
							t.totalFrames = 0;
							t.walkType = _walktype;
							t.extendsStandardTile = false;
							t.width = 0;
							t.height = 0;
							t.setSpriteSheet(true,new Point(clms, rrs), new Point(clms, rrs), tileRow.className, true);
							t.depthPoint = depthadd;
							t.className = "SpriteSheet" + num;
							//tiledic["SpriteSheet" + num] = t;
							
							partofSheet.push(num);
							//spritesheettilesMade.push(["SpriteSheet" + num, [num, 0, 0, sendtoBack, [false, false], 0, _walktype, false, 0, 0, [true, [clms, rrs], [clms, rrs], className, true], depthadd] ]);
							spritesheettilesMade.push(t);
							num++;
						}
					}
				//
				}
			}else {
				// does not use sprite sheet - is a loose tile
				looseTiles.push(tileRow.key);
			}			
		}
		// now add the spritesheet tiles
		//for(spr in 0...spritesheettilesMade.length){
		for(spr in spritesheettilesMade){
			//var m:Array<Dynamic> = spritesheettilesMade[spr];
			//tiledic[m[0]] = m[1];
			tiledic[spr.className] = spr;
		}

		//------

		var rect:Dynamic = {}
		for (e in tiledic) {
			setTileProps(e.className, rect);
		}
		
		//
		displayManager.turnOn();
	}
	
	
	

	private function setTileProps(e:String, rect:Object):Void{
		var key:Int = tiledic[e].key;
		
		tilenum[key] = tiledic[e];
		var tob:TileObject = tilenum[key];
		
		//tob.key = key;
		//tob.className = e;
		//tob.sendToGround = tiledic[e][3];
		//tob.setAnimationData(tiledic[e][4][0], tiledic[e][4][1], tiledic[e][4][2], tiledic[e][4][2]);
		tob.totalFrames = 1;		
		/*tilenum[key][0] = e;
		tilenum[key][3] = tiledic[e][3];//sendtoGround
		tilenum[key][4] = new Array<Dynamic>();
		tilenum[key][4][0] = tiledic[e][4][0];//Animation
		tilenum[key][4][1] = tiledic[e][4][1];//nonLoop
		tilenum[key][4][2] = tiledic[e][4][2];//nonLoop
		tilenum[key][5] = 1;//totalframes
		*/
		//
		
		
		if(!tob.spr_useSheet){//if (!tiledic[e][10][0]) {
			// does not use SpriteSheets
			
			var classX = Type.resolveClass(e);
			var ti = Type.createEmptyInstance(classX);
			rect = ti.getBounds(this);
			
			tob.xoffset = ti.x - rect.x;
			tob.yoffset = ti.y-rect.y;
			//tilenum[key][1] = ti.x-rect.x;//xoffset
			//tilenum[key][2] = ti.y-rect.y;//yoffset
			
			tilebitdata[key] = new BitmapData(ti.width,ti.height,true,0x000000);
			var mtx:Matrix = new Matrix();
			//mtx.tx = tilenum[key][1];
			//mtx.ty = tilenum[key][2];
			mtx.tx = tob.xoffset;
			mtx.ty = tob.yoffset;
			tilebitdata[key].draw(cast(ti, MovieClip), mtx);
			
			//totalFrames
			if(tob.ani_hasAnimation){//if (tiledic[e][4][0]) {
				tob.totalFrames = ti.totalFrames; //tiledic[e][5] = ti.totalFrames;
				//tilenum[key][5] = ti.totalFrames;
				for (o in 1...ti.totalFrames) {
					ti.gotoAndStop(o);
					
					var aniKey:Int = Std.parseInt(key + "000" + o); //key+"_"+o
					
					tilebitdata[aniKey] = new BitmapData(ti.width,ti.height,true,0x000000);
					tilebitdata[aniKey].draw(cast(ti, MovieClip),mtx);
				}
			}
			
			//tiledic[e][8] = ti.width;
			//tiledic[e][9] = ti.height;
			tob.width = ti.width;
			tob.height = ti.height;
		}else{
			//DOES use spriteSheet
			var cl = Type.resolveClass(tob.spr_SheetClass); //var cl = Type.resolveClass(tiledic[e][10][3]);
			var tie = Type.createEmptyInstance(cl);
			
			tob.xoffset = 0;
			tob.yoffset = 0;
			//tilenum[key][1] = 0;
			//tilenum[key][2] = 0;
			
			//var wid:Int = ((tiledic[e][10][2][0]-tiledic[e][10][1][0])+1)* tileWidth;
			//var hei:Int = ((tiledic[e][10][2][1]-tiledic[e][10][1][1])+1)* tileHeight;
			var wid:Int = Std.int(((tob.spr_endCOORD.x - tob.spr_startCOORD.x)+1)* tileWidth);
			var hei:Int = Std.int(((tob.spr_endCOORD.y - tob.spr_startCOORD.y)+1)* tileHeight);
			
			tilebitdata[key] = new BitmapData(wid,hei,true,0x000000);
			var mtxe:Matrix = new Matrix();
			//mtxe.tx = -tiledic[e][10][1][0]* tileWidth;
			//mtxe.ty = -tiledic[e][10][1][1]* tileHeight;
			mtxe.tx = -tob.spr_startCOORD.x * tileWidth;
			mtxe.ty = -tob.spr_startCOORD.y * tileHeight;
			tilebitdata[key].draw(tie,mtxe);	
		}
		
		/*
		tilenum[key][6] = tiledic[e][6];//walkType
		tilenum[key][7] = tiledic[e][7];//Extends standardTile
		tilenum[key][8] = tiledic[e][8];//width
		tilenum[key][9] = tiledic[e][9];//height
		tilenum[key][10] = tiledic[e][11];//depthpoint:Int
		*/
	}	
}