tool # ONLY because Godot doesn't report errors if I omit it ><'
const Util = preload("terrain_utils.gd")
const Terrain = preload("terrain.gd")

const MODE_ADD = 0
const MODE_SUBTRACT = 1
const MODE_SMOOTH = 2
const MODE_FLATTEN = 3
const MODE_TEXTURE = 4
const MODE_COUNT = 5


var _data = [] # TODO Should be renamed "_shape"
var _modulate = 1.0
var _radius = 4
var _opacity = 1.0 # TODO Should be renamed "hardness"
var _sum = 0.0
var _mode = MODE_ADD
#var _mode_secondary = MODE_SUBTRACT
var _channel = Terrain.DATA_HEIGHT
var _source_image = null
var _use_undo_redo = false
var _flatten_height = 0.0


func _init():
	# So that it works even if no brush textures exist at all
	generate(_radius)


func generate(radius):
	if _source_image == null:
		generate_procedural(radius)
	else:
		generate_from_image(_source_image, radius)


func generate_procedural(radius):
	_radius = radius
	var size = 2*radius
	_data = Util.create_grid(size, size, 0)
	_sum = 0
	for y in range(-radius, radius):
		for x in range(-radius, radius):
			var d = Vector2(x,y).distance_to(Vector2(0,0)) / float(radius)
			var v = clamp(1.0 - d*d*d, 0.0, 1.0)
			_data[y+radius][x+radius] = v
			_sum += v


func generate_from_image(image, radius=-1):
	radius = int(round(radius))
	
	if image.get_width() != image.get_height():
		print("Brush shape image must be square!")
		return
	
	_source_image = image
	
	if radius < 0:
		radius = _radius
	else:
		_radius = radius
	
	var size = radius*2
	if size != image.get_width():
		image = image.resized(size, size, Image.INTERPOLATE_BILINEAR)
	
	_data = Util.create_grid(image.get_width(), image.get_height(), 0)
	_sum = 0
	
	for y in range(0, image.get_height()):
		for x in range(0, image.get_width()):
			var color = image.get_pixel(x,y)
			var h = color.a
			_data[y][x] = h
			_sum += h


func set_radius(r):
	r = int(round(r))
	if r > 0 and r != _radius:
		_radius = r
		generate(r)

func get_radius():
	return _radius


func set_opacity(opacity):
	_opacity = clamp(opacity, 0.0, 2.0)


func set_mode(mode):
	assert(mode >= 0 and mode < MODE_COUNT)
	_mode = mode
	if _mode == MODE_TEXTURE:
		_channel = Terrain.DATA_COLOR
	else:
		_channel = Terrain.DATA_HEIGHT


func get_channel():
	return _channel


func get_mode():
	return _mode


func set_modulate(m):
	_modulate = m


func set_flatten_height(h):
	_flatten_height = h

func get_flatten_height():
	return _flatten_height


func set_undo_redo(use_undo_redo):
	_use_undo_redo = use_undo_redo


func paint_world_pos(terrain, wpos, override_mode=-1, channel=0):
	var cell_pos = terrain.world_to_cell_pos(wpos)
	var delta = _opacity * 1.0/60.0
	
	var mode = _mode
	if override_mode != -1:
		mode = override_mode
	
	# Safety checks
	assert(!(_channel == Terrain.DATA_COLOR and typeof(_modulate) != TYPE_COLOR))
	
	# We really want integers, even if floats can contain them fine,
	# because any further calculations on these coordinates
	# could introduce biases or decimals!
	# https://github.com/godotengine/godot/issues/3286
	var x = int(round(cell_pos.x))
	var y = int(round(cell_pos.y))

	if mode == MODE_ADD:
		_paint_height(terrain, x, y, 50.0*delta)
	
	elif mode == MODE_SUBTRACT:
		_paint_height(terrain, x, y, -50*delta)
		
	elif mode == MODE_SMOOTH:
		_smooth_height(terrain, x, y, 4.0*delta)
	
	elif mode == MODE_FLATTEN:
		_flatten_height(terrain, x, y, _flatten_height)
	
	elif mode == MODE_TEXTURE:
		_paint_texture(terrain, x, y, _modulate)
	
	else:
		error("Unknown paint mode " + str(mode))


func _foreach_xy(terrain, tx0, ty0, operator, channel, modifier=true):
	if modifier:
		terrain.set_area_dirty(tx0, ty0, _radius, _use_undo_redo, channel)
	
	var data = terrain.get_data_channel(channel)
	var brush_radius = _data.size()/2
	
	operator.dst = data
	
	for by in range(0, _data.size()):
		var brush_row = _data[by]
		for bx in range(0, brush_row.size()):
			var brush_value = brush_row[bx]
			var tx = tx0 + bx - brush_radius
			var ty = ty0 + by - brush_radius
			# TODO We could get rid if this `if` by calculating proper bounds beforehands
			if terrain.cell_pos_is_valid(tx, ty):
				operator.exec(tx, ty, brush_value)

# TODO Update this part when Godot will support lambdas

class Operator:
	var dst = null
	var opacity = 1.0

class AddOperator extends Operator:
	var factor = 1.0
	func exec(x, y, value):
		dst[y][x] = dst[y][x] + factor * value

class LerpOperator extends Operator:
	var target_value = 0.0
	func exec(x, y, value):
		dst[y][x] = lerp(dst[y][x], target_value, value * opacity)

class LerpOperatorColor extends Operator:
	var target_value = Color(1,1,1,1)
	func exec(x, y, value):
		dst[y][x] = dst[y][x].linear_interpolate(target_value, value * opacity)

class SumOperator extends Operator:
	var sum = 0.0
	func exec(x, y, value):
		sum += dst[y][x] * value


func _paint_height(terrain, tx0, ty0, factor=1.0):
	var op = AddOperator.new()
	op.factor = factor
	_foreach_xy(terrain, tx0, ty0, op, _channel)


func _flatten_height(terrain, tx0, ty0, height):
	var op = LerpOperator.new()
	op.target_value = height
	op.opacity = clamp(_opacity, 0.0, 1.0)
	_foreach_xy(terrain, tx0, ty0, op,  _channel)


func _smooth_height(terrain, tx0, ty0, factor=1.0):
	var sum_op = SumOperator.new()
	_foreach_xy(terrain, tx0, ty0, sum_op, _channel, false)
	
	var lerp_op = LerpOperator.new()
	lerp_op.target_value = sum_op.sum / _sum
	lerp_op.opacity = clamp(_opacity, 0.0, 1.0)
	_foreach_xy(terrain, tx0, ty0, lerp_op, _channel)


func _paint_texture(terrain, tx0, ty0, factor=Color(1,1,1,1)):
	var op = LerpOperatorColor.new()
	op.target_value = factor
	op.opacity = clamp(_opacity, 0.0, 1.0)
	_foreach_xy(terrain, tx0, ty0, op, _channel)
