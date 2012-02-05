package com.as3dmod.core {
	import com.as3dmod.util.ModConstant;	
	
	/**
	 * Code adapted from the org.papervision3d.core.math.Number3D class
	 */
	public class Vector3D {

		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var vectorForZero:int = ModConstant.X;

		public function Vector3D( x:Number = 0, y:Number = 0, z:Number = 0 ) {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public final function add( v:Vector3D ):void {
			x += v.x;
			y += v.y;
			z += v.z;
		}

		public final function subtract( v:Vector3D ):void {
			x -= v.x;
			y -= v.y;
			z -= v.z;
		}

		public function get modulo():Number {
			return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
		}

		public function set modulo(m:Number):void {
			normalize (); x *= m; y *= m; z *= m;
		}

		public function normalize():void {
			var mod:Number = this.modulo;

			if( mod != 0 && mod != 1) {
				this.x /= mod;
				this.y /= mod;
				this.z /= mod;
			} else if(mod == 0) {
				switch(vectorForZero) {
					case ModConstant.X: x = 1; break;
					case ModConstant.Y: y = 1; break;
					case ModConstant.Z: z = 1; break;
				}
			}
		}

		public static function dot( v:Vector3D, w:Vector3D ):Number {
			return ( v.x * w.x + v.y * w.y + w.z * v.z );
		}
	}
}
