/**
 * Copyright (C) 2013 Fernando Bevilacqua
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package;

import com.as3gamegears.achieve.Achieve;
import com.as3gamegears.achieve.Achievement;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.ui.Keyboard;

class Game extends Sprite
{
	public static var MOUSE 		:Vector3D = new Vector3D(100, 100);
	public static var WIDTH 		:Float = 0;
	public static var HEIGHT 		:Float = 0;
	public static var INSTANCE 		:Game;
	
	public var achieve	 			:Achieve;
	public var logs	 				:TextField;
	public var hud	 				:Sprite;
	public var boids 				:Array<Boid> = new Array<Boid>();
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event):Void 
	{
		var i:Int, boid:Boid;
		
		Game.INSTANCE 			= this;
		Game.WIDTH 				= stage.stageWidth;
		Game.HEIGHT 			= stage.stageHeight;
		Game.INSTANCE.achieve	= new Achieve();
		
		stage.addEventListener(MouseEvent.CLICK, onClick);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		for (i in 0...10) 
		{
			boid = new Boid(Game.WIDTH / 2 * Math.random() * 0.8, Game.HEIGHT / 2 * Math.random() * 0.8, 20 +  Math.random() * 20);
			
			addChild(boid);
			boids.push(boid);
			
			boid.reset();
		}
		
		hud = new Sprite();
		addChild(hud);
		
		logs 					= new TextField();
		logs.width 				= Game.WIDTH * 0.6; 
		logs.height 			= Game.HEIGHT * 0.3; 
		logs.background 		= true;
		logs.backgroundColor 	= 0x000000;
		logs.textColor			= 0xffffff;
		logs.alpha				= 0.7;
		addChild(logs);
		
		Game.INSTANCE.achieve.registerProperty("kills", 0, PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, 5, ["partial"]);
		Game.INSTANCE.achieve.registerProperty("criticalDamages", 0, PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, 6, ["partial"]);
		Game.INSTANCE.achieve.registerProperty("deaths", 10, PROPERTY_ACTIVATION.ACTIVE_IF_LESS_THAN, 2);
		
		Game.INSTANCE.achieve.registerAchievement("killer", ["kills"]);
		Game.INSTANCE.achieve.registerAchievement("last", ["deaths"]);
		Game.INSTANCE.achieve.registerAchievement("hero", ["kills", "criticalDamages", "deaths"]);
	}
	
	private function updateHudAchivements(theNewAchievements:Array<Achievement>):Void 
	{
		if (theNewAchievements != null) 
		{
			for (i in 0...theNewAchievements.length) 
			{
				var a:Achievement = theNewAchievements[i];
				hud.addChild(new UnlockedSign(370, 400 - hud.numChildren * (UnlockedSign.HEIGHT + 10), a.name));
			}
		}
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		Game.INSTANCE.achieve.addToProperty(["kills", "criticalDamages"], 1);
		Game.INSTANCE.achieve.addToProperty("deaths", -1);
		
		logs.text = "Props: " + Game.INSTANCE.achieve.dumpProperties() + "\n";
		updateHudAchivements(Game.INSTANCE.achieve.checkAchievements(["partial"]));
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.C) 
		{
			updateHudAchivements(Game.INSTANCE.achieve.checkAchievements());
		}
		
		if (e.keyCode == Keyboard.K) 
		{
			Game.INSTANCE.achieve.setProperty("kills", 1);
			Game.INSTANCE.achieve.setProperty("deaths", 1);
			logs.text = "OK Props: " + Game.INSTANCE.achieve.dumpProperties() + "\n";
		}
	}
	
	public function update():Void 
	{
		for (i in 0...boids.length) 
		{ 
			boids[i].update();
		}
	}
}