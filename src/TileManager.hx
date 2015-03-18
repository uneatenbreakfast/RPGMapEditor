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
//import omni;
import Maps;

class TileManager extends Sprite
{
	public inline static var tileHeight = 50;
	public inline static var tileWidth = 50;
	public inline static var screenWidth = 900;
	
	private var stageManager:Main;
	private var displayManager:DisplayManager;
	
	private var TileSet:Bool = false;
	//
	private var bufferRect:Rectangle = new Rectangle(-tileWidth,-tileHeight,screenWidth+(2* tileWidth),400+(2* tileHeight));
	private var fillcolour:Int = 0x1D4B0B;
	private var bgfill:Int;
	private var columns:Int = 19;
	private var rows:Int = 8;
	private var map:Array<Array<Array<Int>>> = new Array<Array<Array<Int>>>();
	private var anitileList:Array<Dynamic> = new Array<Dynamic>();
	private var warpGates:Array<Dynamic> = new Array<Dynamic>();
	//
	//private var spriteSheetSprites:Array<Dynamic> = new Array<Dynamic>();
	private var spriteSheetSprites:Map<String, BitmapData> = new Map<String, BitmapData>();
	//
	private var pressKeys:Object = {};
	private var isBusy:Bool = false;
	private var showingSheet:Bool = false;
	private var phantomtile:MovieClip;
	private var selectedtile:Int = 2;
	private var selected_Array:Array<Dynamic> = new Array<Dynamic>();
	private var activelayer:Int = 0;
	//private var activelaybut:MovieClip = bg0;
	private var tileDisplay:Array<Dynamic> = new Array<Dynamic>();
	private var prePlace:String = "";
	private var placer:Sprite = new Sprite();
	private var eraseBrush:Bool = false;
	private var cam_point:Point = new Point(0,0);
	private var lastviewpoint:Point = new Point(0,0);
	private var tilenumLength:Int = 0;
	private var mySpriteSheet:ShowSpriteSheets;
	//
	private var tilebitdata:Map<Int, BitmapData> = new Map<Int, BitmapData>();//tilebitdata[key] = BitmapData
	private var tilenum:Map<Int, TileObject> = new Map<Int, TileObject>();//tilenum[key] = [class/string,xoffset,yoffset,sendtoGround,[animation,nonLoop],]
	private var tiledic:Map<String, TileObject> = new Map<String,  TileObject>();
	
	private var spriteSheetWalkables:Array<Dynamic> = new Array<Dynamic>();
	private var tilesets:Array<Dynamic> = new Array<Dynamic>();
	private var spriteSheets:Array<Dynamic> = new Array<Dynamic>();

	// LOAD THE TILESET
	private var req4:URLRequest;
	private var TileSetL:MyLoader;
	// LOAD THE TILESET

	private var groundclip:MovieClip = new MovieClip();
	private var skyclip:MovieClip = new MovieClip();
	private var canvasBD:BitmapData;
	private var bufferBD:BitmapData;
	private var skyBD:BitmapData;
	private var skybuffer:BitmapData;
		//
	private var tmpBit:BitmapData;
	private var tmpBit2:BitmapData;

	private var canvasBitmap:Bitmap;
	private var skyBitmap:Bitmap;
		
	private var layer0visi:Bool = true;
	private var layer1visi:Bool = true;
	private var layer2visi:Bool = true;
	private var layer3visi:Bool = true;
	private var walklayervisi:Bool = false;
	private var hero:MovieClip = new MovieClip();
		
	private var partofSheet:Array<Dynamic> = [];
	private var largerthanView:Array<Dynamic> = [];
	private var saveBusy:Bool = false;
	
	
	
	public var currentmap:String;
	

	public function new() :Void
	{			
		super();
		
		displayManager = DisplayManager.getInstance();
		
		var req4:URLRequest = new URLRequest("TileSets.swf");
		TileSetL = new MyLoader(req4, "TileSet");
		TileSetL.addEventListener("LoadDone",Engine); // Once loaded; initiate the bitmap creation Engine
	}	
	
	function Engine(evC:Event):Void {
		
	
		//for (i in Maps.gm_maps) {
			//gm_maps[i] = Maps.gm_maps[i];
		//}

		//tiledic = MovieClip(TileSetL.loader.content).tiledic;
		//spriteSheetWalkables = MovieClip(TileSetL.loader.content).spriteSheetWalkables;
		//spriteSheets = MovieClip(TileSetL.loader.content).spriteSheets;
		//tilesets = MovieClip(TileSetL.loader.content).tilesets;
		var tileMovieClip:MovieClip = cast(TileSetL.loader.content , MovieClip);		
		var tileDicArr:Array<Dynamic> = cast (tileMovieClip.tiledic, Array<Dynamic> );
		var tileKeysArr:Array<Dynamic> = cast (tileMovieClip.tileKeysArr, Array<Dynamic> );
		tilesets = cast (tileMovieClip.tilesets, Array<Dynamic> );
		
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
		var initnum:Int = 0;
		var yininum:Int = 0;
				
		var tilesetArr = cast (tileMovieClip.tilesetArr, Array<Dynamic> );
		for (ox in tilesetArr) {
			var intArr:Array<Int> = tilesets[ox];
			for(pi in intArr){ //for (pi in tilesets[ox]) {
				var curTarg:Int = tilesets[ox][pi]; 
				var bitImage:BitmapData = tilebitdata[curTarg];
			
				yininum = Math.floor(initnum/16);
			
				var tis = new MovieClip();
				var bit:BitmapData = bitImage;
				var bitm:Bitmap = new Bitmap(bit);
			
				tis.addChild(bitm);
				tis.y  = yininum*55;
				tis.x = (initnum-(yininum*16))* (tileWidth+5)+10;
			
				tis.tilenumber  = curTarg;
				//tis.addEventListener(MouseEvent.CLICK,select_tile);
			
				initnum++;
				
				//toolsbench.addChild(tis);
				tis.width = tileWidth;
				tis.height = tileHeight;
			}
		}
		
		
		for (ni in 1...(tilenumLength+1)) {
			var inarr:Bool = false;
			for (kx in tilesetArr) {//for (kx in tilesets) {
				if (isiteminarray (tilesets[kx], ni)) {
					inarr = true;
					break;
				}
			}
			
			if (isiteminarray (partofSheet, ni)) {
				break;
			}
			
			
			if (!inarr) {
				yininum = Math.floor(initnum/16);
				var key:Int = ni;
				var tix:MovieClip = new MovieClip();
				var bitImage2:BitmapData = tilebitdata[key];
				var bit2:BitmapData = bitImage2;
				var bitm2:Bitmap = new Bitmap(bit2);
									
				tix.y  = yininum*55;
				tix.x = (initnum-(yininum*16))* (tileWidth+5)+10;
				tix.tilenumber = key;
			
				tix.addChild(bitm2);
				tix.width = tileWidth;
				tix.height = tileHeight;

				//tix.addEventListener(MouseEvent.CLICK,select_tile);

				//toolsbench.addChild(tix);
				initnum++;
			}
		}
		
		rebuildmap(rows,columns,"newmap_"+Math.round(Math.random()* 99));
	}
	
	
	

	function setTileProps(e:String, rect:Object):Void{
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
		
		if(key>tilenumLength){
			tilenumLength = key;
		}
	}

	function rebuildmap(rownum:Int,columnnum:Int,newmapname:String):Void{
		currentmap = newmapname;
		//curmap.text = "Current Map :"+currentmap;
			
		map = new Array<Array<Array<Int>>>();
		rows = rownum;
		columns = columnnum;
		for (p in 0...rows) {
			map[p]= new Array<Array<Int>>();
			for (i in 0...columns) {
				map[p][i] = [0,0,0,0];
			}
		}
		anitileList = new Array();
		warpGates = new Array();
		//warptlist.removeAll();
		
		//resetBitmap(true);
		isBusy = false;
	}
	
	
	function buildmap(instr:String):void {
		var pie:Array = instr.split("#");
		if (pie.length==3) {
			anitileList = new Array();
			warpGates = new Array();
			largerthanView = [];
			warptlist.removeAll()
			//
			var head:Array = pie[0].split(",");
			columns = head[0];
			rows = head[1];
			fillcolour = head[2];
			if(fillcolour < 10000 && fillcolour != 0){
				fillcolour = 0;
				bgfill = head[2];
			}
			
			//
			map = pie[1].split("&");
			for (var i:Int = 0; i<map.length; i++) {
				map[i] = map[i].split("|");
				for (var o:Int = 0; o<map[i].length; o++) {
					map[i][o] = map[i][o].split(":");
				}
			}
			
			warpGates = pie[2].split("&");
			for (var s:Int=0;s<warpGates.length;s++) {
				warptlist.addItem({label:s});
				warpGates[s] = warpGates[s].split(":");
				warpGates[s][3] = warpGates[s][3].split("|");
				
				for(var t:Int=0;t<warpGates[s][3].length;t++){
					warpGates[s][3][t] = warpGates[s][3][t].split(",");
				}
			}
			
			extendTilesLoop(0);
			extendTilesLoop(1);
			extendTilesLoop(2);
			largerthanView.sort(Array.UNIQUESORT);
			
			resetBitmap(true);		
		}
		isBusy = false;
	}
	var ignoreList:Array = [omni.BUTTERFLY];//tiles to ignore
	function extendTilesLoop(layer:Int):void {
		for (var i:Int = 0; i<rows; i++) {
			for (var o:Int = 0; o<columns; o++) {
				var key:Int = map[i][o][layer];
				
				if (key!=0) {
					
					
						
					if(!func.isiteminarray(ignoreList,key)){
						var dtile = tilenum[key][0];
											
						if (tiledic[dtile][7]) {
							var sWidth:Int = tilenum[key][8];
							var sHeight:Int = tilenum[key][9];
							
							var xxf:Int = (o * tileWidth)-tilenum[key][1];
							var yyf:Int = (i * tileHeight)-tilenum[key][2];

							largerthanView.push([i,o,sWidth,layer,sHeight,xxf,yyf]);
							
							
						}
						if (tilenum[key][4][0]) {
							var numKey:Int = (i * columns) + o;
							
							
							anitileList[numKey] = [1,tilenum[key][5]];//FrameNum , totalFrames
						}
					}
				}
			}
		}
	}

	
	function removeGate(ey:Int,ex:Int):void{
		for (var s in warpGates) {
			for(var t in warpGates[s][3]){
				if( warpGates[s][3][t][0]==ex && ey==warpGates[s][3][t][1]){
					warpGates[s][3].splice(t,1);
				}
			}
		}
	}
	function removeAnimationTile(ey:Int,ex:Int,activelayer:Int):void {
		if (map[ey][ex][activelayer]!=0) {
			//trace("REMOVE IN:",1,map[ey][ex][activelayer]);
			//trace("REMOVE IN:",1.5,map[ey][ex][activelayer],tilenum[map[ey][ex][activelayer]][4]);
			if (tilenum[map[ey][ex][activelayer]][4][0]) {
				//trace("REMOVE IN:",2);
				for (var i in anitileList) {
					//trace("REMOVE:",i,anitileList);
					if (anitileList[i][0]==ey && anitileList[i][1]==ex && anitileList[i][2]==activelayer) {
						delete anitileList[i];
						anitileList.splice(i, 1);
						break;
					}
				}
			}
		}
	}
	
	function resetBitmap(runonce:Boolean=false):void {
		cam_pointx.text = String(cam_point.x);
		cam_pointy.text = String(cam_point.y);

		if (runonce) {
			anitileList = [];
		}

		bufferBD.lock();
		skybuffer.lock();

		var colstart:Int = Math.floor((cam_point.x-50)/50);
		if (colstart<0) {
			colstart = 0;
		}
		var colend:Int = colstart+19;
		if (colend>columns-1) {
			colend = columns-1;
		}
		//
		var yst:Int = Math.floor((cam_point.y-50)/50);
		if (yst<0) {
			yst = 0;
		}
		var yend:Int = yst+9;
		if (yend>rows-1) {
			yend = rows-1;
		}
		

		
		
		if(bgfill > 0){
			bufferBD.copyPixels(tilebitdata[bgfill],new Rectangle(0, 0 ,screenWidth,400) ,new Point(tileWidth,tileHeight));
		}else{
			bufferBD.fillRect(bufferBD.rect,0x000000);
			bufferBD.fillRect(new Rectangle(0,0,(colend+1-colstart)* tileWidth,(yend+1-yst)* tileHeight),fillcolour);
		}

		skybuffer.fillRect(bufferBD.rect,fillcolour);
		
		

		var tileList1:Array = [];
		if (layer0visi) {

			tileList1 = listLoop(0,runonce,yst,yend,colstart,colend);
			//theloop(0,runonce,yst,yend,colstart,colend);
		}
		if (layer1visi) {

			var tileList2:Array = listLoop(1,runonce,yst,yend,colstart,colend);

			
			tileList1= tileList1.concat( tileList2[1]);
			
			tileList2 = tileList2[0];
			
			var extendList:Array = listExtensions(yst,yend,colstart,colend);
					
			tileList2= tileList2.concat(extendList);
			
			tileList2.sortOn(["y","x"], Array.NUMERIC);
			
			
			tileList1= tileList1.concat(tileList2);
			
		}
		if (layer2visi) {

			var tileList3:Array = listLoop(2,runonce,yst,yend,colstart,colend);
			//theloop(2,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList3);
		
		}
		//invisible action event layer
		if (layer3visi) {

			var tileList4:Array = listLoop(3,runonce,yst,yend,colstart,colend);
			//theloop(3,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList4);
		}
		
		
		// walkable layer
		if (walklayervisi) {
			var tileList5:Array = listWalkable(yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList5);
		}
		
		
		
		
		drawAll(tileList1);

		//
		for (var s in warpGates) {
			for (var t in warpGates[s][3]) {
				var z:Int = warpGates[s][3][t][1];
				var q:Int = warpGates[s][3][t][0];
				var dtile:Class = getDefinitionByName("tl_wg_" + s)  as Class;
				var key:Int = tiledic[dtile][0];
				
				var dx:Int = (q * tileWidth)-cam_point.x+tileWidth;
				var dy:Int = (z * tileHeight)-cam_point.y+tileHeight;
				var pt:Point = new Point(dx, dy);
				var rec:Rectangle =  new Rectangle(0, 0, tileWidth,tileHeight);
				bufferBD.copyPixels(tilebitdata[key], rec, pt,null,null,true);
			}
		}
		//

		bufferBD.unlock();
		skybuffer.unlock();
		canvasBD.copyPixels(bufferBD,new Rectangle(tileWidth,tileHeight,bufferBD.width,bufferBD.height) ,new Point(0,0));
		skyBD.copyPixels(skybuffer,new Rectangle(tileWidth,tileHeight,skybuffer.width,skybuffer.height) ,new Point(0,0));
	}

	function listExtensions(yst:Int,yend:Int,colstart:Int,colend:Int):Array{
		
		var campointx:Int = cam_point.x;
		var campointy:Int = cam_point.y;
		var clipRect:Rectangle = new Rectangle(0,0,50,50);
		var dlist:Array = [];
		var ob:Object = {};
		//[0] = row
		//[1] = column
		//[2] = width
		//[3] = layer
		//[4] = height
		//[5] = xxf ( x location with offset)
		//[6] = yyf ( y location with offset)
		var z:Int;
		var q:Int;
		var layer:Int;
		var key:Int;
		for (var a:Int=0; a<largerthanView.length; a++) {
			if (largerthanView[a][0]>yend || largerthanView[a][0]<yst ||
			  largerthanView[a][1]>colend || largerthanView[a][1]<colstart) {
				
				clipRect.x = largerthanView[a][5]-campointx+tileWidth;
				clipRect.y = largerthanView[a][6]-campointy+tileHeight;
				clipRect.width = largerthanView[a][2];
				clipRect.height = largerthanView[a][4];

				if (clipRect.intersects(bufferRect)) {

					z = largerthanView[a][0];//yoffset
					q = largerthanView[a][1];//xoffset
					layer = largerthanView[a][3]
					key = map[z][q][layer];
					
					if(key == 0){
						continue;
					}
					
					ob = {}
					ob.x = q * tileWidth;
					ob.y = z * tileHeight;
					ob.BitmapData = tilebitdata[key];
					ob.width = tilebitdata[key].width;
					ob.height = tilebitdata[key].height;
					ob.xoff = clipRect.x;
					ob.yoff = clipRect.y;
					dlist.push(ob);
				}
			}
		}
		return dlist;
	}

	 function drawAll(superArray:Array):void{
		var dispList:Array = superArray;
		var dlength:Int = dispList.length;
		var len:Object;
		var pPo:Point = new Point(0,0);
		var rRe:Rectangle = new Rectangle(0,0,0,0);
		
		for (var z:Int = 0; z<dlength; z++) {
			len = dispList[z];
			pPo.x = len.xoff;
			pPo.y = len.yoff;
			rRe.width = len.width;
			rRe.height = len.height;	
			bufferBD.copyPixels(len.BitmapData, rRe, pPo);
		}			
	}

	function pastetile(z:Int,q:Int,layer:Int):void {
		var whichBuffer:BitmapData = bufferBD;

		var key:Int = map[z][q][layer];

		var dx:Int = (q * tileWidth)-cam_point.x+tileWidth;
		var dy:Int = (z * tileHeight)-cam_point.y+tileHeight;
		
		var pt:Point = new Point(dx-(tilenum[key][1]), dy-(tilenum[key][2]));
		var rec:Rectangle =  new Rectangle(0, 0, tilebitdata[key].width, tilebitdata[key].height);
		
		if (tilenum[key][4][0] && anitileList[z+"_"+q]) {
			var toPaste:Int = anitileList[z+"_"+q][3]+1;

			if (toPaste>tilenum[key][5]) {
				toPaste=1;
				anitileList[z+"_"+q][3]=0;
			}
			anitileList[z+"_"+q][3]++;
			
			bufferBD.copyPixels(tilebitdata[key+"_"+toPaste], rec, pt);

		} else {
			whichBuffer.copyPixels(tilebitdata[key], rec, pt,null,null,true);
		}
	}


	function listWalkable(yst:Int,yend:Int,colstart:Int,colend:Int):Array {
		var dlist:Array = [];
		var sendtobot:Array = [];
		var ob:Object = {};
		var numKey:Int;
		var key:Int;
		var xoffset:Int;
		var yoffset:Int;
		var pPoint:Point = new Point();
		var rRect:Rectangle = new Rectangle(0,0,0,0);
		
		var campointx:Int = cam_point.x;
		var campointy:Int = cam_point.y;
		
		for (var z:Int = yst; z<=yend; z++) {
			if (z>=0) {
				for (var q:Int = colstart; q<=colend; q++) {
					if (q>=0) {
						key = int(map[z][q][0]);
						if(key == 0){
							continue;
						}
						if (tilenum[ key ][6]  == 1) { // walkable tile
							//q -> xoffset
							//z -> yoffset
							
							key = 599; // walkable tile image

							xoffset = (q * tileWidth)-campointx+tileWidth;
							yoffset = (z * tileHeight)-campointy+tileHeight;

							ob = {};
							ob.x = (q * tileWidth);
							ob.y = (z * tileHeight)+0+tilenum[key][10];

							numKey = (z * columns) + q;
							
							
							ob.BitmapData = tilebitdata[key];
							ob.width = tilebitdata[key].width;
							ob.height = tilebitdata[key].height;
							
							ob.xoff = xoffset-(tilenum[key][1]);
							ob.yoff = yoffset-(tilenum[key][2]);
							dlist.push(ob);
						}
					}
				}
			}
		}
		return dlist;
	}

	function listLoop(layer:Int,runonce:Boolean,yst:Int,yend:Int,colstart:Int,colend:Int):Array {
		var dlist:Array = [];
		var sendtobot:Array = [];
		var ob:Object = {};
		var numKey:Int;
		var key:Int;
		var xoffset:Int;
		var yoffset:Int;
		var pPoint:Point = new Point();
		var rRect:Rectangle = new Rectangle(0,0,0,0);
		
		var campointx:Int = cam_point.x;
		var campointy:Int = cam_point.y;
		
		for (var z:Int = yst; z<=yend; z++) {
			if (z>=0) {
				for (var q:Int = colstart; q<=colend; q++) {
					if (q>=0) {
						
						if (int(map[z][q][layer])>0) {
							//q -> xoffset
							//z -> yoffset
							
							key = map[z][q][layer];

							xoffset = (q * tileWidth)-campointx+tileWidth;
							yoffset = (z * tileHeight)-campointy+tileHeight;

							ob = {};
							ob.x = (q * tileWidth);

							ob.y = (z * tileHeight)+layer+tilenum[key][10];

							numKey = (z * columns) + q;
							
							if(anitileList[numKey] && tilenum[key][4][0]){
								
								ob.BitmapData = tilebitdata[key+"_"+anitileList[numKey][0]];
								if(anitileList[numKey][0]+1>anitileList[numKey][1]){
									anitileList[numKey][0] = 1;
								}else{
									anitileList[numKey][0]++
								}									
							}else{
								ob.BitmapData = tilebitdata[key];
							}
							
							ob.width = tilebitdata[key].width;
							ob.height = tilebitdata[key].height;
							
							ob.xoff = xoffset-(tilenum[key][1]);
							ob.yoff = yoffset-(tilenum[key][2]);
							
							if(layer==1){
								if(tilenum[key][3]){
									sendtobot.push(ob);
								}else{											
									dlist.push(ob);
								}
							}else{
								dlist.push(ob);
							}
							
						}
							
						
					}
				}
			}
		}
		if(layer==1){
			return [dlist,sendtobot];
		}else{
			return dlist;
		}
	}


	function Mapsize(type:String,num:Int):Int {
		if (num<0) {
			return 0;
		} else if (type=="x" && num>columns) {
			return columns;
		} else if (type=="y" && num>rows-1) {
			return rows-1;
		} else {
			return num;
		}
	}

	
	function addrowscol(keypress:Int):void {
		var rowx:Array = new Array();
		var i:Int = 0;
		var sw;
		var s;
		var tt;
		var restmap:Boolean = false;
		switch (keypress) {
			case 38 :
			//top
				rows++;
				for (i = 0; i<columns; i++) {
					rowx.push([0,0,0,0]);
				}

				map.unshift(rowx);
				restmap = true;
				
				
				for (i = 0; i<largerthanView.length; i++) {
					tt = (largerthanView[i][0] * tileHeight)-largerthanView[i][6];	
					largerthanView[i][0]++;
					largerthanView[i][6] = (largerthanView[i][0] * tileHeight)-tt;		
				}
				for(sw in warpGates){
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][1]++;
					}
				}

				break;
			case 40 :
			//bottom
				rows++;
				for (i = 0; i<columns; i++) {
					rowx.push([0,0,0,0]);
				}
				
				map.push(rowx);
				restmap = true;
				break;

			case 37 :
			//left
				columns++;
				for (i = 0; i<rows; i++) {
					map[i].unshift([0,0,0,0]);
				}

				restmap = true;
				
				for (i = 0; i<largerthanView.length; i++) {
					tt = (largerthanView[i][1] * tileWidth)-largerthanView[i][5];	
					largerthanView[i][1]++
					largerthanView[i][5] = (largerthanView[i][1] * tileWidth)-tt;		
				}
				for(sw in warpGates){
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][0]++;
					}
				}
				
				break;
			case 39 :
			//right
				columns++;
				for (i = 0; i<rows; i++) {
					map[i].push([0,0,0,0]);
				}

				restmap = true;
				break;


		}
		if (restmap) {
			resetBitmap(true);
		}
	}
	function trimmap(keypress:Int):void {
		var restmap:Boolean = false;
		var i:Int = 0;
		var sw;
		var s;
		var tt:Int;
		switch (keypress) {
			case 38 :
			//up
				rows--;
				map.shift();
				restmap = true;
				
				for (i = 0; i<largerthanView.length; i++) {
					tt = (largerthanView[i][0] * tileHeight)-largerthanView[i][6];	
					largerthanView[i][0]--;
					largerthanView[i][6] = (largerthanView[i][0] * tileHeight)-tt;		
				}
				for(sw in warpGates){
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][1]--;
					}
				}
				
				break;
			case 40 :
			//bottom
				if(cam_point.y>0){
					cam_point.y -=tileHeight;
				}
				rows--;
				map.pop();
				restmap = true;
				
				break;
			case 37 :
			//left
				columns--;
				for (i = 0; i<rows; i++) {
					map[i].shift();
				}

				restmap = true;
				
				for (i = 0; i<largerthanView.length; i++) {
					tt = (largerthanView[i][1] * tileWidth)-largerthanView[i][5];	
					largerthanView[i][1]--;
					largerthanView[i][5] = (largerthanView[i][1] * tileWidth)-tt;
					
					if(largerthanView[i][1] < 0){
						// remove the object from the largerthanView array
						largerthanView.splice(i, 1 );
						i--;
					}
				}
				
				
				
				for(sw in warpGates){
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][0]--;
					}
				}
				
				break;
			case 39 :
			//right
				columns--;
				if(cam_point.x>tileWidth){
					cam_point.x -=tileWidth;
				}
				for (i = 0; i<rows; i++) {
					map[i].pop();
				}

				restmap = true;
				break;
		}
		if (restmap) {
			resetBitmap(true);
		}
	}
	*/
	function isiteminarray (arrayx:Array<Dynamic>, item:Dynamic):Bool {
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

	/*
	//-------
	cineEditModebtt.addEventListener(MouseEvent.CLICK,cctv);
	function cctv(e:MouseEvent):void{
		if(cineEditMode){
			cineEditMode = false;
			cineMARK.gotoAndStop(2);
		}else{
			cineEditMode = true;
			cineMARK.gotoAndStop(1);
		}
	}

	stage.addEventListener(MouseEvent.MOUSE_DOWN,mDown);
	stage.addEventListener(MouseEvent.MOUSE_MOVE,mMove);
	stage.addEventListener(MouseEvent.MOUSE_UP,mUp);
	cineMARK.gotoAndStop(2);
	var msx:Int;
	var msy:Int;
	var cineEditMode:Boolean = false
	function mDown(e:MouseEvent):void {
		msx = stage.mouseX;
		msy = stage.mouseY;
	}
	function mMove(e:MouseEvent):void { // moving the screen for cineEditMode
		if (msx!=0 && msy!=0 && stage.mouseY<400 && cineEditMode) {
			var nx:Int = stage.mouseX-msx;
			var ny:Int = stage.mouseY-msy;
			cam_point.x = cam_point.x-nx;
			cam_point.y = cam_point.y-ny;
			
			resetBitmap();
			msx = stage.mouseX;
			msy = stage.mouseY;
		}
	}
	function mUp(e:MouseEvent):void {
		msx = 0;
		msy = 0;
	}
	*/
	
}