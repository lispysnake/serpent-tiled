/*
 * This file is part of serpent.
 *
 * Copyright © 2019 Lispy Snake, Ltd.
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

module serpent.resource;

/**
 * The ResourceManager is used for abstracting access to file-based
 * resources in a platform-agnostic way. Largely we rely upon ZIP archives
 * for bundling, with the assumption that the ZIP assets are supplied
 * with the game's executable as an output of the build system for the
 * game.
 */
final class ResourceManager
{

public:

    /**
     * Construct a new ResourceManager.
     */
    this()
    {
    }

    /**
     * Set the root directory for all lookup operations.
     */
    final void setRootDirectory(string dirpath)
    {
        return;
    }
}