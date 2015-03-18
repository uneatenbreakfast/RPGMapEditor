package admin;
import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.system.*;
import flash.utils.*;
import flash.events.MouseEvent;


class MyLoader extends Sprite {

	public var loader:Loader;
	private var file:String;

	public function new(req:URLRequest , fil:String):Void {
		super();
		
		file = fil;
		var context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, rlComplete);
		loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, preLoader);
		loader.load(req, context);
	}
	private function preLoader(e:ProgressEvent):Void {
		var loaded:Float = Math.round(e.bytesLoaded);
		var total:Float = Math.round(e.bytesTotal);
		var percent:Float = loaded / total * 100;

	}
	private function rlComplete(e:Event):Void {
		//parent[file] = true;
		//MovieClip(root).loadComplete();
		dispatchEvent(new Event("LoadDone"));
	}
	//
}
