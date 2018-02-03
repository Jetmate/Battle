package;

import flixel.FlxObject;
import flixel.util.FlxCollision;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	private var player:Player;
	private var map:TiledLevel;
	private var bounds:FlxTypedGroup<FlxObject>;

	override public function create():Void
	{
		super.create();

		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.console.registerFunction('pixel', function(X:Float, Y:Float) {
			var canvas = new FlxSprite();
			canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
			canvas.drawRect(X, Y, 1, 1, flixel.util.FlxColor.BLUE);
			add(canvas);
		});

		map = new TiledLevel(AssetPaths.level1__tmx);
		add(map.backgroundMap);

		player = new Player(0, 0);
		add(player);

		add(map.foregroundMap);

		FlxG.camera.focusOn(new FlxPoint(map.fullWidth / 2, map.fullHeight / 2));
		FlxG.camera.zoom = 5;
		FlxG.camera.bgColor = FlxColor.fromRGB(250, 250, 250);

		bounds = new FlxTypedGroup<FlxObject>();
		bounds.add(new FlxObject(0, -10, map.fullWidth, 10));
		bounds.add(new FlxObject(0, map.fullHeight, map.fullWidth, 10));
		bounds.add(new FlxObject(-10, 0, 10, map.fullHeight));
		bounds.add(new FlxObject(map.fullWidth, 0, 10, map.fullHeight));
		bounds.forEach(function (object) { object.immovable = true; });
		add(bounds);

		var spawns = new Array<FlxPoint>();
		for (object in map.objectLayer.objects) {
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
		FlxG.collide(map.backgroundMap, player);
		FlxG.collide(bounds, player);
	}
}
