package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.Lib;
import flash.text.TextFormat;
/**
 * ...
 * @author Nelson
 */
class SpriteSheetManager extends ShowSpriteSheets
{
	private var tileManager:TileManager;
	private var displayManager:DisplayManager;
	
	private var pressD:Bool = false;
	private var startArr:Array<Int> = new Array<Int>();
	private var stopArry:Array<Int> = new Array<Int>();

	private var preV:String;
	private var selector = new SelectorCD();

	private var spriteWidth:Int;
	private var spriteHeight:Int;

	private var sel_spritesheetStartingNum:Int;
	private var sel_spritesheetName:String;// Class;

	private var spriteSheetBitData:BitmapData;
	private	var bitsheet:Bitmap;
	private var indiviTileSheet:Sprite;
	private var follower:SelectorCD;
	private var sheetholder:Sprite;
	
	private var looseTilesInGroups:Array<Int> = new Array<Int>();
		
	public function new() 
	{
		super();
		tileManager = TileManager.getInstance();
		displayManager = DisplayManager.getInstance();

		// Set up tileset buttons
		var allTilesets:Array<List_btt> = new Array<List_btt>();
		
		for (i in tileManager.tilesetArr) {
			var tt:List_btt = new List_btt();
			tt.txt.mouseEnabled = false;
			tt.txt.text = i;
			tt.label = i;
			tt.data = "No Data";
			tt.type = "tileset";
			allTilesets.push(tt);
		}
		
		var tt:List_btt = new List_btt();
		tt.txt.mouseEnabled = false;
		tt.label = tt.txt.text = "All Others";
		tt.data = "No Data";
		tt.type = "tileset";
		allTilesets.push(tt);
		
		for (i in tileManager.spriteSheets) {
			var tt:List_btt = new List_btt();
			tt.txt.mouseEnabled = false;
			tt.txt.text = i;
			tt.label = i;
			tt.data = tileManager.tiledic[i].key;
			tt.type = "spritesheet";
			allTilesets.push(tt);
		}
		
		var tilesetOptionsMC = new ScrollerPane(symbo);
		var cellwid:Int = 175;
		var inum:Int = 0;
		for (tt in allTilesets) {
			tt.x = (inum % 3 ) * cellwid;
			tt.y = Math.floor(inum / 3) * 20;
			tt.addEventListener(MouseEvent.CLICK, itemChange);
			tilesetOptionsMC.addChild(tt);
			
			inum++;
		}
		tilesetOptionsMC.x = symbo.x;
		tilesetOptionsMC.y = symbo.y;
		addChild(tilesetOptionsMC);
		// END set up tileset buttons
		
		// 
		var tilesetArr:Array<Dynamic> = tileManager.tilesetArr;
		for (tn in tilesetArr) {
			var t:Array<Int> = tileManager.tilesets[tn];
			looseTilesInGroups = looseTilesInGroups.concat(t);
		}		
		//		
		sheetholder = new Sprite();
		bitsheet = new Bitmap();
		indiviTileSheet = new Sprite();
		sheetholder.addChild(indiviTileSheet);
		sheetholder.addChild(bitsheet);
		
		sheetholder.x = sback.x;
		sheetholder.y = sback.y;
		addChild(sheetholder);

		follower = new SelectorCD();
		follower.alpha = .3;

		sheetholder.addChild(follower);
		sheetholder.addChild(selector);

		sheetholder.addEventListener(MouseEvent.MOUSE_DOWN, dclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_UP, uclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_MOVE, fol);

		graybak.addEventListener(MouseEvent.MOUSE_DOWN, stDrag);
		graybak.addEventListener(MouseEvent.MOUSE_UP, stopxDrag);
		
		changeSheet(tileManager.spriteSheets[0], tileManager.tiledic[tileManager.spriteSheets[0]].key);
	}
	
	private function itemChange(e:MouseEvent):Void {
		if (e.currentTarget.type == "spritesheet") {
			// spritesheet
			changeSheet(e.currentTarget.label, e.currentTarget.data );
		}else {
			// tileset
			changeTileSet(e.currentTarget.label, e.currentTarget.data );
		}
		
	}
	private function changeTileSet(sheetName:String, sheetNum:Int):Void {
		clearSheet();
		
		sel_spritesheetStartingNum = sheetNum;
		sel_spritesheetName = sheetName;
		
		cur_tilesettxt.text = sel_spritesheetName;
		//
		indiviTileSheet = new Sprite();
		var initnum:Int = 0;
		
		if (sel_spritesheetName == "All Others") {			
			for (ni in tileManager.looseTiles) {
				var inarr:Bool = false;

				if (Func.isiteminarray (tileManager.partofSheet, ni)) {
					continue;
				}else if (Func.isiteminarray (looseTilesInGroups, ni)) {
					continue;
				}
								
				if (!inarr) {
					// this lone tile does not belong in a spritesheet nor in a tileset group					
					var key:Int = ni;
					var tix:MovieClip = new MovieClip();
					var bitImage2:BitmapData = tileManager.tilebitdata[key];
					var bit2:BitmapData = bitImage2;
					var bitm2:Bitmap = new Bitmap(bit2);
										
					tix.y  = Math.floor(initnum/10) * 53;
					tix.x = (initnum  * (DisplayManager.tileWidth + 3)) % 530;
					tix.tilenumber = key;
				
					tix.addChild(bitm2);
					tix.width = DisplayManager.tileWidth;
					tix.height = DisplayManager.tileHeight;
					tix.addEventListener(MouseEvent.CLICK, select_tile);
					
					indiviTileSheet.addChild(tix);
					initnum++;
				}
			}
		}else {
			var intArr:Array<Int> = tileManager.tilesets[sheetName];
			
			for(i in intArr){
				var bitImage:BitmapData = tileManager.tilebitdata[i];		
				var tis:MovieClip = new MovieClip();
				var bit:BitmapData = bitImage;
				var bitm:Bitmap = new Bitmap(bit);
			
				tis.addChild(bitm);
				tis.y  = Math.floor(initnum/10) * 53;
				tis.x = (initnum  * (DisplayManager.tileWidth + 3)) % 530;
				tis.width = DisplayManager.tileWidth;
				tis.height = DisplayManager.tileHeight;
				tis.tilenumber  = i;
				tis.addEventListener(MouseEvent.CLICK, select_tile);
			
				indiviTileSheet.addChild(tis);
				initnum++;
			}
		}
		//
		sheetholder.addChild(indiviTileSheet);
		//
	}
	private function changeSheet(sheetName:String, sheetNum:Int):Void {
		clearSheet();
		
		follower.visible = true;
		selector.visible = true;
		sback.visible = true;
		
		sel_spritesheetStartingNum = sheetNum;
		sel_spritesheetName = sheetName;
		
		cur_tilesettxt.text = sel_spritesheetName;
		
		spriteSheetBitData = tileManager.spriteSheetSprites[sel_spritesheetName];
		bitsheet = new Bitmap(spriteSheetBitData);
		sheetholder.addChild(bitsheet);
		
		spriteWidth = Std.int(tileManager.tiledic[sel_spritesheetName].width); //[8];
		spriteHeight = Std.int(tileManager.tiledic[sel_spritesheetName].height); //[9];
		
		resizeR();
	}
	private function clearSheet():Void {
		if (sheetholder.contains(indiviTileSheet)) {
			sheetholder.removeChild(indiviTileSheet);
		}
		if (sheetholder.contains(bitsheet)) {
			sheetholder.removeChild(bitsheet);
		}
		
		follower.visible = false;
		selector.visible = false;
		sback.visible = false;
	}
	private function resizeR():Void {
		follower.x = follower.y = selector.x = selector.y = 0;
		follower.width = follower.height = selector.width = selector.height = 50;
		
		sheetholder.setChildIndex(follower,sheetholder.numChildren-1);
		sheetholder.setChildIndex(selector,sheetholder.numChildren-1);
		
		sback.width = spriteWidth*50;
		sback.height = spriteHeight*50;
	}
	
	private function stDrag(e:MouseEvent):Void {
		startDrag();
	}
	private function stopxDrag(e:MouseEvent):Void {
		stopDrag();
	}
	private function dclick(e:MouseEvent):Void {
		pressD = true;
		var mox:Int = Std.int(e.currentTarget.mouseX / TileManager.tileWidth);
		var moy:Int = Std.int(e.currentTarget.mouseY / TileManager.tileHeight);
		startArr = [mox, moy];

		selector.alpha 	= .3;
		selector.width 	= 0;
		selector.height = 0;
		selector.x 		= mox*50;
		selector.y 		= moy*50;
	}
	private function uclick(e:MouseEvent):Void {
		pressD = false;
		var mox:Int = Math.floor(e.currentTarget.mouseX / TileManager.tileWidth);
		var moy:Int = Math.floor(e.currentTarget.mouseY / TileManager.tileHeight);
		stopArry = [mox,moy];


		displayManager.notEraseBrush(); //displayManager.eraseBrush = false;
		
		displayManager.selected_Array = makeArray(mox, moy);
		displayManager.selectedtile = displayManager.selected_Array[0][0];
		tileselc.text = displayManager.selected_Array[0][0] + "";
	}
	
	private function select_tile(e:MouseEvent):Void {
		var mc:MovieClip = cast(e.currentTarget, MovieClip);
		displayManager.notEraseBrush();
		
		displayManager.selected_Array = [[mc.tilenumber]];
		displayManager.selectedtile = displayManager.selected_Array[0][0];
		tileselc.text = mc.tilenumber + "";
		
		displayManager.setghosttile();
	}
	
	
	private function makeArray(endX:Int,endY:Int):Array<Array<Int>> {
		var rawrow:Int = endY-startArr[1];
		var rawcol:Int = endX-startArr[0];
		var rows:Int = Std.int(Math.abs(rawrow)+1);
		var col:Int = Std.int(Math.abs(rawcol)+1);

		var mostLeft:Int = startArr[0];
		var mostUp:Int = startArr[1];
		if (rawcol<0) {
			mostLeft = mostLeft-(col-1);
		}
		if (rawrow<0) {
			mostUp = mostUp-(rows-1);
		}
		var num:Int = sel_spritesheetStartingNum + (mostUp * spriteWidth) + mostLeft; //stnum+(mostUp*spriteWidth)+mostLeft;
		var Arr:Array<Array<Int>> = new Array<Array<Int>>();
		for (r in 0...rows) {
			Arr[r]=[];
			for (c in 0...col) {
				Arr[r][c] = num+(r* spriteWidth)+c;
			}
		}
		return Arr;
	}
	private function fol(e:MouseEvent):Void {
		var xx:Int = Math.floor(e.currentTarget.mouseX/50);
		var yy:Int = Math.floor(e.currentTarget.mouseY/50);
		follower.x = xx * 50;
		follower.y = yy * 50;

		var now:String = xx+""+yy;
		if (pressD && preV!=now) {
			preV = now;
			//
			var rawcol:Int = xx-startArr[0];
			var rawrow:Int = yy-startArr[1];

			var rows:Int = Std.int(Math.abs(rawrow)+1);
			var col:Int = Std.int(Math.abs(rawcol)+1);

			var mostLeft:Int = startArr[0];
			var mostUp:Int = startArr[1];

			if (rawcol<0) {
				mostLeft = mostLeft-(col-1);
			}
			if (rawrow<0) {
				mostUp = mostUp-(rows-1);
			}
			selector.x = mostLeft * 50;
			selector.y = mostUp * 50;

			selector.width = col*50;
			selector.height = rows*50;
			//
		}
	}
}