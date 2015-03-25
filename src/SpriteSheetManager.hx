package ;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.text.TextField;

/**
 * ...
 * @author Nelson
 */
class SpriteSheetManager extends ShowSpriteSheets
{

	public function new() 
	{
		var pressD:Boolean = false;
		var startArr:Array = new Array();
		var stopArry:Array = new Array();
		var stnum:int = MovieClip(root).spriteSheets[0][1];
		var preV:String;

		var selector = new SelectorCD();
		var widther:Class = MovieClip(root).spriteSheets[0][0];
		//trace("widther:",widther, MovieClip(root).spriteSheets[0]);
		var spriteWidth:int = MovieClip(root).tiledic[widther][8];
		var spriteHeight:int = MovieClip(root).tiledic[widther][9];
		//trace("widther:",widther, MovieClip(root).spriteSheets[0]);
		//trace("spriteWxxxxidth:",spriteWidth, spriteHeight);
		var sel_spritesheet:int;
		var sel_spritesheetlab:Class;

		var cellwid:int = 140;
		var h:int = Math.floor(symbo.height/20);
		for (var i in MovieClip(root).spriteSheets) {
			var df:TextFormat = new TextFormat();
			df.font = "Arial";
			df.size = 12;
			
			var sp:MovieClip = new MovieClip();
			var tt:TextField = new TextField();
			tt.defaultTextFormat = df;
			tt.height = 20;
			tt.width = cellwid;
			tt.text = MovieClip(root).spriteSheets[i][0];
			sp.label = MovieClip(root).spriteSheets[i][0];
			sp.data = MovieClip(root).spriteSheets[i][1];
			sp.addChild(tt);
			sp.x = symbo.x+ Math.floor(i/h) * cellwid;
			sp.y = symbo.y+ (i - Math.floor(i/h) * h) * 20;
			sp.addEventListener(MouseEvent.CLICK, itemChange);
			addChild(sp);
		}

		closebtt.addEventListener(MouseEvent.CLICK, closx);
		
		var sheet:BitmapData = MovieClip(root).spriteSheetSprites[MovieClip(root).spriteSheets[0][0]]
		var bitsheet:Bitmap = new Bitmap(sheet);
		sheetholder.addChild(bitsheet);

		var follower = new SelectorCD();
		follower.alpha = .3;

		sheetholder.addChild(follower)
		sheetholder.addChild(selector)

		resizeR()
	//-----
		sheetholder.addEventListener(MouseEvent.MOUSE_DOWN,dclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_UP,uclick);
		sheetholder.addEventListener(MouseEvent.MOUSE_MOVE,fol);

		graybak.addEventListener(MouseEvent.MOUSE_DOWN,stDrag);
		graybak.addEventListener(MouseEvent.MOUSE_UP,stopxDrag);
	}
		
	
	function itemChange(e:MouseEvent):Void {
		sel_spritesheet = e.currentTarget.data;
		sel_spritesheetlab = e.currentTarget.label;
		
		changeSheet();
	}
	function changeSheet():Void {
		sheetholder.removeChild(bitsheet);
		
		sheet = MovieClip(root).spriteSheetSprites[sel_spritesheetlab]
		bitsheet = new Bitmap(sheet);
		sheetholder.addChild(bitsheet);
		
		stnum = sel_spritesheet;
		
		var tmp:Class = sel_spritesheetlab;
		spriteWidth = MovieClip(root).tiledic[tmp][8];
		spriteHeight = MovieClip(root).tiledic[tmp][9];
		
		resizeR();
	}

	function nub(e:KeyboardEvent):Void {
		if (e.keyCode ==32) {
			closx2();
		}
	}
	
	function closx(e:MouseEvent):Void {
		closx2();
	}
	function closx2():Void {
		//clist.removeEventListener(Event.CHANGE, itemChange);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN,nub);
		MovieClip(root).showingSheet = false;
		visible = false;
	}
	function showinit():Void{
		stage.addEventListener(KeyboardEvent.KEY_DOWN,nub);
		//clist.addEventListener(Event.CHANGE, itemChange);
		MovieClip(root).showingSheet = true;
		visible = true;
		
		if(sel_spritesheetlab){
			changeSheet();
		}
	}
	//-----------



	function resizeR():Void {
		follower.x = follower.y = selector.x = selector.y = 0;
		follower.width = follower.height = selector.width = selector.height = 50;
		
		sheetholder.setChildIndex(follower,sheetholder.numChildren-1);
		sheetholder.setChildIndex(selector,sheetholder.numChildren-1);
		
		sback.width = spriteWidth*50;
		sback.height = spriteHeight*50;
		graybak.width = spriteWidth*50+35
		graybak.height = spriteHeight*50+40+135;
		
		if(graybak.width< 460 ){
			graybak.width = 460;
		}
		
		//trace(sback.width,spriteWidth,"spriteWidthspriteWidth");
	}
	
	function stDrag(e:MouseEvent):Void {
		startDrag();
	}
	function stopxDrag(e:MouseEvent):Void {
		stopDrag();
	}

	function dclick(e:MouseEvent):Void {
		pressD = true;
		var mox:int = Math.floor(e.currentTarget.mouseX/MovieClip(root).tileWidth);
		var moy:int = Math.floor(e.currentTarget.mouseY/MovieClip(root).tileHeight);
		startArr = [mox,moy];

		selector.alpha = .3;
		selector.width = 0;
		selector.height = 0;
		selector.x = mox*50;
		selector.y =moy*50;
	}
	function uclick(e:MouseEvent):Void {
		pressD = false;
		var mox:int = Math.floor(e.currentTarget.mouseX/MovieClip(root).tileWidth);
		var moy:int = Math.floor(e.currentTarget.mouseY/MovieClip(root).tileHeight);
		stopArry = [mox,moy];


		MovieClip(root).eraseBrush = false;
		MovieClip(root).selected_Array = makeArray(mox,moy);
		MovieClip(root).selectedtile = MovieClip(root).selected_Array[0][0];
		MovieClip(root).selct.text = MovieClip(root).selected_Array[0][0];
		tileselc.text = MovieClip(root).selct.text;
	}
	function makeArray(endX:Int,endY:Int):Array {
		var rawrow:int =endY-startArr[1];
		var rawcol:int = endX-startArr[0];
		var rows:int = Math.abs(rawrow)+1;
		var col:int = Math.abs(rawcol)+1;

		var mostLeft:int = startArr[0];
		var mostUp:int = startArr[1];
		if (rawcol<0) {
			mostLeft = mostLeft-(col-1);
		}
		if (rawrow<0) {
			mostUp = mostUp-(rows-1);
		}
		var num:int = stnum+(mostUp*spriteWidth)+mostLeft;
		var Arr:Array = new Array();
		for (var r:int = 0; r<rows; r++) {
			Arr[r]=[];
			for (var c:int = 0; c<col; c++) {
				Arr[r][c] = num+(r* spriteWidth)+c;
			}
		}
		return Arr;
	}
	function fol(e:MouseEvent):Void {
		var xx:int = Math.floor(e.currentTarget.mouseX/50);
		var yy:int = Math.floor(e.currentTarget.mouseY/50);
		follower.x = xx * 50;
		follower.y = yy * 50;

		var now:String = xx+""+yy;
		if (pressD && preV!=now) {
			preV = now;
			//
			var rawcol:int = xx-startArr[0];
			var rawrow:int = yy-startArr[1];

			var rows:int = (Math.abs(rawrow)+1);
			var col:int = (Math.abs(rawcol)+1);

			var mostLeft:int = startArr[0];
			var mostUp:int = startArr[1];

			if (rawcol<0) {
				mostLeft = mostLeft-(col-1);
			}
			if (rawrow<0) {
				mostUp = mostUp-(rows-1);
			}
			selector.x = mostLeft * 50;
			selector.y = mostUp * 50

			selector.width = col*50;
			selector.height = rows*50;
			//
		}
	}
}