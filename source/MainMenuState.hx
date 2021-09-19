package;

import flixel.addons.transition.FlxTransitionableState;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story', 'freeplay', 'options', 'credits'];

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.4.2" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var camFollow:FlxObject;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		var sidebg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('sideBG'));
		sidebg.scrollFactor.x = 0;
		sidebg.scrollFactor.y = 0.18;
		sidebg.updateHitbox();
		sidebg.screenCenter();
		sidebg.antialiasing = true;
		add(sidebg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var border:FlxSprite = new FlxSprite(-75, 80).loadGraphic(Paths.image('menuBorder'));
		border.setGraphicSize(Std.int(border.width * 0.9985));
		border.updateHitbox();
		border.screenCenter();
		border.antialiasing = true;
		add(border);
		
		var splash:FlxSprite = new FlxSprite(-80, 0).loadGraphic(Paths.image('optionSplash'));
		splash.setGraphicSize(Std.int(splash.width), Std.int(splash.height * 1.015));
		splash.updateHitbox();
		splash.screenCenter();
		splash.antialiasing = true;
		add(splash);

		var fallingCharacters:FlxSprite = new FlxSprite(10, 0);
		fallingCharacters.frames = Paths.getSparrowAtlas('falling', 'preload');
		fallingCharacters.animation.addByPrefix('falling', 'falling', 12, true);
		fallingCharacters.animation.play('falling', true);
		add(fallingCharacters);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + '-normal', 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + "-hover", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite) 
				{
					if (curSelected != spr.ID) {
						FlxTween.tween(spr, {alpha: 0}, 1.3, 
						{
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) 
							{
								spr.kill();
							}
						});
					} 
					else 
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) 
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice) 
							{
								case 'story':
									FlxG.switchState(new StoryMenuState());
									trace("Story Menu Selected");
								case 'freeplay':
									FlxG.switchState(new FreeplayState());
									trace("Freeplay Menu Selected");
								case 'options':
									FlxG.switchState(new OptionsMenu());
								case 'credits':
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									FlxG.switchState(new CreditsSubState());
									trace("Credits Menu Selected");
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
