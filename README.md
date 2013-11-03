IntersectRect
=============

Find rectangles overlapping area (AS3 vs custom - proof of concept in FlashPunk).


Just found out - _through bad times_ - that the rects involved in `Rectangle.intersection()` (and `intersects()`) calls
must guarantee to have non-negative sizes, otherwise no collision will be detected, even though they effectively overlap.

Basically just ensure you have only non-negative-sized rectangles in your app or run the rect through something like this and you'll be fine:

```as3
		/**
		 * Fix rectangle if dimensions are negative.
		 * 
		 * Ex.: [x: 5, y:5, w:-15, h:10] -> [x: -10, y:5, w:15, h:10]
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
```

Here's a fairly generic code to calc the overlapping region:

```as3
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
```