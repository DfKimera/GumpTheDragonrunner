package ggj2012.dialogs {
	
	import ggj2012.*;
	
	import flash.display.MovieClip;
	import flash.ui.*;
	import flash.events.*;
	import flash.utils.*;
	
	public class GameOver extends MovieClip {
		
		
		public function GameOver() {
			
			this.addEventListener(Event.ADDED_TO_STAGE, onInit);
			
		}
		
		private function onInit(ev:Event):void {
			
			trace("Game over dialog created!");
			
			this.x = Game.scene.stageWidth / 2;
			this.y = Game.scene.stageHeight / 2;
			
			totalScoreDisplay.text = String(Game.score);
			coinsCollectedDisplay.text = String(Game.coinsCollected);
			timePlayedDisplay.text = Math.floor(Game.totalTimePlayed / 60) + " minutes and " + (Game.totalTimePlayed % 60) + " seconds";
			
			playAgainBtn.addEventListener(MouseEvent.CLICK, onPlayAgain);
			facebookShareBtn.addEventListener(MouseEvent.CLICK, onFacebookShare);
			
			setTimeout(function() {
				Game.input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}, 1000);
			
		}
		
		private function onKeyDown(ev:KeyboardEvent) {
			if (ev.keyCode == Keyboard.SPACE || ev.keyCode == Keyboard.ENTER) {
				onPlayAgain(ev);
			}
		}
		
		private function onFacebookShare(ev:Event):void {
			Utils.facebookShare();
		}
		
		private function onPlayAgain(ev:Event):void {
			
			Game.input.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			this.visible = false;
			
			Game.restart();
			
		}
	}
	
}
