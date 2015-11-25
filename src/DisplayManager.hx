package ;

import fl.motion.Color;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.Lib;
import Omni;

//import com.demonsters.debugger.MonsterDebugger;

/**
 * ...
 * @author Nelson
 */
class DisplayManager extends MainStageMC
{
	private static var thisManager:DisplayManager;
	
	public inline static var tileHeight = 50;
	public inline static var tileWidth = 50;
	public inline static var GameScreenWidth = 1200;
	public inline static var GameScreenHeight = 600;
	private inline static var tileNumSpacer:String = "00";
		
	private var gameEdgeLeft:Int;
	private var gameEdgeRight:Int;
	
	public var windowWidth:Int;
	public var windowHeight:Int;
	
	
	private var stageManager:Main;
	private var saveMapManager:SaveMapManager;
	private var tileManager:TileManager;
	
	// take from TileManager
	private var tilebitdata:Map<Int, BitmapData>;
	private var tilenum:Map<Int, TileObject>;
	private var spriteSheetSprites:Map<String, BitmapData>;	
	//
	
	private var TileSet:Bool = false;
	//
	private var bufferRect:Rectangle;
	public var fillcolour:Int = 0x1D4B0B; // dark green
	private var bgfill:Int;
	public var columns:Int;
	public var rows:Int;
	private var map:Array<Array<Array<Int>>> = new Array<Array<Array<Int>>>();
	private var anitileList:Array<Dynamic> = new Array<Dynamic>();
	public var warpGates:Array<WarpGate> = new Array<WarpGate>();
	
	//
	private var pressKeys:Map<Int, Bool> = new Map<Int, Bool>();
	private var isBusy:Bool = false;	
	private var showingSheet:Bool = false;
	private var phantomtile:MovieClip;
	
	// selected tiles
	public var selectedtile:Int = 2;
	public var selected_Array:Array<Array<Int>> = new Array<Array<Int>>();
	private var visi_selectedTile_btt:ToggleButton;
	private var selected_bit:Bitmap;
	
	public var save_btt_toggle:ToggleButton;
	
	//
	public var warp_selected:WarpGate = null;
	private var activelayer:Int = 0;

	private var tileDisplay:Array<Dynamic> = new Array<Dynamic>();
	private var prePlace:String = "";
	private var placer:Sprite = new Sprite();
	
	public var eraseBrush:Bool = false;
	private var cam_point:Point = new Point(0,0);
	private var lastviewpoint:Point = new Point(0,0);
	private var tilenumLength:Int = 0;
	
	private var mySpriteSheet:SpriteSheetManager;
	//

	private var spriteSheetWalkables:Array<Dynamic> = new Array<Dynamic>();
	private var tilesets:Array<Dynamic> = new Array<Dynamic>();
	
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
				
	private var partofSheet:Array<Dynamic> = [];
	private var largerthanView:Array<Dynamic> = new Array<Dynamic>();
	private var saveBusy:Bool = false;	// prevents clicks to modify the map
	
	private var previouslyUsedTiles:Array<MovieClip> = new Array<MovieClip>();
	
	public var currentmap:String;
	private var currentVersion:Int;
	
	private var visibleLayer:Array<Bool> = [true, true, true, true, true, false, true, false]; //[0,1,2,3-events, 4-warpgates, 5-walk, 6-selectedtile_visibility,7-showGrid]
	
	private var cineEditMode:Bool = false; // let's you freely click and pan around map
	private var cineEditMode_Point:Point = new Point(); // for cineEditMode=TRUE - starting point for the drag
		
	private var mouseCoordinate:Point = new Point();
	private var eraser:ToggleButton;
	
	private var activePanel:MovieClip;
	public var selectedTileSet:Array<String>;
	public var authorName:String = "";
	
	//
	private var ignoreList:Array<Int> = [ Omni.BUTTERFLY ];//tiles to ignore
	private var grassOptTiles:Array<Int> = [939, 963, 964];
	
	private var walkNodesMap:Array<Array<Array<WalkNode>>>;
	
	
	//	
	public static function getInstance():DisplayManager {
		if (thisManager == null) {
			thisManager = new DisplayManager();
		}
		return thisManager;
	}
	
	public function new() :Void
	{			
		super();
		
		/*
		MonsterDebugger.initialize(this);
        MonsterDebugger.trace(this, "Hello World!");
		*/
		
		columns = 26;
		rows = 14;
		
		bufferRect 	= new Rectangle( -tileWidth, -tileHeight, GameScreenWidth + (2 * tileWidth), GameScreenHeight + (2 * tileHeight));		
		canvasBD 	= new BitmapData(GameScreenWidth, GameScreenHeight, false, 0x333333); 		
		bufferBD 	= new BitmapData(GameScreenWidth + (2 * tileWidth), GameScreenHeight + (2 * tileHeight), false, 0x333333);		
		skyBD 		= new BitmapData(GameScreenWidth, GameScreenHeight, true, 0x333333);		
		skybuffer 	= new BitmapData(GameScreenWidth + (2 * tileWidth), GameScreenHeight + (2 * tileHeight), true, 0x333333);
		tmpBit 		= new BitmapData(bufferBD.width, bufferBD.height, false, fillcolour);
		
		canvasBitmap = new Bitmap(canvasBD);
		skyBitmap 	= new Bitmap(skyBD);
		
		var rndNames:Array<String> = ["Kaiba","Seto","Yugi","Yami","Tea","Tristan","Joey","Mai"];
		authorName = rndNames[Std.int(Math.random() * rndNames.length)] + "_" + Func.randInt(1000);
	}
	
	public function turnOn():Void{
		saveMapManager 		= SaveMapManager.getInstance();
		tileManager 		= TileManager.getInstance();
		
		tilebitdata 		= tileManager.tilebitdata;
		tilenum 			= tileManager.tilenum;
		spriteSheetSprites 	= tileManager.spriteSheetSprites;
		
		windowWidth = stage.stageWidth;
		windowHeight = stage.stageHeight;
		
		//
		groundclip.addChild(canvasBitmap);
		skyclip.addChild(skyBitmap);

		groundclip.x = 600;
		skyclip.x = groundclip.x;
		
		addChild(groundclip);
		addChild(skyclip);
		//addChild(new fpsBox(stage,0,400));
		//-----
				
		// Housekeeping
		//walk_eye.gotoAndStop(2);
		
		gameEdgeLeft	= Std.int(groundclip.x);
		gameEdgeRight	= Std.int(groundclip.x + GameScreenWidth);
		
		// Buttons 		
		eraser = toggleButtonMaker(new Eraser_Btt(), 0, null, erased, false);
		eraser.x = 603.4;
		eraser.y = 632.1;
		
		var cineEditModeBtt:ToggleButton = toggleButtonMaker(new EditMode_Btt(),0,null,cctv,false);
		cineEditModeBtt.x = 691;
		cineEditModeBtt.y = 632.1;
		
		var cineEditModeBtt:ToggleButton = toggleButtonMaker(new EditMode_Btt(),0,null,cctv,false);
		cineEditModeBtt.x = 691;
		cineEditModeBtt.y = 632.1;
		
		
		visi_selectedTile_btt 	= toggleButtonMaker(s_tileVisibtt, 6, null, setvisi, true); 		
		save_btt_toggle 		= toggleButtonMaker(save_btt, 0, null, saveMap, false);
		//-----------------------
		// Toggle replace Buttons
		toggleButtonMaker(visibility_lay_0_btt, 0, null, setvisi, visibleLayer[0]);
		toggleButtonMaker(visibility_lay_1_btt, 1, null, setvisi, visibleLayer[1]);
		toggleButtonMaker(visibility_lay_2_btt, 2, null, setvisi, visibleLayer[2]);
		toggleButtonMaker(visibility_lay_e_btt, 3, null, setvisi, visibleLayer[3]);
		toggleButtonMaker(visibility_lay_w_btt, 4, null, setvisi, visibleLayer[4]);
		toggleButtonMaker(visibility_lay_wk_btt, 5, null, showWalkableTiles, visibleLayer[5]);
		toggleButtonMaker(showgrid_btt, 		7, null, setvisi, visibleLayer[5]);// show Grid Button
		
		var tg:Array<ToggleButton> = new Array<ToggleButton>();
		toggleButtonMaker(lay_0_btt, 0, tg, setlayer, false);
		toggleButtonMaker(lay_1_btt, 1, tg, setlayer, false);
		toggleButtonMaker(lay_2_btt, 2, tg, setlayer, false);
		toggleButtonMaker(lay_e_btt, 3, tg, setlayer, false);
		toggleButtonMaker(lay_w_btt, 4, tg, setlayer, false);
		
		tg[0].toggle(true);
		//-----------------------
		
		// Button Functions
		stage.addEventListener(MouseEvent.MOUSE_DOWN, 	startplacetile);
		stage.addEventListener(MouseEvent.MOUSE_UP, 	stopplacetile);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, 	ghosttile);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, 	mouseCamScrollWheel);
		stage.addEventListener(Event.ENTER_FRAME, 		mouseCamScroll);
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN,	mDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE,	mMove);
		stage.addEventListener(MouseEvent.MOUSE_UP,		mUp);
		stage.addEventListener(KeyboardEvent.KEY_DOWN,	keyscan);
		stage.addEventListener(KeyboardEvent.KEY_UP,	stopkeyscan);
		
		newmap_btt.buttonMode = true;
		newmap_btt.addEventListener(MouseEvent.CLICK, 	showNewPanel);
		sheets_btt.addEventListener(MouseEvent.CLICK, 	showSheets);
		
		outputbtt.addEventListener(MouseEvent.CLICK, 	saveMapManager.outputmap);
		inputbtt.addEventListener(MouseEvent.CLICK,		showinput);
		loadmap_btt.addEventListener(MouseEvent.CLICK, 	showmaplist);
		mapsettings_btt.addEventListener(MouseEvent.CLICK, shwmenu);
		
		grassoptimizer_btt.addEventListener(MouseEvent.CLICK, optimizeGrass);
		
		//
		rebuildmap(rows,columns,"newmap_"+Math.round(Math.random()* 99));
		setghosttile();
		//
	}
	
	private function toggleButtonMaker(replaceClip:MovieClip, valueInt:Int, toggleGroup:Array<ToggleButton>, func:Dynamic, defaultState:Bool):ToggleButton {
		var setDepth:Int = -1;
		if (this.contains(replaceClip)) {
			setDepth = this.getChildIndex(replaceClip);
		}		
		
		var btt:ToggleButton = new ToggleButton(replaceClip);
		btt.x = replaceClip.x;
		btt.y = replaceClip.y;
		btt.valueInt = valueInt;
		btt.addEventListener(MouseEvent.CLICK, func);
		btt.scrubCoord();
		btt.toggle(defaultState);
		
		addChild(btt);
		
		if (setDepth>-1) {
			setChildIndex(btt, setDepth);
		}
		
		if (toggleGroup != null) {
			toggleGroup.push(btt);
			btt.setToggleGroup(toggleGroup);
		}
		
		return btt;
	}
	
	public function newmap(rownum:Int, columnnum:Int, newmapname:String):Void {
		
		if (save_btt_toggle.isSelected) {
			//  there has been a change - need to prompt save point
			saveBusy = true;
			
			// Prompt save
			var d:DialogueSave = promptSave();
			d.continueFunction = rebuildmap;
			d.continueParams = [rownum, columnnum , newmapname];
			//
		}else {
			rebuildmap(rownum, columnnum , newmapname);
		}
		
	}
	public function rebuildmap(rownum:Int,columnnum:Int,newmapname:String):Void{
		updateMapName(newmapname);
		currentVersion = 0;
			
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
		warpGates = new Array<WarpGate>();
		
		resetBitmap(true);
		isBusy = false;
		
		//
		save_btt_toggle.toggle(false);
		showSheets();
	}

	private function showmaplist(e:MouseEvent):Void{
		switchToPanel(new LoadMap());
	}
	private function showNewPanel(e:MouseEvent):Void{
		switchToPanel(new NewMap_Panel());
	}
	private function shwmenu(e:MouseEvent=null):Void{
		switchToPanel(new Settings_Panel());
	}
	
	
	private function showinput(e:MouseEvent):Void{
		if (!isBusy) {
			isBusy = true;
			var d:EnterMap = new EnterMap();
			d.x = 455;
			d.y = 224;
			addChild(d);
		}
	}

	private function showSheets(e:MouseEvent = null):Void {
		switchToPanel(new SpriteSheetManager ());
	}
	
	private function switchToPanel(pmc:MovieClip):Void {
		if (activePanel != null) {
			removeChild(activePanel);
		}
		
		activePanel = pmc;
		activePanel.x = 55;
		addChild(activePanel);
	}
	
	public function loadNewMap(mapName:String, version:String, mapData:String):Void {
		updateMapName(mapName);
		resetCamera();
		buildmap(mapData);
		currentVersion = Std.parseInt(version);
		
		save_btt_toggle.toggle(false);
		showSheets();
	}
	public function updateMapName(mapName:String):Void {
		currentmap = mapName;
		mapname_txt.text = currentmap + " :: By "+ authorName;
	}
	public function updateBgTint(newTint:Int):Void {
		fillcolour = newTint;
	}	
	private function buildmap(instr:String):Void{
		var pie:Array<String> = instr.split("#");
		
		if (pie.length==3) {
			anitileList = new Array<Dynamic>();
			warpGates = new Array<WarpGate>();
			largerthanView = new Array<Dynamic>();
			map = new Array<Array<Array<Int>>>();
			//
			var head:Array<String> = pie[0].split(",");
			columns = Std.parseInt(head[0]);
			rows = Std.parseInt(head[1]);
			fillcolour = Std.parseInt(head[2]);
			if(fillcolour < 10000 && fillcolour != 0){
				fillcolour = 0;
				bgfill = Std.parseInt(head[2]);
			}else {
				// no background
				bgfill = 0;
			}
			
			// map:Array<Array<Array<Int>>> = new Array<Array<Array<Int>>>();
			//map = pie[1].split("&");
			var mapA:Array<String> = pie[1].split("&");
			for ( i in 0...rows){ //mapA.length) {
				map[i]= new Array<Array<Int>>(); // rows
				//map[i] = map[i].split("|");
				var mapB:Array<String> = mapA[i].split("|");
				for (o in 0...columns){ //mapB[i].length) {
					map[i][o] = new Array<Int>(); // cols
					//map[i][o] = mapB[i][o].split(":");
					var mapC:Array<String> = mapB[o].split(":");
					
					for (j in 0...mapC.length) {
						map[i][o][j] = Std.parseInt(mapC[j]);
					}
				}
			}

			warpGates = new Array<WarpGate>();
			var allWarpGates:Array<String> = pie[2].split("&");//warpGates = pie[2].split("&");
			if (pie[2] != "") {
				// at least 1 warpgate
				for (s in 0...allWarpGates.length) {				
					var gates:Array<String> = allWarpGates[s].split(":");//warpGates[s] = allWarpGates[s].split(":");
					var w:WarpGate = new WarpGate();				
					w.x = Std.parseInt(gates[0]);
					w.y = Std.parseInt(gates[1]);
					w.toTownName = gates[2];// [2] is a string - town name
					w.warpLocations = new Array<Point>();
					w.warpInt = s;
					/*
					warpGates[s][0] = Std.parseInt(gates[0]);
					warpGates[s][1] = Std.parseInt(gates[1]);
					warpGates[s][2] = gates[2];// [2] is a string - town name
					warpGates[s][3] = new Array<Point>();*/
					
					//warpGates[s][3] = allWarpGates[s][3].split("|");
					var wLocs:Array<String> = gates[3].split("|");
					for (t in 0...wLocs.length) {
						var xy:Array<String> = wLocs[t].split(",");
						var p:Point = new Point(Std.parseInt(xy[0]), Std.parseInt( xy[1]) );
						//warpGates[s][3].push(p);
						w.warpLocations.push(p);
					}
					
					tileManager.newWarpTile(warpGates.length);
					warpGates.push(w);				
				}
			}
			
			extendTilesLoop(0);
			extendTilesLoop(1);
			extendTilesLoop(2);
			//largerthanView.sort(Array.UNIQUESORT);
			//largerthanView.sort(sortByY);
			
			resetBitmap(true);		
		}
		isBusy = false;
	}
	private function outputSTR():String{
		var strmap:String;
		
		var fv:Int = fillcolour;
		if(bgfill!=0){
			fv = bgfill;
		}  
		
		strmap = columns+","+rows+","+fv+"#";
		for (p in 0...rows) {
			for( i in 0...columns) {
				strmap += map[p][i][0]+":";
				strmap += map[p][i][1]+":";
				strmap += map[p][i][2]+":";
				strmap += map[p][i][3];
				if (i != columns-1) {
					strmap +="|";
				}
			}
			if (p!=rows-1) {
				strmap +="&";
			}
		}
		strmap += "#";
			
		for (s in warpGates) {
			strmap += s.x + ":";
			strmap += s.y + ":";
			strmap += s.toTownName + ":";
			for(t in 0...s.warpLocations.length){
				strmap += s.warpLocations[t].x;
				strmap += ",";
				strmap += s.warpLocations[t].y;
				
				if (t != s.warpLocations.length-1) {
					strmap +="|";
				}
			}
			if (s != warpGates[warpGates.length-1]) {
				strmap +="&";
			}
		}
		return strmap;
	}
	
	private function extendTilesLoop(layer:Int):Void{
		for (i in 0...rows) {
			for (o in 0...columns) {
				var key:Int = map[i][o][layer];
				
				if (key!=0) {
						
					if(!Func.isiteminarray(ignoreList,key)){
						var dtile:TileObject = tilenum[key];
											
						if(dtile.extendsStandardTile){//if (tiledic[dtile][7]) {
							var sWidth:Int = Std.int(dtile.width);// tilenum[key][8];
							var sHeight:Int = Std.int(dtile.height);// tilenum[key][9];
							
							var xxf:Int = Std.int((o * tileWidth) - dtile.xoffset);// tilenum[key][1];
							var yyf:Int = Std.int((i * tileHeight) - dtile.yoffset);// tilenum[key][2];

							largerthanView.push([i,o,sWidth,layer,sHeight,xxf,yyf]);							
						}
						if (tilenum[key].ani_hasAnimation){//[4][0]) {
							var numKey:Int = (i * columns) + o;

							anitileList[numKey] = [1, dtile.totalFrames];//FrameNum , totalFrames
						}
					}
				}
			}
		}
	}

	private function setlayer(e:MouseEvent):Void{
		var mc:ToggleButton = cast(e.currentTarget, ToggleButton);
		var nowlayer:Int = mc.valueInt;
		
		activelayer = nowlayer;
		
		if (nowlayer == 4) {
			// just selected WARP layer button - open up the settings panel for the warps
			shwmenu();
			resetPhantomTile();
		}else {
			// other layers - show sprite sheet
			showSheets();
		}
	}
	private function setvisi(e:MouseEvent):Void {
		var mc:ToggleButton = cast(e.currentTarget, ToggleButton);
		var num:Int = mc.valueInt;
		visibleLayer[num] = !visibleLayer[num];
		
		mc.toggle(visibleLayer[num]);
		resetBitmap();
	}
	private function showWalkableTiles(e:MouseEvent):Void {
		var mc:ToggleButton = cast(e.currentTarget, ToggleButton);
		var num:Int = mc.valueInt;
		visibleLayer[num] = !visibleLayer[num];
		
		generateWalkNodes();
		mc.toggle(visibleLayer[num]);
		resetBitmap();
	}
	private function generateWalkNodes():Void {
		walkNodesMap = new Array<Array<Array<WalkNode>>>();
		for (z in 0...rows+1) {
			walkNodesMap.push(new Array<Array<WalkNode>>());
			walkNodesMap.push(new Array<Array<WalkNode>>());
			walkNodesMap.push(new Array<Array<WalkNode>>());
			for (q in 0...columns+1) {
				walkNodesMap[z*3].push(new Array<WalkNode>());
				walkNodesMap[z*3].push(new Array<WalkNode>());
				walkNodesMap[z*3].push(new Array<WalkNode>());		
				
				walkNodesMap[(z*3)+1].push(new Array<WalkNode>());
				walkNodesMap[(z*3)+1].push(new Array<WalkNode>());
				walkNodesMap[(z*3)+1].push(new Array<WalkNode>());		
				
				walkNodesMap[(z*3)+2].push(new Array<WalkNode>());
				walkNodesMap[(z*3)+2].push(new Array<WalkNode>());
				walkNodesMap[(z*3)+2].push(new Array<WalkNode>());
			}
		}
		// base layer
		for (z in 0...rows) {
			for (q in 0...columns) {
				var tob:TileObject = tilenum.get(map[z][q][0]);
				
				if (tob == null) { 
					continue;
				}
				
				if (tob.isWalkable) {
					if (tob.isSpecialWalkType) {
						walkNodesAddWalkForm(z, q - 1, 	tob.walkGLevel, tob.walkNode_L, tob.depthPoint);
						walkNodesAddWalkForm(z, q, 		tob.walkGLevel, tob.walkNode_M, tob.depthPoint);
						walkNodesAddWalkForm(z, q + 1, 	tob.walkGLevel, tob.walkNode_R, tob.depthPoint);
					}else {
						walkNodesAddWalkForm(z, q, 0, [1, 1, 1,  1, 1, 1,  1, 1, 1], 0);
					}
				}				
			}
		}
		//
	}
	private function walkNodesAddWalkForm(rowx:Int, colx:Int, glevel:Int, arr:Array<Int>, addDepth:Float):Void {
		if (arr == null) {
			return;
		}
		if (map[rowx] == null) {
			return;
		}
		if (map[rowx][colx] == null) {
			return;
		}
		
		var sy:Float = rowx * tileHeight + 7.5;
		var sx:Float = colx * tileWidth + 7.5;
		var gap:Float = 50 / 3;
		for (i in 0...3) {
			for (j in 0...3) {
				if (arr[((i) * 3) + j] == 1) {

					// can walk here
					var wnode:WalkNode = new WalkNode();
					wnode.x = sx + (16.6) * j;
					wnode.y = sy + (16.6) * i;
					wnode.depth = Std.int(addDepth);
					wnode.level = glevel;
					
					var nx:Int = cast(Math.floor(wnode.x/ gap), Int);
					var ny:Int = cast(Math.floor(wnode.y / gap), Int);
					
					// if there already is a walkNode on the same glevel as this one, then don't add another - prevent duplicates
					var addToNodes:Bool = true;
					for (w in walkNodesMap[ny][nx]) {
						if (w.level == glevel) {
							addToNodes = false;
							break;
						}
					}
					
					if (addToNodes) {
						if (walkNodesMap[ny-1] != null) {
							for (w in walkNodesMap[ny-1][nx]) {
								if (w.level == glevel) {
									wnode.addNeighbour(w);
									w.addNeighbour(wnode);
								}
							}
						}
						if (walkNodesMap[ny][nx - 1] != null) {
							for (w in walkNodesMap[ny][nx-1]) {
								if (w.level == glevel) {
									wnode.addNeighbour(w);
									w.addNeighbour(wnode);
								}
							}
						}
						walkNodesMap[ny][nx].push(wnode);						
					}					
				}
				
			}
		}
	}
	private function erased(e:MouseEvent):Void{
		eraseBrush = true;
		resetPhantomTile();
		updateSelectedTileInfo();
	}
	public function resetPhantomTile():Void {
		groundclip.removeChild(phantomtile);
		phantomtile = new SelectorCD();
		phantomtile.alpha = .3;
		phantomtile.xoffset = 0;
		phantomtile.yoffset = 0;
		groundclip.addChild(phantomtile);
	}

	private function startplacetile(e:MouseEvent):Void{
		if (!isBusy && !cineEditMode) {
			prePlace = "";
			placer.addEventListener(Event.ENTER_FRAME, placetile);
		}
	}
	private function stopplacetile(e:MouseEvent):Void{
		placer.removeEventListener(Event.ENTER_FRAME,placetile);
	}
	private function mouseInMapArea():Bool {
		return (stage.mouseY > 0 && stage.mouseY < GameScreenHeight &&	stage.mouseX < gameEdgeRight && stage.mouseX > gameEdgeLeft);
	}
	private function placetile(e:Event):Void{
		if(saveBusy){
			return;
		}
		
		var spritego:Bool = true;
		if(mySpriteSheet!=null){
			if (mySpriteSheet.hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				spritego = false;
			}
		}	
		
		var dx:Int =  Math.floor((groundclip.mouseX + cam_point.x) / tileWidth) * tileWidth;
		var dy:Int = Math.floor((groundclip.mouseY + cam_point.y) / tileHeight) * tileHeight;
		
		var bar:String = dx + "_" + dy;
		
		var ex:Int =  Math.floor((groundclip.mouseX + cam_point.x) / tileWidth);
		var ey:Int = Math.floor((groundclip.mouseY + cam_point.y) / tileHeight);
		
		if (mouseInMapArea() && spritego && !cineEditMode) {					
			if (bar !=prePlace) {
				if ((dy/tileHeight)<rows && ex>=0 && ex<columns) {
					prePlace = bar;
					save_btt_toggle.toggle(true); // there has been a change to the map -> save is now valid
										
					if (eraseBrush) {
						// remove the tile
						removeGate(ey, ex);
						if(activelayer!=4){
							removeAnimationTile(ey,ex,activelayer);
							map[ey][ex][activelayer]=0;
						}
						resetBitmap();
					}else if (activelayer == 4) {
						// Warp Layer - PLACE WARPS ONLY
						// more than one warp on one cell ????
						var over:Bool = false;
						if (warp_selected == null) {
							addChild(new ErrorMessage("You must select a warp to use - See settings",  gameEdgeLeft, GameScreenHeight - 20));
							return;
						}						
						for(s in warp_selected.warpLocations){
							if(s.x == ex && s.y == ey){
								over = true;
								break;
							}
						}
						if(!over){
							warp_selected.warpLocations.push(new Point(ex,ey));
							resetBitmap();
						}
					} else {
						// normal tiles bg/objects/sky/EVENT
						if(selected_Array.length>0){
							
							var eyst:Int = ey;
							var exst:Int = ex;
							for(ro in 0...selected_Array.length){
								for(co in 0...selected_Array[0].length){
									ey = eyst + ro;
									ex = exst + co;
									
									if(ey < rows && ex <columns){
									
										removeAnimationTile(ey,ex,activelayer);
										map[ey][ex][activelayer]=selected_Array[ro][co];
										if (tilenum[map[ey][ex][activelayer]].ani_hasAnimation) { //if (tiledic[tilenum[map[ey][ex][activelayer]][0]][4][0]) {
										
											
											anitileList[ numSpacer(ey,ex) ] = [ey,ex,activelayer,1];
										}
									}
								
								}
							}
						}else{
							removeAnimationTile(ey,ex,activelayer);
							map[ey][ex][activelayer]=selectedtile;
							if (tilenum[map[ey][ex][activelayer]].ani_hasAnimation) {//if (tiledic[tilenum[map[ey][ex][activelayer]][0]][4][0]) {
								//anitileList[ey+"_"+ex]=[ey,ex,activelayer,1];
								
								anitileList[ numSpacer(ey,ex) ] = [ey,ex,activelayer,1];
								
							}
							
							
							var key:Int = selectedtile;
							if(!Func.isiteminarray(ignoreList,key)){
								var dtile = tilenum[key];
								if (dtile.extendsStandardTile) {//if (tiledic[dtile][7]) {
									var sWidth:Float = dtile.width; // tilenum[key][8];
									var sHeight:Float = dtile.height; // tilenum[key][9];
									var i:Int = ey;
									var o:Int = ex;
									//trace("WH:",sWidth,sHeight,"     ",key,tilenum[key]);
			
									var xxf:Int = Std.int((o * tileWidth) - dtile.xoffset);// tilenum[key][1];
									var yyf:Int = Std.int((i * tileHeight) - dtile.yoffset);// tilenum[key][2];
			
									largerthanView.push([i,o,sWidth,activelayer,sHeight,xxf,yyf]);
								}
							}
						}
						resetBitmap();
						//
					}
				}
			}
		}
	}
	private function removeGate(ey:Int,ex:Int):Void{
		for (s in warpGates) {
			/*for(t in 0...warpGates[s][3].length){//for(t in warpGates[s][3]){
				if( warpGates[s][3][t][0]==ex && ey==warpGates[s][3][t][1]){
					warpGates[s][3].splice(t,1);
				}
			}*/
			
			for(t in 0...s.warpLocations.length){
				if( s.warpLocations[t].x == ex && ey == s.warpLocations[t].y){
					s.warpLocations.splice(t, 1);
					break;
				}
			}
		}
	}
	private function removeAnimationTile(ey:Int,ex:Int,activelayer:Int):Void{
		if (map[ey][ex][activelayer]!=0) {
			//trace("REMOVE IN:",1,map[ey][ex][activelayer]);
			//trace("REMOVE IN:",1.5,map[ey][ex][activelayer],tilenum[map[ey][ex][activelayer]][4]);
			if (tilenum[map[ey][ex][activelayer]].ani_hasAnimation){ //[4][0]) {
				//trace("REMOVE IN:",2);
				for (i in 0...anitileList.length) {//for (var i in anitileList) {
					if (anitileList[i] == null) {
						continue;
					}
					if (anitileList[i][0] == ey && anitileList[i][1]==ex && anitileList[i][2]==activelayer) {
						//delete anitileList[i];
						anitileList.splice(i, 1);
						break;
					}
				}
			}
		}
	}
	private function ghosttile(e:MouseEvent):Void{
		if (mouseInMapArea()) {
			phantomtile.visible = true;
			var dx:Int = Math.floor((groundclip.mouseX+cam_point.x)/tileWidth);
			var dy:Int = Math.floor((groundclip.mouseY+cam_point.y)/tileHeight);
			
			mouseCoordinate.x = dx;
			mouseCoordinate.y = dy;
			
			if(map[dy] == null){
				return;
			}else if(map[dy][dx] == null){
				return;
			}
			
			var ww:Int = 0;
			if(map[dy] != null && map[dy][dx]!=null){
				if( map[dy][dx][0] != 0){
					//ww = tilenum[ map[dy][dx][0] ][6];
					//ww = tilenum[ map[dy][dx][0] ].walkType;
				}
			}
			
			tile_0.text = map[dy][dx][0]+"";
			tile_1.text = map[dy][dx][1]+"";
			tile_2.text = map[dy][dx][2]+"";
			tile_3.text = map[dy][dx][3]+"";
			

			//
			phantomtile.x = ( dx* tileWidth)-cam_point.x-phantomtile.xoffset;
			phantomtile.y = ( dy* tileHeight)-cam_point.y-phantomtile.yoffset;
		}else{
			phantomtile.visible = false;
		}
	}
	public function setghosttile():Void {
		if (phantomtile != null) {
			if (groundclip.contains(phantomtile)) {
				groundclip.removeChild(phantomtile);
			}
		}
		
		phantomtile = new MovieClip();
		phantomtile.alpha = .3;

		var bitImage:BitmapData = tilebitdata[selectedtile];
		var bit:BitmapData = bitImage;
		var bitm:Bitmap = new Bitmap(bit);
		
		phantomtile.addChild(bitm);
		phantomtile.xoffset = tilenum[selectedtile].xoffset;
		phantomtile.yoffset = tilenum[selectedtile].yoffset;
		
		groundclip.addChild(phantomtile);
	}
	private function mouseCamScrollWheel(e:MouseEvent):Void {
		// mouse wheel moves camera y up/down
		if (mouseInMapArea()) {
			if (e.delta>0) {
				//scroll up
				if (cam_point.y>0) {
					var yls:Int = 15;
					cam_point.y -= yls;
					if (cam_point.y<0) {
						cam_point.y = 0;
					}
					resetBitmap();
				}
			} else {
				//scroll down

				if (cam_point.y<((rows * tileHeight)-GameScreenHeight)) {
					var yrs:Int = 15;
					cam_point.y += yrs;
					if (cam_point.y>(rows * tileHeight)-GameScreenHeight) {
						cam_point.y = (rows * tileHeight)-GameScreenHeight;
					}
					resetBitmap();
				}
			}
		}
	}
	private function mouseCamScroll(e:Event):Void {
		// mouse hover on sides moves camera left/right
		if (mouseInMapArea() && !cineEditMode) {
			if (stage.mouseX > gameEdgeRight-100  && cam_point.x<(columns * tileWidth)-GameScreenWidth && stage.mouseX<gameEdgeRight) {
				var rp:Float = (100-(gameEdgeRight-stage.mouseX))/100;
				var rs:Int = Std.int(15* rp);
				cam_point.x += rs;
				if (cam_point.x>(columns * tileWidth)-GameScreenWidth) {
					cam_point.x = (columns * tileWidth)-GameScreenWidth;
				}
				resetBitmap();
			} else if (stage.mouseX < gameEdgeLeft+100 && stage.mouseX > gameEdgeLeft && cam_point.x>0) {
				//window move left
				var lp:Float = (100-(stage.mouseX-gameEdgeLeft))/100;
				var ls:Int = Std.int(15* lp);
				cam_point.x -= ls;
				if (cam_point.x<0) {
					cam_point.x = 0;
				}
				resetBitmap();
			}
		}
	}
		
	private function updateStatusInfoBar():Void {
		var str:String = "Camera : " + cam_point.x + " x " + cam_point.y;
		str += "         ";
		str += "R | C : <font color='#FF3300'>" + mouseCoordinate.y + "</font> | <font color='#00CCFF'>"+ mouseCoordinate.x+"</font>";
		
		statusinfo_txt.htmlText = str;	
	}
	
	private function resetCamera():Void {
		cam_point.x = 0;
		cam_point.y = 0;
	}
	
	private function resetBitmap(runonce:Bool=false):Void{
		updateStatusInfoBar();

		if (runonce) {
			anitileList = [];
		}

		bufferBD.lock();
		skybuffer.lock();

		var colstart:Int = Math.floor((cam_point.x-50)/50);
		if (colstart<0) {
			colstart = 0;
		}
		
		var colWidth:Int = Std.int((GameScreenWidth / tileWidth)+1);
		var colend:Int = colstart+colWidth;
		if (colend>columns-1) {
			colend = columns-1;
		}
		//
		var yst:Int = Math.floor((cam_point.y-50)/50);
		if (yst<0) {
			yst = 0;
		}
		
		var yHeight:Int = Std.int((GameScreenHeight / tileHeight)+1);
		var yend:Int = yst+yHeight;
		if (yend>rows-1) {
			yend = rows-1;
		}
		
		
		bufferBD.fillRect(bufferBD.rect, 0x000000);
		if(bgfill > 0){
			bufferBD.copyPixels(tilebitdata[bgfill], new Rectangle(0, 0 , GameScreenWidth, GameScreenHeight) , new Point(tileWidth, tileHeight));
		}else{
			bufferBD.fillRect(new Rectangle(0, 0, (colend + 1 - colstart) * tileWidth, (yend + 1 - yst) * tileHeight), fillcolour);
		}

		skybuffer.fillRect(bufferBD.rect,fillcolour);
		
		var tileList1Return:Array<Array<DrawObject>> = new Array<Array<DrawObject>>();
		var tileList1:Array<DrawObject> = new Array<DrawObject>();
		
		if (visibleLayer[0]) {
			//BG Layer - always behind hero
			tileList1Return = listLoop(0, runonce, yst, yend, colstart, colend);
			tileList1 = tileList1Return[0];
			//theloop(0,runonce,yst,yend,colstart,colend);
		}
		
		if (visibleLayer[1]) {
			// Objects Layer - depth is sorted by y
			var tileList2Return:Array<Array<DrawObject>> = listLoop(1, runonce, yst, yend, colstart, colend);
			var tileList2:Array<DrawObject> = new Array<DrawObject>();
			tileList1 = tileList1.concat( tileList2Return[1]);			
			tileList2 = tileList2Return[0];
			
			var extendList:Array<DrawObject> = listExtensions(yst,yend,colstart,colend);	
			tileList2 = tileList2.concat(extendList);
			tileList2.sort(sortByY);			//tileList2.sortOn(["y","x"], Array.NUMERIC);

			tileList1= tileList1.concat(tileList2);
		}
		if (visibleLayer[2]) {
			// Sky Layer - always above hero
			var tileList3Return:Array<Array<DrawObject>> = listLoop(2,runonce,yst,yend,colstart,colend);
			//theloop(2,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList3Return[0]);
		}
		
		
		if (visibleLayer[3]) {
			// invisible Action Event Layer
			var tileList4Return:Array<Array<DrawObject>> = listLoop(3,runonce,yst,yend,colstart,colend);
			//theloop(3,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList4Return[0]);
		}
		
		//
		drawAll(tileList1);
		
		//
		skyclip.graphics.clear();
		if (visibleLayer[5]) {
			// Walkable Layer 

			var camx:Float = cam_point.x;
			var camy:Float = cam_point.y;

			var gridCol:Array<UInt> = [0xfff000, 0xff0000, 0x00ff00];
			for (z in (yst*3)...((yend+1)*3)) {
				for (q in (colstart * 3)...((colend + 1) * 3)) {
					
					for (w in walkNodesMap[z][q]) {
						for (edge in w.neighbours) {
							skyclip.graphics.lineStyle(.5, gridCol[w.level]);
							
							skyclip.graphics.moveTo((w.x-camx), ((w.y+w.depth)-camy) );
							skyclip.graphics.lineTo((edge.x-camx), ((edge.y+edge.depth)-camy));
						}
						
					}
					
				}
			}
			
			
			
		}
		
		
		if (visibleLayer[7]) {
			// show grid-------------
			skyclip.graphics.lineStyle(1, 0xff0000);
			var camx:Int = cast(cam_point.x % TileManager.tileWidth, Int);
			var camy:Int = cast(cam_point.y % TileManager.tileHeight, Int);
			
			for (iy in 0...rows) {
				skyclip.graphics.moveTo(0-camx, iy*TileManager.tileHeight-camy);
				skyclip.graphics.lineTo(GameScreenWidth-camx, iy * TileManager.tileHeight-camy);
			}
			for (ix in 0...columns) {
				skyclip.graphics.moveTo(ix*TileManager.tileWidth -camx, 0-camy);
				skyclip.graphics.lineTo(ix*TileManager.tileWidth -camx, GameScreenHeight-camy);
			}
			
		}

		//
		if (visibleLayer[4]) {
			// Show warpgates
			for (s in warpGates) { 
				for (t in s.warpLocations) { //for (var t in warpGates[s][3]) {
					var z:Int = Std.int(t.y); // warpGates[s][3][t][1];
					var q:Int = Std.int(t.x); // warpGates[s][3][t][0];

					//var dtile:Class = getDefinitionByName("tl_wg_" + s)  as Class;
					//var key:Int = tiledic[dtile][0];
					var key:Int = tileManager.tiledic.get("tl_wg_" + s.warpInt).key;
					var dx:Float = (q * tileWidth)- cam_point.x + tileWidth;
					var dy:Float = (z * tileHeight)- cam_point.y + tileHeight;
					var pt:Point = new Point(dx, dy);
					var rec:Rectangle =  new Rectangle(0, 0, tileWidth, tileHeight);
					bufferBD.copyPixels(tilebitdata[key], rec, pt,null,null,true);
				}
			}
		}
		//

		bufferBD.unlock();
		skybuffer.unlock();
		canvasBD.copyPixels(bufferBD,new Rectangle(tileWidth,tileHeight,bufferBD.width,bufferBD.height) ,new Point(0,0));
		skyBD.copyPixels(skybuffer,new Rectangle(tileWidth,tileHeight,skybuffer.width,skybuffer.height) ,new Point(0,0));
	}
	
	private function sortByY(a:DrawObject, b:DrawObject):Int {
		if (a.y == b.y) return 0;
		if (a.y > b.y) return 1;
		return -1;
	}

	private function listExtensions(yst:Int,yend:Int,colstart:Int,colend:Int):Array<DrawObject> {
		
		var campointx:Float = cam_point.x;
		var campointy:Float = cam_point.y;
		var clipRect:Rectangle = new Rectangle(0,0,50,50);
		var dlist:Array<DrawObject> = new Array<DrawObject>();
		var ob:DrawObject;
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
		for (a in 0...largerthanView.length) {
			if (largerthanView[a][0]>yend || largerthanView[a][0]<yst ||
			  largerthanView[a][1]>colend || largerthanView[a][1]<colstart) {
				
				clipRect.x = largerthanView[a][5]-campointx+tileWidth;
				clipRect.y = largerthanView[a][6]-campointy+tileHeight;
				clipRect.width = largerthanView[a][2];
				clipRect.height = largerthanView[a][4];

				if (clipRect.intersects(bufferRect)) {

					z = largerthanView[a][0];//yoffset
					q = largerthanView[a][1];//xoffset
					layer = largerthanView[a][3];
					key = map[z][q][layer];
					
					if(key == 0){
						continue;
					}
					
					ob = new DrawObject();
					ob.x = q * tileWidth;
					ob.y = z * tileHeight;
					ob.bitmapData = tilebitdata[key];
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

	private function drawAll(superArray:Array<DrawObject>):Void{
		var dispList:Array<DrawObject> = superArray;
		var pPo:Point = new Point(0,0);
		var rRe:Rectangle = new Rectangle(0,0,0,0);
		
		for (len in dispList) {
			pPo.x = len.xoff;
			pPo.y = len.yoff;
			rRe.width = len.width;
			rRe.height = len.height;	
			bufferBD.copyPixels(len.bitmapData, rRe, pPo);
		}			
	}

	private function pastetile(z:Int,q:Int,layer:Int):Void{
		var whichBuffer:BitmapData = bufferBD;

		var key:Int = map[z][q][layer];
		var tob:TileObject = tilenum[key];

		var dx:Int = Std.int((q * tileWidth)-cam_point.x+tileWidth);
		var dy:Int = Std.int((z * tileHeight)-cam_point.y+tileHeight);
		
		//var pt:Point = new Point(dx-(tilenum[key][1]), dy-(tilenum[key][2]));
		var pt:Point = new Point(dx-(tob.xoffset), dy-(tob.yoffset));
		var rec:Rectangle =  new Rectangle(0, 0, tilebitdata[key].width, tilebitdata[key].height);
		
		
		
		if (tob.ani_hasAnimation && anitileList[numSpacer(z, q)]) {//if (tob.ani_hasAnimation && anitileList[z+"_"+q]) { //if (tilenum[key][4][0] && anitileList[z+"_"+q]) {
			var toPaste:Int = anitileList[numSpacer(z, q)][3]+1;

			if (toPaste>tob.totalFrames){ //tilenum[key][5]) {
				toPaste=1;
				//anitileList[z+"_"+q][3]=0;
				anitileList[numSpacer(z, q)][3]=0;
				
			}
			//anitileList[z+"_"+q][3]++;
			anitileList[numSpacer(z, q)][3]++;
			
			
			//bufferBD.copyPixels(tilebitdata[key+"_"+toPaste], rec, pt);
			bufferBD.copyPixels(tilebitdata[ numSpacer(key, toPaste) ], rec, pt);
		} else {
			whichBuffer.copyPixels(tilebitdata[key], rec, pt,null,null,true);
		}
	}

	private function listLoop(layer:Int,runonce:Bool,yst:Int,yend:Int,colstart:Int,colend:Int):Array<Array<DrawObject>> {
		var dlist:Array<DrawObject> = new Array<DrawObject>();
		var sendtobot:Array<DrawObject> = new Array<DrawObject>();
		var ob:DrawObject;
		var numKey:Int;
		var key:Int;
		var xoffset:Int;
		var yoffset:Int;
		var pPoint:Point = new Point();
		var rRect:Rectangle = new Rectangle(0,0,0,0);
		
		var campointx:Int = cast(cam_point.x, Int);
		var campointy:Int = cast(cam_point.y, Int);
		
		var tob:TileObject;
		
		for (z in yst...(yend+1)) {
			if (z>=0) {
				for (q in colstart...(colend+1)) {
					if (q>=0) {
						if (map[z][q][layer]>0) {
							//q -> xoffset
							//z -> yoffset
							
							key = map[z][q][layer];
							tob = tilenum[key];
							
							//--- selected tile has visiblity set to false
							if (!visibleLayer[6]) {
								if (key == selectedtile) {
									continue;
								}
							}
							//---

							xoffset = (q * tileWidth)-campointx+tileWidth;
							yoffset = (z * tileHeight)-campointy+tileHeight;

							ob = new DrawObject();
							ob.x = (q * tileWidth);

							ob.y = (z * tileHeight) + layer + tob.depthPoint; //tilenum[key][10];

							numKey = (z * columns) + q;
							
							if(anitileList[numKey] != null && tob.ani_hasAnimation){ //tilenum[key][4][0]){
								//ob.bitmapData = tilebitdata[key+"_"+anitileList[numKey][0]];
								ob.bitmapData = tilebitdata[numSpacer(key, anitileList[numKey][0])];
								if(anitileList[numKey][0]+1>anitileList[numKey][1]){
									anitileList[numKey][0] = 1;
								}else{
									anitileList[numKey][0]++;
								}									
							}else{
								ob.bitmapData = tilebitdata[key];
							}
							
							
							ob.width = tilebitdata[key].width;
							ob.height = tilebitdata[key].height;
							
							ob.xoff = xoffset - (tob.xoffset);// tilenum[key][1]);
							ob.yoff = yoffset - (tob.yoffset);// tilenum[key][2]);
							
							if(layer==1){
								if(tob.sendToGround){ //tilenum[key][3]){
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
		if (layer == 1) {
			var r:Array<Array<DrawObject>> = [dlist, sendtobot];
			return r;
		}else {
			var r2:Array<Array<DrawObject>> = [dlist];
			return r2;
		}
	}

	private function Mapsize(type:String,num:Int):Int {
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

	private function keyscan(e:KeyboardEvent):Void{
		if(pressKeys.exists(e.keyCode)){
			return;
		}
		if(e.shiftKey){
			addExtraRowsCols(e.keyCode);
		}else if(e.ctrlKey){
			trimmap(e.keyCode);
		}
		
		pressKeys[e.keyCode] = true;
	}

	private function stopkeyscan(e:KeyboardEvent):Void {
		pressKeys.remove(e.keyCode);
		 //delete pressKeys[ e.keyCode ];
	} 
	
	public function addExtraRowsCols(keypress:Int):Void{
		var rowx:Array<Array<Int>> = new Array<Array<Int>>();
		var tt:Int;
		var restmap:Bool = false;
		switch (keypress) {
			case 38 :
			//top
				rows++;
				for (i in 0...columns) {
					rowx.push([0,0,0,0]);
				}

				map.unshift(rowx);
				restmap = true;
				
				
				for (i in 0...largerthanView.length) {
					tt = (largerthanView[i][0] * tileHeight)-largerthanView[i][6];	
					largerthanView[i][0]++;
					largerthanView[i][6] = (largerthanView[i][0] * tileHeight)-tt;		
				}
				for(sw in warpGates){
					//for(s in warpGates[sw][3]){
					//	warpGates[sw][3][s][1]++;
					//}
					for(s in sw.warpLocations){
						s.y++;
					}
				}

				//break;
			case 40 :
			//bottom
				rows++;
				for (i in 0...columns) {
					rowx.push([0,0,0,0]);
				}
				
				map.push(rowx);
				restmap = true;
				//break;

			case 37 :
			//left
				columns++;
				for (i in 0...rows) {
					map[i].unshift([0,0,0,0]);
				}

				restmap = true;
				
				for (i in 0...largerthanView.length) {
					tt = (largerthanView[i][1] * tileWidth)-largerthanView[i][5];	
					largerthanView[i][1]++;
					largerthanView[i][5] = (largerthanView[i][1] * tileWidth)-tt;		
				}
				for(sw in warpGates){
					//for(s in warpGates[sw][3]){
					//	warpGates[sw][3][s][0]++;
					//}
					for(s in sw.warpLocations){
						s.x++;
					}
				}
				
				//break;
			case 39 :
			//right
				columns++;
				for (i in 0...rows) {
					map[i].push([0,0,0,0]);
				}

				restmap = true;
				//break;
		}
		if (restmap) {
			resetBitmap(true);
			shwmenu();
		}
	}
	public function trimmap(keypress:Int):Void{
		var restmap:Bool = false;
		var i:Int = 0;
		var tt:Int;
		switch (keypress) {
			case 38 :
			//up
				if (rows < 2) {
					return;
				}
				rows--;
				map.shift();
				restmap = true;
				
				for (i in 0...largerthanView.length) {
					tt = (largerthanView[i][0] * tileHeight)-largerthanView[i][6];	
					largerthanView[i][0]--;
					largerthanView[i][6] = (largerthanView[i][0] * tileHeight)-tt;		
				}
				for(sw in warpGates){
					//for(s in warpGates[sw][3]){
						//warpGates[sw][3][s][1]--;
					//}
					for(s in sw.warpLocations){
						s.y--;
					}
				}

			case 40 :
			//bottom
				if (rows < 2) {
					return;
				}
				if(cam_point.y>0){
					cam_point.y -=tileHeight;
				}
				rows--;
				map.pop();
				restmap = true;

			case 37 :
			//left
				if (columns < 2) {
					return;
				}
				columns--;
				for (i in 0...rows) {
					map[i].shift();
				}

				restmap = true;
				
				for (i in 0...largerthanView.length) {
					if (largerthanView[i] == null) {
						continue; // object has been removed
					}
					tt = (largerthanView[i][1] * tileWidth)-largerthanView[i][5];	
					largerthanView[i][1]--;
					largerthanView[i][5] = (largerthanView[i][1] * tileWidth)-tt;
					
					if(largerthanView[i][1] < 0){
						// remove the object from the largerthanView array
						//largerthanView.splice(i, 1 );
						//i--;
						largerthanView[i] = null;
					}
				}
								
				for (sw in warpGates) {
					for(s in sw.warpLocations){
						s.x--;
					}
					
					//for(s in warpGates[sw][3]){
					//	warpGates[sw][3][s][0]--;
					//}
				}

			case 39 :
			//right
				if (columns < 2) {
					return;
				}
				columns--;
				if(cam_point.x>tileWidth){
					cam_point.x -=tileWidth;
				}
				for (i in 0...rows) {
					map[i].pop();
				}

				restmap = true;
		}
		if (restmap) {
			resetBitmap(true);
			shwmenu();
		}
	}
	
	private function isiteminarray (arrayx:Array<Dynamic>, item:Dynamic):Bool {
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
	
	private function numSpacer(ox:Int, oy:Int):Int {
		return Std.parseInt(ox + tileNumSpacer + oy);
	}
	
	public function notEraseBrush():Void {
		eraseBrush = false;
		eraser.toggle(false);
		
		visibleLayer[6] = true; // not a layer, but selectedtilevisibility
		visi_selectedTile_btt.toggle(true);
	}
	
	public function updateSelectedTileInfo(addToPrev:Bool = true ):Void {		
				
		if (selectedtile != 0 && !eraseBrush) {
			
			// Add to previously selected list
			if (this.s_tilenumtxt.text != selectedtile+"" && addToPrev) {
				previouslyUsed();
			}			
			//
			
			this.s_tilenumtxt.text = selectedtile + "";
			//this.s_walktypetxt.text = tilenum[selectedtile].walkType + "";
			
			if (selected_bit != null) {
				removeChild(selected_bit);
			}		
			
			var bitImage:BitmapData = tilebitdata[selectedtile];
			var bit:BitmapData = bitImage;
			selected_bit = new Bitmap(bit);
			selected_bit.x = 610;
			selected_bit.y = 690;
			selected_bit.width = tileWidth;
			selected_bit.height = tileHeight;
			addChild(selected_bit);
			
			
			
		}else {
			this.s_tilenumtxt.text = "-";
			//this.s_walktypetxt.text = "-";
		}
	}
	public function previouslyUsed():Void {
		var bit:BitmapData = tilebitdata[selectedtile];
		var ss:Bitmap = new Bitmap(bit);
		var sbit:MovieClip = new MovieClip();
		sbit.addChild(ss);		
		sbit.width = tileWidth;
		sbit.height = tileHeight;
		sbit.tilenumber = selectedtile;
		sbit.addEventListener(MouseEvent.CLICK, select_tile);
		
		previouslyUsedTiles.push(sbit);
		refreshPreviouslyUsedTiles();
	}
	private function select_tile(e:MouseEvent):Void {
		var mc:MovieClip = cast(e.currentTarget, MovieClip);
		notEraseBrush();
		
		selected_Array = [[mc.tilenumber]];
		selectedtile = selected_Array[0][0];
		
		setghosttile();
		updateSelectedTileInfo(false);
	}
	private function refreshPreviouslyUsedTiles():Void {
		var i:Int = 0;
		
		if (previouslyUsedTiles.length > 80) {
			previouslyUsedTiles.shift();
		}
		
		for (rev in (-(previouslyUsedTiles.length - 1))...1) {			
			var ibit:Sprite = previouslyUsedTiles[rev*-1];
			ibit.x = ((i * 60) % GameScreenWidth) + gameEdgeLeft + 10; 
			ibit.y = Math.floor((i * 60) / GameScreenWidth) * 60 + GameScreenHeight+160;
			addChild(ibit);
			
			i++;
		}
		
	}

	private function cctv(e:MouseEvent):Void{
		cineEditMode = !cineEditMode;
		var e:ToggleButton = cast( e.currentTarget, ToggleButton);
		e.toggle(cineEditMode);
	}
	private function mDown(e:MouseEvent):Void{
		cineEditMode_Point.x = stage.mouseX;
		cineEditMode_Point.y = stage.mouseY;
	}
	private function mMove(e:MouseEvent):Void{ // moving the screen for cineEditMode
		if (cineEditMode_Point.x != 0 && cineEditMode_Point.y != 0 && stage.mouseY < 400 && cineEditMode) {
			var nx:Int = Std.int(stage.mouseX-cineEditMode_Point.x);
			var ny:Int = Std.int(stage.mouseY-cineEditMode_Point.y);
			cam_point.x = cam_point.x-nx;
			cam_point.y = cam_point.y-ny;
			
			resetBitmap();
			cineEditMode_Point.x = stage.mouseX;
			cineEditMode_Point.y = stage.mouseY;
		}
	}
	private function mUp(e:MouseEvent):Void{
		cineEditMode_Point.x = 0;
		cineEditMode_Point.y = 0;
	}
	
	public function disableInterface():Void {
		
	}
	private function optimizeGrass(e:MouseEvent):Void {
		for (rowx in 0...map.length) {
			for (colx in 1...map[rowx].length) {
				var ele:Array<Int> = map[rowx][colx];//[0,0,0,0]
				if (grassOptTiles.indexOf(ele[0]) > -1) {
					var pastEle:Array<Int> = map[rowx][colx-1];
					if (grassOptTiles.indexOf(pastEle[0]) > -1) {
						// large grass tile next to each other therefore must remove
						map[rowx][colx][0] = 0;
					}
				}
				
			}
		}
		resetBitmap();
		save_btt_toggle.toggle(true); // map has been changed, activate save button
	}
		
	private function saveMap(e:MouseEvent):Void {
		currentVersion++;
		saveMapManager.saveMap(authorName, currentmap, currentVersion, outputSTR());
		save_btt_toggle.toggle(false);
	}
	public function cancelSaveDialogue(mo:ModalScreen):Void {
		saveBusy = false;
		removeChild(mo);
	}
	public function promptSave():DialogueSave {
		var m:ModalScreen = new ModalScreen();
		var d:DialogueSave = new DialogueSave(m);
		d.x = m.width / 2;
		d.y = m.height / 2;
		//d.continueFunction = getMapFromDB;
		//d.continueParams = [key];
		m.addChild(d);
		
		addChild(m);
		
		return d;
	}
	
}