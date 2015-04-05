package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
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
	private var stnum:Int;
	private var preV:String;

	private var selector = new SelectorCD();
	private var widther:String;// Class

	private var spriteWidth:Int;
	private var spriteHeight:Int;

	private var sel_spritesheet:Int;
	private var sel_spritesheetlab:String;// Class;
	
	private var cellwid:Int;
	private var h:Int;
	
	private var sheet:BitmapData;
	private	var bitsheet:Bitmap;
	private var follower:SelectorCD;
	
	public function new() 
	{
		super();
		tileManager = TileManager.getInstance();
		displayManager = DisplayManager.getInstance();
		
		widther = tileManager.spriteSheets[0]; 			//spriteSheets.push(["tl_grasslands",1])
		stnum = tileManager.tiledic[widther].key;		//spriteSheets.push(["tl_grasslands",1])
		

		spriteWidth = Std.int(tileManager.tiledic[widther].width);// MovieClip(root).tiledic[widther][8];
		spriteHeight =  Std.int(tileManager.tiledic[widther].height);// MovieClip(root).tiledic[widther][9];

		cellwid = 140;
		h = Math.floor(symbo.height / 20);		
	}
	public function init():Void {
		var inum:Int = 0;
		for (i in tileManager.spriteSheets) {
			var df:TextFormat = new TextFormat();
			df.font = "Arial";
			df.size = 12;
			
			var sp:MovieClip = new MovieClip();
			var tt:TextField = new TextField();
			tt.defaultTextFormat = df;
			tt.height = 20;
			tt.width = cellwid;
			tt.text = i;
			sp.label = i;
			sp.data = tileManager.tiledic[i].key;
			sp.addChild(tt);
			sp.x = symbo.x+ Math.floor(inum/h) * cellwid;
			sp.y = symbo.y+ (inum - Math.floor(inum/h) * h) * 20;
			sp.addEventListener(MouseEvent.CLICK, itemChange);
			addChild(sp);
			
			inum++;
		}


		
		sheet = tileManager.spriteSheetSprites[tileManager.spriteSheets[0]];
		bitsheet = new Bitmap(sheet);
		sheetholder.addChild(bitsheet);

		follower = new SelectorCD();
		follower.alpha = .3;

		sheetholder.addChild(follower);
		sheetholder.addChild(selector);

		resizeR();
	//-----
		sheetholder.addEventListener(MouseEvent.MOUSE_DOWN, dclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_UP, uclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_MOVE, fol);

		graybak.addEventListener(MouseEvent.MOUSE_DOWN, stDrag);
		graybak.addEventListener(MouseEvent.MOUSE_UP, stopxDrag);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN,nub);
		//clist.addEventListener(Event.CHANGE, itemChange);
		tileManager.showingSheet = true;
		this.visible = true;
		
		if(sel_spritesheetlab != null){
			changeSheet();
		}
	}

	
	private function itemChange(e:MouseEvent):Void {
		sel_spritesheet = e.currentTarget.data;
		sel_spritesheetlab = e.currentTarget.label;
		
		changeSheet();
	}
	private function changeSheet():Void {
		sheetholder.removeChild(bitsheet);
		
		sheet = tileManager.spriteSheetSprites[sel_spritesheetlab];
		bitsheet = new Bitmap(sheet);
		sheetholder.addChild(bitsheet);
		
		stnum = sel_spritesheet;
		
		var tmp:String = sel_spritesheetlab;
		spriteWidth = Std.int(tileManager.tiledic[tmp].width); //[8];
		spriteHeight = Std.int(tileManager.tiledic[tmp].height); //[9];
		
		resizeR();
	}

	private function nub(e:KeyboardEvent):Void {
		if (e.keyCode ==32) {
			closx2();
		}
	}
	
	private function closx(e:MouseEvent):Void {
		closx2();
	}
	private function closx2():Void {
		//clist.removeEventListener(Event.CHANGE, itemChange);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN,nub);
		tileManager.showingSheet = false;
		this.visible = false;
	}

	//-----------



	private function resizeR():Void {
		follower.x = follower.y = selector.x = selector.y = 0;
		follower.width = follower.height = selector.width = selector.height = 50;
		
		sheetholder.setChildIndex(follower,sheetholder.numChildren-1);
		sheetholder.setChildIndex(selector,sheetholder.numChildren-1);
		
		sback.width = spriteWidth*50;
		sback.height = spriteHeight*50;
		/*graybak.width = spriteWidth * 50 + 35;
		graybak.height = spriteHeight*50+40+135;
		
		if(graybak.width< 460 ){
			graybak.width = 460;
		}*/
		
		//trace(sback.width,spriteWidth,"spriteWidthspriteWidth");
	}
	
	private function stDrag(e:MouseEvent):Void {
		startDrag();
	}
	private function stopxDrag(e:MouseEvent):Void {
		stopDrag();
	}

	private function dclick(e:MouseEvent):Void {
		pressD = true;
		var mox:Int = Std.int(e.currentTarget.mouseX/ TileManager.tileWidth);
		var moy:Int = Std.int(e.currentTarget.mouseY/TileManager.tileHeight);
		startArr = [mox, moy];

		selector.alpha 	= .3;
		selector.width 	= 0;
		selector.height = 0;
		selector.x 		= mox*50;
		selector.y 		= moy*50;
	}
	private function uclick(e:MouseEvent):Void {
		pressD = false;
		var mox:Int = Math.floor(e.currentTarget.mouseX/TileManager.tileWidth);
		var moy:Int = Math.floor(e.currentTarget.mouseY/TileManager.tileHeight);
		stopArry = [mox,moy];


		displayManager.notEraseBrush(); //displayManager.eraseBrush = false;
		
		displayManager.selected_Array = makeArray(mox,moy);
		displayManager.selectedtile = displayManager.selected_Array[0][0];
		displayManager.selct.text = displayManager.selected_Array[0][0]+"";
		tileselc.text = displayManager.selct.text;
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
		var num:Int = stnum+(mostUp*spriteWidth)+mostLeft;
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