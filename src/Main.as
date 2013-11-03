package 
{
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Input;
	import flash.system.System;
	import net.flashpunk.Engine;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Text;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	[SWF(width = "640", height = "480")]
	public class Main extends Engine 
	{
		
		public function Main():void 
		{
			trace("FP " + FP.VERSION + " started!");
			super(640, 480, 60, false);
			
			//FP.console.toggleKey = Key.TAB;
			//FP.console.log("TAB - toggle console");
			FP.screen.color = 0x111111;
			FP.console.enable();
			
			FP.world = new TestWorld;
		}
		
		override public function init():void 
		{
			super.init();

		}
		
		override public function update():void
		{
			super.update();
			
			// press ESCAPE to exit debug player
			if (Input.check(Key.ESCAPE)) {
				System.exit(1);
			}
		}
	}
}