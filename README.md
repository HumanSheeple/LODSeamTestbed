GTPESL (Godot Terrain Painter Editor with Seamless LODing) A joint venture by Zylann and HumanSheeple
======================

This is a vertex height and shader editor for Godot with Level Of Detail capability.


![Editor screenshot](http://funkyimg.com/i/2tLi5.png)

Features
----------

- Custom Terrain node
- Auto-Updating Seamless Level Of Detail based on Quadtree engine mostly coded by Zylann, Mesher, Seamer and Neighbouring written by HumanSheeple
- Resizeable square between 1 and 1024 units of space
- Paint and smooth the terrain in the editor
- Brush with customizable shape, size and opacity
- Takes advantage of frustum culling by chunking the terrain in multiple meshes
- Choose from 18 different seamless terrain types to paint and mix how you like onto the terrain all from a single material.
- Triplanar rock shaders autogenerate when terrain steep enough
- Collisions
- Smooth or hard-edges rendering
- Save to image and normal map
- Terrain data saved inside the scene like Tilemap and Gridmap
- Edition behaviour works both in editor and game
- Undo/redo
- Experimental: quad rotation to improve shading in some cases

- Extras: sample assets in this repo :)


TODO/ideas
-----------

- Meshing is very VERY slow (will this plugin remain pure GDScript?)
- Baked mode for faster terrain loading (it is currently rebuilt from data both in editor and game)
- Save terrain data as a separate resource to unbloat the scene file
- Decorrelate resolution and size
- Make Terrain inherit Spatial so it can be moved around
- Paint meshes on top of the terrain (grass, trees, rocks...) <-- I want to make a vegetation generator plugin too :p
- Improve normals (data "pixels" produce lighting artefacts)
- Texture painting
- Make live edition work
- Mesh simplification (an editor lib would be welcome)
- Infinite terrain mode

- Extras: importer for terrains made in DCCs (Blender/3DS etc)

