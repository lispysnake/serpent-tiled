/*
 * This file is part of serpent.
 *
 * Copyright © 2019-2020 Lispy Snake, Ltd.
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module serpent.tiled.tsx;

public import serpent.tiled.tileset;

import std.xml;
import std.file;
import std.exception : enforce;
import std.conv : to;
import std.format;
import std.path : dirName, buildPath;

/**
 * The TSXParser is a utility class that exists solely to parse TSX files
 * and TSX fragments contained within TMX files.
 */
final class TSXParser
{

package:

    /**
     * This function actually handles the <tileset> tag fully and builds a
     * TileSet from it.
     */
    static final TileSet parseTileSetElement(string baseDir, Element e) @safe
    {
        enforce(e.tag.name == "tileset", "Expected 'tileset' element");
        auto tileset = new TileSet();
        tileset.baseDir = baseDir;

        /* Step through <tileset> attributes */
        foreach (attr, attrValue; e.tag.attr)
        {
            switch (attr)
            {
            case "name":
                tileset.name = attrValue;
                break;
            case "tilewidth":
                tileset.tileWidth = to!int(attrValue);
                break;
            case "tileheight":
                tileset.tileHeight = to!int(attrValue);
                break;
            case "tilecount":
                tileset.tileCount = to!int(attrValue);
                break;
            case "columns":
                tileset.columns = to!int(attrValue);
                break;
            case "spacing":
                tileset.spacing = to!int(attrValue);
                break;
            case "margin":
                tileset.margin = to!int(attrValue);
                break;
            default:
                break;
            }
        }

        tileset.validate();

        /* Step through child elements now */
        foreach (item; e.elements)
        {
            switch (item.tag.name)
            {
            case "image":
                tileset.collection = false;
                parseRootImage(tileset, item);
                break;
            case "tile":
                parseTile(tileset, item);
                break;
            default:
                break;
            }
        }

        return tileset;
    }

    /**
     * Parse a singular tile.
     */
    static final void parseTile(TileSet tileset, Element element) @safe
    {
        int id = to!int(element.tag.attr["id"]);
        foreach (item; element.elements)
        {
            switch (item.tag.name)
            {
            case "animation":
                /* Handle animation */
                break;
            case "image":
                parseTileImage(tileset, id, item);
                break;
            default:
                break;
            }
        }
    }

    /**
     * Handle per-tile-image (!collection)
     */
    static final void parseTileImage(TileSet tileset, int gid, Element element) @trusted
    {
        tileset.collection = true;
        auto source = element.tag.attr["source"];
        auto width = to!int(element.tag.attr["width"]);
        auto height = to!int(element.tag.attr["height"]);

        auto texture = new Texture(buildPath(tileset.baseDir, source));
        auto tile = Tile(texture);
        tileset.setTile(gid, tile);
    }

    /**
     * Parse the root image (tilesheet) for this tileset.
     */
    static final void parseRootImage(TileSet tileset, Element element) @trusted
    {
        string source = "";
        int width = 0;
        int height = 0;

        /* Step attributes */
        foreach (attr, attrValue; element.tag.attr)
        {
            switch (attr)
            {

            case "source":
                source = attrValue;
                break;
            case "width":
                width = to!int(attrValue);
                break;
            case "height":
                height = to!int(attrValue);
                break;
            default:
                break;
            }
        }

        auto texture = new Texture(buildPath(tileset.baseDir, source));

        /* Start at MARGIN gap (X/Y) */
        int x = tileset.margin;
        int y = tileset.margin;
        int column = 0;

        tileset.reserve();
        enforce(tileset.columns > 0, "Column number must be greater than zero");
        enforce(tileset.tileCount > 0, "tileCount must be greater than zero");

        /* Step through all potential tile regions */
        foreach (tileID; 0 .. tileset.tileCount)
        {
            auto region = rectanglef(x, y, tileset.tileWidth, tileset.tileHeight);
            auto uv = UVCoordinates(width, height, region);
            Tile t = Tile(uv);
            t.texture = texture;
            tileset.setTile(tileID, t);

            ++column;

            /* At this point we need to insert the region + tile.. */

            /* When we exceed the columns, start a new row */
            if (column >= tileset.columns)
            {
                column = 0;
                auto computeWidth = x + tileset.tileWidth + tileset.margin;
                enforce(computeWidth == width,
                        "Expect image width of %d, got %d".format(width, computeWidth));
                x = tileset.margin;
                y += tileset.spacing + tileset.tileHeight;
            }
            else
            {
                x += tileset.tileWidth + tileset.spacing;
            }
        }
    }

public:

    /**
     * As a static utility class, there is no point in constructing us.
     */
    @disable this();

    /**
     * Load a .tsx file from disk and return a TileSet instance for it.
     */
    static final TileSet loadTSX(string path) @trusted
    {
        auto r = cast(string) std.file.read(path);
        std.xml.check(r);
        auto baseDir = dirName(path);

        auto doc = new Document(r);
        return parseTileSetElement(baseDir, doc);
    }
}
