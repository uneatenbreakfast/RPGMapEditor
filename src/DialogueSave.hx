package ;
import flash.events.MouseEvent;

/**
 * ...
 * @author Nelson
 */
class DialogueSave extends Dialogue_Save
{
	private var modal:ModalScreen;
	
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
	}
	private function cancelclick(e:MouseEvent):Void {
		// close modal screen
		
		DisplayManager.getInstance().cancelSaveDialogue(modal);
	}
	
}