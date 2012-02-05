package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.MeshProxy;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;
	import com.as3dmod.util.ModConstant;	

	/**
	 * 	<b>Bend modifier.</b> Bends an object along an axis. 
	 * 	<br>
	 * 	<br>IMPORTANT: This is the new version of the code - it allows bending at any angle.
	 * 	<br>Please refer here for a demo: 
	 * 	<a href="http://www.everydayflash.com/">http://www.everydayflash.com/</a><br>
	 * 	<br>
	 * 	<br>If you were using the old verion of the Bend class, and your code is now broken,
	 * 	just update to revision 29 from the SVN repository located here:
	 * 	<br><a href="http://as3dmod.googlecode.com/svn/trunk/">http://as3dmod.googlecode.com/svn/trunk/</a>
	 * 	
	 * 	@version 2.0
	 * 	@author Bartek Drozdz
	 */
	public class Bend extends Modifier implements IModifier {
		
		private var _force:Number;
		private var _offset:Number;
		
		private var _angle:Number;
		private var cosa:Number;
		private var ncosa:Number;
		private var sina:Number;
		private var nsina:Number;
		
		private var _diagAngle:Number;
		
		private var _constraint:int = ModConstant.NONE;
		
		private var max:int;
		private var min:int;
		private var mid:int;
		private var width:Number;
		private var height:Number;
		private var origin:Number;
		private var switchAxes:Boolean;

		public function Bend(f:Number=0, o:Number=.5, a:Number=0, switchAxes:Boolean=false) {
			_force = f;
			_offset = o;
			angle = a;
			this.switchAxes = switchAxes;
		}

		override public function setModifiable(mod:MeshProxy):void {
			super.setModifiable(mod);
			max = (switchAxes) ? mod.midAxis : mod.maxAxis;
			min = mod.minAxis;
			mid = (switchAxes) ? mod.maxAxis : mod.midAxis;
			
			width = mod.getSize(max);	
			height = mod.getSize(mid);
			origin = mod.getMin(max);
			
			_diagAngle = Math.atan(width / height);
		}

		/**
		 * 	[0 - 2] where 0 = no bend, and 2 360 deg bend.
		 * 	When > 2 will start rolling on itself, which does not look good.
		 * 	(default - 0)
		 */
		public function set force(f:Number):void { _force = f; }		
		public function get force():Number { return _force; }
		
		/**
		 * Can be either ModConstants.LEFT, ModConstants.RIGHT or ModConstants.NONE
		 * (default - NONE)
		 */
		public function set constraint(c:int):void { _constraint = c; }
		public function get constraint():int { return _constraint; }
		
		/**
		 * [0 - 1] The start place of the bend. 
		 */
		public function get offset():Number { return _offset; }
		public function set offset(offset:Number):void { _offset = offset; }

		/**
		 * 	The angle of the diagonal of the mesh
		 */
		public function get diagAngle():Number { return _diagAngle; }
		
		/**
		 * The angle of the bend. In rad.
		 */
		public function get angle():Number { return _angle; }
		public function set angle(a:Number):void { 
			_angle = a; 
			cosa = Math.cos(a);
			sina = Math.sin(a);
			ncosa = Math.cos(-a);
			nsina = Math.sin(-a);
		}

		/**
		 *  Applies the modifier to the mesh
		 */
		public function apply():void {	
			if(force == 0) return;

			var vs:Array = mod.getVertices();
			var vc:int = vs.length;
			
			var distance:Number = origin + width * offset;
			var radius:Number = width / Math.PI / force;
			var bendAngle:Number = Math.PI * 2 * (width / (radius * Math.PI * 2));

			for (var i:int = 0; i < vc; i++) {
				var v:VertexProxy = vs[i] as VertexProxy;
				
				var vmax:Number = v.getValue(max);
				var vmid:Number = v.getValue(mid);
				var vmin:Number = v.getValue(min);

				var vmax2:Number = cosa * vmax - sina * vmid;
				var vmid2:Number = cosa * vmid + sina * vmax;
				
				vmax = vmax2;
				vmid = vmid2;

				var p:Number = (vmax - origin) / width;

				if ((constraint == ModConstant.LEFT && p <= offset) || (constraint == ModConstant.RIGHT && p >= offset)) {	
				} else {
					var fa:Number = ((Math.PI / 2) - bendAngle * offset) + (bendAngle * p);
					var op:Number = Math.sin(fa) * (radius + vmin);
					var ow:Number = Math.cos(fa) * (radius + vmin);
					vmin = op - radius;
					vmax = distance - ow;
				}

				vmax2 = ncosa * vmax - nsina * vmid;
				vmid2 = ncosa * vmid + nsina * vmax;
				
				vmax = vmax2;
				vmid = vmid2;
				
				v.setValue(max, vmax);
				v.setValue(mid, vmid);
				v.setValue(min, vmin);
			}
		}
	}
}


