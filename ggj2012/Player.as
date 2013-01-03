package ggj2012 {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	public class Player extends Entity {
		
		public static const BASE_WIDTH:Number = 80;
		public static const BASE_HEIGHT:Number = 120;
		
		public static const HALF_WIDTH:Number = BASE_WIDTH / 2;
		public static const HALF_HEIGHT:Number = BASE_HEIGHT / 2;
		
		public var deltaY:Number = 0;
		public var deltaX:Number = 0;
		
		public var maxDeltaX:Number = 6;
		public var maxDeltaY:Number = Game.gravity * 1.4;
		
		public var accelX:Number = 1.05;
		public var accelY:Number = Game.gravity / 8;
		
		public var runningSpeed:Number = 9;
		
		public var playerBounds:Array = [[256, 1150],[Game.floorY - 120,0]];
		
		public var isJumping:Boolean = false;
		public var isSliding:Boolean = false;
		public var isUnderRectangle:Boolean = false;
		public var isAlive:Boolean = false;
		public var isColliding:Boolean = false;
		
		public var body:Rectangle = new Rectangle(0, 0, BASE_WIDTH, BASE_HEIGHT);
		public var slidingBody:Rectangle = new Rectangle(0, BASE_HEIGHT / 2, BASE_WIDTH, BASE_HEIGHT / 2);
		
		public var jumpForce:Number = 120;
		public var jumpAmount:Number = 0;
		public var jumpAccel:Number = 10;
		public var jumpBoost:Number = 0;
		
		public var startX:Number = 0;
		public var startY:Number = 0;
		
		public var slidingDuration:Number = 0;
		
		public var currentDirection:String = "right";
		
		public function Player(startX:Number, startY:Number) {
			super();
			
			this.x = this.startX = startX;
			this.y = this.startY = startY;
			
			this.spriteFile = "player.swf";
			
		}
		
		public override function onSpawn(ev:Event):void {
			
			this.spriteWidth = Player.BASE_WIDTH;
			this.spriteHeight = Player.BASE_HEIGHT;
			
			this.isAlive = true;
			
			this.setAnimation("running");
			
		}
		
		public override function onThink(ev:Event):void {
			
			body.x = Game.map.getOffsetX() + this.x;
			body.y = this.y;
			
			slidingBody.x = body.x
			slidingBody.y = this.y + HALF_HEIGHT;
			
			if (Game.input.isKeyDown(Keyboard.RIGHT) && !isSliding) {				
				goRight();
			} else if (Game.input.isKeyDown(Keyboard.LEFT) && !isSliding) {
				goLeft();
			} else {
				deltaX *= 0.6;
			}
			
			if (Game.input.isKeyDown(Keyboard.UP) && !isSliding) {
				jump();
			}
			
			if (Game.input.isKeyDown(Keyboard.SPACE) || Game.input.isKeyDown(Keyboard.DOWN)) {
				slide();
			}
			
			if (Game.PAUSED) { return; }
			
			processCollision();
			
			this.x += deltaX;
			this.y += deltaY;
			
			checkBounds();
			
			processGravity();
			
			processSliding();
			
		}
		
		public function jump():void {
			
			if (isJumping) {
				return;
			}
			
			trace("Jump!");
			
			jumpAmount = jumpForce
			isJumping = true;
			
			this.setAnimation("jumping");
			
		}
		
		public function slide():void {
			if (isSliding) {
				return;
			}
			
			trace("Slide!");
			
			slidingDuration = 18;
			isSliding = true;
			
			this.setAnimation("sliding");
			
			if (!isJumping) {
				Game.audio.PlayOnce("audio/sfx/slide.mp3");
			}
		}
		
		public function checkBounds():void {
			if (this.x < playerBounds[0][0]) {
				this.x = playerBounds[0][0];
				deltaX = 0;
				
				Game.playerDeath();
				
			} else if (this.x > playerBounds[0][1]) {
				this.x = playerBounds[0][1];
				deltaY = 0;
			}
			
			if (this.y > playerBounds[1][0]) {
				this.y = playerBounds[1][0];
				deltaY = 0;
				if(isJumping) {
					isJumping = false;
					
					if(!isSliding) {
						this.setAnimation("running");
					}
				}
			} else if (this.y < playerBounds[1][1]) {
				this.y = playerBounds[1][1];
				deltaY = 0;
			}
			
		}
		
		public function processSliding():void {
			
			if (slidingDuration > 0) {
				slidingDuration--; // countdown to keep sliding stance
			} else if (isSliding) {
				
				if (isColliding) {
					return; // if counter ended before we left a tunnel, don't stop now
				}
				
				isSliding = false;
				isUnderRectangle = false;
				
				if(!isJumping) {
					this.setAnimation("running");
				}
			}
			
		}
		
		public function processGravity():void {
			if (jumpAmount > 0) { // this will accelerate the initial jump
				jumpBoost += jumpAccel
				jumpAmount -= jumpAccel;
				
				if (jumpAmount < 0) {
					jumpAmount = 0;
				}
				
			} 
			
			if (jumpBoost > 0) { // this will stop acceleration next to azimuth
				
				deltaY = jumpBoost;
				jumpBoost = jumpBoost / 1.6;
				
				if (jumpBoost < 5) {
					jumpBoost = 0;
				}
				
				deltaY = -jumpBoost;
				
			} else { // this will decay acceleration with gravity
				
				deltaY += accelY;
				if (deltaY > maxDeltaY) {
					deltaY = maxDeltaY;
				}
				
			}
		}
		
		public function processCollision():void {
			var hInfo:CollisionInfo = Game.map.checkCollisions(this.body, deltaX, 0);
			
			if (hInfo.penetration != 0) { // if there is penetration, there is collision
				
				isColliding = true;
				
				var reactionDelta = - hInfo.penetration;
				
				if (reactionDelta > 0) { // flip runningSpeed sign according to the collision reaction
					reactionDelta +=  runningSpeed;
				} else {
					reactionDelta -= runningSpeed;
				}
				
				if(isSliding) {
					if (!isUnderRectangle) {
						
						// check if we can slide under or if we're going against solid wall
						
						if (!Game.map.checkCollisions(this.slidingBody, deltaX, 0).hasCollided) {
							isUnderRectangle = true;
							slidingDuration = (hInfo.opposingRectangle.width / runningSpeed) + 5;
							trace("Sliding under rectangle! Extended sliding duration to " + slidingDuration + " frames");
							
							reactionDelta = 0;
						}
						
					} else {
						reactionDelta = 0;
					}
				}
				
				if (!isSliding || !isUnderRectangle) {
					deltaX += reactionDelta;
				}
				
			} else {
				isColliding = false;
			}
			
			var vInfo:CollisionInfo = Game.map.checkCollisions(this.body, deltaX - hInfo.penetration, deltaY)
			
			if (vInfo.hasCollided) {
				deltaY = 0;
				
				if (!isJumping) {
					jumpBoost = 0;
				}
				
				isJumping = false;
				if(!isSliding) {
					this.setAnimation("running");
				}
			}
			
		}
		
		public function goRight():void {
			
			deltaX += accelX;
			if (deltaX > maxDeltaX) {
				deltaX = maxDeltaX;
			}
			
		}
		
		public function goLeft():void {
			
			deltaX -= accelX;
			if (deltaX < -maxDeltaX) {
				deltaX = -maxDeltaX;
			}
			
		}
	}
	
}
