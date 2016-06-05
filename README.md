# Achieve

Library to easily implement achievements in a game. Every achievement is described as a combination of properties (which are counters) guided by simple update and activation rules. When all the properties related to an achievement are active, the achievement is unlocked.

Properties can also be tagged and updated/reset in batch, which is useful for implementing level related achievements, such as `"kill all enemies of level N"`. A property can be updated with a single method call and the library takes care of analyzing activation rules and checking if a new achievement was unlocked.

## Usage

```
function initGame() :Void {
  Achieve.registerProperty("killedEnemies", 0, PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, 10, "levelStuff");
  Achieve.registerProperty("lives", 3, PROPERTY_ACTIVATION.ACTIVE_IF_EQUALS_TO, 3, "levelStuff");
  Achieve.registerProperty("completedLevels", 0, PROPERTY_ACTIVATION.ACTIVE_IF_GREATER_THAN, 5);
  Achieve.registerProperty("deaths", 0, PROPERTY_ACTIVATION.ACTIVE_IF_EQUALS_TO, 0);

  Achieve.registerAchievement("masterKill", ["killedEnemies"]); // Kill 10+ enemies.
  Achieve.registerAchievement("cantTouchThis", ["lives"]); // Complete a level and don't die.
  Achieve.registerAchievement("nothingElse", ["completedLevels"]); // Beat all 5 levels.
  Achieve.registerAchievement("hero", ["completedLevels", "deaths"]); // Beat all 5 levels, do not die during the process
  
  Achieve.onAchievementUnlock = onAchievementUnlock;
}

function gameLoop() :Void {
  if(enemyWasKilled()) {
    Achieve.addToProperties(["killedEnemies"], 1);
  }

  if(playerJustDied()) {
    Achieve.addToProperty("lives", -1);
    Achieve.addToProperties(["deaths"], 1);
  }
}

function levelUp() :Void {
  Achieve.addToProperty("completedLevels", 1);

  // Reset all properties tagged with 'levelStuff'
  Achieve.resetProperties("levelStuff");
}

function onAchievementUnlock(achievementName:String) :Void {
  // Handle achievement unlock here...
  ...
}
```

## Motivation

Achieve was created to illustrate [how to code unlockable achievements for your game (a simple approach)](http://gamedevelopment.tutsplus.com/tutorials/how-to-code-unlockable-achievements-for-your-game-a-simple-approach--gamedev-6012).

## Contributors

If you liked the project and want to help, you are welcome! Submit pull requests or [open a new issue](https://github.com/Dovyski/Achieve/issues) describing your idea.

## License

Achieve is licensed under the MIT license.
