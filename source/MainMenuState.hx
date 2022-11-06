package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var zardyExpandedVerison:String = '2.15';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'freeplay',
		'options', 
		'plush', 
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	#if debug
	var debugKeys:Array<FlxKey>;
	#end

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		Paths.clearStoredMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		#if debug
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG', 'zardy'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat', 'zardy'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		var tex2 = Paths.getSparrowAtlas('newMenu/menu_credits', 'zardy');
		var tex4 = Paths.getSparrowAtlas('newMenu/plushie', 'zardy');

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets', 'zardy');

		for (i in 0...optionShit.length)
			{
				if (i == 0)
					{
						var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
						var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
						menuItem.frames = tex;
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
						menuItem.animation.play('idle');
						menuItem.ID = i;
						menuItem.screenCenter(X);
						menuItems.add(menuItem);
						var scr:Float = (optionShit.length - 4) * 0.135;
						if(optionShit.length < 6) scr = 0;
						menuItem.scrollFactor.set(0, scr);
						menuItem.antialiasing = ClientPrefs.globalAntialiasing;
						//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
						menuItem.updateHitbox();
					}
					if (i == 1)
					{
						var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
						var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
						menuItem.frames = tex;
						menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
						menuItem.animation.play('idle');
						menuItem.ID = i;
						menuItem.screenCenter(X);
						menuItems.add(menuItem);
						var scr:Float = (optionShit.length - 4) * 0.135;
						if(optionShit.length < 6) scr = 0;
						menuItem.scrollFactor.set(0, scr);
						menuItem.antialiasing = ClientPrefs.globalAntialiasing;
						//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
						menuItem.updateHitbox();
					}
					if (i == 2)
					{
						var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
						var plushie:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
						plushie.frames = tex4;
						plushie.animation.addByPrefix('idle', "plushieSmall", 24);
						plushie.animation.addByPrefix('selected', "plushieBig", 24);
						plushie.ID = i;
						plushie.animation.play('idle');
						plushie.screenCenter(X);
						menuItems.add(plushie);
						plushie.scrollFactor.set();
					}
					if (i == 3)
					{
						var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
						var credits:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
						credits.frames = tex2;
						credits.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
						credits.animation.addByPrefix('selected', optionShit[i] + " white", 24);
						credits.ID = i;
						credits.animation.play('idle');
						credits.screenCenter(X);
						menuItems.add(credits);
						credits.scrollFactor.set();
					}
				/*
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
				*/
			}

		FlxG.camera.follow(camFollowPos, null, 1);


		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Zardy Expanded v" + zardyExpandedVerison, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'plush')
				{
					CoolUtil.browserLoad("https://www.makeship.com/products/zardy-plush");
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
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
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if debug
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
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
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
