package;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import flixel.FlxObject;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Player extends flixel.FlxSprite {
  private var gravity = 400;
  private var jumpSpeed = -130;
  private var walkSpeed = 40;

  private var rightKeys = [FlxKey.D, FlxKey.RIGHT];
  private var leftKeys = [FlxKey.A, FlxKey.LEFT];
  private var jumpKeys = [FlxKey.W, FlxKey.UP];

  public function new(X:Float, Y:Float) {
    super(X, Y);
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
    if (FlxG.keys.anyPressed(rightKeys)) {
      velocity.x = walkSpeed;
      if (animation.name != 'walk') {
        animation.play('walk', false, false, -1);
      }
    } else if (FlxG.keys.anyPressed(leftKeys)) {
      velocity.x = -walkSpeed;
      if (animation.name != 'walk') {
        animation.play('walk', false, false, -1);
      }
    } else {
      velocity.x = 0;
      animation.play('idle');
    }

    if (FlxG.keys.anyJustPressed(jumpKeys) && isTouching(FlxObject.DOWN)) {
      velocity.y = jumpSpeed;
    }

    acceleration.y = gravity;

    super.update(elapsed);
  }
}
