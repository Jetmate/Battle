package;

import flixel.addons.tile.FlxTileAnimation;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import haxe.io.Path;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;

import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.tile.FlxBaseTilemap;
// import flixel.addons.editors.tiled.TiledObjectLayer;

import flixel.FlxG;
import flixel.FlxObject;

class TiledLevel extends TiledMap {
    public var backgroundMap:FlxTilemapExt;
    public var foregroundMap:FlxTilemapExt;
    public var objectLayer:TiledObjectLayer;
    public var tileSet:TiledTileSet;

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

    function getAnimation(tile) {
        if (tileSet.getPropertiesByGid(tile) != null) {
            return cast(tileSet.getPropertiesByGid(tile), TiledTilePropertySet).animationFrames;
        }
        return null;
    }

    function processAnimation(animation:Array<TileAnimationData>, name:String, looped:Bool) {
        var smallest = Lambda.fold(animation, function (val:TileAnimationData, acc:Float) {
            return (acc != 0 && acc < val.duration) ? acc : val.duration;
        }, 0);

        var frames = new Array<Int>();
        for (data in animation) {
            for (i in 0...(Std.int(data.duration / smallest))) {
                frames.push(data.tileID + tileSet.firstGID);
            }
        }

        return new FlxTileAnimation(name, frames, 1 / (smallest / 1000), looped);
    }

    public function new(tiledLevel:String) {
        super(tiledLevel);

        tileSet = tilesetArray[0];
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
                    var animation = getAnimation(clearedTile);

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
                tilemap.setSpecialTiles(specialTiles);

                var slopes = [
                    "nw" => [],
                    "ne" => [],
                    "sw" => [],
                    "se" => [],
                ];

                for (i in tileSet.firstGID...tileSet.numTiles + tileSet.firstGID) {
                    tilemap.setTileProperties(i, FlxObject.NONE);
                    var properties = tileSet.getPropertiesByGid(i);
                    if (properties != null) {
                        if (properties.contains("collide")) {
                            tilemap.setTileProperties(i);
                        }
                        if (properties.contains("sloped")) {
                            slopes[properties.get("sloped")].push(i);
                        }
                    }
                }
                tilemap.setSlopes(slopes["nw"], slopes["ne"], slopes["sw"], slopes["se"]);

                if (layer.name == "background") {
                    backgroundMap = tilemap;
                } else {
                    foregroundMap = tilemap;
                }
            } else if (layer.type == TiledLayerType.OBJECT) {
                objectLayer = cast(layer, TiledObjectLayer);
            }
        }
    }

    public function tileProperties(property:String, func:Int->Void) {
        for (i in tileSet.firstGID...tileSet.numTiles + tileSet.firstGID) {
            if (tileSet.getPropertiesByGid(i) != null) {
                if (tileSet.getPropertiesByGid(i).contains(property)) {
                    func(i);
                }
            }
        }
    }
}
