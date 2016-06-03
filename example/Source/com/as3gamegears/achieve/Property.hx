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
	public var active(get, null):Bool;
	public var progress(get, null):Float;
	public var range(get, null):Int;
	
	private var mActivationValue:Int;
	private var mInitialValue:Int;
	private var mValue:Int;
	
	public function new(theName:String, theInitialValue:Int, theActivation:PROPERTY_ACTIVATION, theActivationValue:Int, ?theTags:Array<String>)
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
		if (tags != null && tags.indexOf(theTag) != -1)
		{
			return true;
		}
		
		return false;
	}
	
	public function hasAnyTag(theTags:Array<String>):Bool
	{
		for (i in 0...theTags.length)
		{
			if (tags != null && tags.indexOf(theTags[i]) != -1)
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
				if (tags.indexOf(theTags[i]) == -1)
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	private function get_progress():Float
	{
		return Math.abs((mValue - mInitialValue) / (mActivationValue - mInitialValue));
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
		return mValue = v;
	}
	
	private function get_active():Bool
	{
		var aRet:Bool = false;
		
		switch (activation) 
		{
			case PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN: 	aRet = (value > mActivationValue);
			case PROPERTY_ACTIVATION.ACTIVE_IF_LESS_THAN: 		aRet = (value < mActivationValue);
		}
		
		return aRet;
	}
}