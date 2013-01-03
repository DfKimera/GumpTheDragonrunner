package ggj2012 {
	
	import flash.geom.Rectangle;
	import flash.net.*;
	
	public class Utils {
		
		public static const TO_DEGREES:Number = 0.0174532925;
		public static const TO_RADIANS:Number = 57.2957795;
		
		public static function getEntityDistance(e1:Entity, e2:Entity):Number {
			
			return Math.sqrt( Math.pow((e1.x + (e1.spriteWidth / 2)) - (e2.x + (e2.spriteWidth / 2)), 2) + Math.pow(e1.y - e2.y, 2) );
			
		}
		
		public static function rectanglesIntersect(a:Rectangle, b:Rectangle):Boolean {
			return !(a.x > b.x + (b.width - 1) || a.x + (a.width - 1) < b.x || a.y > b.y + (b.height - 1) || a.y + (a.height - 1) < b.y);
		}
		
		public static function rectanglesIntersectOnX(a:Rectangle, b:Rectangle):Boolean {
			return ((a.x + a.width) > b.x && a.x < (b.x + b.width));
		}
		
		public static function rectanglesIntersectOnY(a:Rectangle, b:Rectangle):Boolean {
			return ((a.y + a.height) > b.y && a.y < (b.y + b.height));
		}
		
		public static function getHorizontalPenetration(a:Rectangle, b:Rectangle) {
			if (rectanglesIntersectOnX(a, b)) {
				var midB:Number = b.x + (b.width / 2)
				if (a.x <= midB) {
					return (a.x + a.width) - b.x;
				} else {
					return a.x - (b.x + b.width);
				}
			} else {
				return 0;
			}
		}
		
		public static function zeroPad(number:int, width:int):String {
			var ret:String = String(number);
			
			while ( ret.length < width ) {
				ret = "0" + ret;
			}
			return ret;
		}
		
		public static function facebookShare():void {
			
			var req:URLRequest = new URLRequest();
			req.url = "http://www.facebook.com/dialog/feed";
			
			var vars:URLVariables = new URLVariables();
			
			vars.app_id = "262159917190203";
			vars.link = "http://www.dfkimera.com/a3/gump";
			vars.picture = "http://www.dfkimera.com/a3/gump/sprites/facebook_icon.png";
			vars.name = "Gump: the Dragonrunner";
			vars.caption = "I've made "+Game.score+" points on Gump: the Dragonrunner!";
			vars.description = "A3 Studios' GGJ 2012 fast-paced action game!";
			vars.message = "I challenge you to beat me!";
			vars.redirect_uri = "http://www.dfkimera.com/a3/gump";
			
			req.data = vars;
			req.method = URLRequestMethod.GET;
			
			navigateToURL(req, "_blank");
			
		}

	}
	
}
