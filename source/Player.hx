package;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import flixel.FlxObject;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.tile.FlxTilemap;

typedef KeysInput = {
  right : FlxKey,
  left : FlxKey,
  up : FlxKey,
  down : FlxKey,
  jump : FlxKey
}

class Player extends flixel.FlxSprite {
  private var gravity = 400;
  private var jumpSpeed = -130;
  private var walkSpeed = 40;

  private var keys:KeysInput;
  private var level:TiledLevel;

  public function new(X:Float, Y:Float, keys:KeysInput, level:TiledLevel) {
    super(X, Y);

    this.keys = keys;
    this.level = level;

    var spritesheet = new FlxFramesCollection(
      FlxGraphic.fromAssetKey(AssetPaths.player__png)
    );
    spritesheet.addSpriteSheetFrame(new FlxRect(0, 0, 8, 15));
    spritesheet.addSpriteSheetFrame(new FlxRect(8, 0, 8, 15));
    spritesheet.addSpriteSheetFrame(new FlxRect(0, 15, 8, 15));
    spritesheet.addSpriteSheetFrame(new FlxRect(8, 15, 8, 15));
    setFrames(spritesheet);

    animation.add('walk', [0, 1], 5);
    animation.add('idle', [2, 3], 2);
    animation.play('idle');

    width -= 2;
    centerOffsets();
  }

  public override function update(elapsed:Float) {
    if (FlxG.keys.anyPressed([keys.right])) {
      velocity.x = walkSpeed;
      if (animation.name != 'walk') {
        animation.play('walk', false, false, -1);
      }
    } else if (FlxG.keys.anyPressed([keys.left])) {
      velocity.x = -walkSpeed;
      if (animation.name != 'walk') {
        animation.play('walk', false, false, -1);
      }
    } else {
      velocity.x = 0;
      animation.play('idle');
    }

    if (FlxG.keys.anyJustPressed([keys.jump]) && isTouching(FlxObject.DOWN)) {
      var x1 = Std.int(x / 5);
      var y1 = Std.int((y + height) / 5);
      var x2 = Std.int((x + width - 1) / 5);
      if (
        FlxG.keys.anyPressed([keys.down]) &&
        (level.tileHasValueByCoords(x1, y1, 'collide', 'up') || level.tileHasValueByCoords(x2, y1, 'collide', 'up')) &&
        (
          !(level.tileHasPropertyByCoords(x1, y1, 'collide') && !level.tileHasValueByCoords(x1, y1, 'collide', 'up')) &&
          !(level.tileHasPropertyByCoords(x2, y1, 'collide') && !level.tileHasValueByCoords(x2, y1, 'collide', 'up'))
        )
      ) {
        velocity.y = -jumpSpeed;
        level.backgroundMap.setTileProperties(level.backgroundMap.getTile(x1, y1), FlxObject.NONE);
      } else {
        velocity.y = jumpSpeed;
      }
    }

    acceleration.y = gravity;

    super.update(elapsed);
  }
}
