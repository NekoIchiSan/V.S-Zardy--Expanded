package;

import flixel.FlxState;
import flixel.FlxG;

class MacVideoHandlerState extends MusicBeatState
{
	public function new(path:String)
	{
		super();

		new MacVideoHandler(path);
	}
}