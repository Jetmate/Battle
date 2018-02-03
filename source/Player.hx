package;

import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;

class Player extends flixel.FlxSprite {
  public function new(X:Float, Y:Float) {
    super(X, Y);
    var spritesheet = FlxTileFrames.fromGraphic(
      FlxGraphic.fromAssetKey(AssetPaths.player__png),
      new FlxPoint(8, 15)
    );
    setFrames(spritesheet);
    animation.add('walk', [0, 1], 3);
    animation.add('idle', [2, 3], 2);
    animation.play('idle');
  }

  public override function update(elapsed:Float) {
    super.update(elapsed);

    if (FlxG.keys.pressed.D) {
      velocity.x = 10;
      animation.play('walk');
    } else if (FlxG.keys.pressed.A) {
      velocity.x = -10;
      animation.play('walk');
    } else {
      velocity.x = 0;
      animation.play('idle');
    }
  }
}
