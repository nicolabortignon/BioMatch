﻿package away3d.test
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.render.Renderer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	* SimpleView
	* @author katopz@sleepydesign.com
	*/
	public class SimpleView extends Sprite
	{
		protected var view		:View3D;
		protected var target	:Object3D;
		
		public function SimpleView()
		{
			target = new Object3D();
			
			view = new View3D({
				x:stage.stageWidth * .5, y:stage.stageHeight * .5, 
				camera: new Camera3D( { y:2000*Math.sin(Math.PI/6), z:2000 } ), 
				renderer:Renderer.BASIC
			});
			
            view.scene.addChild(target);
            view.camera.lookAt(target.position);
			
			view.addEventListener(Event.ADDED_TO_STAGE, init);
			addChild(view);
		}
		
        protected function init(event:Event) : void
		{
			//stage
            stage.scaleMode = "noScale";
            stage.showDefaultContextMenu = true;
            stage.stageFocusRect = false;
            stage.quality = "medium";
            stage.frameRate = 30;
            
            create();
		}
        
        protected function create() : void
        {
        	 //plz override me
        }
        
        protected function start() : void
		{
			view.camera.lookAt(target.position);
			addEventListener(Event.ENTER_FRAME, run);
		}
		
        protected function run(event:Event) : void
        {
			//update
            view.scene.updateTime();
            view.render();
            
            //draw
            draw();
        }
        
        protected function draw() : void
        {
        	 //plz override me
        }
	}
}