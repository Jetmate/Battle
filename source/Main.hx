package;

import flixel.FlxGame;
import openfl.display.Sprite;

// #if debug
// import debugger.HaxeRemote;
// #end


class Main extends Sprite
{
	public function new() {
// #if debug
//     new debugger.HaxeRemote(true, "localhost");
// #end
		super();
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
	}
}
