package ggj2012 
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Aryel 'DfKimera' Tupinambá
	 */
	public class Item extends MovieClip {
		
		public var points:int = 10;
		public var body:Rectangle;
		
		public var isCollected:Boolean = false;
		
		public function collect():void {
			
			if (this.isCollected) {
				return;
			}
			
			Game.score += this.points;
			
			this.visible = false;
			this.isCollected = true;
			
			if (this.parent) {
				this.parent.removeChild(this);
			}
			
			delete this;
		}
		
	}

}