package ggj2012 
{
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author Aryel 'DfKimera' Tupinambá
	 */
	public class InputManager extends EventDispatcher {
		
		public var stage:Stage;
		private var keys:Array = new Array();
		
		public function InputManager(stage:Stage) {
			
			this.stage = stage;
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
		}
		
		private function onKeyDown(ev:KeyboardEvent):void {
			this.keys[ev.keyCode] = true;
			dispatchEvent(ev);
		}
		
		private function onKeyUp(ev:KeyboardEvent):void {
			this.keys[ev.keyCode] = false;
			dispatchEvent(ev);
		}
		
		public function isKeyDown(keyCode:int):Boolean {
			if (this.keys[keyCode]) {
				return true;
			} else {
				return false;
			}
		}
		
	}

}