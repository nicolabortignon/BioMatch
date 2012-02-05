package com.as3dmod.util {
	import com.carlcalderon.arthropod.Debug;	
	
	/**
	 * @author Bartek Drozdz
	 */
	public class Log {
		
		public static function init():void {
			Debug.clear();
		}
		
		public static function info(msg:Object):void {
			Debug.log(msg.toString());
		}
		
		public static function error(msg:Object):void {
			Debug.log(msg.toString(), 0xff8080);
		}
	}
}
