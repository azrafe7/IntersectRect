package  
{
	import flash.display.BlendMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.World;
	import punk.fx.effects.GlowFX;
	import punk.fx.graphics.FXText;
	
	/**
	 * Testing world to showcase RayCaster and ProximityManager.
	 * 
	 * @author azrafe7
	 */
	public class TestWorld extends World 
	{

		protected const DRAG_COLOR:uint = 0x333333;
		protected const DEFAULT_ALPHA:Number = .5;

		private const RECT_A_COLOR:uint = 0xFF0000;
		private const RECT_B_COLOR:uint = 0x00FF00;
		private const CUSTOM_OUTLINE_COLOR:uint = 0x4030D0;
		private const DEFAULT_OUTLINE_COLOR:uint = 0xD0D030;
		
		private var glowFX:GlowFX = new GlowFX(2, 0, 6);
		private var info:FXText;
		private var mouseInfo:FXText;
		
		private var rectA:Rectangle;
		private var rectB:Rectangle;
		
		private var mustFixSize:Boolean = true;
		
		private var customOverlapRect:Rectangle;
		private var overlapRect:Rectangle;
		
		private var customIsOverlapping:Boolean;
		private var isOverlapping:Boolean;
		
		protected var startPoint:Point = new Point();
		protected var endPoint:Point = new Point();

		private var dragging:Boolean = false;
		
		private var intersection:Function;
		

		public function TestWorld() 
		{
			
		}
		
		override public function begin():void 
		{
			super.begin();
			
			// sticky info text
			info = new FXText("", 0, 0, {size:12});
			info.effects.add(glowFX);
			info.scrollX = info.scrollY = 0;
			addGraphic(info, -2, 10, 32);
			
			mouseInfo = new FXText("", 0, 0, {size:12});
			mouseInfo.effects.add(glowFX);
			mouseInfo.scrollX = mouseInfo.scrollY = 0;
			addGraphic(mouseInfo, -2, 10, FP.height - 90);
			
			
			FP.log("SPACE - generated random rectangles  |  F - fix sizes (only positive)");
			
			info.setStyle("RECT_A", { color:RECT_A_COLOR } );
			info.setStyle("RECT_B", { color:RECT_B_COLOR} );
			info.setStyle("CUSTOM", { color:CUSTOM_OUTLINE_COLOR} );
			info.setStyle("DEFAULT", { color:DEFAULT_OUTLINE_COLOR} );
			
			FP.camera.offset( -FP.halfWidth, -FP.halfHeight);
			
			intersection = new_intersection;
		}
		
		override public function update():void 
		{
			super.update();

			// handle input
			
			// reset
			if (Input.pressed(Key.R)) {
				FP.world.removeAll();
				FP.world = new TestWorld();
			}
			
			// positive size
			if (Input.pressed(Key.F)) {
				mustFixSize = !mustFixSize;

				customOverlapRect = intersection(rectA, rectB);
				overlapRect = rectA.intersection(rectB);
				//if (overlapRect.width <= 0 && overlapRect.height <= 0) overlapRect = rectB.intersection(rectA);
			}
			
			// random rects
			if (rectA == null || Input.pressed(Key.SPACE)) {
				rectA = setRandomRect(rectA);
				rectB = setRandomRect(rectB);
				
				if (Math.random() < .2) rectB = rectA.clone();
				
				customOverlapRect = intersection(rectA, rectB);
				overlapRect = rectA.intersection(rectB);
				//if (overlapRect.width <= 0 && overlapRect.height <= 0) overlapRect = rectB.intersection(rectA);
			}
			
			// fix size ?
			if (mustFixSize) {
				fixRect(rectA);
				fixRect(rectB);

				customOverlapRect = intersection(rectA, rectB);
				overlapRect = rectA.intersection(rectB);
				//if (overlapRect.width <= 0 && overlapRect.height <= 0) overlapRect = rectB.intersection(rectA);
			}
			
			// format and display info text
			info.richText = "FIX SIZES (ONLY POSITIVE ALLOWED): " + (mustFixSize ? "ON" : "OFF") + "\n\n" +
   					        "<RECT_A>RECT_A\n" + formatRect(rectA) + "</RECT_A>\n\n" +
					        "<RECT_B>RECT_B\n" + formatRect(rectB) + "</RECT_B>\n\n\n\n\n\n" +
					        "<CUSTOM>CUSTOM_INTERSECTION [" + (intersects(rectA, rectB)) + "]\n" + formatRect(customOverlapRect) + "</CUSTOM>\n\n" +
					        "<DEFAULT>DEFAULT_INTERSECTION [" + (rectA.intersects(rectB)) + "]\n" + formatRect(overlapRect) + "</DEFAULT>";

			// mouse dragging
			dragging = Input.mouseDown;
			if (Input.mousePressed) {
				startPoint.x = Input.mouseX;
				startPoint.y = Input.mouseY;
			}
			if (dragging) {
				endPoint.x = Input.mouseX;
				endPoint.y = Input.mouseY;
			}
			
			if (dragging) {
				mouseInfo.text = "FROM: " + startPoint.x + ", " + startPoint.y + "   TO: " + endPoint.x + ", " + endPoint.y + "   LENGTH: " + FP.distance(startPoint.x, startPoint.y, endPoint.x, endPoint.y).toFixed(1) + " @ " + FP.angle(startPoint.x, startPoint.y, endPoint.x, endPoint.y).toFixed(1) + " deg\n";
			} else mouseInfo.text = "\n";
			mouseInfo.text += "MOUSE COORDS: " + Input.mouseX + ", " + Input.mouseY + "\nWORLD COORDS: " + (Input.mouseX + FP.camera.x).toFixed(1) + ", " + (Input.mouseY + FP.camera.y).toFixed(1);
		}
		
		override public function render():void 
		{
			super.render();
			
			Draw.blend = BlendMode.ADD;
			
			// world
			Draw.linePlus(0, -FP.halfHeight, 0, FP.halfHeight, 0x333333);
			Draw.linePlus(-FP.halfWidth, 0, FP.halfWidth, 0, 0x333333);
			
			
			// Rectangles
			// rect A
			//Draw.rectPlus(rectA.x, rectA.y, rectA.width, rectA.height, RECT_A_COLOR, DEFAULT_ALPHA);
			Draw.rectPlus(rectA.x, rectA.y, rectA.width, rectA.height, RECT_A_COLOR, 1, false);
			// rect B
			//Draw.rectPlus(rectB.x, rectB.y, rectB.width, rectB.height, RECT_B_COLOR, DEFAULT_ALPHA);
			Draw.rectPlus(rectB.x, rectB.y, rectB.width, rectB.height, RECT_B_COLOR, 1, false);
			// custom
			if (customOverlapRect.width > 0 && customOverlapRect.height > 0)
				Draw.rectPlus(customOverlapRect.x, customOverlapRect.y, customOverlapRect.width, customOverlapRect.height, CUSTOM_OUTLINE_COLOR, DEFAULT_ALPHA);
				Draw.rectPlus(customOverlapRect.x, customOverlapRect.y, customOverlapRect.width, customOverlapRect.height, CUSTOM_OUTLINE_COLOR, .75, false);
			// default
			if (overlapRect.width > 0 && overlapRect.height > 0)
				Draw.rectPlus(overlapRect.x, overlapRect.y, overlapRect.width, overlapRect.height, DEFAULT_OUTLINE_COLOR, DEFAULT_ALPHA);
				Draw.rectPlus(overlapRect.x, overlapRect.y, overlapRect.width, overlapRect.height, DEFAULT_OUTLINE_COLOR, .75, false);
			
			// dragged line
			if (dragging) {
				Draw.blend = BlendMode.ADD;
				Draw.linePlus(startPoint.x + FP.camera.x, startPoint.y + FP.camera.y, endPoint.x + FP.camera.x, endPoint.y + FP.camera.y, DRAG_COLOR, DEFAULT_ALPHA);
				//Draw.dot(startPoint.x, startPoint.y, DRAG_COLOR, DEFAULT_ALPHA, false);
				//Draw.dot(endPoint.x, endPoint.y, DRAG_COLOR, DEFAULT_ALPHA, false);
				Draw.blend = BlendMode.NORMAL;
			}
		}
		
		
		// custom intersects() - fast but works only for non negative dimensioned rectangles
		public function intersects(rect1:Rectangle, rect2:Rectangle):Boolean {
			return !(rect1.x > rect2.x + (rect2.width - 1) || rect1.x + (rect1.width - 1) < rect2.x || rect1.y > rect2.y + (rect2.height - 1) || rect1.y + (rect1.height - 1) < rect2.y);
		}
		
		/**
		 * Finds overlapping area between [rect1] and [rect2]. Notes: ...
		 * 
		 * Set [fixDimensions] to true to make it work also for rectangles with negative widths or heights.
		 * The original rects will not be modified.
		 * 
		 * @param	rect1				Rectangle to check for collision/overlapping with [rect2].
		 * @param	rect2				Rectangle to check for collision/overlapping with [rect1].
		 * @param	fixDimensions		Adjust dimensions & pos if width || height < 0?
		 * 
		 * @return Overlapping rectangle region or an empty rectangle if [rect1] and [rect2] don't overlap.
		 */
		public function new_intersection(rect1:Rectangle, rect2:Rectangle, fixDimensions:Boolean = true):Rectangle 
		{
			// init
			var x1:Number = rect1.x, 		y1:Number = rect1.y,		// rect1 pos
				w1:Number = rect1.width, 	h1:Number = rect1.height,	// rect1 size
				x2:Number = rect2.x, 		y2:Number = rect2.y,		// rect2 pos
				w2:Number = rect2.width, 	h2:Number = rect2.height;	// rect2 size
				
			// convert to positive dimensions?
			if (fixDimensions) {
				// rect1
				if (w1 < 0) { x1 += w1; w1 = -w1; }
				if (h1 < 0) { y1 += h1; h1 = -h1; }
				// rect2
				if (w2 < 0) { x2 += w2; w2 = -w2; }
				if (h2 < 0) { y2 += h2; h2 = -h2; }
			}
			
			// calc bounds
			var left:Number = Math.max(x1, x2);
			var right:Number = Math.min(x1 + w1, x2 + w2);
			var top:Number = Math.max(y1, y2);
			var bottom:Number = Math.min(y1 + h1, y2 + h2);
			
			// calc size
			var width:Number = right - left;
			var height:Number = bottom - top;
			
			return (width < 0 || height < 0) ? new Rectangle() : new Rectangle(left, top, width, height);
		}
		
		
		public function old_intersection(rect1:Rectangle, rect2:Rectangle):Rectangle 
		{
			var left:Number = Math.max(rect1.x, rect2.x);
			var right:Number = Math.min(rect1.right, rect2.right);
			var top:Number = Math.max(rect1.y, rect2.y);
			var bottom:Number = Math.min(rect1.bottom, rect2.bottom);

			var width:Number = right - left;
			var height:Number = bottom - top;
			return (width < 0 || height < 0) ? new Rectangle() : new Rectangle(left, top, width, height);
		}
		
		
		
		public function setRandomRect(rect:Rectangle, positiveSize:Boolean = false):Rectangle
		{
			var res:Rectangle = (rect != null) ? rect : new Rectangle();
			
			res.x = Math.random() * FP.halfWidth * .5 - FP.halfWidth * .25;
			res.y = Math.random() * FP.halfHeight * .5 - FP.halfHeight * .25;
			res.width = Math.random() * 300 - 150;
			res.height = Math.random() * 300 - 150;
			
			if (positiveSize) {
				fixRect(res);
			}
			
			return res;
		}
		
		/**
		 * Fix rectangle if dimensions are negative.
		 * 
		 * Ex.: [x: 5, y:5, w:-15, h:10] -> [x: -10, y:5, w:15, h:10]
		 * 
		 * @param	rect		The rectangle to fix.
		 * 
		 * @return The fixed rect.
		 */
		public function fixRect(rect:Rectangle):Rectangle 
		{
			if (rect.width < 0) {
				rect.x += rect.width;
				rect.width *= -1;
			}
			if (rect.height < 0) {
				rect.y += rect.height;
				rect.height *= -1;
			}
			
			return rect;
		}
		
		public function formatRect(rect:Rectangle):String 
		{
			return "x: " + rect.x.toFixed(2) + "\ny: " + rect.y.toFixed(2) + "\nw: " + rect.width.toFixed(2) + "\nh: " + rect.height.toFixed(2);
		}
	}

}