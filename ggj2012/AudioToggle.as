package ggj2012 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	
	public class AudioToggle extends MovieClip {
		
		
		public function AudioToggle() {
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(ev:Event):void {
			
			Game.toggleAudio();
			this.play();
			
		}
	}
	
}
