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

class Achievement 
{
	public var name(default, null):String;
	public var props(default, null):Array<String>;	
	public var unlocked(default, null):Bool = false;
	public var progress(default, null):Float = 0;
	public var range(default, null):Int = 0;
	public var absProgress(default, null):Int = 0;
	
	public var data:Dynamic;
	
	public function new(theId:String, theRelatedProps:Array<String>)
	{
		name = theId;
		props = theRelatedProps;
		
		calculateDerivativeValues();
		subscribe();
	}
	
	private function calculateDerivativeValues():Void
	{
		var rangeMultProgress:Float = 0;
		absProgress = 0;
		range = 0;
		
		for (propName in props)
		{
			var property:Property = Achieve.property(propName);
			var propRange:Int = property.range;
			var propProgress:Float = property.progress;
			rangeMultProgress += propRange * propProgress;
			absProgress += property.absProgress;
			range += propRange;
		}
		
		progress = rangeMultProgress / range;
	}
	
	public function reset():Void
	{
		unlocked = false;
	}
	
	private function subscribe():Void
	{
		for (propName in props)
		{
			var prop:Property = Achieve.property(propName);
			prop.addAchievementListener(this);
		}
	}
	
	public function hasProperty(theName:String):Bool
	{
		return (props.indexOf(theName) != -1);
	}
	
	public function hasAnyProperty(theNames:Array<String>):Bool
	{
		for (propName in theNames)
		{
			if (hasProperty(propName))
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function hasAllProperties(theNames:Array<String>):Bool
	{
		for (propName in theNames)
		{
			if (!hasProperty(propName))
			{
				return false;
			}
		}
		
		return true;
	}
	
	@:allow(com.as3gamegears.achieve.Property)
	private function onPropertyProgress(theProp:Property):Void
	{
		var oldAbsProgress:Int = absProgress;
		calculateDerivativeValues();
		
		if (absProgress != oldAbsProgress)
		{
			Achieve.processAchievementProgress(this, (absProgress - oldAbsProgress));
		}
	}
	
	@:allow(com.as3gamegears.achieve.Property)
	private function onPropertyFinish(theProp:Property):Void
	{
		// check if it's unlocked already
		if (unlocked)
		{
			return;
		}
		
		// check if all its properties are finished
		for (propName in props)
		{
			if (!Achieve.property(propName).finished)
			{
				return;
			}
		}
		
		unlocked = true;
		Achieve.processAchievementUnlock(this);
	}
	
	public function toString():String
	{
		return "[Achivement " + name + "]";
	}
}