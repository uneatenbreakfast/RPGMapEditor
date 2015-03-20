package ;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
/**
 * ...
 * @author Nelson
 */
class DisplayManager extends MainStageMC
{
	private static var thisManager:DisplayManager;
	
	
	public inline static var tileHeight = 50;
	public inline static var tileWidth = 50;
	public inline static var screenWidth = 900;
	
	private var stageManager:Main;
	
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
	private var pressKeys:Map<Int, Bool> = new Map<Int, Bool>();
	
	private var isBusy:Bool = false;
	private var cineEditMode:Bool = false;
	
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
	private var tilenum:Map<Int, TileObject> = new Map<Int, TileObject>();
	//tilenum[key] = [class/string, xoffset, yoffset, sendtoGround,[animation,nonLoop],]

	/*
	 * tilenum[key][0] = e;//Class/String
	 * tilenum[key][3] = tiledic[e][3];//sendtoGround
	 * tilenum[key][4] = new Array();
	 * tilenum[key][4][0] = tiledic[e][4][0];//Animation
	 * tilenum[key][4][1] = tiledic[e][4][1];//nonLoop
	 * tilenum[key][4][2] = tiledic[e][4][2];//afterAnimationif_nonLoop
	 * tilenum[key][4][3] = tiledic[e][4][3];//syncTile
	 * tilenum[key][5] = 1;//totalframes
	 * tilenum[key][6] = tiledic[e][6];//walkType
	 * tilenum[key][7] = tiledic[e][7];//Extends standardTile
	 * tilenum[key][8] = tiledic[e][8];//width
	 * tilenum[key][9] = tiledic[e][9];//height
	 * tilenum[key][10] = tiledic[e][11];//depthpoint:int
	 */
	
	
	

	private var tiledic:Map<String, TileObject> = new Map<String,  TileObject>();
	
	private var spriteSheetWalkables:Array<Dynamic> = new Array<Dynamic>();
	private var tilesets:Array<Dynamic> = new Array<Dynamic>();
	private var spriteSheets:Array<Dynamic> = new Array<Dynamic>();

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
	
	public static function getInstance():DisplayManager {
		if (thisManager == null) {
			thisManager = new DisplayManager();
		}
		return thisManager;
	}
	
	public function new() :Void
	{			
		super();
		
		canvasBD = new BitmapData(900,400,false,0x333333);
		bufferBD = new BitmapData(900+(2* tileWidth),400+(2* tileHeight),false,0x333333);
		skyBD = new BitmapData(900,400,true,0x333333);
		skybuffer = new BitmapData(900+(2* tileWidth),400+(2* tileHeight),true,0x333333);

		tmpBit = new BitmapData(bufferBD.width, bufferBD.height, false, fillcolour);
		canvasBitmap = new Bitmap(canvasBD);
		skyBitmap = new Bitmap(skyBD);

		// Housekeeping
		//walk_eye.gotoAndStop(2);
	}
	
	function Engine(e:Event):Void{

		toolsbench.mask = toolscover;
		
		groundclip.addChild(canvasBitmap);
		skyclip.addChild(skyBitmap);
		hero.x = 400;
		hero.y = 200;
		
		addChild(groundclip);
		addChild(hero);
		addChild(skyclip);
		//addChild(new fpsBox(stage,0,400));
		//
		stage.addEventListener(MouseEvent.MOUSE_DOWN,startplacetile);
		stage.addEventListener(MouseEvent.MOUSE_UP,stopplacetile);
		stage.addEventListener(MouseEvent.MOUSE_MOVE,ghosttile);
		
		stage.addEventListener(MouseEvent.MOUSE_WHEEL,mouseCamScrollWheel);
		stage.addEventListener(Event.ENTER_FRAME,mouseCamScroll);
		
		eraser.addEventListener(MouseEvent.CLICK,erased);
		bg0.addEventListener(MouseEvent.CLICK,setlayer);
		bg1.addEventListener(MouseEvent.CLICK,setlayer);
		bg2.addEventListener(MouseEvent.CLICK,setlayer);
		bg3.addEventListener(MouseEvent.CLICK,setlayer);
		
		on0.addEventListener(MouseEvent.CLICK,setvisi);
		on1.addEventListener(MouseEvent.CLICK,setvisi);
		on2.addEventListener(MouseEvent.CLICK,setvisi);
		on3.addEventListener(MouseEvent.CLICK,setvisi);
		walk_eye.addEventListener(MouseEvent.CLICK,setvisi);
		
		sheets.addEventListener(MouseEvent.CLICK,showSheets);
		obis.addEventListener(MouseEvent.CLICK,setlayer);
		outputbtt.addEventListener(MouseEvent.CLICK,outputmap);
		inputbtt.addEventListener(MouseEvent.CLICK,showinput);
		shwmapsbttx.addEventListener(MouseEvent.CLICK,showmaplist);
		menusetbtt.addEventListener(MouseEvent.CLICK,shwmenu);
		stage.addEventListener(KeyboardEvent.KEY_DOWN,keyscan);
		stage.addEventListener(KeyboardEvent.KEY_UP,stopkeyscan);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, nub);
		
		showSheets2();// show Sheet uponStartup
		//
		
		rebuildmap(rows,columns,"newmap_"+Math.round(Math.random()* 99));
		setghosttile();
		//
	}
	
	function rebuildmap(rownum:Int,columnnum:Int,newmapname:String):Void{
		currentmap = newmapname;
		//curmap.text = "Current Map :"+currentmap;
			
		/*map = new Array<Array<Array<Int>>>();
		//rows = rownum;
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
		
		*/
		resetBitmap(true);
		isBusy = false;
	}

	function nub(e:KeyboardEvent):Void{
		if (!isBusy) {
			if(e.keyCode ==32){
				showSheets2();
			}
		}
	}
	function shwmenu(e:MouseEvent):Void{
		if (!isBusy) {
			isBusy = true;
			var p:MenuSettings = new MenuSettings();
			p.x  = 455;
			p.y = 224;
			addChild(p);
		}
	}
	function showmaplist(e:MouseEvent):Void{
		if (!isBusy) {
			isBusy = true;
			var p:Maplist = new Maplist();
			p.x  = 455;
			p.y = 224;
			addChild(p);
		}
	}
	function showinput(e:MouseEvent):Void{
		if (!isBusy) {
			isBusy = true;
			var d:EnterMap = new EnterMap();
			d.x = 455;
			d.y = 224;
			addChild(d);
		}
	}

	function showSheets(e:MouseEvent):Void{
		showSheets2();
	}

	function showSheets2():Void{	
		if (!showingSheet) {
			if(!mySpriteSheet){
				showingSheet = true;
				mySpriteSheet = new ShowSpriteSheets();
				mySpriteSheet.x = 1238;
				mySpriteSheet.y = 306;
				addChild(mySpriteSheet);
				mySpriteSheet.showinit();
			}else{
				if(!mySpriteSheet.visible){
					mySpriteSheet.showinit();
				}
			}
		}
	}

	function buildmap(instr:String):Void{
		var pie:Array = instr.split("#");
		if (pie.length==3) {
			anitileList = new Array();
			warpGates = new Array();
			largerthanView = [];
			warptlist.removeAll();
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
			for ( i in 0...map.length) {
				map[i] = map[i].split("|");
				for (o in 0...map[i].length) {
					map[i][o] = map[i][o].split(":");
				}
			}
			
			warpGates = pie[2].split("&");
			for (s in 0...warpGates.length) {
				warptlist.addItem({label:s});
				warpGates[s] = warpGates[s].split(":");
				warpGates[s][3] = warpGates[s][3].split("|");
				
				for(t in 0...warpGates[s][3]){
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
	
	
	private var ignoreList:Array<Int> = [omni.BUTTERFLY];//tiles to ignore
	function extendTilesLoop(layer:Int):Void{
		for (i in 0...rows) {
			for (o in 0...columns) {
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
						if (tilenum[key].ani_hasAnimation){//[4][0]) {
							var numKey:Int = (i * columns) + o;

							anitileList[numKey] = [1,tilenum[key][5]];//FrameNum , totalFrames
						}
					}
				}
			}
		}
	}

	function setlayer(e:MouseEvent):Void{
		var nullColour:Color = new Color();
		nullColour.setTint(0xFFFFFF, 0);
		activelaybut.transform.colorTransform = nullColour;
		//
		var nowlayer:Int;
		switch (e.target) {
			case bg0 :
				nowlayer=0;
				break;
			case bg1 :
				nowlayer=1;
				break;
			case bg2 :
				nowlayer=2;
				break;
			case bg3 :
				nowlayer=3;
				break;
			case obis:
				nowlayer = 4;
			break;
		}
		activelayer = nowlayer;
		activelaybut = e.target;
		//
		var cTint:Color = new Color();
		cTint.setTint(0xFFFFFF, 1);
		e.target.transform.colorTransform = cTint;
	}
	function setvisi(e:MouseEvent):Void{
		var num:Int;
		switch (e.target) {
			case on0 :
				num = 0;
				break;
			case on1 :
				num=1;
				break;
			case on2 :
				num=2;
				break;
			case on3 :
				num=3;
				break;
			case walk_eye :
				if(walklayervisi){// turn it off
					e.target.gotoAndStop(2);
					walklayervisi = false;
				}else{// turn it on
					e.target.gotoAndStop(1);
					walklayervisi = true;
				}
				resetBitmap();
				return;
				break;
		}
		
		if(this["layer"+num+"visi"]){
			this["layer"+num+"visi"] = false;
		}else{
			this["layer"+num+"visi"] = true;
		}
		
		if(this["layer"+num+"visi"]){
			e.target.gotoAndStop(1);
		}else{
			e.target.gotoAndStop(2);
		}
		
		resetBitmap();
		
	}
	function erased(e:MouseEvent):Void{
		eraseBrush = true;
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
				placer.addEventListener(Event.ENTER_FRAME,placetile);
			}
	}
	private function stopplacetile(e:MouseEvent):Void{
		placer.removeEventListener(Event.ENTER_FRAME,placetile);
	}
	private function placetile(e:Event):Void{
		if(saveBusy){
			return;
		}
		
		var spritego:Bool = true;
		if(mySpriteSheet!=null){
			if(mySpriteSheet.hitTestPoint(stage.mouseX,stage.mouseY,true)){
				spritego = false;
			}
		}	
		
		var dx:Int =  Math.floor((groundclip.mouseX+cam_point.x)/tileWidth)*tileWidth;
		var dy:Int = Math.floor((groundclip.mouseY+cam_point.y)/tileHeight)*tileHeight;
		var bar:String = dx+"_"+dy;
		var ex:Int =  Math.floor((groundclip.mouseX+cam_point.x)/tileWidth);
		var ey:Int = Math.floor((groundclip.mouseY+cam_point.y)/tileHeight);
		if (stage.mouseY<400 && stage.mouseY>0 && stage.mouseX<900 && spritego && !cineEditMode) {
			if (bar !=prePlace) {
				if (dy/tileHeight<rows && ex>=0 && ex<columns) {
					prePlace = bar;
					if (eraseBrush) {
						removeGate(ey, ex);
						if(activelayer!=4){
							removeAnimationTile(ey,ex,activelayer);
							map[ey][ex][activelayer]=0;
						}
						resetBitmap();
					}else if (activelayer == 4) {
						var over:Boolean=false;
						var sw:Int = warptlist.selectedItem.label;
						for(s in 0...warpGates[sw][3]){
							if(warpGates[sw][3][s][0] == ex && warpGates[sw][3][s][1] == ey){
								over = true;
								break;
							}
						}
						if(!over){
							warpGates[sw][3].push([ex,ey]);
							resetBitmap();
						}
					} else {
						
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
										if (tiledic[tilenum[map[ey][ex][activelayer]][0]][4][0]) {
											anitileList[ey+"_"+ex]=[ey,ex,activelayer,1];
										}
									}
								
								}
							}
						}else{
							removeAnimationTile(ey,ex,activelayer);
							map[ey][ex][activelayer]=selectedtile;
							if (tiledic[tilenum[map[ey][ex][activelayer]][0]][4][0]) {
								anitileList[ey+"_"+ex]=[ey,ex,activelayer,1];
							}
							
							
							var key:Int = selectedtile;
							if(!func.isiteminarray(ignoreList,key)){
								var dtile = tilenum[key][0];
								if (tiledic[dtile][7]) {
									var sWidth:Int = tilenum[key][8];
									var sHeight:Int = tilenum[key][9];
									var i:Int = ey;
									var o:Int = ex;
									//trace("WH:",sWidth,sHeight,"     ",key,tilenum[key]);
			
									var xxf:Int = (o * tileWidth)-tilenum[key][1];
									var yyf:Int = (i * tileHeight)-tilenum[key][2];
			
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
	function removeGate(ey:Int,ex:Int):Void{
		for (s in warpGates) {
			for(t in 0...warpGates[s][3].length){//for(t in warpGates[s][3]){
				if( warpGates[s][3][t][0]==ex && ey==warpGates[s][3][t][1]){
					warpGates[s][3].splice(t,1);
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
					//trace("REMOVE:",i,anitileList);
					if (anitileList[i][0]==ey && anitileList[i][1]==ex && anitileList[i][2]==activelayer) {
						//delete anitileList[i];
						anitileList.splice(i, 1);
						break;
					}
				}
			}
		}
	}
	function ghosttile(e:MouseEvent):Void{
		if (stage.mouseY>0 && stage.mouseY<400) {
			phantomtile.visible = true;
			var dx:Int = Math.floor((stage.mouseX+cam_point.x)/tileWidth);
			var dy:Int = Math.floor((stage.mouseY+cam_point.y)/tileHeight);
			mousexy.text = dy+"-"+dx;
			
			if(map[dy] == null){
				return;
			}else if(map[dy][dx] == null){
				return;
			}
			
			var ww:Int = 0;
			if(map[dy] != null && map[dy][dx]!=null){
				if( map[dy][dx][0] != 0){
					ww = tilenum[ map[dy][dx][0] ][6];
				}
			}
			
			tile_0.text = String(map[dy][dx][0]+" w:"+ww);
			tile_1.text = String(map[dy][dx][1]);
			tile_2.text = String(map[dy][dx][2]);
			tile_3.text = String(map[dy][dx][3]);
			

			//
			phantomtile.x = ( dx* tileWidth)-cam_point.x-phantomtile.xoffset;
			phantomtile.y = ( dy* tileHeight)-cam_point.y-phantomtile.yoffset;
		}else{
			phantomtile.visible = false;
		}
	}
	function setghosttile():Void{
		phantomtile = new MovieClip();
		phantomtile.alpha = .3;

		var bitImage:BitmapData = tilebitdata[selectedtile];
		var bit:BitmapData = bitImage;
		var bitm:Bitmap = new Bitmap(bit);
		
		phantomtile.addChild(bitm);
		phantomtile.xoffset = tilenum[selectedtile][1];
		phantomtile.yoffset = tilenum[selectedtile][2];
		
		groundclip.addChild(phantomtile);
	}
	function mouseCamScrollWheel(e:MouseEvent):Void{
		if (stage.mouseY < 400) {
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

				if (cam_point.y<((rows * tileHeight)-400)) {
					var yrs:Int = 15;
					cam_point.y += yrs;
					if (cam_point.y>(rows * tileHeight)-400) {
						cam_point.y = (rows * tileHeight)-400;
					}
					resetBitmap();
				}
			}
		}else{
			if (e.delta>0) {
				toolsbench.y += 125;
			} else {
				toolsbench.y -= 125;
			}
		}
	}
	function mouseCamScroll(e:Event):Void{
		if (stage.mouseY<400 && !cineEditMode) {
			if (stage.mouseX > 900-100  && cam_point.x<(columns * tileWidth)-screenWidth && stage.mouseX<900) {
				var rp:Number = (100-(900-stage.mouseX))/100;
				var rs:Int = 15* rp;
				cam_point.x += rs;
				if (cam_point.x>(columns * tileWidth)-screenWidth) {
					cam_point.x = (columns * tileWidth)-screenWidth;
				}
				resetBitmap();
			} else if (stage.mouseX < 100 && cam_point.x>0) {
				//window move left
				var lp:Number = (100-stage.mouseX)/100;
				var ls:Int = 15* lp;
				cam_point.x -= ls;
				if (cam_point.x<0) {
					cam_point.x = 0;
				}
				resetBitmap();
			}
		}
	}
	function select_tile(e:MouseEvent):Void{
		eraseBrush = false;
		
		selectedtile = e.currentTarget.tilenumber;
		selct.text = String(selectedtile);
		selected_Array = new Array();

		groundclip.removeChild(phantomtile);
		setghosttile();
	}
	function resetBitmap(runonce:Bool=false):Void{
		cam_pointx.text = cam_point.x+"";
		cam_pointy.text = cam_point.y+"";

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
		
		var tileList1:Array<Array<DrawObject>> = new Array<Array<DrawObject>>();
		if (layer0visi) {
			tileList1 = listLoop(0,runonce,yst,yend,colstart,colend);
			//theloop(0,runonce,yst,yend,colstart,colend);
		}
		if (layer1visi) {

			var tileList2:Array<Array<DrawObject>> = listLoop(1,runonce,yst,yend,colstart,colend);
			tileList1 = tileList1.concat( tileList2[1]);
			
			
			tileList2 = tileList2[0];
			
			var extendList:Array<DrawObject> = listExtensions(yst,yend,colstart,colend);	
			tileList2= tileList2.concat(extendList);
			tileList2.sortOn(["y","x"], Array.NUMERIC);

			tileList1= tileList1.concat(tileList2);
		}
		if (layer2visi) {

			var tileList3:Array<DrawObject> = listLoop(2,runonce,yst,yend,colstart,colend);
			//theloop(2,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList3);
		
		}
		//invisible action event layer
		if (layer3visi) {

			var tileList4:Array<DrawObject> = listLoop(3,runonce,yst,yend,colstart,colend);
			//theloop(3,runonce,yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList4);
		}
		
		
		// walkable layer
		if (walklayervisi) {
			var tileList5:Array<DrawObject> = listWalkable(yst,yend,colstart,colend);
			tileList1= tileList1.concat(tileList5);
		}
		
		drawAll(tileList1);

		//
		for (s in 0...warpGates.length) { //for (var s in warpGates) {
			for (t in warpGates[s][3].length) { //for (var t in warpGates[s][3]) {
				var z:Int = warpGates[s][3][t][1];
				var q:Int = warpGates[s][3][t][0];

				//var dtile:Class = getDefinitionByName("tl_wg_" + s)  as Class;
				//var key:Int = tiledic[dtile][0];
				var key:Int = tiledic.get("tl_wg_" + s).key;
				
				var dx:Int = (q * tileWidth)- cam_point.x + tileWidth;
				var dy:Int = (z * tileHeight)- cam_point.y + tileHeight;
				var pt:Point = new Point(dx, dy);
				var rec:Rectangle =  new Rectangle(0, 0, tileWidth, tileHeight);
				bufferBD.copyPixels(tilebitdata[key], rec, pt,null,null,true);
			}
		}
		//

		bufferBD.unlock();
		skybuffer.unlock();
		canvasBD.copyPixels(bufferBD,new Rectangle(tileWidth,tileHeight,bufferBD.width,bufferBD.height) ,new Point(0,0));
		skyBD.copyPixels(skybuffer,new Rectangle(tileWidth,tileHeight,skybuffer.width,skybuffer.height) ,new Point(0,0));
	}

	function listExtensions(yst:Int,yend:Int,colstart:Int,colend:Int):Array<DrawObject> {
		
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
		var dlength:Int = dispList.length;
		var len:DrawObject;
		var pPo:Point = new Point(0,0);
		var rRe:Rectangle = new Rectangle(0,0,0,0);
		
		for (z in 0...dlength) {
			len = dispList[z];
			pPo.x = len.xoff;
			pPo.y = len.yoff;
			rRe.width = len.width;
			rRe.height = len.height;	
			bufferBD.copyPixels(len.bitmapData, rRe, pPo);
		}			
	}

	function pastetile(z:Int,q:Int,layer:Int):Void{
		var whichBuffer:BitmapData = bufferBD;

		var key:Int = map[z][q][layer];
		var tob:TileObject = tilenum[key];

		var dx:Int = (q * tileWidth)-cam_point.x+tileWidth;
		var dy:Int = (z * tileHeight)-cam_point.y+tileHeight;
		
		//var pt:Point = new Point(dx-(tilenum[key][1]), dy-(tilenum[key][2]));
		var pt:Point = new Point(dx-(tob.xoffset), dy-(tob.yoffset));
		var rec:Rectangle =  new Rectangle(0, 0, tilebitdata[key].width, tilebitdata[key].height);
		
		if (tob.ani_hasAnimation && anitileList[z+"_"+q]) { //if (tilenum[key][4][0] && anitileList[z+"_"+q]) {
			var toPaste:Int = anitileList[z+"_"+q][3]+1;

			if (toPaste>tob.totalFrames){ //tilenum[key][5]) {
				toPaste=1;
				anitileList[z+"_"+q][3]=0;
			}
			anitileList[z+"_"+q][3]++;
			
			bufferBD.copyPixels(tilebitdata[key+"_"+toPaste], rec, pt);

		} else {
			whichBuffer.copyPixels(tilebitdata[key], rec, pt,null,null,true);
		}
	}


	private function listWalkable(yst:Int,yend:Int,colstart:Int,colend:Int):Array<DrawObject> {
		var dlist:Array<DrawObject> = new Array<DrawObject>();
		var sendtobot:Array = new Array<DrawObject>();
		var ob:DrawObject;
		var numKey:Int;
		var key:Int;
		var xoffset:Int;
		var yoffset:Int;
		var pPoint:Point = new Point();
		var rRect:Rectangle = new Rectangle(0,0,0,0);
		
		var campointx:Int = cam_point.x;
		var campointy:Int = cam_point.y;
		
		for (z in yst...(yend+1)) {
			if (z>=0) {
				for (q in colstart...(colend+1)) {//for (var q:Int = colstart; q<=colend; q++) {
					if (q>=0) {
						key = map[z][q][0];
						if(key == 0){
							continue;
						}
						
						var tob:TileObject = tilenum[key];
						if (tob.walkType  == 1) { // walkable tile
							//q -> xoffset
							//z -> yoffset
							
							key = 599; // walkable tile image

							xoffset = (q * tileWidth)-campointx+tileWidth;
							yoffset = (z * tileHeight)-campointy+tileHeight;

							ob = new DrawObject();
							ob.x = (q * tileWidth);
							ob.y = (z * tileHeight) + 0 + tob.depthPoint; //tilenum[key][10];

							numKey = (z * columns) + q;
							
							ob.bitmapData = tilebitdata[key];
							ob.width = tilebitdata[key].width;
							ob.height = tilebitdata[key].height;
							
							ob.xoff = xoffset - (tob.xoffset);//tilenum[key][1]);
							ob.yoff = yoffset - (tob.yoffset);//tilenum[key][2]);
							dlist.push(ob);
						}
					}
				}
			}
		}
		return dlist;
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

							xoffset = (q * tileWidth)-campointx+tileWidth;
							yoffset = (z * tileHeight)-campointy+tileHeight;

							ob = new DrawObject();
							ob.x = (q * tileWidth);

							ob.y = (z * tileHeight) + layer + tob.depthPoint; //tilenum[key][10];

							numKey = (z * columns) + q;
							
							if(anitileList[numKey] && tob.ani_hasAnimation){ //tilenum[key][4][0]){
								
								ob.bitmapData = tilebitdata[key+"_"+anitileList[numKey][0]];
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

	private function keyscan(e:KeyboardEvent):Void{
		if(pressKeys.exists(e.keyCode)){
			return;
		}
		if(e.shiftKey){
			addrowscol(e.keyCode);
		}else if(e.ctrlKey){
			trimmap(e.keyCode);
		}
		
		pressKeys[e.keyCode] = true;
	}

	function stopkeyscan(e:KeyboardEvent):Void {
		pressKeys.remove(e.keyCode);
		 //delete pressKeys[ e.keyCode ];
	} 
	function addrowscol(keypress:Int):Void{
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
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][1]++;
					}
				}

				break;
			case 40 :
			//bottom
				rows++;
				for (i in 0...columns) {
					rowx.push([0,0,0,0]);
				}
				
				map.push(rowx);
				restmap = true;
				break;

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
					for(s in warpGates[sw][3]){
						warpGates[sw][3][s][0]++;
					}
				}
				
				break;
			case 39 :
			//right
				columns++;
				for (i in 0...rows) {
					map[i].push([0,0,0,0]);
				}

				restmap = true;
				break;


		}
		if (restmap) {
			resetBitmap(true);
		}
	}
	function trimmap(keypress:Int):Void{
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
				
				for (i in 0...largerthanView.length) {
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
				for (i in 0...rows) {
					map[i].shift();
				}

				restmap = true;
				
				for (i in 0...largerthanView.length) {
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
				for (i in 0...rowss) {
					map[i].pop();
				}

				restmap = true;
				break;
		}
		if (restmap) {
			resetBitmap(true);
		}
	}
	
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
	function cctv(e:MouseEvent):Void{
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
	function mDown(e:MouseEvent):Void{
		msx = stage.mouseX;
		msy = stage.mouseY;
	}
	function mMove(e:MouseEvent):Void{ // moving the screen for cineEditMode
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
	function mUp(e:MouseEvent):Void{
		msx = 0;
		msy = 0;
	}
	*/
}