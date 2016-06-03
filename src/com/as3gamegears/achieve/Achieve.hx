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

import haxe.ds.StringMap;

// TODO: documentation
// TODO: convert sample project
	
class Achieve 
{
	public var numProperties(default, null):Int;
	public var numActiveProperties(get, null):Int;
	
	public var numAchievements(default, null):Int;
	public var numUnlockedAchievements(get, null):Int;
	public var numLockedAchievements(get, null):Int;
	
	private var mProps 			:StringMap<Property>;
	private var mAchievements 	:StringMap<Achievement>;
	
	public function new()
	{
		mProps 			= new StringMap<Property>();
		mAchievements 	= new StringMap<Achievement>();
	}
	
	public function registerProperty(theName:String, theInitialValue:Int, theaActivationMode:PROPERTY_ACTIVATION, theValue:Int, ?theTags:Array<String>):Property
	{
		if (containsProperty(theName))
		{
			throw ("Property \"" + theName + "\" is already registered.");
		}
		
		mProps.set(theName, new Property(theName, theInitialValue, theaActivationMode, theValue, theTags));
		numProperties++;
		return mProps.get(theName);
	}
	
	public function unregisterProperty(theName:String):Property
	{
		if (containsProperty(theName))
		{
			var prop:Property = mProps.get(theName);
			mProps.remove(theName);
			numProperties--;
			return prop;
		}
		
		return null;
	}
	
	public function registerAchievement(theName:String, theRelatedProps:Array<Property>):Achievement
	{
		if (checkAchievementExists(theName))
		{
			throw ("Achievement \"" + theName + "\" is already registered.");
		}
		
		var numProps:Int = theRelatedProps.length;
		for (i in 0...numProps)
		{
			checkPropertyExist(theRelatedProps[i].name);
		}
		
		mAchievements.set(theName, new Achievement(theName, theRelatedProps));
		numAchievements++;
		return mAchievements.get(theName);
	}
	
	public function unregisterAchievement(theName:String):Achievement
	{
		if (checkAchievementExists(theName))
		{
			var achievement:Achievement = mAchievements.get(theName);
			mAchievements.remove(theName);
			numAchievements--;
			return achievement;
		}
		
		return null;
	}
	
	public function getProperty(theProp:String):Int 
	{
		checkPropertyExist(theProp);
		return mProps.get(theProp).value;
	}
	
	public function addToProperty(theProp:ArrayOrString, theValue:Int):Void
	{
		if (Std.is(theProp, Array))
		{
			var propNames:Array<String> = cast theProp;
			var numProps:Int = propNames.length;
			for (i in 0...numProps)
			{
				setProperty(propNames[i], getProperty(propNames[i]) + theValue);
			}
		}
		else if (Std.is(theProp, String)) 
		{
			setProperty(theProp, getProperty(theProp) + theValue);
		}
	}
	
	public function setProperty(theProp:ArrayOrString, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		if (Std.is(theProp, Array))
		{
			var props:Array<String> = cast theProp;
			var numProps:Int = props.length;
			
			for (i in 0...numProps) 
			{
				doSetValue(theProp[i], getProperty(props[i]) + theValue, theIgnoreActivationContraint);
			}
		}
		else if (Std.is(theProp, String)) 
		{
			doSetValue(theProp, theValue, theIgnoreActivationContraint);
		}
	}
	
	private function doSetValue(theProp:String, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		checkPropertyExist(theProp);
		
		if (!theIgnoreActivationContraint)
		{
			switch (mProps.get(theProp).activation)
			{			
				case PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN: 	theValue = theValue > mProps.get(theProp).value ? theValue : mProps.get(theProp).value;
				case PROPERTY_ACTIVATION.ACTIVE_IF_LESS_THAN: 		theValue = theValue < mProps.get(theProp).value ? theValue : mProps.get(theProp).value;
			}
		}
		
		mProps.get(theProp).value = theValue;
	}
	
	public function resetProperties(?theTags:Array<String>):Void
	{
		for (prop in mProps)
		{
			if (theTags == null || prop.hasAnyTag(theTags))
			{
				prop.reset();
			}
		}
	}
	
	public function containsProperty(theName:String):Bool
	{
		return mProps.exists(theName);
	}
	
	private inline function checkPropertyExist(theName:String):Void
	{
		if (!containsProperty(theName))
		{
			throw ("Unknown achievement property \"" + theName + "\". Check if it was correctly defined by registerProperty().");
		}
	}
	
	public function checkAchievementExists(theName:String):Bool
	{
		return mAchievements.exists(theName);
	}
	
	public function checkAchievements(?theTags:Array<String>, ?result:Array<Achievement>):Array<Achievement>
	{
		for (achievement in mAchievements) 
		{
			if (achievement.unlocked == false) 
			{
				var aActiveProps:Int = 0;
				var numProps:Int = achievement.props.length;
				
				for (p in 0...numProps)
				{
					var aProp:Property = mProps.get(achievement.props[p].name);
					
					if ((theTags == null || aProp.hasAnyTag(theTags)) && aProp.active)
					{
						aActiveProps++;
					}
				}
				
				if (aActiveProps == achievement.props.length)
				{
					achievement.unlocked = true;
					
					result = (result != null) ? result : new Array<Achievement>();
					result.push(achievement);
				}
			}
		}
		
		return result;
	}
	
	public function getAllUnlockedAchievements(?achievements:Array<Achievement>):Array<Achievement>
	{
		for (achievement in mAchievements) 
		{
			if (achievement.unlocked) 
			{
				achievements = (achievements != null) ? achievements : new Array<Achievement>();
				achievements.push(achievement);
			}
		}
		
		return achievements;
	}
	
	public function getAllAchievements(?achievements:Array<Achievement>):Array<Achievement>
	{
		achievements = (achievements != null) ? achievements : new Array<Achievement>();
		
		for (achievement in mAchievements) 
		{
			achievements.push(achievement);
		}
		
		return achievements;
	}
	
	public function achievementUnlocked(theName:String):Bool
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName).unlocked;
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return false;
	}
	
	public function getAchievement(theName:String):Achievement
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName);
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return null;
	}
	
	public function dumpProperties():String
	{
		var aRet:String = "";
		
		for (i in mProps.keys()) {
			aRet += i + "=" + mProps.get(i).value + ", ";
		}
		
		return aRet.substr(0, aRet.length - 2);
	}
	
	private function get_numActiveProperties():Int
	{
		var result:Int = 0;
		
		for (p in mProps)
		{
			if (p.active)
			{
				result++;
			}
		}
		
		return result;
	}
	
	private function get_numUnlockedAchievements():Int
	{
		var result:Int = 0;
		
		for (a in mAchievements)
		{
			if (a.unlocked)
			{
				result++;
			}
		}
		
		return result;
	}
	
	private function get_numLockedAchievements():Int
	{
		return numAchievements - numUnlockedAchievements;
	}
}

@:enum
abstract PROPERTY_ACTIVATION(String) from String to String
{
	var ACTIVE_IF_GREATER_THAN	= ">";
	var ACTIVE_IF_LESS_THAN		= "<";
}

abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 { }
typedef ArrayOrString = OneOfTwo<Array<String>, String>;