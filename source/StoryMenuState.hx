package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	//var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['Beginnings', 'Rainy-Pipes', 'Soothing-Summits'],
		['Chiwld-Season', 'Timber-Terror', '3-Gnomes-in-a-Trenchcoat'],
		['Ceramic-Mischief']
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],

	];

	var weekNames:Array<String> = [
		"How to Funk",
		"Daddy Dearest",
		"Spooky Month",
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var storyBG:FlxSprite;
	var storyTracks:FlxSprite;
	var storyThem:FlxSprite;
	var storyBf:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var upArrow:FlxSprite;
	var downArrow:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		//scoreText = new FlxText(10, 0, 0, "SCORE: 0", 36);
		//scoreText.setFormat("VCR OSD Mono", 32);

		//txtWeekTitle = new FlxText(FlxG.width * 0.7, 0, 0, "", 32);
		//txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		//txtWeekTitle.alpha = 0.7;

		//var rankText:FlxText = new FlxText(0, 0);
		//rankText.text = 'RANK: GREAT';
		//rankText.setFormat(Paths.font("vcr.ttf"), 32);
		//rankText.size = scoreText.size;
		//rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		storyBG = new FlxSprite(0, 0).loadGraphic(Paths.image('campaign/storyBG'));
		storyBG.visible = true;
		storyBG.antialiasing = true;
		storyBG.updateHitbox();
		add(storyBG);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, 0, i);
			weekThing.y = ((weekThing.height + 1) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);
			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 20 + weekThing.x);
				lock = new FlxSprite(0, 0).loadGraphic(Paths.image('campaign/storyLocked'));
				//lock.animation.addByPrefix('lock', 'lock');
				//lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		storyThem = new FlxSprite(0, 0).loadGraphic(Paths.image('campaign/storyThem'));
		storyThem.visible = true;
		storyThem.antialiasing = true;
		storyThem.updateHitbox();
		add(storyThem);

		storyTracks = new FlxSprite(0, 0);
		storyTracks.frames = Paths.getSparrowAtlas('campaign/weekButton_assets');
		storyTracks.animation.addByPrefix('house', 'HOUSE');
		storyTracks.animation.addByPrefix('forest', 'FOREST');
		storyTracks.animation.addByPrefix('school', 'SCHOOL');
		storyTracks.animation.play('house');
		add(storyTracks);

		storyBf = new FlxSprite(870, FlxG.height * 0.05);
		storyBf.frames = Paths.getSparrowAtlas('campaign/storyBf');
		storyBf.animation.addByPrefix('idle', "storyIdle", 24);
		storyBf.antialiasing = true;
		storyBf.animation.play('idle');
		storyBf.setGraphicSize(Std.int(storyBf.width * 0.75));
		storyBf.updateHitbox();
		add(storyBf);

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		upArrow = new FlxSprite(780, 350);
		upArrow.frames = Paths.getSparrowAtlas('campaign/up_assets');
		upArrow.animation.addByPrefix('idle', "IDLE");
		upArrow.animation.addByPrefix('press', "PRESS", 10, false);
		upArrow.antialiasing = true;
		upArrow.animation.play('idle');
		difficultySelectors.add(upArrow);

		sprDifficulty = new FlxSprite(550, 150);
		sprDifficulty.frames = Paths.getSparrowAtlas('campaign/difficulty_assets');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.9));
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		downArrow = new FlxSprite(780, 530);
		downArrow.frames = Paths.getSparrowAtlas('campaign/down_assets');
		downArrow.animation.addByPrefix('idle', "IDLE");
		downArrow.animation.addByPrefix('press', "PRESS", 10, false);
		downArrow.antialiasing = true;
		downArrow.animation.play('idle');
		difficultySelectors.add(downArrow);

		trace("Line 150");

		//add(yellowBG);
		//add(grpWeekCharacters);

		//txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		//txtTracklist.alignment = CENTER;
		//txtTracklist.font = rankText.font;
		//txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		// add(rankText);
		//add(scoreText);
		//add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
    {

		trace(curWeek);

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		//scoreText.text = "WEEK SCORE:" + lerpScore;

		//txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		//txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(1);			
				}

				if (controls.UP_P)
					upArrow.animation.play('press')
				else
					upArrow.animation.play('idle');		

				if (controls.DOWN_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
					downArrow.animation.play('press')
				else
					downArrow.animation.play('idle');		

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 0;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 0;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 0;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: 230 + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
		
		switch(curWeek)
		{
			case 0:
			{
				storyTracks.animation.play('house');
			}
			case 1:
			{
				storyTracks.animation.play('forest');
			}
			case 2:
			{
				storyTracks.animation.play('school');
			}
		}
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		//txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
		{
			//txtTracklist.text += "\n" + i;
		}

		//txtTracklist.text = txtTracklist.text.toUpperCase();

		//txtTracklist.screenCenter(X);
		//txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}