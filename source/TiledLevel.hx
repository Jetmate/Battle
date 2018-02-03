package;

import flixel.addons.tile.FlxTileAnimation;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.tile.FlxTile;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import haxe.io.Path;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTile;

import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.tile.FlxBaseTilemap;
// import flixel.addons.editors.tiled.TiledObjectLayer;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;

class TiledLevel extends TiledMap {
    public var backgroundMap:FlxTilemapExt;
    public var foregroundMap:FlxTilemapExt;
    public var objectLayer:TiledObjectLayer;

    static var FLIPPED_X_FLAG = 0x80000000;
	static var FLIPPED_Y_FLAG   = 0x40000000;
	static var FLIPPED_XY_FLAG   = 0x20000000;

    static function flippedX(tile) {
        return tile & FLIPPED_X_FLAG != 0;
    }

    static function flippedY(tile) {
        return tile & FLIPPED_Y_FLAG != 0;
    }

    static function flippedXY(tile) {
        return tile & FLIPPED_XY_FLAG != 0;
    }

    static function clearFlags(tile) {
        return tile & ~(FLIPPED_X_FLAG |
                        FLIPPED_Y_FLAG |
                        FLIPPED_XY_FLAG);
    }

    static function getAnimation(tile, tileSet:TiledTileSet) {
        if (tileSet.getPropertiesByGid(tile) != null) {
            return cast(tileSet.getPropertiesByGid(tile), TiledTilePropertySet).animationFrames;
        }
        return null;
    }

    static function processAnimation(animation:Array<TileAnimationData>, name:String, looped:Bool) {
        var smallest = Lambda.fold(animation, function (val:TileAnimationData, acc:Float) {
            return (acc != 0 && acc < val.duration) ? acc : val.duration;
        }, 0);

        var frames = new Array<Int>();
        for (data in animation) {
            for (i in 0...(Std.int(data.duration / smallest))) {
                frames.push(data.tileID + 1);
            }
        }

        trace(frames, smallest);
        return new FlxTileAnimation(name, frames, 1 / (smallest / 1000), looped);
    }

    public function new(tiledLevel:String) {
        super(tiledLevel);

        var tileSet:TiledTileSet = tilesetArray[0];
        if (tileSet == null) {
            throw "No tileset found.";
        }
        FlxG.debugger.addTrackerProfile(
            new TrackerProfile(TiledTileSet, ["firstGID", "imageSource", "margin", "name", "numCols", "numRows", "numTiles", "properties", "spacing", "tileHeight", "tileImagesSources", "tileProps", "tileWidth"])
        );

        var imagePath = new Path(tileSet.imageSource);
        var processedPath = Path.join([
            "assets/images",
            imagePath.file + "." + imagePath.ext
        ]);

        for (layer in layers) {
            if (layer.type == TiledLayerType.TILE) {
                var tileLayer = cast(layer, TiledTileLayer);
                var tiles = new Array<Int>();
                var specialTiles = new Array<FlxTileSpecial>();

                // trace(tileLayer.tileArray);
                for (i in 0...tileLayer.tileArray.length) {
                    var tile = tileLayer.tileArray[i];
                    var clearedTile = clearFlags(tile);
                    // trace(tile, clearedTile);
                    var animation = getAnimation(clearedTile, tileSet);

                    if (flippedX(tile) || flippedY(tile) || flippedXY(tile) || animation != null && animation.length != 0) {
                        // var rotation = 0;
                        // if (flippedXY(tile)) {
                        //     if (flippedX(tile)) {
                        //         rotation = -90
                        //     }
                        // }
                        trace(clearedTile);
                        var specialTile = new FlxTileSpecial(
                            clearedTile,
                            flippedX(tile),
                            flippedY(tile),
                            flippedXY(tile) ? 90 : 0
                        );
                        if (animation != null && animation.length != 0) {
                            specialTile.animation = processAnimation(animation, Std.string(clearedTile), true);
                        }
                        specialTiles.push(specialTile);
                    } else {
                        specialTiles.push(null);
                    }
                    tiles.push(clearedTile);
                }

                var tilemap = new FlxTilemapExt();
                tilemap.loadMapFromArray(
                    tiles,
                    width, height,
                    processedPath,
                    tileWidth, tileHeight,
                    FlxTilemapAutoTiling.OFF,
                    tileSet.firstGID
                );
                trace(tiles);
                tilemap.setSpecialTiles(specialTiles);

                if (layer.name == "background") {
                    backgroundMap = tilemap;
                } else {
                    foregroundMap = tilemap;
                }
            } else if (layer.type == TiledLayerType.OBJECT) {
                objectLayer = cast(layer, TiledObjectLayer);
            }
        }

        for (i in tileSet.firstGID...tileSet.numTiles + tileSet.firstGID) {
            backgroundMap.setTileProperties(i, FlxObject.NONE);
            if (tileSet.getPropertiesByGid(i) != null) {
                if (tileSet.getPropertiesByGid(i).contains('collide')) {
                    backgroundMap.setTileProperties(i);
                }
            }
        }
    }

    // private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState) {
    //     var x:Int = o.x;
    //     var y:Int = o.y;

    //     // Objects in Tiled are aligned bottom-left (top-left in flixel)
    //     if (o.gid != -1) {
    //         y -= g.map.getGidOwner(o.gid).tileHeight;
    //     }
    // // }

    // public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
    //     return backgroundMap.overlaps  FlxG.overlap(collidableTiles, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
    // }
}
