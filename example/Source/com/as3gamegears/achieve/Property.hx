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
package com.as3gamegears.achieve;

import com.as3gamegears.achieve.Achieve.PROPERTY_ACTIVATION;

/**
 * Describes a property used to measure an achievement progress. A property is pretty much a counter
 * with some special attributes (such as default value and update constraints).
 */
class Property
{
	public var value(get, set):Int;
	public var name(default, null):String;
	public var tags(default, null):Array<String>;
	public var activation(default, null):PROPERTY_ACTIVATION;
	public var finished(default, null):Bool = false;
	public var progress(get, null):Float;
	public var absProgress(get, null):Int;
	public var range(get, null):Int;
	
	public var data:Dynamic;
	
	private var mActivationValue:Int;
	private var mInitialValue:Int;
	private var mValue:Int;
	
	private var listeners:Array<Achievement> = [];
	
	public function new(theName:String, theInitialValue:Int = 0, theActivation:PROPERTY_ACTIVATION = PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, theActivationValue:Int = 99, ?theTags:Array<String>)
	{
		name 				= theName;
		tags 				= theTags;
		activation 			= theActivation;
		mActivationValue 	= theActivationValue;
		mInitialValue 		= theInitialValue;
		reset();
	}
	
	public function reset():Void 
	{
		mValue = mInitialValue;
	}
	
	public function hasTag(theTag:String):Bool
	{
		if (tags != null && tags.indexOf(theTag) >= 0)
		{
			return true;
		}
		
		return false;
	}
	
	public function hasAnyTag(theTags:Array<String>):Bool
	{
		for (i in 0...theTags.length)
		{
			if (tags != null && tags.indexOf(theTags[i]) >= 0)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function hasAllTags(theTags:Array<String>):Bool
	{
		if (tags == null && theTags.length > 0)
		{
			return false;
		}
		
		if (tags != null)
		{
			for (i in 0...theTags.length)
			{
				if (tags.indexOf(theTags[i]) < 0)
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	@:allow(com.as3gamegears.achieve.Achievement)
	private function addAchievementListener(achievement:Achievement):Void
	{
		if (listeners.indexOf(achievement) < 0)
		{
			listeners.push(achievement);
		}
	}
	
	@:allow(com.as3gamegears.achieve.Achievement)
	private function removeAchievementListener(achievement:Achievement):Void
	{
		listeners.remove(achievement);
	}
	
	private function get_progress():Float
	{
		return absProgress / range;
	}
	
	private function get_absProgress():Int
	{
		var abs:Float = Math.abs(mValue - mInitialValue);
		abs = Math.min(range, absProgress);
		return Std.int(abs);
	}
	
	private function get_range():Int
	{
		return Std.int(Math.abs(mActivationValue - mInitialValue));
	}
	
	private function get_value():Int
	{
		return mValue;
	}
	
	private function set_value(v:Int):Int
	{
		var oldFinished:Bool = finished;
		var processProgress:Bool = !finished;
		var oldValue:Int = mValue;
		mValue = v;
		
		Achieve.processPropertyChange(this, (mValue - oldValue));
		
		var newFinished:Bool = switch (activation) 
		{
			case PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN: 	(value >= mActivationValue); // (value > mActivationValue);
			case PROPERTY_ACTIVATION.ACTIVE_IF_LESS_THAN: 		(value <= mActivationValue); // (value < mActivationValue);
		};
		
		if (processProgress)
		{
			for (a in listeners)
			{
				a.onPropertyProgress(this);
			}
		}
		
		if (newFinished && oldFinished != newFinished)
		{
			finished = true;
			Achieve.processPropertyFinish(this);
			
			for (a in listeners)
			{
				a.onPropertyFinish(this);
			}
		}
		
		return  v;
	}
}