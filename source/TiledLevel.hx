package;

import haxe.io.Path;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
// import flixel.addons.editors.tiled.TiledObjectLayer;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;

class TiledLevel extends TiledMap {
    public var backgroundTiles:FlxTypedGroup<FlxTilemap>;
    public var collidableTiles:FlxTypedGroup<FlxTilemap>;
    public var objectLayers:Array<TiledObjectLayer>;

    public function new(tiledLevel:String) {
        super(tiledLevel);

        collidableTiles = new FlxTypedGroup<FlxTilemap>();
        backgroundTiles = new FlxTypedGroup<FlxTilemap>();
        objectLayers = new Array<TiledObjectLayer>();

        for (tileLayer in layers) {
            if (tileLayer.type == TiledLayerType.TILE) {
                var tileSheetName:String = tileLayer.properties.get("tileset");
                if (tileSheetName == null) {
                    throw "'tileset' property not defined for the '" +
                        tileLayer.name + "' layer. Please add the property to " +
                        "the layer.";
                }


                var tileSet:TiledTileSet = getTileSet(tileSheetName);
                if (tileSet == null) {
                    throw "Tileset " + tileSheetName + " not found. Did you " +
                        "mispell the 'tilesheet' property in " + tileLayer.name +
                        "' layer?";
                }

                var imagePath = new Path(tileSet.imageSource);
                var processedPath = Path.join([
                    "assets/images",
                    imagePath.file + "." + imagePath.ext
                ]);

                var tilemap = new FlxTilemap();
                tilemap.loadMapFromArray(
                    cast(tileLayer, TiledTileLayer).tileArray,
                    width, height,
                    processedPath,
                    tileWidth, tileHeight,
                    tileSet.firstGID, 1, 1
                );

                if (tileLayer.properties.contains("collide")) {
                    collidableTiles.add(tilemap);
                } else {
                    backgroundTiles.add(tilemap);
                }
            } else if (tileLayer.type == TiledLayerType.OBJECT) {
                objectLayers.push(cast(tileLayer, TiledObjectLayer));
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

    public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
        return FlxG.overlap(collidableTiles, obj, notifyCallback, processCallback);
    }
}
