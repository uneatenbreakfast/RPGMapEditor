package ;
import flash.events.MouseEvent;

/**
 * ...
 * @author Nelson
 */
class DialogueSave extends Dialogue_Save
{
	private var modal:ModalScreen;
	
	public var continueFunction:Dynamic;
	public var continueParams:Array<Dynamic>;
	
	public function new(modalScreen:ModalScreen) 
	{
		super();
		
		modal = modalScreen;
		
		yesbtt.addEventListener(MouseEvent.CLICK, yesclick);
		nobtt.addEventListener(MouseEvent.CLICK, noclick);
		cancelbtt.addEventListener(MouseEvent.CLICK, cancelclick);
	}
	private function yesclick(e:MouseEvent):Void {
		//save -> continue
	}
	private function noclick(e:MouseEvent):Void {
		// don't save -> continue 
		if (continueParams.length == 3) {
			continueFunction(continueParams[0], continueParams[1], continueParams[2]);// rebuild map
		}else {
			continueFunction(continueParams[0]);// getMapFromDB
		}
		
		
		cancelclick();
	}
	private function cancelclick(e:MouseEvent=null):Void {
		// close modal screen
		DisplayManager.getInstance().cancelSaveDialogue(modal);
	}
	
}