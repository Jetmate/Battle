package;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxObject;
import flixel.util.FlxCollision;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxTiledSprite;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	private var player:Player;
	private var map:TiledLevel;
	private var bounds:FlxTypedGroup<FlxObject>;

	override public function create():Void
	{
		super.create();

		FlxG.scaleMode = new FixedScaleMode();
		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.console.registerFunction('pixel', function(X:Float, Y:Float) {
			var canvas = new FlxSprite();
			canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
			canvas.drawRect(X, Y, 1, 1, flixel.util.FlxColor.BLUE);
			add(canvas);
		});

		map = new TiledLevel(AssetPaths.level1__tmx);

		player = new Player(0, 0, {
			right: FlxKey.RIGHT,
			left: FlxKey.LEFT,
			up: FlxKey.UP,
			down: FlxKey.DOWN,
			jump: FlxKey.Z
		}, map);

		FlxG.camera.focusOn(new FlxPoint(map.fullWidth / 2, map.fullHeight / 2));
		FlxG.camera.zoom = 5;
		// FlxG.camera.bgColor = FlxColor.fromRGB(250, 250, 250);

		bounds = new FlxTypedGroup<FlxObject>();
		bounds.add(new FlxObject(0, -10, map.fullWidth, 10));
		bounds.add(new FlxObject(0, map.fullHeight, map.fullWidth, 10));
		bounds.add(new FlxObject(-10, 0, 10, map.fullHeight));
		bounds.add(new FlxObject(map.fullWidth, 0, 10, map.fullHeight));
		bounds.forEach(function (object) { object.immovable = true; });
		add(bounds);

		var spritesheet = new FlxFramesCollection(
      FlxGraphic.fromAssetKey(AssetPaths.backgrounds__png)
    );
    spritesheet.addSpriteSheetFrame(new FlxRect(0, 0, 15, 15));

		var spawns = new Array<FlxPoint>();
		for (object in map.objectLayer.objects) {
			switch object.type {
				case 'spawn': {
					spawns.push(new FlxPoint(object.x, object.y));
				}
				case 'background': {
					var canvas = new FlxSprite(object.x, object.y);
					canvas.makeGraphic(object.width, object.height, FlxColor.TRANSPARENT, false);
					var frame = spritesheet.frames[0];
					trace(object.height, frame.frame.height);
					for (x in 0...Math.ceil(object.width / frame.frame.width)) {
						for (y in 0...Math.ceil(object.height / frame.frame.height)) {
							var sprite = new FlxSprite();
							sprite.loadGraphic(FlxGraphic.fromFrame(frame));
							canvas.stamp(sprite, Std.int(x * frame.frame.width), Std.int(y * frame.frame.height));
						}
					}
					add(canvas);
				}
			}
		}
		var spawn = FlxG.random.getObject(spawns);
		player.setPosition(spawn.x, spawn.y - player.height);

		add(map.backgroundMap);
		add(player);
		add(map.foregroundMap);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FlxG.collide(map.backgroundMap, player);
		FlxG.collide(bounds, player);
	}
}
