package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
using CoolUtil;

class CreditsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<ListUserdata> = [];
	var curCharacter:String = '';

	var blackbar:FlxSprite;
	var curSelected:Int = 0;
	var usersWork:FlxText;
	var usersText:FlxText;
	var usersAvatar:FlxSprite;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	public function new()
	{
		super();

		var userList = CoolUtil.coolTextFile(Paths.txt('creditsMenu'));
	
		for (i in 0...userList.length)
		{
			var data:Array<String> = userList[i].split(':');
			textMenuItems.push(new ListUserdata(data[0], data[1], Std.parseInt(data[2]), data[3], data[4]));
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.15;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		blackbar = new FlxSprite(420, -100).makeGraphic(10, 1000, FlxColor.BLACK);
		add(blackbar);

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		creditsItemsSort();

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(20, 120 + (i * 50), 350, textMenuItems[i].curUser, 64, true);
			optionText.setFormat(Paths.font("funkin.otf"), 64, FlxColor.WHITE, LEFT);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
	}

	public function addUserToList(curUser:String, curPicture:String, curNumber:Int, curWork:String, curText:String)
	{
		textMenuItems.push(new ListUserdata(curUser, curPicture, curNumber, curWork, curText));
	}

	function creditsItemsSort()
	{
		var avatarPath:String = textMenuItems[curSelected].curPicture; 

		remove(usersAvatar);
		usersAvatar = new FlxSprite(550,100).loadGraphic(Paths.image('avatars/$avatarPath'));
		add(usersAvatar);

		remove(usersWork);
		usersWork = new FlxText(450, 300, 0, textMenuItems[curSelected].curWork, 32, true);
		usersWork.text = StringTools.replace(usersWork.text, "\\n", " \n\n");
		usersWork.font = 'VCR OSD Mono';
		add(usersWork);

		remove(usersText);
		usersText = new FlxText(450, 580, 0, textMenuItems[curSelected].curText, 32, true);
		usersText.text = StringTools.replace(usersText.text, "\\n", "\n");
		usersText.font = 'VCR OSD Mono';
		add(usersText);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);		

		if (controls.UP_P)
		{
			changeSelection(-1);
			creditsItemsSort();
		}
		

		if (controls.DOWN_P)
		{
			changeSelection(1);
			creditsItemsSort();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 100);
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{	
			var numberUser = textMenuItems.length;
			if (textMenuItems[curSelected].curNumber == 69)
			{
				FlxG.sound.play(Paths.sound('fartBigReverb'), 1);
			}
		}

		grpOptionsTexts.forEach(function(txt:FlxText)
		{
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected)
				txt.color = FlxColor.YELLOW;
		});
	}	

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;
		if (curSelected >= textMenuItems.length)
			curSelected = 0;
	}
}

class ListUserdata
{
	public var curUser:String = "";
	public var curWork:String = "";
	public var curPicture:String = "";
	public var curText:String = "";
	public var curNumber:Int = 0;

	public function new(curUser:String, curPicture:String, curNumber:Int, curWork:String, curText:String)
	{
		this.curUser = curUser;
		this.curWork = curWork;
		this.curPicture = curPicture;
		this.curText = curText;
		this.curNumber = curNumber;
	}
}