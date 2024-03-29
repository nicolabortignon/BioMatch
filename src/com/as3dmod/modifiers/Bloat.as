﻿package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.Vector3D;
	import com.as3dmod.core.VertexProxy;	

	/**
	 * <b>Bloat modifier.</b>
	 * 
	 * Bloats a mesh by forcing vertices out of specified sphere.
	 * @author makc
	 */
	public class Bloat extends Modifier implements IModifier {

		private var _center:Vector3D = new Vector3D;
		/**
		 * Center of bloating sphere.
		 */
		public function get center ():Vector3D { return _center; }
		/**
		 * @private setter
		 */
		public function set center (v:Vector3D):void { _center = v; }

		private var _r:Number = 0;
		/**
		 * Radius of bloating sphere.
		 * @default 0
		 */
		public function get radius ():Number { return _r; }
		/**
		 * @private setter
		 */
		public function set radius (v:Number):void { _r = Math.max (0, v); }

		private var _a:Number = 0.01;
		/**
		 * Bloating "pressure" fall-off exponent factor. Zero means no fall-off.
		 * @default 0.01
		 */
		public function get a ():Number { return _a; }
		/**
		 * @private setter
		 */
		public function set a (v:Number):void { _a = Math.max (0, v); }

		private var _u:Vector3D = new Vector3D;
		/**
		 * @inheritDoc
		 */
		public function apply():void {
			var vs:Array = mod.getVertices();

			for each (var v:VertexProxy in vs) {

				// get a vector towards vertex
				_u.x = v.x; _u.y = v.y; _u.z = v.z;
				_u.subtract (_center);

				// change norm to norm + r * exp (-a * norm)
				_u.modulo += _r * Math.exp ( - _u.modulo * _a);

				// move vertex accordingly
				_u.add (_center);
				v.x = _u.x; v.y = _u.y; v.z = _u.z;
			}
		}

	}
	
}