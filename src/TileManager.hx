package ;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.errors.Error;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import flash.Lib;

import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.MessageChannel;
import flash.utils.ByteArray;
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
import haxe.remoting.AMFConnection.registerClassAlias;

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
	//public var tilesetArr:Array<Dynamic> = new Array<Dynamic>();
	private var spriteSheetWalkables:Array<Dynamic> = new Array<Dynamic>();
	public var tilesets:Map<String, Array<Int>>;
	
	public var partofSheet:Array<Int> = new Array<Int>();
	public var looseTiles:Array<Int> = new Array<Int>();
	
	private var largerthanView:Array<Dynamic> = [];
	private var saveBusy:Bool = false;
	
	// LOAD THE TILESET
	private var TileSetL:MyLoader;
	private var emptyWorkerSwf:MyLoader;
	// LOAD THE TILESET
	
	
	// Concurrency
	private var bm:MessageChannel;
	private var mb:MessageChannel;
	private var imageBytes:ByteArray;
	
	private var con_key:Dynamic;
	private var con_Mode:String = null;
	
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
		registerClassAlias("TileObject", TileObject);
		registerClassAlias("Point", Point);
		registerClassAlias("BitmapData", BitmapData);
		
		if (Worker.current.isPrimordial) {
			
			var req4:URLRequest = new URLRequest("TileSets.swf");
			TileSetL = new MyLoader(req4, "TileSet");
			TileSetL.addEventListener("LoadDone", Engine); // Once loaded; initiate the bitmap creation Engine			
		}else {
			// This this the background worker thread - Don't load the tileset files
			// Do the worker thread stuff
			trace("Started [BACK THREAD] supposably  : Thread 2 of 2");		
			
			// main sends messages to this worker
			mb = Worker.current.getSharedProperty("mtb");
			mb.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			
			// this bg worker sending msg back to main
			bm = Worker.current.getSharedProperty("btm");
			//bm.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain);
			
			imageBytes = Worker.current.getSharedProperty("imageBytes");
			
			bm.send("init");
		}
	}
	private function Engine(evC:Event):Void {
		// Only the MAIN thread gets here, the worker thread doesn't
		
		// create the background worker
		var worker:Worker = WorkerDomain.current.createWorker(Lib.current.loaderInfo.bytes);
		bm = worker.createMessageChannel(Worker.current);
		mb = Worker.current.createMessageChannel(worker);
		
		bm.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain);
		
		worker.setSharedProperty("mtb", mb);
		worker.setSharedProperty("btm", bm);
		
		imageBytes = new ByteArray();
		imageBytes.shareable = true;
		worker.setSharedProperty("imageBytes", imageBytes);
				
		worker.start();
		trace("Started [MAIN Thread] : Thread 1 of 2");
		// concurrency END
		
		// Get the tileset objects list
		// since it's just an array, we don't need to do any heavy processing to retrieve it so no need for concurrency
		var tileMovieClip:MovieClip = cast(evC.target.loader.content , MovieClip);
		
		var tilesetsDic = cast (tileMovieClip.tilesets, Array<Dynamic> );
		var tilesetArr = cast (tileMovieClip.tilesetArr, Array<Dynamic> );
		tilesets = new Map<String, Array<Int>>();
		for (i in tilesetArr) {
			tilesets.set(i, tilesetsDic[i] );
		}
		
		//
	}
	
	// concurrency
	private function onBackToMain(e:Event):Void {
		//trace(Worker.current.isPrimordial, "[BACK TO MAIN] received message from [BACK THREAD]");	
		var firstMessageHeader:Dynamic = bm.receive();
		
		if (con_Mode == null) {
			switch(firstMessageHeader) {
				case "start_spriteSheets":
					con_Mode = "start_spriteSheets";
				
				case "Start_TileProcessing":
					con_Mode = "Start_TileProcessing";
					
				case "start_tilebitdata":
					con_Mode = "start_tilebitdata";
					
				case "start_partofSheet":
					con_Mode = "start_partofSheet";
					
				case "start_looseTiles":
					con_Mode = "start_looseTiles";
					
				case "start_spriteSheetSprites":
					con_Mode = "start_spriteSheetSprites";
					
				case "init":
					// thread is ready to work
					trace("Worker thread ready, initializing");
					var mv:MovieClip = cast(TileSetL.loader.content , MovieClip);
					mb.send( TileSetL.loader.contentLoaderInfo.bytes );		
			}
		}else {
			if (firstMessageHeader == "Done_TileProcessing") {
				trace("[ DONE CONCURRENT TILE PROCESSING (1/5) ]");
				con_Mode = null;
				return;
			}else if (firstMessageHeader == "stop_spriteSheets") {
				trace("[ DONE CONCURRENT - Spritesheets (2/5) ]");
				con_Mode = null;
				return;
			}else if (firstMessageHeader == "stop_partofSheet") {
				trace("[ DONE CONCURRENT - partofsheet (4/5) ]");
				con_Mode = null;
				return;
			}else if (firstMessageHeader == "stop_tilebitdata") {
				trace("[ DONE CONCURRENT - tilebitdata (3/5) ]");
				con_Mode = null;
				return;
			}else if (firstMessageHeader == "stop_looseTiles") {
				trace("[ DONE CONCURRENT - looseTiles (5/5) ]");
				con_Mode = null;
				return;
			}
			else if (firstMessageHeader == "stop_spriteSheetSprites") {
				trace("[ DONE CONCURRENT - spriteSheetSprites (6/6) ]");
				//
				displayManager.turnOn();	
				//
				con_Mode = null;
				return;
			}
			
			switch(con_Mode) {
				case "start_spriteSheets":
					//-------
					spriteSheets.push(firstMessageHeader);
					//-------
				case "Start_TileProcessing":
					//-------
					if (con_key == null) {
						con_key = firstMessageHeader;
					}else {
						var b:ByteArray = firstMessageHeader;					
						var t:TileObject = TileObject.makeTileObject( b.readObject());
						b.position = 0;
						
						tiledic.set(con_key, t);
						con_key = null;
						
						var key:Int = t.key;
						tilenum[key] = t;
					}
					//-------
				case "start_tilebitdata":
					//-------
					if (con_key == null) {
						con_key = firstMessageHeader;
					}else {
						var width:Int = firstMessageHeader;
						var height:Int = bm.receive();
						var b:ByteArray = bm.receive();
						b.position = 0;
						
						
						var bb:BitmapData = new BitmapData(width, height);
						bb.setPixels(new Rectangle(0, 0, width, height), b);
						
						tilebitdata.set(cast(con_key, Int), bb);												
						con_key = null;
					}
					//-------	
				case "start_partofSheet":
					//-------
					partofSheet.push(firstMessageHeader);
					//-------		
				case "start_looseTiles":
					//-------
					looseTiles.push(firstMessageHeader);
					//-------	
				case "start_spriteSheetSprites":
					//-------
					if (con_key == null) {
						con_key = firstMessageHeader;
					}else {
						var width:Int = firstMessageHeader;
						var height:Int = bm.receive();
						var b:ByteArray = bm.receive();
						b.position = 0;
						
						var bb:BitmapData = new BitmapData(width, height);
						bb.setPixels(new Rectangle(0, 0, width, height), b);
						
						spriteSheetSprites.set(cast(con_key, String), bb);	
						
						trace("Setting", con_key, bb);
						
						con_key = null;
					}
					//-------	
				case "init":
					// thread is ready to work
					trace("Worker thread ready, initializing");
					var mv:MovieClip = cast(TileSetL.loader.content , MovieClip);
					mb.send( TileSetL.loader.contentLoaderInfo.bytes );		
					
			}
		}
	} 
	private function onMainToBack(e:Event):Void {
		if(mb.messageAvailable){
			trace(Worker.current.isPrimordial, "is false || [MAIN TO BACK]received message from [MAIN THREAD]");
			
			var AD:ApplicationDomain = ApplicationDomain.currentDomain;
			var context:LoaderContext = new LoaderContext( false, AD );

			var lb:Loader = new Loader();
			lb.contentLoaderInfo.addEventListener (Event.COMPLETE, loadedBytes);
			lb.loadBytes(mb.receive(), context);
		}
	} 
	private function loadedBytes(e:Event):Void {
		loadAssets( cast(e.target.content , MovieClip)    );
	}
	
	// end concurrency
	
	private function loadAssets(tilsetmc:MovieClip):Void {		
		var tileMovieClip:MovieClip = tilsetmc;// cast(TileSetL.loader.content , MovieClip);		
		var tileDicArr:Array<Dynamic> = cast (tileMovieClip.tiledic, Array<Dynamic> );
		var tileKeysArr:Array<Dynamic> = cast (tileMovieClip.tileKeysArr, Array<Dynamic> );
		spriteSheetWalkables = cast (tileMovieClip.spriteSheetWalkables, Array<Dynamic> );
				
					
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
	
			t.extendsStandardTile	= tileDicArr[i][7];
			t.width					= tileDicArr[i][8];
			t.height				= tileDicArr[i][9];
			
			t.depthPoint			= tileDicArr[i][11];	
			t.className 			= i;
			
			t.isWalkable			= tileDicArr[i][12][0];
			if (t.isWalkable) {				
				t.isSpecialWalkType		= tileDicArr[i][12][1];
				t.walkGLevel			= tileDicArr[i][12][2];
				t.walkNode_L			= tileDicArr[i][12][3];
				t.walkNode_M			= tileDicArr[i][12][4];
				t.walkNode_R			= tileDicArr[i][12][5];			
			}		
		
			
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
		//tiledic[classname][6] = FREE TO REPLACE
		//tiledic[classname][7] = extends standardtile
		//tiledic[classname][8] = width
		//tiledic[classname][9] = height
		//tiledic[classname][10][0] = useSheet;
		//tiledic[classname][10][1] = [startCOORD]
		//tiledic[classname][10][2] = [endCOORD]
		//tiledic[classname][10][3] = SpriteSheetCLASS
		//tiledic[classname][10][4] = needtomakeTileDIC?
		//tiledic[classname][11] = depthpoint:int=0;
		//tiledic[classname][12] = [iswalkable, isspecialwalk,glevel, [L],[M],[R]  ]
		
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
							
							var t:TileObject = new TileObject();
							t.key = num;
							t.xoffset = 0;
							t.yoffset = 0;
							t.sendToGround = sendtoBack;
							t.setAnimationData(false, false, 0,0);
							t.totalFrames = 0;
							t.isWalkable = tileRow.isWalkable;
							t.isSpecialWalkType = false;
							t.extendsStandardTile = false;
							t.width = 0;
							t.height = 0;
							t.setSpriteSheet(true,new Point(clms, rrs), new Point(clms, rrs), tileRow.className, true);
							t.depthPoint = depthadd;
							t.className = "SpriteSheet" + num;
							
							partofSheet.push(num);
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

		// Send processed data back to Main thread
		//bm.send(tiledic);
		
		//--------
		// tiledic
		bm.send("Start_TileProcessing");
		for (key in tiledic.keys()) {
			//
			bm.send(key);
			
			var bt:ByteArray = new ByteArray();
			bt.writeObject( tiledic.get(key) );			
			//
			bm.send( bt );
		}
		bm.send("Done_TileProcessing");
		//--------
		
		//--------
		bm.send("start_spriteSheets");
		for (str in spriteSheets) {
			bm.send(str);
		}
		bm.send("stop_spriteSheets");
		//--------
		
		//--------
		bm.send("start_tilebitdata");
		for (bit in tilebitdata.keys()) {
			var im:BitmapData = tilebitdata.get(bit);
			//var ib:String = im.getPixels(new Rectangle(0, 0, im.width, im.height)).toString();
			
			var bty:ByteArray = new ByteArray();
			bty.writeObject(im);
			
			bm.send(bit);
			bm.send(im.width);
			bm.send(im.height);
			bm.send(im.getPixels(new Rectangle(0,0,im.width, im.height)));
		}
		bm.send("stop_tilebitdata");
		//--------
		
		//--------
		bm.send("start_partofSheet");
		for (str in partofSheet) {
			bm.send(str);
		}
		bm.send("stop_partofSheet");
		//--------
		
		bm.send("start_looseTiles");
		for (str in looseTiles) {
			bm.send(str);
		}
		bm.send("stop_looseTiles");
		//--------
		
		bm.send("start_spriteSheetSprites");
		for (key in spriteSheetSprites.keys()) {
			bm.send(key);

			var im:BitmapData = spriteSheetSprites.get((key));
			var bty:ByteArray = new ByteArray();
			bty.writeObject(im);
			
			bm.send(im.width);
			bm.send(im.height);
			bm.send(im.getPixels(new Rectangle(0, 0, im.width, im.height)));
		}
		bm.send("stop_spriteSheetSprites");
		//--------
		
	}
	
	private function setTileProps(e:String, rect:Object):Void{
		var key:Int = tiledic[e].key;
		
		tilenum[key] = tiledic[e];
		var tob:TileObject = tilenum[key];
		tob.totalFrames = 1;		
		
		if(!tob.spr_useSheet){//if (!tiledic[e][10][0]) {
			// does not use SpriteSheets
			
			var classX = Type.resolveClass(e);
			var ti = Type.createEmptyInstance(classX);
			rect = ti.getBounds(this);
			
			tob.xoffset = ti.x - rect.x;
			tob.yoffset = ti.y-rect.y;
			
			tilebitdata[key] = new BitmapData(ti.width,ti.height,true,0x000000);
			var mtx:Matrix = new Matrix();
	
			mtx.tx = tob.xoffset;
			mtx.ty = tob.yoffset;
			tilebitdata[key].draw(cast(ti, MovieClip), mtx);
			
			//totalFrames
			if(tob.ani_hasAnimation){
				tob.totalFrames = ti.totalFrames; 
				for (o in 1...ti.totalFrames) {
					ti.gotoAndStop(o);
					
					var aniKey:Int = Std.parseInt(key + "000" + o); //key+"_"+o
					
					tilebitdata[aniKey] = new BitmapData(ti.width,ti.height,true,0x000000);
					tilebitdata[aniKey].draw(cast(ti, MovieClip),mtx);
				}
			}
			
			tob.width = ti.width;
			tob.height = ti.height;
		}else{
			//DOES use spriteSheet
			var cl = Type.resolveClass(tob.spr_SheetClass);
			var tie = Type.createEmptyInstance(cl);
			
			tob.xoffset = 0;
			tob.yoffset = 0;

			var wid:Int = Std.int(((tob.spr_endCOORD.x - tob.spr_startCOORD.x)+1)* tileWidth);
			var hei:Int = Std.int(((tob.spr_endCOORD.y - tob.spr_startCOORD.y)+1)* tileHeight);
			
			tilebitdata[key] = new BitmapData(wid,hei,true,0x000000);
			var mtxe:Matrix = new Matrix();
	
			mtxe.tx = -tob.spr_startCOORD.x * tileWidth;
			mtxe.ty = -tob.spr_startCOORD.y * tileHeight;
			tilebitdata[key].draw(tie,mtxe);	
		}		
	}	
	
	public function newWarpTile(i:Int):Void {
		var tileName:String = "tl_wg_" + i;
		
		if(tiledic[tileName] == null){
			var warpN:Int = i;
			i = -9999 + i;

			var t:TileObject = new TileObject();
			tiledic[tileName] = t;
			
			t.key 					= i;
			t.xoffset 				= 0;
			t.yoffset				= 0;
			t.sendToGround			= false;
			t.setAnimationData(false, false, 0, 0);
			t.totalFrames			= 0;
			t.isSpecialWalkType		= false;
			t.extendsStandardTile	= false;
			t.width					= 0;
			t.height				= 0;
			t.setSpriteSheet(false, new Point(), new Point(), "", false);
			t.depthPoint			= 0;	
			t.className 			= tileName;
					
			tilenum[t.key] = tiledic[tileName];
			var tob:TileObject = tilenum[t.key];
			tob.totalFrames = 1;		

			var classX = Type.resolveClass("tl_wg_template");
			var ti = Type.createEmptyInstance(classX);
			ti.num.text = warpN+ "";
					
			tilebitdata[t.key] = new BitmapData(ti.width,ti.height,true,0x000000);
			var mtx:Matrix = new Matrix();

			mtx.tx = tob.xoffset;
			mtx.ty = tob.yoffset;
			tilebitdata[t.key].draw(cast(ti, MovieClip), mtx);
			
			tob.width = ti.width;
			tob.height = ti.height;
		}
		
	}
}