tool

# Note:
# This is a very slow part of this plugin, due to GDScript mostly.
# I tried to optimize it without SurfaceTool to reduce calculations,
# but it didn't improve much.
# This plugin must be converted to C++/GDNative.

static func tryget(d, k, defval):
	if d.has(k):
		return d[k]
	return defval

# heights: array of arrays of floats
# normals: arrays of arrays of Vector3
# x0, y0, w, h: sub-rectangle to generate from the above grids
# smooth_shading: if set to true, normals will be used instead of "polygon-looking" ones
# returns: a Mesh
static func make_heightmap(opt):
	# Unpack parameters
	var input_heights = opt.heights
	var input_normals = opt.normals
	var input_colors = opt.colors
	var x0 = opt.x0
	var y0 = opt.y0
	var w = opt.w
	var h = opt.h
	var h0 = h-2
	var h1 = h-1
	var LOD = opt.lod_index
	var smooth_shading = tryget(opt, "smooth_shading", true)
	var north_edge = opt.north_edge
	var east_edge = opt.east_edge
	var west_edge = opt.west_edge
	var south_edge = opt.south_edge

	# Set up the bitshifting factor based upon the LOD
	var factor = int(1)<<int(LOD)
	if smooth_shading == false:
		return make_heightmap_faceted(input_heights, input_colors, x0, y0, w, h)
		
	var max_y = int(y0 + (w*factor))
	var max_x = int(x0 + (h*factor))
	var max_y0 = max_y+1
	var max_x0 = max_x+1
	
	var terrain_size_x = input_heights.size()-1
	var terrain_size_y = 0
	if input_heights.size() > 0:
		terrain_size_y = input_heights[0].size()-1
	
	if max_y >= terrain_size_y:
		max_y = terrain_size_y
	if max_x >= terrain_size_x:
		max_x = terrain_size_x
	
	var vertices = Vector3Array()
	var normals = Vector3Array()
	var colors = ColorArray()
	var uv = Vector2Array()
	var indices = IntArray()
		
	var uv_scale = Vector2(1.0/terrain_size_x, 1.0/terrain_size_y)
	var half_east_face = false
	var half_north_face = false
	for y in range(y0+factor, max_y, factor):
		var hrow = input_heights[y]
		var crow = input_colors[y]
		var nrow = input_normals[y]
		for x in range(x0+factor, max_x, factor):
			vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
			uv.push_back(Vector2(x, y) * uv_scale)
			colors.push_back(crow[x])
			normals.push_back(nrow[x])

	
	if vertices.size() == 0:
		print("No vertices generated! ", x0, ", ", y0, ", ", w, ", ", h)
		return null
	
	var vertex_count = vertices.size()
	var quad_count = (h1)*(h1)

	var i = 0
	var half_index_east = false
	var half_index_north = false
	for y in range(1, h1):
		for x in range(1, h1):
			indices.push_back(i)
			indices.push_back(i+w)
			indices.push_back(i+h1)
			indices.push_back(i)
			indices.push_back(i+1)
			indices.push_back(i+w)
			i += 1
		i += 1
	
	var east_vertex_count = 0
	var north_vertex_count = 0
	var west_vertex_count = 0
	var indexoffset = 0
	var northeastcorner = 0
	var northwestcorner = 0
	var southwestcorner = 0
	var southeastcorner = 0
	var rowcounter = 0
	
	if(east_edge==0):
		for y in range(max_y, max_y0, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x0, (factor>>int(1))):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				east_vertex_count+=1
		indexoffset = 0
		southeastcorner = i+h1
		for y in range(0, 1):
			indices.push_back(i)
			indices.push_back(i+w+indexoffset)
			indices.push_back(southeastcorner)
			indices.push_back(i)
			indices.push_back(i+w+1+indexoffset)
			indices.push_back(i+w+indexoffset)
			for x in range(0, w-2):
				indices.push_back(i)
				indices.push_back(i+w+2+indexoffset)
				indices.push_back(i+w+1+indexoffset)
				indices.push_back(i)
				indices.push_back(i+w+3+indexoffset)
				indices.push_back(i+w+2+indexoffset)
				indices.push_back(i)
				indices.push_back(i+1)
				indices.push_back(i+w+3+indexoffset)
				indexoffset+=1
				i += 1
		indices.push_back(i)
		indices.push_back(i+w+2+indexoffset)
		indices.push_back(i+w+1+indexoffset)
		indexoffset+=1
		indices.push_back(i)
		indices.push_back(i+w+2+indexoffset)
		indices.push_back(i+w+1+indexoffset)
		
		i+=1
	
	
	
	if(east_edge==1):
		for y in range(max_y, max_y0, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x0, factor):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				east_vertex_count+=1
		southeastcorner = i+h1
		indices.push_back(i)
		indices.push_back(i+w)
		indices.push_back(southeastcorner)
		for y in range(0, 1):
			for x in range(1, h1):
				indices.push_back(i)
				indices.push_back(i+w+1)
				indices.push_back(i+w)
				indices.push_back(i)
				indices.push_back(i+1)
				indices.push_back(i+w+1)
				i += 1
			indices.push_back(i)
			indices.push_back(i+w+1)
			indices.push_back(i+w)
			i += 1

	if(east_edge==2):
		for y in range(max_y, max_y0, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x0, factor<<int(1)):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				east_vertex_count+=1
		half_index_east = false
		indexoffset = 0
		southeastcorner = i+h1
		for y in range(0, 1):
			for x in range(0, h1):
				if (half_index_east==false):
					indices.push_back(i)
					indices.push_back(i+w-indexoffset)
					indices.push_back(i+h1-indexoffset)
					indices.push_back(i)
					indices.push_back(i+1)
					indices.push_back(i+w-indexoffset)
					half_index_east=true
				elif(half_index_east==true):
					indices.push_back(i)
					indices.push_back(i+1)
					indices.push_back(i+h1-indexoffset)
					half_index_east=false
					indexoffset+=1
				i += 1
		

	northeastcorner = i + east_vertex_count - 1
	northwestcorner = i + east_vertex_count
	if (north_edge==0):
		for y in range(y0, max_y, (factor>>int(1))):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			vertices.push_back(Vector3(max_x-x0, hrow[max_x], y-y0))
			uv.push_back(Vector2(max_x, y) * uv_scale)
			colors.push_back(crow[max_x])
			normals.push_back(nrow[max_x])
			north_vertex_count+=1
		var rowcounter = 1
		
		i = i + east_vertex_count +1
		indices.push_back(i)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i-1)
		i+=1
		indices.push_back(i)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i-1)
		i+=1
		for y in range(0, h0):
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			indices.push_back(i-1)
			i+=1
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			indices.push_back(i-1)
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1)+h1)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			rowcounter+=1
			i += 1
		indices.push_back(i)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i-1)
		indices.push_back(northeastcorner)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i)



	if (north_edge==1):
		for y in range(y0, max_y, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			vertices.push_back(Vector3(max_x-x0, hrow[max_x], y-y0))
			uv.push_back(Vector2(max_x, y) * uv_scale)
			colors.push_back(crow[max_x])
			normals.push_back(nrow[max_x])
			north_vertex_count+=1
		
		var rowcounter = 1
		
		i = i + east_vertex_count +1
		
		indices.push_back(i)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i-1)
		i+=1
		for y in range(0, h0):
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			indices.push_back(i-1)
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1)+h1)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			rowcounter+=1
			i += 1
		indices.push_back(i-1)
		indices.push_back(northeastcorner)
		indices.push_back((h0*rowcounter)+(rowcounter-1))





	if (north_edge==2):
		for y in range(y0, max_y0, factor<<int(1)):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			vertices.push_back(Vector3(max_x-x0, hrow[max_x], y-y0))
			uv.push_back(Vector2(max_x, y) * uv_scale)
			colors.push_back(crow[max_x])
			normals.push_back(nrow[max_x])
			north_vertex_count+=1
		half_index_north = false
		indexoffset = 0
		var rowcounter = 1
		
		i = i + east_vertex_count +1
		for y in range(0, ((h>>int(1))-1)):
			
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			indices.push_back(i-1)
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1)+h1)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			rowcounter+=1
			indices.push_back(i)
			indices.push_back((h0*rowcounter)+(rowcounter-1)+h1)
			indices.push_back((h0*rowcounter)+(rowcounter-1))
			rowcounter+=1
			indexoffset+=1
			i += 1
		indices.push_back(i)
		indices.push_back((h0*rowcounter)+(rowcounter-1))
		indices.push_back(i-1)
		indices.push_back(i)
		indices.push_back(northeastcorner)
		indices.push_back((h0*rowcounter)+(rowcounter-1))

	i = northeastcorner + north_vertex_count + 2
	southwestcorner = i-1

	if(west_edge==0):
		for y in range(y0, y0+1, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x, (factor>>int(1))):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				west_vertex_count+=1
		
		indexoffset = 0
		for x in range(0, h0):
			indices.push_back(i)
			indices.push_back(indexoffset)
			indices.push_back(i-1)
			i += 1
			indices.push_back(i)
			indices.push_back(indexoffset)
			indices.push_back(i-1)
			indices.push_back(i)
			indices.push_back(indexoffset+1)
			indices.push_back(indexoffset)
			indexoffset+=1
			i += 1
		
		for a in range(0, 2):
			indices.push_back(i)
			indices.push_back(indexoffset)
			indices.push_back(i-1)
			i+=1
		indices.push_back(northwestcorner)
		indices.push_back(indexoffset)
		indices.push_back(i-1)
	

	if(west_edge==1):
		for y in range(y0, y0+1, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x, factor):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				west_vertex_count+=1
		
		indexoffset=0
		for x in range(0, h0):
			indices.push_back(i)
			indices.push_back(indexoffset+1)
			indices.push_back(indexoffset)
			indices.push_back(i)
			indices.push_back(indexoffset)
			indices.push_back(i-1)
			indexoffset+=1
			i += 1
		indices.push_back(i)
		indices.push_back(indexoffset)
		indices.push_back(i-1)
		indices.push_back(northwestcorner)
		indices.push_back(indexoffset)
		indices.push_back(i)
	
	if(west_edge==2):
		for y in range(y0, y0+1, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, max_x, factor<<int(1)):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
				west_vertex_count+=1
		
		indexoffset = 0
		for y in range(0, 1):
			for x in range(0, (h/2)-2):
				indices.push_back(i)
				indices.push_back(indexoffset)
				indices.push_back(i-1)
				indices.push_back(i)
				indices.push_back(indexoffset+1)
				indices.push_back(indexoffset)
				indexoffset+=1
				indices.push_back(i)
				indices.push_back(indexoffset+1)
				indices.push_back(indexoffset)
				indexoffset+=1
				i+=1
			indices.push_back(i)
			indices.push_back(indexoffset)
			indices.push_back(i-1)
			indices.push_back(i)
			indices.push_back(indexoffset+1)
			indices.push_back(indexoffset)
			indexoffset+=1
			indices.push_back(i)
			indices.push_back(indexoffset+1)
			indices.push_back(indexoffset)
			indexoffset+=1
			indices.push_back(northwestcorner)
			indices.push_back(indexoffset)
			indices.push_back(i)

	i+=1
	if (south_edge==0):
		for y in range(y0+(factor>>int(1)), max_y, factor>>int(1)):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, x0+1, factor):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
		
		rowcounter = 0
		indices.push_back(i)
		indices.push_back(southwestcorner)
		indices.push_back(rowcounter)
		i+=1
		indices.push_back(i)
		indices.push_back(i-1)
		indices.push_back(rowcounter*h1)
		rowcounter+=1

		for y in range(0, w-3):
			indices.push_back(i)
			indices.push_back((rowcounter-1)*h1)
			indices.push_back(rowcounter*h1)
			i+=1
			indices.push_back(i)
			indices.push_back(i-1)
			indices.push_back(rowcounter*h1)
			i+=1
			indices.push_back(i)
			indices.push_back(i-1)
			indices.push_back(rowcounter*h1)
			rowcounter+=1
		indices.push_back(i)
		indices.push_back((rowcounter-1)*h1)
		indices.push_back(rowcounter*h1)
		i+=1
		for a in range (0,2):
			indices.push_back(i)
			indices.push_back(i-1)
			indices.push_back(rowcounter*h1)
			i+=1
		indices.push_back(i)
		indices.push_back(i-1)
		indices.push_back(rowcounter*h1)
		indices.push_back(i)
		indices.push_back((rowcounter)*h1)
		indices.push_back(southeastcorner)
	
	if (south_edge==1):
		for y in range(y0+factor, max_y, factor):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, x0+1, factor):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
		
		rowcounter = 0
		indices.push_back(i)
		indices.push_back(southwestcorner)
		indices.push_back(rowcounter)
		rowcounter+=1
		indices.push_back(i)
		indices.push_back((rowcounter-1)*h1)
		indices.push_back(rowcounter*h1)
		i+=1

		for y in range(0, w-3):
			indices.push_back(i)
			indices.push_back(i-1)
			indices.push_back((rowcounter)*h1)
			i+=1
			rowcounter+=1
			indices.push_back(i-1)
			indices.push_back((rowcounter-1)*h1)
			indices.push_back((rowcounter)*h1)
		indices.push_back(i)
		indices.push_back(i-1)
		indices.push_back((rowcounter)*h1)
		indices.push_back(i)
		indices.push_back((rowcounter)*h1)
		indices.push_back(southeastcorner)
	
	if (south_edge==2):
		for y in range(y0+(2*factor), max_y, factor<<int(1)):
			var hrow = input_heights[y]
			var crow = input_colors[y]
			var nrow = input_normals[y]
			for x in range(x0, x0+1, factor):
				vertices.push_back(Vector3(x-x0, hrow[x], y-y0))
				uv.push_back(Vector2(x, y) * uv_scale)
				colors.push_back(crow[x])
				normals.push_back(nrow[x])
		
		rowcounter = 0
		indices.push_back(i)
		indices.push_back(southwestcorner)
		indices.push_back(rowcounter)
		rowcounter+=1
		indices.push_back(i)
		indices.push_back((rowcounter-1)*h1)
		indices.push_back(rowcounter*h1)
		rowcounter+=1

		for y in range(0, w-10):
			indices.push_back(i)
			indices.push_back((rowcounter-1)*h1)
			indices.push_back(rowcounter*h1)
			i+=1
			indices.push_back(i)
			indices.push_back(i-1)
			indices.push_back(rowcounter*h1)
			rowcounter+=1
			indices.push_back(i)
			indices.push_back((rowcounter-1)*h1)
			indices.push_back((rowcounter)*h1)
			rowcounter+=1
		indices.push_back(i)
		indices.push_back((rowcounter-1)*h1)
		indices.push_back((rowcounter)*h1)
		indices.push_back(i)
		indices.push_back((rowcounter)*h1)
		indices.push_back(southeastcorner)
	
	var arrays = []
	arrays.resize(9)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uv
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh = Mesh.new()
	mesh.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
		
	return mesh

# Separating in two functions kinda sucks, but:
# 1) Vertices are laid out differently in faceted shading
# 2) SurfaceTool calculates normals for us
# 3) In GDScript that's a faster solution
static func make_heightmap_faceted(heights, colors, x0, y0, w, h):
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#st.add_smooth_group(true)
	
	var max_y = y0 + w
	var max_x = x0 + h
	
	var terrain_size_x = heights.size()-1
	var terrain_size_y = 0
	if heights.size() > 0:
		terrain_size_y = heights[0].size()-1
	
	if max_y >= terrain_size_y:
		max_y = terrain_size_y
	if max_x >= terrain_size_x:
		max_x = terrain_size_x
	
	var uv_scale = Vector2(1.0/terrain_size_x, 1.0/terrain_size_y)
	
	for y in range(y0, max_y):
		
		var row = heights[y]
		var color_row = colors[y]
		
		for x in range(x0, max_x):
			
			var p00 = Vector3(x-x0, row[x], y-y0)
			var p10 = Vector3(x+1-x0, row[x+1], y-y0)
			var p01 = Vector3(x-x0, heights[y+1][x], y+1-y0)
			var p11 = Vector3(x+1-x0, heights[y+1][x+1], y+1-y0)
			
			var uv00 = Vector2(x, y) * uv_scale
			var uv10 = Vector2(x+1, y) * uv_scale
			var uv11 = Vector2(x+1, y+1) * uv_scale
			var uv01 = Vector2(x, y+1) * uv_scale
			
			var c00 = color_row[x]
			var c10 = color_row[x+1]
			var c01 = colors[y+1][x]
			var c11 = colors[y+1][x+1]
			
			st.add_uv(uv00)
			st.add_color(c00)
			st.add_vertex(p00)
			
			st.add_uv(uv10)
			st.add_color(c10)
			st.add_vertex(p10)
			
			st.add_uv(uv11)
			st.add_color(c11)
			st.add_vertex(p11)
			
			st.add_uv(uv00)
			st.add_color(c00)
			st.add_vertex(p00)
			
			st.add_uv(uv11)
			st.add_color(c11)
			st.add_vertex(p11)
			
			st.add_uv(uv01)
			st.add_color(c01)
			st.add_vertex(p01)
	
	st.generate_normals()
	
	#st.index()
	var mesh = st.commit()
	return mesh
