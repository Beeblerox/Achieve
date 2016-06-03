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
	public var props(default, null):Array<Property>;	
	public var unlocked(get, set):Bool;
	public var progress(get, null):Float;
	
	public var data:Dynamic;
	
	private var mUnlocked:Bool;
	
	public function new(theId:String, theRelatedProps:Array<Property>)
	{
		name 		= theId;
		props 		= theRelatedProps;
		mUnlocked 	= false;
	}
	
	public function hasProperty(theName:String):Bool
	{
		for (prop in props)
		{
			if (prop.name == theName)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function hasAnyProperty(theNames:Array<String>):Bool
	{
		for (propName in theNames)
		{
			for (prop in props)
			{
				if (prop.name == propName)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	public function hasAllProperties(theNames:Array<String>):Bool
	{
		for (propName in theNames)
		{
			var hasProp:Bool = false;
			
			for (prop in props)
			{
				if (prop.name == propName)
				{
					hasProp = true;
				}
			}
			
			if (!hasProp)
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function get_progress():Float
	{
		var propRange:Int;
		var propProgress:Float;
		
		var rangeSum:Int = 0;
		var rangeMultProgress:Float = 0;
		
		for (prop in props)
		{
			propRange = prop.range;
			propProgress = prop.progress;
			
			rangeSum += propRange;
			rangeMultProgress += propRange * propProgress;
		}
		
		return rangeMultProgress / rangeSum;
	}
	
	public function toString():String
	{
		return "[Achivement " + name + "]";
	}
	
	private function get_unlocked():Bool
	{
		return mUnlocked;
	}
	
	private function set_unlocked(v:Bool):Bool
	{
		return mUnlocked = v;
	}
}