package ggj2012.items {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import ggj2012.Item;
	import ggj2012.Game;
	
	
	public class Coin extends Item {
		
		
		public function Coin() {
			
			this.points = 100;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onInit);
			
		}
		
		override public function collect():void {
			
			if (!this.isCollected) {
				Game.coinsCollected++;
				Game.audio.PlayOnce("audio/sfx/coin.mp3");
			}
			
			super.collect();
			
			
		}
		
		private function onInit(ev:Event):void {
			if (Math.random() > 0.3) {
				this.parent.removeChild(this);
				isCollected = true;
				delete this;
			}
		}
	}
	
}
