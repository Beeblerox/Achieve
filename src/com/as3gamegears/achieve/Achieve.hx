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

// TODO: documentation...

class Achieve 
{
	public static var numProperties(default, null):Int;
	public static var numFinishedProperties(get, null):Int;
	
	public static var numAchievements(default, null):Int;
	public static var numUnlockedAchievements(get, null):Int;
	public static var numLockedAchievements(get, null):Int;
	
	/**
	 * Property name -> Property value -> Property progress -> Property range -> Void
	 */
	public static var onPropertyProgress		:String->Int->Void;
	/**
	 * Achievement name -> Achievement value delta -> Void
	 */
	public static var onAchievementProgress		:String->Int->Void;
	
	public static var onPropertyFull			:String->Void;
	
	public static var onAchievementUnlock		:String->Void;
	
	private static var mProps 					:StringMap<Property> = new StringMap<Property>();
	private static var mAchievements 			:StringMap<Achievement> = new StringMap<Achievement>();
	
	/**
	 * Helper array for achievement management
	 */
	private static var mAchievementsArray		:Array<Achievement> = [];
	
	public static function registerProperty(theName:String, theInitialValue:Int, theaActivationMode:PROPERTY_ACTIVATION, theValue:Int, ?theTags:Array<String>):Property
	{
		if (containsProperty(theName))
		{
			throw ("Property \"" + theName + "\" is already registered.");
		}
		
		mProps.set(theName, new Property(theName, theInitialValue, theaActivationMode, theValue, theTags));
		numProperties++;
		return mProps.get(theName);
	}
	
	public static function unregisterProperty(theName:String):Property
	{
		if (containsProperty(theName))
		{
			for (achievement in mAchievements)
			{
				if (achievement.hasProperty(theName))
				{
					throw ("Can't unregister property \"" + theName + "\", since it is already in use.");
				}
			}
			
			var prop:Property = mProps.get(theName);
			mProps.remove(theName);
			numProperties--;
			return prop;
		}
		
		return null;
	}
	
	public static function registerAchievement(theName:String, theRelatedProps:Array<String>):Achievement
	{
		if (checkAchievementExists(theName))
		{
			throw ("Achievement \"" + theName + "\" is already registered.");
		}
		
		var numProps:Int = theRelatedProps.length;
		for (i in 0...numProps)
		{
			checkPropertyExist(theRelatedProps[i]);
		}
		
		mAchievements.set(theName, new Achievement(theName, theRelatedProps));
		numAchievements++;
		return mAchievements.get(theName);
	}
	
	public static function unregisterAchievement(theName:String):Achievement
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
	
	public static function getProperty(theProp:String):Int 
	{
		checkPropertyExist(theProp);
		return mProps.get(theProp).value;
	}
	
	public static function addToProperty(theProp:String, theValue:Int):Void
	{
		setProperty(theProp, getProperty(theProp) + theValue);
	}
	
	public static function addToProperties(theProps:Array<String>, theValue:Int):Void
	{
		var numProps:Int = theProps.length;
		for (i in 0...numProps)
		{
			setProperty(theProps[i], getProperty(theProps[i]) + theValue);
		}
	}
	
	public static function setProperty(theProp:String, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		doSetValue(theProp, theValue, theIgnoreActivationContraint);
	}
	
	public static function setProperties(theProps:Array<String>, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		var numProps:Int = theProps.length;
		
		for (i in 0...numProps) 
		{
			doSetValue(theProps[i], getProperty(theProps[i]) + theValue, theIgnoreActivationContraint);
		}
	}
	
	public static function property(theProp:String):Property
	{
		checkPropertyExist(theProp);
		return mProps.get(theProp);
	}
	
	private static function doSetValue(theProp:String, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
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
		
		var prop:Property = mProps.get(theProp);
		prop.value = theValue;
	}
	
	public static function resetProperties(?theTags:Array<String>):Void
	{
		for (prop in mProps)
		{
			if (theTags == null || prop.hasAnyTag(theTags))
			{
				prop.reset();
			}
		}
	}
	
	public static function reset():Void
	{
		resetProperties();
		
		for (a in mAchievements)
		{
			a.reset();
		}
	}
	
	public static function containsProperty(theName:String):Bool
	{
		return mProps.exists(theName);
	}
	
	private static inline function checkPropertyExist(theName:String):Void
	{
		if (!containsProperty(theName))
		{
			throw ("Unknown achievement property \"" + theName + "\". Check if it was correctly defined by registerProperty().");
		}
	}
	
	public static function checkAchievementExists(theName:String):Bool
	{
		return mAchievements.exists(theName);
	}
	
	public static function getAllUnlockedAchievements(?achievements:Array<Achievement>):Array<Achievement>
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
	
	public static function getAllAchievements(?achievements:Array<Achievement>):Array<Achievement>
	{
		achievements = (achievements != null) ? achievements : new Array<Achievement>();
		
		for (achievement in mAchievements) 
		{
			achievements.push(achievement);
		}
		
		return achievements;
	}
	
	public static function achievementUnlocked(theName:String):Bool
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName).unlocked;
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return false;
	}
	
	public static function achievement(theName:String):Achievement
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName);
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return null;
	}
	
	public static function getAchievementsWith(theProps:Array<String>, ?achievements:Array<Achievement>):Array<Achievement>
	{
		achievements = (achievements != null) ? achievements : new Array<Achievement>();
		
		for (a in mAchievements)
		{
			if (a.hasAnyProperty(theProps))
			{
				achievements.push(a);
			}
		}
		
		return achievements;
	}
	
	public static function getAchievementsBy(?theTags:Array<String>, ?achievements:Array<Achievement>):Array<Achievement>
	{
		achievements = (achievements != null) ? achievements : new Array<Achievement>();
		var propNames:Array<String> = [];
		
		for (prop in mProps)
		{
			if (prop.hasAnyTag(theTags))
			{
				propNames.push(prop.name);
			}
		}
		
		return getAchievementsWith(propNames, achievements);
	}
	
	public static function dumpProperties():String
	{
		var aRet:String = "";
		
		for (i in mProps.keys()) {
			aRet += i + "=" + mProps.get(i).value + ", ";
		}
		
		return aRet.substr(0, aRet.length - 2);
	}
	
	@:allow(com.as3gamegears.achieve.Achievement)
	private static function processAchievementProgress(theAchievement:Achievement, deltaValue:Int):Void
	{
		if (onAchievementProgress != null)
		{
			onAchievementProgress(theAchievement.name, deltaValue);
		}
	}
	
	@:allow(com.as3gamegears.achieve.Achievement)
	private static function processAchievementUnlock(theAchievement:Achievement):Void
	{
		if (onAchievementUnlock != null)
		{
			onAchievementUnlock(theAchievement.name);
		}
	}
	
	@:allow(com.as3gamegears.achieve.Property)
	private static function processPropertyChange(theProp:Property, deltaValue:Int):Void
	{
		if (onPropertyProgress != null)
		{
			onPropertyProgress(theProp.name, deltaValue);
		}
	}
	
	@:allow(com.as3gamegears.achieve.Property)
	private static function processPropertyFinish(theProp:Property):Void
	{
		if (onPropertyFull != null)
		{
			onPropertyFull(theProp.name);
		}
	}
	
	private static function get_numFinishedProperties():Int
	{
		var result:Int = 0;
		
		for (p in mProps)
		{
			if (p.finished)
			{
				result++;
			}
		}
		
		return result;
	}
	
	private static function get_numUnlockedAchievements():Int
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
	
	private static function get_numLockedAchievements():Int
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