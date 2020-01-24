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

module serpent.core.component;

/**
 * Simple UDA decorator. May be used in future for runtime introspection,
 * but is an explicit requiremenet to ensure we don't add random objects
 * and instances to entities.
 */
final struct serpentComponent
{
}

/**
 * The ComponentManager is responsible for assigning and removing components
 * (tags + data) from specific entities. In future it will evolve to have
 * improved memory management, with Region allocation and entity sorting.
 *
 * For now, it will be simple to get us to demo stages.
 */
final class ComponentManager
{

package:

    this()
    {

    }
}