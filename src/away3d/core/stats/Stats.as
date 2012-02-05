package away3d.core.stats 
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.*;
    
    public class Stats extends Sprite
    {
        private var totalElements:int = 0;
        private var meshes:int = 0;
        public var scopeMenu:View3D = null;
        public var displayMenu:Sprite = null;
        public var geomMenu:Sprite = null;
        private var lastrender:int;
        private var fpsLabel:StaticTextField;
        private var titleField:StaticTextField;
        private var perfLabel:StaticTextField;
        private var ramLabel:StaticTextField;
        private var swfframerateLabel:StaticTextField;
        private var avfpsLabel:StaticTextField;
        private var peakLabel:StaticTextField;
        private var faceLabel:StaticTextField;
        private var faceRenderLabel:StaticTextField;
        private var geomDetailsLabel:TextField;
        private var meshLabel:StaticTextField;
        private var fpstotal:int = 0;
        private var refreshes:int = 0;
        private var bestfps:int = 0;
        private var lowestfps:int = 999;
        private var bar:Sprite;
        private var barwidth:int = 0;
        private var closebtn:Sprite;
        private var cambtn:Sprite;
        private var clearbtn:Sprite;
        private var geombtn:Sprite;
        private var barscale:int = 0;
        private var stageframerate:Number;
        private var displayState:int;
        private var camLabel:TextField;
        private var camMenu:Sprite;
        private var camProp:Array;
        private var rectclose:Rectangle = new Rectangle(228,4,18,17);
        private var rectcam:Rectangle = new Rectangle(207,4,18,17);
        private var rectclear:Rectangle = new Rectangle(186,4,18,17);
        private var rectdetails:Rectangle = new Rectangle(165,4,18,17);
        private var geomLastAdded:String;
        private var defautTF:TextFormat = new TextFormat("Verdana", 10, 0x000000);
		private var defautTFBold:TextFormat = new TextFormat("Verdana", 10, 0x000000, true);
        //
        private const VERSION:String = "2";
        private const REVISION:String = "2.7";
        private const APPLICATION_NAME:String = "Away3D.com";
        
        public var sourceURL:String;
        
        private var menu0:ContextMenuItem;
        private var menu1:ContextMenuItem;
        private var menu2:ContextMenuItem;
         
        public function Stats(scope:View3D, framerate:Number = 0)
        {
            scopeMenu = scope;
            stageframerate = (framerate)? framerate : 30;
            displayState = 0;
            sourceURL = scope.sourceURL;
			tabEnabled = false;
            
            menu0 = new ContextMenuItem("Away3D Project stats", true, true, true);
            menu1 = new ContextMenuItem("View Source", true, true, true); 
            menu2 = new ContextMenuItem(APPLICATION_NAME+"\tv" + VERSION +"."+REVISION, true, true, true);
            
			var scopeMenuContextMenu:ContextMenu = new ContextMenu();
            scopeMenuContextMenu = new ContextMenu();
            scopeMenuContextMenu.customItems = sourceURL? [menu0, menu1, menu2] : [menu0, menu2];
            
            menu0.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, displayStats);
            menu1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, viewSource);
            menu2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, visitWebsite);
            
            scopeMenuContextMenu.hideBuiltInItems();
			scopeMenu.contextMenu = scopeMenuContextMenu;
        }
        
        public function addSourceURL(url:String):void
        {
        	sourceURL = url;
			var scopeMenuContextMenu:ContextMenu = new ContextMenu();
			scopeMenuContextMenu.customItems = sourceURL? [menu0, menu1, menu2] : [menu0, menu2];
			scopeMenu.contextMenu = scopeMenuContextMenu;
        }
        
        //Displays stats
        public function displayStats(e:ContextMenuEvent):void
        {
             if(!displayMenu){
             	scopeMenu.statsOpen = true;
                generateSprite();
                addEventMouse();
                //applyShadow();
             }
        }
        
        //Redirect to site
        public function visitWebsite(e:ContextMenuEvent):void 
        {
            var url:String = "http://www.away3d.com";
            var request:URLRequest = new URLRequest(url);
            try {
                navigateToURL(request);
            } catch (error:Error) {
                
            }
        }
        
        //View Source files
        public function viewSource(e:ContextMenuEvent):void 
        {
            var request:URLRequest = new URLRequest(sourceURL);
            try {
                navigateToURL(request, "_blank");
            } catch (error:Error) {
                
            }
        }
                
        //Closes stats and cleans up a bit...
        private function closeStats():void
        {
        	scopeMenu.statsOpen = false;
      		displayState = 0;
            scopeMenu.removeEventListener(MouseEvent.MOUSE_DOWN, onCheckMouse);
            scopeMenu.removeEventListener(MouseEvent.MOUSE_MOVE, updateTips);
            scopeMenu.removeChild(displayMenu);
            displayMenu = null;
        }
        
        //Mouse Events
        private function addEventMouse():void
        {  
            scopeMenu.addEventListener(MouseEvent.MOUSE_DOWN, onCheckMouse);
            scopeMenu.addEventListener(MouseEvent.MOUSE_MOVE, updateTips);
        }
        
        private function updateTips(me:MouseEvent):void
        { 
            if(scopeMenu != null){
                var x:Number = displayMenu.mouseX;
                var y:Number = displayMenu.mouseY;
                var pt:Point = new Point(x,y);
                try {
                    if(rectcam.containsPoint(pt)){
                        titleField.text = "CAMERA INFO";
                    } else if(rectclose.containsPoint(pt)){
                        titleField.text = "CLOSE STATS";
                    } else if(rectclear.containsPoint(pt)){
                        titleField.text = "CLEAR AVERAGES";
                    } else if(rectdetails.containsPoint(pt)){
                        titleField.text = "MESH INFO";
                    } else{
                        titleField.text = "AWAY3D PROJECT";
                    }
                } catch (e:Error) {
                    
                }
            }
        }
        
        
        private function onCheckMouse(me:MouseEvent):void
        { 
            var x:Number = displayMenu.mouseX;
            var y:Number = displayMenu.mouseY;
            var pt:Point = new Point(x,y);
            
            if(rectcam.containsPoint(pt)){
                if(displayState != 1){
                    closeOtherScreen(displayState);
                    displayState = 1;
                    showCamInfo();
                } else{
                    displayState = 0;
                    hideCamInfo();
                }
            } else if(rectdetails.containsPoint(pt)){
                if(displayState != 2){
                    closeOtherScreen(displayState);
                    displayState = 2;
                    showGeomInfo();
                } else{
                    displayState = 0;
                    hideGeomInfo();
                }
            } else if(rectclose.containsPoint(pt)){
                closeStats();
            } else if(rectclear.containsPoint(pt)){
                clearStats();
            } else{
            	if(displayMenu.mouseY<=20)
            	{
                	displayMenu.startDrag();
                	scopeMenu.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
             	}
            }
        }
        
        private function closeOtherScreen(actual:int):void {
             switch(actual){
                case 1:
                hideCamInfo();
                break;
                case 2:
                hideGeomInfo();
             }
        }
        
        private function mouseReleased(event:MouseEvent):void {
            displayMenu.stopDrag();
            scopeMenu.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased);
        }
        
        //drawing the stats container
        private function generateSprite():void
        {  
          
            displayMenu = new Sprite();
            var myMatrix:Matrix = new Matrix();
            myMatrix.rotate(90 * Math.PI/180); 
            displayMenu.graphics.beginGradientFill("linear", [0x333366, 0xCCCCCC], [1,1], [0,255], myMatrix, "pad", "rgb", 0);
            displayMenu.graphics.drawRect(0, 0, 250, 86);
            
            displayMenu.graphics.beginFill(0x333366);
            displayMenu.graphics.drawRect(3, 3, 244, 20);
             
            scopeMenu.addChild(displayMenu);
             
            displayMenu.x -= displayMenu.width*.5;
            displayMenu.y -= displayMenu.height*.5;
            
            // generate closebtn
            closebtn = new Sprite();
            closebtn.graphics.beginFill(0x666666);
            closebtn.graphics.drawRect(0, 0, 18, 17);
            var cross:Sprite = new Sprite();
            cross.graphics.beginFill(0xC6D0D8);
            cross.graphics.drawRect(2, 7, 14, 4);
            cross.graphics.endFill();
            cross.graphics.beginFill(0xC6D0D8);
            cross.graphics.drawRect(7, 2, 4, 14);
            cross.graphics.endFill();
            cross.rotation = 45;
            cross.x+=9;
            cross.y-=4;
            closebtn.addChild(cross);
            displayMenu.addChild(closebtn);
            closebtn.x = 228;
            closebtn.y = 4;
            
            // generate cam btn
            cambtn = new Sprite();
            var cam:Graphics = cambtn.graphics;
            cam.beginFill(0x666666);
            cam.drawRect(0, 0, 18, 17);
            cam.endFill();
            cam.beginFill(0xC6D0D8);
            cam.moveTo(10,8);
            cam.lineTo(16,4);
            cam.lineTo(16,14);
            cam.lineTo(10,10);
            cam.lineTo(10,8);
            cam.drawRect(2, 6, 8, 6);
            cam.endFill();
            displayMenu.addChild(cambtn);
            cambtn.x = 207;
            cambtn.y = 4;
            
            // generate clear btn
            clearbtn = new Sprite();
            var clear_btn:Graphics = clearbtn.graphics;
            clear_btn.beginFill(0x666666);
            clear_btn.drawRect(0, 0, 18, 17);
            clear_btn.endFill();
            clear_btn.beginFill(0xC6D0D8);
            clear_btn.drawRect(6, 6, 6, 6);
            clear_btn.endFill();
            displayMenu.addChild(clearbtn);
            clearbtn.x = 186;
            clearbtn.y = 4;
            
            // generate geometrie btn
            geombtn = new Sprite();
            var geom_btn:Graphics = geombtn.graphics;
            geom_btn.beginFill(0x666666);
            geom_btn.drawRect(0, 0, 18, 17);
            geom_btn.endFill();
            geom_btn.beginFill(0xC6D0D8, 0.7);
            geom_btn.moveTo(3,4);
            geom_btn.lineTo(11,2);
            geom_btn.lineTo(16,5);
            geom_btn.lineTo(7,7);
            geom_btn.lineTo(3,4);
            geom_btn.beginFill(0x7D8489, 0.8);
            geom_btn.moveTo(3,4);
            geom_btn.lineTo(7,7);
            geom_btn.lineTo(7,16);
            geom_btn.lineTo(3,12);
            geom_btn.lineTo(3,4);
            geom_btn.beginFill(0xC6D0D8,1);
            geom_btn.moveTo(7,7);
            geom_btn.lineTo(16,5);
            geom_btn.lineTo(15,13);
            geom_btn.lineTo(7,16);
            geom_btn.lineTo(7,7);
            geom_btn.endFill();
             
            geom_btn.endFill();
            displayMenu.addChild(geombtn);
            geombtn.x = 165;
            geombtn.y = 4;
            
            // generate bar
            displayMenu.graphics.beginGradientFill("linear", [0x000000, 0xFFFFFF], [1,1], [0,255], new Matrix(), "pad", "rgb", 0);
            displayMenu.graphics.drawRect(3, 22, 244, 4);
            displayMenu.graphics.endFill();
            bar = new Sprite();
            bar.graphics.beginFill(0xFFFFFF);
            bar.graphics.drawRect(0, 0, 244, 4);
            displayMenu.addChild(bar);
            bar.x = 3;
            bar.y = 22;
            barwidth = 244;
            barscale = int(barwidth/stageframerate);
            
            // displays Away logo
            displayPicto();
            
            // Generate textfields
            // title
            titleField = new StaticTextField(new TextFormat("Verdana", 10, 0xFFFFFF, true));
            titleField.text = "AWAY3D PROJECT";
            titleField.height = 20;
            titleField.width = 140;
            titleField.x = 22;
            titleField.y = 4;
            displayMenu.addChild(titleField);
            
            // fps
            var fpst:StaticTextField = new StaticTextField(defautTFBold);
            fpst.text = "FPS:";
            fpsLabel = new StaticTextField();
            displayMenu.addChild(fpst);
            displayMenu.addChild(fpsLabel);
            fpst.x = 3;
            fpst.y = fpsLabel.y = 30;
            fpsLabel.x = fpst.x+fpst.width-2;
            
            //average perf
            var afpst:StaticTextField = new StaticTextField(defautTFBold);
            afpst.text = "AFPS:";
            avfpsLabel = new StaticTextField();
            displayMenu.addChild(afpst);
            displayMenu.addChild(avfpsLabel);
            afpst.x = 52;
            afpst.y = avfpsLabel.y = fpsLabel.y;
            avfpsLabel.x = afpst.x+afpst.width-2;
            
            //Max peak
            var peakfps:StaticTextField = new StaticTextField(defautTFBold);
            peakfps.text = "Max:";
            peakLabel = new StaticTextField();
            displayMenu.addChild(peakfps);
            displayMenu.addChild(peakLabel);
            peakfps.x = 107;
            peakfps.y = peakLabel.y = avfpsLabel.y;
            peakfps.autoSize = "left";
            peakLabel.x = peakfps.x+peakfps.width-2;
            
            //MS
            var pfps:StaticTextField = new StaticTextField(defautTFBold);
            pfps.text = "MS:";
            perfLabel = new StaticTextField();
            perfLabel.defaultTextFormat = defautTF;
            displayMenu.addChild(pfps);
            displayMenu.addChild(perfLabel);
            pfps.x = 177;
            pfps.y = perfLabel.y = fpsLabel.y;
            pfps.autoSize = "left";
            perfLabel.x = pfps.x+pfps.width-2;
             
            //ram usage
            var ram:StaticTextField = new StaticTextField(defautTFBold);
            ram.text = "RAM:";
            ramLabel = new StaticTextField();
            displayMenu.addChild(ram);
            displayMenu.addChild(ramLabel);
            ram.x = 3;
            ram.y = ramLabel.y = 46;
            ram.autoSize = "left";
            ramLabel.x = ram.x+ram.width-2;
            
            //meshes count
            var meshc:StaticTextField = new StaticTextField(defautTFBold);
            meshc.text = "MESHES:";
            meshLabel = new StaticTextField();
            displayMenu.addChild(meshc);
            displayMenu.addChild(meshLabel);
            meshc.x = 90;
            meshc.y = meshLabel.y = ramLabel.y;
            meshc.autoSize = "left";
            meshLabel.x = meshc.x+meshc.width-2;
            
            //swf framerate
            var rate:StaticTextField = new StaticTextField(defautTFBold);
            rate.text = "SWF FR:";
            swfframerateLabel = new StaticTextField();
            displayMenu.addChild(rate);
            displayMenu.addChild(swfframerateLabel);
            rate.x = 170;
            rate.y = swfframerateLabel.y = ramLabel.y;
            rate.autoSize = "left";
            swfframerateLabel.x = rate.x+rate.width-2;
            
            //faces
            var faces:StaticTextField = new StaticTextField(defautTFBold);
            faces.text = "T ELEMENTS:";
            faceLabel = new StaticTextField();
            displayMenu.addChild(faces);
            displayMenu.addChild(faceLabel);
            faces.x = 3;
            faces.y = faceLabel.y = 62;
            faces.autoSize = "left";
            faceLabel.x = faces.x+faces.width-2;
            
            //shown faces
            var facesrender:StaticTextField = new StaticTextField(defautTFBold);
            facesrender.text = "R ELEMENTS:";
            faceRenderLabel = new StaticTextField();
            displayMenu.addChild(facesrender);
            displayMenu.addChild(faceRenderLabel);
            facesrender.x = 115;
            facesrender.y = faceRenderLabel.y = faceLabel.y;
            facesrender.autoSize = "left";
            faceRenderLabel.x = facesrender.x+facesrender.width-2;
        }
        
        public function updateStats(renderedfaces:int, camera:Camera3D):void
        {
            var now:int = getTimer();
            var perf:int = now - lastrender;
            lastrender = now;
            
            if (perf < 1000) {
                var fps:int = int(1000 / (perf+0.001));
                fpstotal += fps;
                refreshes ++;
                var average:int = fpstotal/refreshes;
                bestfps = (fps>bestfps)? fps : bestfps;
                lowestfps = (fps<lowestfps)? fps : lowestfps;
                var w:int = barscale*fps;
                bar.width = (w<=barwidth)? w : barwidth;
            }
            //color
            var procent:int = (bar.width/barwidth)*100;
            var colorTransform:ColorTransform = bar.transform.colorTransform;
            colorTransform.color =  255-(2.55*procent) << 16 | 2.55*procent << 8 | 40;
            bar.transform.colorTransform = colorTransform;
                
            if(displayState == 0){
                avfpsLabel.text = ""+average;
                ramLabel.text = ""+int(System.totalMemory/1024/102.4)/10+"MB";
                peakLabel.text = lowestfps+"/"+bestfps;
                fpsLabel.text = "" + fps; 
                perfLabel.text = "" + perf;
                faceLabel.text = ""+totalElements;
                faceRenderLabel.text = ""+renderedfaces;
                meshLabel.text = ""+meshes;
                swfframerateLabel.text = ""+stageframerate;
            } else if(displayState == 1){
                var caminfo:String = "";
                for(var i:int = 0;i<camProp.length;i++){
                    try{
                        if(i>12){
                            caminfo += String(camera[camProp[i]])+"\n";
                        } else {
                            var info:String = String(camera[camProp[i]]);
                            caminfo += info.substring(0, 19)+"\n";
                        }
                    } catch(e:Error){
                        caminfo += "\n";
                    }
                }
                camLabel.text = caminfo;
            } else if(displayState == 2){
                geomDetailsLabel.text = stats;
                //geomDetailsLabel.scrollV = geomDetailsLabel.maxScrollV;
            }
        }
        
        //clear peaks
        private function clearStats():void
        {
            fpstotal = 0;
            refreshes = 0;
            bestfps = 0;
            lowestfps = 999;
        }
        
        //geometrie info
        private function showGeomInfo():void
        {
            if(geomMenu == null){
                createGeometryMenu();
            } else{
                displayMenu.addChild(geomMenu);
                geomMenu.y = 26;
            }
        }
        
        private function hideGeomInfo():void
        {   
            if(geomMenu != null){
                displayMenu.removeChild(geomMenu);
            }
        }
        private function createGeometryMenu():void{
            geomMenu = new Sprite();
            var myMatrix:Matrix = new Matrix();
            myMatrix.rotate(90 * Math.PI/180);
            geomMenu.graphics.beginGradientFill("linear", [0x333366, 0xCCCCCC], [1,1], [0,255], myMatrix, "pad", "rgb", 0);
            geomMenu.graphics.drawRect(0, 0, 250, 200);
            displayMenu.addChild(geomMenu);
            geomMenu.y = 26;
            geomDetailsLabel = new TextField();
            geomDetailsLabel.x = 3;
            geomDetailsLabel.y = 3;
            geomDetailsLabel.defaultTextFormat = defautTF;
            geomDetailsLabel.text = stats;
            geomDetailsLabel.height = 200;
            geomDetailsLabel.width = 235;
            geomDetailsLabel.multiline = true;
            geomDetailsLabel.selectable = true;
            geomDetailsLabel.wordWrap = true;
            geomMenu.addChild(geomDetailsLabel);
        }
        
        //cam info
        private function showCamInfo():void
        {
            if(camMenu == null){
                createCamMenu();
            } else{
                displayMenu.addChild(camMenu);
                camMenu.y = 26;
            }
        }
        
        private function hideCamInfo():void
        {   
            if(camMenu != null){
                displayMenu.removeChild(camMenu);
            }
        }
        
        // cam info menu
        private function createCamMenu():void
        {
            camMenu = new Sprite();
            var myMatrix:Matrix = new Matrix();
            myMatrix.rotate(90 * Math.PI/180);
            camMenu.graphics.beginGradientFill("linear", [0x333366, 0xCCCCCC], [1,1], [0,255], myMatrix, "pad", "rgb", 0);
            camMenu.graphics.drawRect(0, 0, 250, 220);
            displayMenu.addChild(camMenu);
            camMenu.y = 26;
            
            camLabel = new TextField();
            camLabel.height = 210;
            camLabel.width = 170;
            camLabel.multiline = true;
            camLabel.selectable = false;
            var tf:TextFormat = defautTF;
            tf.leading = 1.5;
            camLabel.defaultTextFormat = tf;
            camLabel.wordWrap = true;
            camMenu.addChild(camLabel);
            camLabel.x = 100;
            camLabel.y = 3;
            camProp = ["x","y","z","zoom","focus","distance","panangle","tiltangle","targetpanangle","targettiltangle","mintiltangle","maxtiltangle","steps","target"];
            //props
            var campropfield:TextField = new TextField();
            tf = new TextFormat("Verdana", 10, 0x000000, true);
            tf.leading = 1.5;
            tf.align = "right";
            campropfield.defaultTextFormat = tf;
            campropfield.x = campropfield.y = 3;
            campropfield.multiline = true;
            campropfield.selectable = false;
            campropfield.autoSize = "left";
            campropfield.height = 210;
            for(var i:int = 0;i<camProp.length;i++){
                campropfield.appendText(camProp[i]+":\n");
            }
            camMenu.addChild(campropfield);
        }
        
        private function displayPicto():void
        {
            var logo:Sprite = new Sprite();
            var graphic:Graphics = logo.graphics;
            //graphic.beginFill(0x666666);
            graphic.beginFill(0x000000);
            graphic.drawRect(0, 0, 18, 17);
            var arr:Array = image;
            for(var i:int = 0;i<arr.length;i++){
                graphic.beginFill(Number(arr[i][2]));
                graphic.drawRect(arr[i][0], arr[i][1], 1, 1);
            }
            
            graphic.endFill();
            displayMenu.addChild(logo);
            logo.x = logo.y = 4;
        }
        private function get image():Array
        {
            return [[7,1,262151],[8,1,3215136],[9,1,2033436],[10,1,1],[7,2,2098723],[8,2,5908501],[9,2,4922400],[10,2,720913],[6,3,327691],[7,3,6957102],[8,3,5975556],[9,3,6368779],[10,3,4789809],[11,3,2],[6,4,2361127],[7,4,10833686],[8,4,4926728],[9,4,6239495],[10,4,9190690],[11,4,1114647],[5,5,786453],[6,5,7088423],[7,5,14055707],[8,5,2103310],[9,5,3877139],[10,5,13134098],[11,5,5577773],[12,5,131077],[4,6,1],[5,6,3608110],[6,6,11227664],[7,6,12748351],[8,6,65793],[9,6,986379],[10,6,14980667],[11,6,10044437],[12,6,2230306],[4,7,1179676],[5,7,8007967],[6,7,14911011],[7,7,6509633],[10,7,9138771],[11,7,13989655],[12,7,7350824],[13,7,327689],[3,8,262153],[4,8,4592689],[5,8,12016138],[6,8,15774570],[7,8,855309],[10,8,2434083],[11,8,16233056],[12,8,11489803],[13,8,3345958],[3,9,1966887],[4,9,8665113],[5,9,15636021],[6,9,6773581],[11,9,9140836],[12,9,15240489],[13,9,8467743],[14,9,852240],[2,10,458767],[3,10,5774639],[4,10,13265683],[5,10,10845518],[6,10,257],[11,10,657931],[12,10,14396016],[13,10,12739344],[14,10,5184297],[15,10,2],[2,11,2557230],[3,11,10307863],[4,11,12548133],[5,11,723464],[12,11,1512721],[13,11,14651446],[14,11,10307352],[15,11,1508630],[1,12,983068],[2,12,7154221],[3,12,9522185],[4,12,1314568],[6,12,131586],[7,12,921102],[8,12,1710618],[9,12,1513239],[10,12,657930],[13,12,2892051],[14,12,12610067],[15,12,7220009],[16,12,196614],[1,13,3936052],[2,13,5908749],[3,13,1773570],[4,13,4402968],[5,13,10714191],[6,13,12884326],[7,13,14396274],[8,13,15053429],[9,13,14790257],[10,13,13935206],[11,13,12159571],[12,13,9265971],[13,13,2759432],[14,13,2561537],[15,13,8601360],[16,13,3346464],[1,14,3938326],[2,14,5712395],[3,14,10900499],[4,14,11951126],[5,14,11490833],[6,14,11358991],[7,14,11227662],[8,14,11161870],[9,14,11030286],[10,14,10964497],[11,14,10898963],[12,14,10833429],[13,14,11096344],[14,14,8797973],[15,14,4595726],[16,14,4594459],[17,14,327941],[1,15,2296596],[2,15,3280925],[3,15,2821148],[4,15,2624284],[5,15,2558749],[6,15,2624031],[7,15,2558496],[8,15,2558498],[9,15,2492705],[10,15,2361630],[11,15,2361374],[12,15,2295839],[13,15,2295840],[14,15,2427171],[15,15,2624036],[16,15,1377300]];
        }
        
        internal var type:String;
        internal var elementcount:int;
        internal var url:String;
        
        public var stats:String = "";
        
        public function clearObjects():void
        {
        	stats = "";
        	totalElements = 0;
        	meshes = 0;
        	geomLastAdded = "";
        }
        
        // registration faces and types
        public function addObject(node:Mesh):void
        {
        	type = node.type;
        	elementcount = node.elements.length;
        	url = node.url;
            if (type != null && elementcount != 0) {
                stats += " - " + type + " , elements: " + elementcount + ", url: " + url + "\n";
	            geomLastAdded = " - " + type + " , elements: " + elementcount + ", url: " + url + "\n";
                totalElements += elementcount;
                meshes += 1;
            } else {
            	stats += " - " + type + " , url: " + url + "\n";
            	geomLastAdded = " - " + type + " , url: " + url + "\n";
            }
        }
        
        //TODO: generateClipBoardInfo not implemented yet
        /*
        private function generateClipBoardInfo():void{
            var strReport:String = "-- AWAY3D STATS REPORT --\n\n";
            strReport+= "GEOMETRY:\n";
            strReport+= stats ;
            strReport+= "\nCAMERA:\n";
            var camera:Camera3D = scopeMenu.camera; 
            //System.setClipboard(strReport);
        }
        */
    }
}

import flash.text.TextField;
import flash.text.TextFormat;
	
internal class StaticTextField extends TextField
{
	public function StaticTextField(textFormat:TextFormat=null)
	{
		super();
		if(!textFormat)
			textFormat = new TextFormat("Verdana", 10, 0x000000);
		
		defaultTextFormat = textFormat;
		
		selectable = false;
		mouseEnabled = false;
		mouseWheelEnabled = false;
		
		autoSize = "left";
		tabEnabled = false;
	}
}
	