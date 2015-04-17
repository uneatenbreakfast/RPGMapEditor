package ;
import flash.display.Sprite;

/**
 * ...
 * @author Nelson
 */
class ModalScreen extends Sprite
{

	public function new() 
	{
		super();
		var displayManager:DisplayManager = DisplayManager.getInstance();
		
		this.graphics.beginFill(0x000000, .5);
		this.graphics.drawRect(0, 0, displayManager.windowWidth, displayManager.windowHeight);		
	}
	
}