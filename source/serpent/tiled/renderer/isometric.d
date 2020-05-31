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

public import serpent.core.entity;
public import serpent.core.processor;
public import serpent.core.view;

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

    final void drawMap(View!ReadOnly queryView, ref QuadBatch batch, EntityID id)
    {

    }

}
