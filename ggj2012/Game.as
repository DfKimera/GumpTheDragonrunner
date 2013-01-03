package ggj2012 {
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ggj2012.dialogs.GameOver;
	
	
	public class Game extends MovieClip {
		
		public static var instance:Game;
		public static var input:InputManager;
		public static var audio:AudioManager;
		public static var scene:Stage;
		
		public static var menu:Loader;
		public static var menuBackground:BackgroundScroller;
		public static var inMainMenu:Boolean = true;		
		
		public static var gravity:Number = 5.2;
		public static var floorY:Number = 650;
		
		public static var score:Number = 0;
		public static var coinsCollected:Number = 0;
		public static var totalTimePlayed:Number = 0;
		
		public static var PAUSED:Boolean = false;
		public static var DEBUG_PHYSICS:Boolean = false;
		public static var AUDIO_ENABLED:Boolean = true;
		
		public static var shaderURL:String = "shaders/world.pbj";
		public static var shader:ShaderFilter;
		
		public static var map:Map;
		public static var player:Player;
		
		public static var playTimer:Timer = new Timer(1000);
		
		public static var gameOverDialog:GameOver = null;
		public static var audioToggle:AudioToggle;
		
		public function Game() {
			
			Game.instance = this;
			
			scene = this.stage;
			input = new InputManager(scene);
			audio = new AudioManager();
			
			playTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			
			scoreDisplay.visible = false;
			
			audioToggle = new AudioToggle();
			audioToggle.x = 20;
			audioToggle.y = 20;
			
			Game.menu = new Loader();
			Game.menu.contentLoaderInfo.addEventListener(Event.COMPLETE, onMenuInit);
			Game.menu.load(new URLRequest("sprites/menu.swf"));
			
			menuBackground = new BackgroundScroller();
			addChild(menuBackground);
			
			audio.PlayMusic("audio/music/another_arsonist.mp3");
			
			addChild(Game.menu);
			addChild(Game.audioToggle);
			
		}
        
        private function setupShader():void {
			
			trace("Loading world shader...");
			
			var shaderLoader:URLLoader = new URLLoader();
			shaderLoader.dataFormat = URLLoaderDataFormat.BINARY;
			shaderLoader.addEventListener(IOErrorEvent.IO_ERROR, function (ev) {
				trace("Shader loading error: " + ev);
			});
			shaderLoader.addEventListener(Event.COMPLETE, function (ev) {
				trace("Loading, applying filter...");
				var s:Shader = new Shader(shaderLoader.data);
				
				s.data.center_x.value = [640];
				//s.data.center_y.value = [800];
				s.data.radius.value = [8];
				
				shader = new ShaderFilter();
				shader.shader = s;
				this.filters = [shader];
				//Game.map.filters = [shader]
				trace("Filter applied!");
			});
			shaderLoader.load(new URLRequest(shaderURL));
			
            
        }
		
		private function onTimerTick(ev:TimerEvent):void {
			totalTimePlayed++;
		}
		
		private function onMenuInit(ev:Event):void {
			
			trace("Menu loaded");
			Game.menu.content.addEventListener("menuHover", menuHover);
			Game.menu.content.addEventListener("menuPlayGame", menuPlayGame);
			Game.menu.content.addEventListener("menuSectionMain", function (ev) {
				Game.audio.PlayMusic("audio/music/another_arsonist.mp3");
			});
			
			Game.menu.content.addEventListener("menuSectionCredits", function (ev) {
				Game.audio.PlayMusic("audio/music/griefing_gunners.mp3");
			});
			
			Game.menu.content.addEventListener("creditsTaunt", menuCreditsTaunt);
			
			inMainMenu = true;
			
			this.addEventListener(Event.ENTER_FRAME, onGameThink);
		}
		
		private function menuCreditsTaunt(ev:Event):void {
			Game.audio.PlayOnce("audio/sfx/taunt.mp3");
		}
		
		private function menuHover(ev:Event):void {
			Game.audio.PlayOnce("audio/sfx/scrolling.mp3");
		}
		
		private function menuPlayGame(ev:Event):void {
			
			Game.audio.PlayOnce("audio/sfx/selection.mp3");
			
			Game.menu.unload();
			Game.menu.visible = false;
			menuBackground.visible = false;
			
			scoreDisplay.visible = true;
			inMainMenu = false;
			
			startGame();
			
		}
		
		public static function toggleAudio():void {
			
			AUDIO_ENABLED = !AUDIO_ENABLED;
			
			if(!AUDIO_ENABLED) {
				Game.audio.audioEnabled = false;
				Game.audio.currentMusicChannel.stop();
			} else {
				Game.audio.audioEnabled = true;
				Game.audio.PlayMusic(Game.audio.currentMusic);
			}
			
		}
		
		public function startGame():void {
			
			//setupShader();
			
			Game.scene.focus = null;

			map = new Map();
			addChild(map);
			
			swapChildren(map, scoreDisplay);
			swapChildren(menu, audioToggle);
			
			player = new Player(500, 500);
			addChild(player);
			
			playTimer.start();
			
			audio.PlayMusic("audio/music/blue_berry_brigade.mp3");
			
		}
		
		private function onGameThink(ev:Event):void {
			
			menuBackground.x -= 1;
			if (menuBackground.x < -2560) {
				menuBackground.x = 0;
			}
			
			if (inMainMenu) { return; }
			
			if (Game.PAUSED) { return; }
			
			map.moveForeground( -player.runningSpeed );
			map.moveBackground( -player.runningSpeed * map.backgroundMovementRatio );
			
			Game.score++;
			scoreDisplay.text = Utils.zeroPad(Game.score, 10);
		}
		
		public static function playerDeath():void {
			
			PAUSED = true;
			
			Game.audio.PlayOnce("audio/sfx/death.mp3");
			
			gameOverDialog = new GameOver()
			instance.addChild(gameOverDialog);
			
		}
		
		public static function restart():void {
			
			trace("Restarting game...");
			
			score = 0;
			coinsCollected = 0;
			totalTimePlayed = 0;
			
			playTimer.reset();
			
			instance.removeChild(player);
			player.destroy();
			player = null
			
			instance.removeChild(map);
			map.destroy();
			map = null;
			
			PAUSED = false;
			
			instance.startGame();
			
			gameOverDialog = null;
			
		}
	}
	
}
