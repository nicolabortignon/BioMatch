package com.as3dmod.util {

	public class XMath {
	
		public static function normalize(start:Number, end:Number, val:Number):Number
		{
			var range:Number = end - start;
			var normal:Number;
		 
			if (range == 0) {
				normal = 1;
			} else {
				normal = trim(0, 1, (val - start) / end);
			}
	
			return normal;
		}
		
		public static function toRange(start:Number, end:Number, normalized:Number):Number
		{
			var range:Number = end - start;
			var val:Number;
		 
			if (range == 0) {
				val = 1;
			} else {
				val = start + (end - start) * normalized;
			}
	
			return val;
		}
		
		public static function inInRange(start:Number, end:Number, value:Number, excluding:Boolean=false):Boolean {
			if(excluding) return value >= start && value <= end;
			else return value > start && value < end;
		}
		
		public static function sign(val:Number, ifZero:Number=0):Number {
			if(val == 0) return ifZero;
			else return (val > 0) ? 1 : -1;
		}
		
		public static function trim(start:Number, end:Number, value:Number):Number {
			return Math.min(end, Math.max(start, value));
		}
	}
}
