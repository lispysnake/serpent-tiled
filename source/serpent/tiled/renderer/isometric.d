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

module serpent.tiled.renderer.isometric;

import serpent.tiled.component;

public import serpent.ecs.entity;
public import serpent.core.processor;
public import serpent.ecs.view;

import serpent.tiled : TileFlipMode;
import serpent.graphics.batch;

import serpent.graphics.renderer;
import serpent.core.transform;

/**
 * The IsometricMapRenderer will only attempt to render maps with
 * the MapOrientation.Isometric orientation
 */
final class IsometricMapRenderer : Renderer
{

public:

    /**
     * Register the MapComponent if not already registered
     */
    final override void bootstrap() @safe
    {
        context.entity.tryRegisterComponent!MapComponent;
    }

    /**
     * For every Isometric orientation map, push the visible for renderering
     */
    final override void queryVisibles(View!ReadOnly queryView, ref FramePacket packet)
    {
        foreach (entity, transform, map; queryView.withComponents!(TransformComponent,
                MapComponent))
        {
            if (map.map.orientation == MapOrientation.Isometric)
            {
                packet.pushVisibleEntity(entity.id, this, transform.position);
            }
        }
    }

    /**
     * Submit the map for rendering
     */
    final override void submit(View!ReadOnly queryView, ref QuadBatch batch, EntityID id)
    {
        drawMap(queryView, batch, id);
    }

private:

    /**
     * Perform the actual drawing.
     *
     * Currently this is unoptimised and doesn't perform any clipping
     * whatsoever. We will spend some time cleaning it up before promoting
     * its use.
     */
    final void drawMap(View!ReadOnly queryView, ref QuadBatch qb, EntityID id)
    {
        auto mapComponent = queryView.data!MapComponent(id);
        auto transform = queryView.data!TransformComponent(id);
        auto startX = 0.0f;
        auto startY = 0.0f;

        auto drawX = startX;
        auto drawY = startY;

        auto transformScale = vec3f(1.0f, 1.0f, 1.0f);

        float drawZ = transform.position.z;

        const auto heightIncrement = mapComponent.map.tileHeight / 2.0f;
        const auto widthIncrement = mapComponent.map.tileWidth / 2.0f;

        foreach (layerID; 0 .. mapComponent.map.layers.length)
        {
            auto layer = mapComponent.map.layers[layerID];

            drawX = startX;
            drawY = startY;

            foreach (y; 0 .. layer.height)
            {
                foreach (x; 0 .. layer.width)
                {
                    auto gid = layer.data[x + y * layer.width];
                    auto tile = gid & ~TileFlipMode.Mask;
                    auto tileset = mapComponent.map.findTileSet(tile);
                    if (tileset is null)
                    {
                        drawX += widthIncrement;
                        drawY += heightIncrement;
                        continue;
                    }
                    auto t2 = tileset.getTile(tile);

                    auto transformPosition = vec3f(drawX + layer.offsetX,
                            drawY + layer.offsetY, drawZ);

                    float tileWidth = mapComponent.map.tileWidth;
                    float tileHeight = mapComponent.map.tileHeight;

                    /* Anchor the image correctly. */
                    if (tileset.collection)
                    {
                        tileWidth = t2.texture.width;
                        tileHeight = t2.texture.height;

                        /* Account for non-regular tiles */
                        if (tileWidth != mapComponent.map.tileWidth
                                || tileHeight != mapComponent.map.tileHeight)
                        {
                            transformPosition.y += mapComponent.map.tileHeight;
                            transformPosition.y -= tileHeight;
                        }
                    }

                    /* Currently only support horizontal + vertical flip */
                    UVCoordinates uv = t2.uv;
                    if ((gid & TileFlipMode.Horizontal) == TileFlipMode.Horizontal)
                    {
                        uv.flipHorizontal();
                    }
                    if ((gid & TileFlipMode.Vertical) == TileFlipMode.Vertical)
                    {
                        uv.flipVertical();
                    }

                    qb.drawTexturedQuad(encoder, t2.texture, transformPosition,
                            transformScale, tileWidth, tileHeight, uv, t2.texture.rgba);

                    /* Increment draw index */
                    drawX += widthIncrement;
                    drawY += heightIncrement;
                    drawZ += 0.1f;
                }

                auto yOffset = y * heightIncrement;
                auto xOffset = y * widthIncrement;

                drawX = startX - xOffset;
                drawY = startY + yOffset;
            }
        }
    }

}
