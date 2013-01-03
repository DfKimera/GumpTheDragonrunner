package ggj2012 
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import ggj2012.clusters.*;
	import ggj2012.items.Coin;
	
	/**
	 * ...
	 * @author Aryel 'DfKimera' Tupinambá
	 */
	public class Map extends MovieClip  {
		
		public static var clusterTypes:Array = [
			Cluster1,
			Cluster2,
			Cluster3,
			Cluster4,
			Cluster5,
			Cluster6,
			Cluster7,
			Cluster8,
			Cluster9,
			Cluster10,
			Cluster11
		];
		
		public var backgroundMovementRatio:Number = 0.12;
		
		public var backgroundSprite:BackgroundScroller = new BackgroundScroller();
		
		public var foregroundSprite:MovieClip = new MovieClip();
		
		public var dragonTail:DragonTail = new DragonTail();
		public var dragonHead:DragonHead = new DragonHead();
		
		public var dragonHeadBob:Number = 0;
		public var dragonHeadBobDelta:Number = 1;
		public var dragonHeadBobMax:Number = 30;
		
		public var generationOffset:Number = 1600;
		public var generationMargin:Number = 400;
		
		public var solidRectangles:Array = new Array();
		public var collectibles:Array = new Array();
		
		public function Map() {
			
			addChild(backgroundSprite);
			addChild(dragonTail);
			addChild(foregroundSprite);
			Game.instance.addChild(dragonHead);
			
			
			this.addEventListener(Event.ENTER_FRAME, onThink);
			
		}
		
		public function destroy():void {
			Game.instance.removeChild(dragonHead);
		}
		
		private function renderDragon():void {
			
			dragonTail.x -= Game.player.runningSpeed;
			if (dragonTail.x < -1280) {
				dragonTail.x = 0;
			}
			
			dragonHeadBob += dragonHeadBobDelta;
			if (Math.abs(dragonHeadBob) > dragonHeadBobMax) {
				dragonHeadBobDelta *= -1;
			}
			
			dragonTail.y = Game.floorY - 10;
			dragonHead.y =  Game.floorY - 10 + dragonHeadBob;
			
		}
		
		private function onThink(ev:Event):void {
			
			if (Game.PAUSED) { return; }
			
			if (generationOffset < this.getOffsetX() + Game.scene.stageWidth) {
				generateNewSection();
			}
			
			if (this.getOffsetX() > generationOffset + Game.scene.stageWidth) {
				removeUsedSection();
			}
			
			renderDragon();
			
		}
		
		public function getOffsetX():Number {
			return -this.foregroundSprite.x;
		}
		
		public function registerSolidRect(rect:Rectangle):void {
			this.solidRectangles.push(rect);
		}
		
		public function registerCollectible(prop:Item, body:Rectangle):void {
			prop.body = body;
			this.collectibles.push(prop);
		}
		
		public function removeUsedSection() {
			solidRectangles.shift();
			collectibles.shift();
		}
		
		public function generateNewSection():void {
			
			var clusterType:Class = Map.clusterTypes[1 + Math.floor(Math.random() * (clusterTypes.length-1))];
			
			var cluster:MovieClip = new clusterType();
			cluster.x = generationOffset + generationMargin;
			cluster.y = Game.floorY;
			
			for (var i = 0; i < cluster.numChildren; i++) {
				
				if (!(cluster.getChildAt(i) is MovieClip)) {
					continue;
				}
				
				var prop:MovieClip = MovieClip(cluster.getChildAt(i));
				
				var body:Rectangle = new Rectangle();
				body.x = cluster.x + prop.x - (prop.width / 2);
				body.y = cluster.y + prop.y - (prop.height);
				body.width = prop.width;
				body.height = prop.height;
				
				if (prop is Item) {
					this.registerCollectible(Item(prop), body);
				} else {
					this.registerSolidRect(body);
				}
				
				
			}
			
			foregroundSprite.addChild(cluster);
			
			generationOffset += cluster.width + generationMargin;
			
		}
		
		public function checkCollisions(rect:Rectangle, offsetX:Number = 0, offsetY:Number = 0):CollisionInfo {
			
			rect.x += offsetX;
			rect.y += offsetY;
			
			var info:CollisionInfo = new CollisionInfo();
						
			for (var i in solidRectangles) {
				if (!solidRectangles[i]) { continue; }
				
				if ( Utils.rectanglesIntersect( Rectangle(solidRectangles[i]), rect)) {
					
					info.hasCollided = true;
					info.penetration = Utils.getHorizontalPenetration( rect, Rectangle(solidRectangles[i]) );
					info.opposingRectangle = Rectangle(solidRectangles[i]);
					
					break;
				}
			}
			
			for (var k in collectibles) {
				if (!collectibles[k]) { continue; }
				
				if ( Utils.rectanglesIntersect( Item(collectibles[k]).body, rect)) {
					
					Item(collectibles[k]).collect();
					delete collectibles[k];
					
				}
			}
			
			rect.x -= offsetX;
			rect.y -= offsetY;
			
			return info;
			
		}
		
		private function onBackgroundLoaded(ev:Event):void {
			trace("Background loaded!");
		}
		
		public function moveForeground(deltaX:Number):void {
			this.foregroundSprite.x += deltaX;
		}
		
		public function moveBackground(deltaX:Number):void {
			this.backgroundSprite.x += deltaX;
			if (backgroundSprite.x < -2560) {
				backgroundSprite.x = 0;
			}
		}
		
	}

}