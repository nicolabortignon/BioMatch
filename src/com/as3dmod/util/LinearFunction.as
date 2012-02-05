package com.as3dmod.util {
	import flash.geom.Point;	
	
	/**
	 * @author Bartek Drozdz
	 */
	public class LinearFunction {

		private var b:Point;
		private var a:Point;
		private var fa:Number;
		private var fb:Number;

		public function LinearFunction(a:Point, b:Point) {
			this.a = a;
			this.b = b;
			
			fa = (b.y - a.y)/(b.x - a.x);
			fb = a.y - (b.y - a.y)/(b.x - a.x) * a.x;
		}
		
		public function perpendicular(c:Point):Point {
			var fc:Number = c.y + 1/fa * c.x;
			var px:Number = (fc - fb) / (fa + 1/fa);
			var py:Number = fa * px + fb;
			return new Point(px, py);
		}
		
		public function perpendicularDistance(c:Point):Number {
			var p:Point = perpendicular(c);
			return calcDistance(c, p);
		}
		
		public function perpendicularX(c:Point):Number {
			var p:Point = perpendicular(c);
			return p.x - c.x;
		}
		
		public function perpendicularY(c:Point):Number {
			var p:Point = perpendicular(c);
			return p.y - c.y;
		}
		
		public function get distance():Number {
			return calcDistance(a, b);
		}
		
		public function value(x:Number):Number {
			return x * fa + fb;
		}
		
		public static function calcDistance(pa:Point, pb:Point):Number {
			var dx:Number = pb.x - pa.x;
			var dy:Number = pb.y - pa.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
	}
}
