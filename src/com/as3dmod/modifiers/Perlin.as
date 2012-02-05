package com.as3dmod.modifiers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;	
	
	/**
	 * 	<b>Perlin modifier.</b>
	 * 
	 *  Generates a perlin noise bitmap and displaces vertices 
	 *  based on the color value of each pixel of the noise map.
	 */
	public class Perlin extends Modifier implements IModifier {
		
		private var b:BitmapData = null;
		private var off:Number;
		private var frc:Number;
		private var seed:Number;
		
		private var start:Number = 0;
		private var end:Number = 0;
		private var bmpWidth:Number;
		private var bmpHeight:Number;
		
		private var _inverse:Boolean = false;

		/**
		 * @param	f force. May be modified later with the force attribute
		 * @param	bmpWidth Bitmap width. The width of the bitmap that will be generating the noise		 * @param	bmpHeight Bitmap height. The height of the bitmap that will be generating the noise
		 */
		public function Perlin(f:Number=1, bmpWidth:Number=25, bmpHeight:Number=25, seed:Number=0) {
			this.bmpHeight = bmpHeight;
			this.bmpWidth = bmpWidth;
			frc = f;
			b = new BitmapData(bmpWidth, bmpHeight);
			off = 0;
			if(seed == 0) seed = Math.random() * 1000;
		}
		
		public function setFalloff(start:Number=0, end:Number=1):void {
			this.start = start;
			this.end = end;
		}
		
		/**
		 * The force by which the perlin color value used to move the vertex will be multiplied.
		 */
		public function set force(f:Number):void {
			frc = f;
		}
		
		public function get force():Number {
			return frc;
		}
		
		/**
		 * Returns a preview of the perlin noise source bitmapData
		 * 
		 * @return bitmap Bitmap object that can be attached to a display list. Contains the bitmapData used a the perlin noise source.
		 */
		public function get previev():Bitmap {
			var pr:Bitmap = new Bitmap(b);
			pr.scaleX = pr.scaleY = 4;
			return pr;
		}

		public function apply():void {
			var p:Point = new Point(off++, 0);
			b.perlinNoise(bmpWidth, bmpHeight, 1, seed, false, true, BitmapDataChannel.RED, true, [p, p, p]);
			
			var vs:Array = mod.getVertices();
			var vc:int = vs.length;
			
			for (var i:int = 0; i < vc; i++) {
				var v:VertexProxy = vs[i] as VertexProxy;
				
				var ma:Number = (inverse) ? 1 - v.getRatio(mod.maxAxis) : v.getRatio(mod.maxAxis);				var md:Number = (inverse) ? 1 - v.getRatio(mod.midAxis) : v.getRatio(mod.midAxis);
				
                var px:int = Math.ceil(ma * (bmpWidth - 1));
				var py:int = Math.ceil(md * (bmpHeight - 1));
				
				var vzpos:Number = b.getPixel(px, py) & 0xff;
				
				var fa:Number = v.getRatio(mod.maxAxis);
				if(start < end) {
		 			if (fa < start) fa = 0;
					if (fa > end) fa = 1;
				} else if(start > end) {
					fa = 1 - fa;
					if (fa > start) fa = 0;
					if (fa < end) fa = 1;
				} else {
					fa = 1;
				}
				
                v.setValue(mod.minAxis, v.getValue(mod.minAxis) + (128 - vzpos) * frc * fa);
			}
		}
		
		public function get inverse():Boolean {
			return _inverse;
		}
		
		public function set inverse(inverse:Boolean):void {
			_inverse = inverse;
		}
	}
}