package ggj2012 {

	import flash.display.*;
	import flash.events.Event;
	import flash.net.*;
	
	import flash.utils.*;

	public class Entity extends MovieClip {
		
		public const SPRITE_DIR:String = "sprites/";
		
		private var spriteLoader:Loader;
		public var spriteFile:String;
		public var sprite:MovieClip;
		
		public var spriteWidth:Number = 0;
		public var spriteHeight:Number = 0;
		
		public var bodyContainer:Sprite = new Sprite();
		
		public var defaultAnimation:String = "idle";
		public var currentAnimation:String = "idle";
		public var animationLocked:Boolean = false;
		public var animationFreeze:Boolean = false;
		
		public var initialized:Boolean = false;
		
		public function Entity() {
			this.addEventListener(Event.ADDED_TO_STAGE, setupSprite);
		}
		
		public function destroy():void {
			
			this.removeEventListener(Event.ENTER_FRAME, onThink);
			this.removeEventListener(Event.ENTER_FRAME, onEntityThink);
			
			this.spriteLoader.unload();
			
		}
		
		private function setupSprite(ev:Event):void {
			this.spriteLoader = new Loader();
			
			var spritePath:String = SPRITE_DIR + this.spriteFile;
			trace("Loading sprite: "+spritePath);
			
			this.spriteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, renderSprite);
			this.spriteLoader.load(new URLRequest(spritePath))
			
			this.addChild(bodyContainer);
			
		}
		
		private function renderSprite(ev:Event):void {
			this.sprite = MovieClip(this.spriteLoader.content);
			this.addChild(this.sprite);
			this.onInit(ev);
		}
		
		public function resetAnimation():void {
			this.setAnimation(this.defaultAnimation);
		}
		
		public function setAnimation(anim:String):void {
			
			if(animationLocked) { return; }
			
			if(this.currentAnimation != anim) {
				this.currentAnimation = anim;
				this.sprite.gotoAndStop(anim);
			}
		}
		
		public function lockAnimation(anim:String):void {
			this.currentAnimation = anim;
			this.sprite.gotoAndStop(anim);
			animationLocked = true;
			animationFreeze = true;
		}
		
		public function holdAnimation(anim:String, timeout:int) {
			if(animationLocked) { return; }
			
			var prevAnim:String = this.currentAnimation;
			var context = this;
			
			animationLocked = true;
			
			this.currentAnimation = anim;
			this.sprite.gotoAndStop(anim);
			
			setTimeout(function () {
				if(animationFreeze) { return; }
				context.animationLocked = false;
				context.setAnimation(prevAnim);
			}, timeout);
			
		}
		
		private function onInit(ev:Event):void {
			
			trace("on init");
			
			if(!initialized) {
				initialized = true;
			} else {
				return;
			}
			
			spriteWidth = this.width;
			spriteHeight = this.height;
			
			onSpawn(ev);
			
			this.addEventListener(Event.ENTER_FRAME, onThink);
			this.addEventListener(Event.ENTER_FRAME, onEntityThink);
			
		}
		
		public function onSpawn(ev:Event):void {
			
		}
		
		public function onThink(ev:Event):void {
			
		}
		
		protected function onEntityThink(ev:Event):void {
			
			
		}
		
	}
}
