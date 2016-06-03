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

import flash.display.Sprite;
import flash.geom.Vector3D;

class Boid extends Sprite
{			
	public var role:Int;
	
	public var position:Vector3D;
	public var velocity:Vector3D;
	public var mass:Float;
	public var screenCenter:Vector3D;
	
	public function new(posX:Float, posY:Float, totalMass:Float) 
	{
		super();
		
		position 		= new Vector3D(posX, posY);
		velocity 		= new Vector3D(-1, -2);
		mass	 		= totalMass;
		screenCenter 	= new Vector3D(Game.WIDTH / 2, Game.HEIGHT / 2);
		
		x = position.x;
		y = position.y;
		
		initGraphics();
	}
	
	private function initGraphics():Void 
	{
		graphics.lineStyle(2, 0xffaabb);
		graphics.beginFill(0xFF0000);
		graphics.moveTo(0, 0);
		graphics.lineTo(0, -20);
		graphics.lineTo(10, 20);
		graphics.lineTo(-10, 20);
		graphics.lineTo(0, -20);
		graphics.endFill();
		
		graphics.moveTo(0, 0);
	}
	
	public function getAngle(vector:Vector3D):Float 
	{
		return Math.atan2(vector.y, vector.x);
	}
	
	public function update():Void
	{
		position.incrementBy(velocity);
		
		x = position.x;
		y = position.y;
		
		// Adjust boid rodation to match the velocity vector.
		rotation = 90 + (180 * getAngle(velocity)) / Math.PI;
		
		if (x < 0 || x > Game.WIDTH || y < 0 || y > Game.HEIGHT) 
		{
			reset();
		}
	}
	
	public function reset():Void 
	{
		velocity.x = 0.5 + Math.random() * 7 * (Math.random() >= 0.5 ? -1 : 1); 
		velocity.y = 0.5 + Math.random() * 7 * (Math.random() >= 0.5 ? -1 : 1); 
		position.x = Game.WIDTH / 2;
		position.y = Game.HEIGHT / 2;			
	}		
}