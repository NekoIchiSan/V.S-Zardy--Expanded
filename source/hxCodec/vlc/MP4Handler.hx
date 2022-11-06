package vlc;

import openfl.events.Event;
import flixel.FlxG;
import vlc.bitmap.VlcBitmap;
import flixel.FlxSprite;

/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `MP4Sprite`.
 */

 // lol time to break code maybe?

class MP4Handler
{
	public var sprite:FlxSprite;
	
	#if desktop
	#end
	public static var vlcBitmap:VlcBitmap;

	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;

	var pauseMusic:Bool;

	public function new(width:Float = 320, height:Float = 240, autoScale:Bool = true, outputTo:FlxSprite = null)
	{

		vlcBitmap = new VlcBitmap();
		vlcBitmap.set_height(FlxG.stage.stageHeight);
		vlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		//super(width, height, autoScale);

		vlcBitmap.onVideoReady = onVLCVideoReady;
		vlcBitmap.onComplete = finishVideo;
		vlcBitmap.onError = onVLCError;

		FlxG.addChildBelowMouse(vlcBitmap);
		if(outputTo != null){
			vlcBitmap.x = -20000; // defn off screen
			//vlcBitmap.alpha = 0;

			sprite = outputTo;
		}

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		FlxG.signals.focusGained.add(function()
		{
			vlcBitmap.resume();
		});
		FlxG.signals.focusLost.add(function()
		{
			vlcBitmap.pause();
		});
	}

	function update(e:Event)
	{
		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && vlcBitmap.isPlaying)
			finishVideo();

		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			vlcBitmap.volume = 0;
		else
			vlcBitmap.volume = FlxG.sound.volume + 0.4;
	}

	#if sys
	function checkFile(fileName:String):String
	{
		#if !android
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
		#else
		return "file://" + fileName;
		#end
	}
	#end

	function onVLCVideoReady()
	{
		trace("Video loaded!");

		if (sprite != null)
			sprite.loadGraphic(vlcBitmap.bitmapData);	

		if (readyCallback != null)
			readyCallback();
	}

	function onVLCError()
	{
		// TODO: Catch the error
		throw "VLC caught an error!";
	}

	public function finishVideo()
	{
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
			//FlxG.game.removeChild(sprite);

			if (finishCallback != null)
				finishCallback();
		}
	}

	/**
	 * Native video support for Flixel & OpenFL
	 * @param path Example: `your/video/here.mp4`
	 * @param repeat Repeat the video.
	 * @param pauseMusic Pause music until done video.
	 */
	public function playVideo(path:String,?repeat:Bool = false, pauseMusic:Bool = false)
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		#if sys
 		vlcBitmap.play(checkFile(path));

		//this.repeat = vlcBitmap.repeat ? -1 : 0;
		#else
		throw "Doesn't support sys";
		#end
	}
}
