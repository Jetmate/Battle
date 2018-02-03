package;

import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;

class PlayState extends FlxState {
	private var player:Player;
	private var map:TiledLevel;

	override public function create():Void
	{
		super.create();

		map = new TiledLevel(AssetPaths.level1__tmx);
		add(map.backgroundTiles);
		add(map.collidableTiles);

		player = new Player(0, 0);
		add(player);

		FlxG.camera.focusOn(new FlxPoint(0, 0));
		FlxG.camera.zoom = 3;
		FlxG.camera.bgColor = FlxColor.fromRGB(250, 250, 250);

		var spawns = new Array<FlxPoint>();
		for (object in map.objectLayers[0].objects) {
			switch object.type {
				case 'spawn': {
					spawns.push(new FlxPoint(object.x, object.y));
				}
			}
		}
		var spawn = FlxG.random.getObject(spawns);
		player.setPosition(spawn.x, spawn.y - player.height);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		map.collideWithLevel(player);
	}
}
