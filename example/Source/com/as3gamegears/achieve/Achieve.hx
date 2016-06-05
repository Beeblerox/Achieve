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

/**
 * Achievement manager class
 */
class Achieve 
{
	/**
	 * Number of registered properties
	 */
	public static var numProperties(default, null):Int;
	/**
	 * Number of properties which has been "finshed".
	 */
	public static var numFinishedProperties(get, null):Int;
	
	/**
	 * Number of registered achievements
	 */
	public static var numAchievements(default, null):Int;
	/**
	 * Number of unlocked achievements
	 */
	public static var numUnlockedAchievements(get, null):Int;
	/**
	 * Number of still locked achievements
	 */
	public static var numLockedAchievements(get, null):Int;
	
	/**
	 * Callback method which is called when property changes its value and not finished.
	 * It should take following arguments: propery name and value delta (how much property changed)
	 */
	public static var onPropertyProgress		:String->Int->Void;
	/**
	 * Callback method which is called when achievement is locked and you progress to unlocking it.
	 * It should take following arguments: achievement name and progress delta
	 */
	public static var onAchievementProgress		:String->Int->Void;
	
	/**
	 * Callback method which is called when property "finishes". Called only once (until property reset).
	 * It takes propery name as an argument.
	 */
	public static var onPropertyFull			:String->Void;
	
	/**
	 * Callback method which is called on achievement unlock event. Called only once (until achievement reset).
	 * It takes achievement name as an argument.
	 */
	public static var onAchievementUnlock		:String->Void;
	
	/**
	 * Dictionary for all registered properties
	 */
	private static var mProps 					:StringMap<Property> = new StringMap<Property>();
	/**
	 * Dictionary for all registered achievements
	 */
	private static var mAchievements 			:StringMap<Achievement> = new StringMap<Achievement>();
	
	/**
	 * Create new property, which you can use later for tracking values related to achievements.
	 * @param	theName					the name of the property. You can have access to property by its name later.
	 * @param	theInitialValue			start value for property
	 * @param	theaActivationMode		property "finish" mode. There are two modes: ACTIVE_IF_GREATER_THAN means that property "finished" then its value is >= to the activation value, and ACTIVE_IF_LESS_THAN means that property "finished" then its value is <= to the activation value
	 * @param	theaActivationValue		value then property "finishes"
	 * @param	theTags					and array of property's tags.
	 * @return	Added property.
	 */
	public static function registerProperty(theName:String, theInitialValue:Int = 0, theaActivationMode:PROPERTY_ACTIVATION = PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, theaActivationValue:Int = 100, ?theTags:Array<String>):Property
	{
		if (containsProperty(theName))
		{
			throw ("Property \"" + theName + "\" is already registered.");
		}
		
		mProps.set(theName, new Property(theName, theInitialValue, theaActivationMode, theaActivationValue, theTags));
		numProperties++;
		return mProps.get(theName);
	}
	
	/**
	 * Removes property from the achievement system
	 * @param	theName		the name of the property
	 * @return	Removed property.
	 */
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
	
	/**
	 * Adds new achievement to the manager.
	 * @param	theName				the name of achievement
	 * @param	theRelatedProps		an array or related properties names.
	 * @return	Added achievement.
	 */
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
	
	/**
	 * Removes achievement from the manager.
	 * @param	theName		the name of achievement to remove
	 * @return	Removed achievement
	 */
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
	
	/**
	 * Returns the value of specified property
	 * @param	theProp		property's name
	 * @return	Value of the property
	 */
	public static function getProperty(theProp:String):Int 
	{
		checkPropertyExist(theProp);
		return mProps.get(theProp).value;
	}
	
	/**
	 * Adds specified number to the property's values.
	 * @param	theProp		property's name
	 * @param	theValue	value to add to property
	 */
	public static function addToProperty(theProp:String, theValue:Int):Void
	{
		setProperty(theProp, getProperty(theProp) + theValue);
	}
	
	/**
	 * Adds number to specified properties
	 * @param	theProps	an array of properties names to modify.
	 * @param	theValue	value to add to properties
	 */
	public static function addToProperties(theProps:Array<String>, theValue:Int):Void
	{
		var numProps:Int = theProps.length;
		for (i in 0...numProps)
		{
			setProperty(theProps[i], getProperty(theProps[i]) + theValue);
		}
	}
	
	/**
	 * Sets property's values to specified number
	 * @param	theProp		property's name
	 * @param	theValue	value to set
	 */
	public static function setProperty(theProp:String, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		doSetValue(theProp, theValue, theIgnoreActivationContraint);
	}
	
	/**
	 * Sets properties value to specified number.
	 * @param	theProps	an array of properties names to modify.
	 * @param	theValue	value to set
	 */
	public static function setProperties(theProps:Array<String>, theValue:Int, theIgnoreActivationContraint:Bool = false):Void
	{
		var numProps:Int = theProps.length;
		
		for (i in 0...numProps) 
		{
			doSetValue(theProps[i], getProperty(theProps[i]) + theValue, theIgnoreActivationContraint);
		}
	}
	
	/**
	 * Gets the property with specified name
	 * @param	theProp		property name
	 * @return	property with specified name (if registered in manager).
	 */
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
	
	/**
	 * Resets properties to initial value.
	 * @param	theTags		an optional array of tags. If specified then only properties with these tags will be reset.
	 */
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
	
	/**
	 * Resets all properties and achievements (they become locked again).
	 */
	public static function reset():Void
	{
		resetProperties();
		
		for (a in mAchievements)
		{
			a.reset();
		}
	}
	
	/**
	 * Checks if the property is registered in manager.
	 * @param	theName		the to search for.
	 * @return	true if property is in manager, false otherwise.
	 */
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
	
	/**
	 * Checks if the achievement is registered in manager.
	 * @param	theName		the to search for.
	 * @return	true if achievement is in manager, false otherwise.
	 */
	public static function checkAchievementExists(theName:String):Bool
	{
		return mAchievements.exists(theName);
	}
	
	/**
	 * Searches for all unlocked achievements in manager.
	 * @param	achievements	an optional array to fill with found achievements.
	 * @return	an array of unlocked achievements.
	 */
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
	
	/**
	 * Returns an array of all achievements in manager.
	 * @param	achievements	an optional array to fill with found achievements.
	 * @return	an array of all achievements (both locked and unlocked).
	 */
	public static function getAllAchievements(?achievements:Array<Achievement>):Array<Achievement>
	{
		achievements = (achievements != null) ? achievements : new Array<Achievement>();
		
		for (achievement in mAchievements) 
		{
			achievements.push(achievement);
		}
		
		return achievements;
	}
	
	/**
	 * Checks if achievement with specified name is unlocked.
	 * @param	theName		the name of achievement
	 * @return	true if achievement is unlocked, false if not.
	 */
	public static function achievementUnlocked(theName:String):Bool
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName).unlocked;
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return false;
	}
	
	/**
	 * Returns achievement with specified name (if it's registered in manager).
	 * @param	theName		the name of achievement to search for.
	 * @return	achievement with specified name.
	 */
	public static function achievement(theName:String):Achievement
	{
		if (checkAchievementExists(theName))
		{
			return mAchievements.get(theName);
		}
		
		throw ("Unknown achievement \"" + theName + "\". Check if it was correctly defined by registerAchievement().");
		return null;
	}
	
	/**
	 * Returns all achievements which have at least one of specified properties.
	 * @param	theProps		an array of property names.
	 * @param	achievements	optional array to fill with found achievements. If null, then new array will be created.
	 * @return	array of achievements with specified properties.
	 */
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
	
	/**
	 * Returns all achievements which have at least one property with specified tags.
	 * @param	theProps		an array of tags.
	 * @param	achievements	optional array to fill with found achievements. If null, then new array will be created.
	 * @return	array of achievements with specified tags.
	 */
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
	
	/**
	 * Converts all registered properties to string.
	 */
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