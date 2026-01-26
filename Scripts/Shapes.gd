extends Node2D

var screenSize:Vector2i = DisplayServer.window_get_size()

@export var drawShape:bool = true

enum shapes {CIRCLES, CANTOR, KOCH, SIERPINSKI}
@export var shape:shapes

@export var center:Vector2i = Vector2i(screenSize.x/2,screenSize.y/2)
@export_group("Circles")
@export_range(1, 1360) var radius:int = 350
@export_range(2,349) var minRadius:int = 20
@export_range(2,10) var step:int = 2

@export_group("Cantor Set")
@export var spacing:int = 20

@export_group("Koch Fractal")
@export_range(1,5) var KochDepth:int = 1
@export var KochColor:Color = Color.AQUA

@export_group("Sierpinski")
@export var triangleSize:int = 400
@export_range(0,10) var sierpinskiDepth:int = 1
@export var sp_zoomSpeed:float = 1.0
var sp_currentZoom:float = 1.0

var triangles_rotated = []
var angle = 0
var speed = 500

func _ready():
	pass

var time = 0.0
func _process(delta: float) -> void:
	#sp_currentZoom += delta * sp_zoomSpeed
	#queue_redraw()
	pass

func _draw():
	#draw_set_transform(Vector2(center.x, center.y + 250), 0, Vector2(sp_currentZoom, sp_currentZoom))
	
	if drawShape:
		DrawShapes()
	else:
		pass

func DrawShapes():
	match shape:
		shapes.CIRCLES:
			DrawCircles(center, radius)
		shapes.CANTOR:
			Cantor(Vector2(0, center.y), screenSize.y)
		shapes.KOCH:
			KochFractal()
		shapes.SIERPINSKI:
			SierpinskiTriangle()

	for t in triangles_rotated:
		DrawTriangle(t.points)

func RandomColor():
	return Color.from_hsv(randf(), randf_range(.2,.6), randf_range(.8,1))

#region Draw shapes
func DrawCircle(pos:Vector2, radius:float):
	draw_arc(pos, radius, 0, PI*2, 100, RandomColor(), 1)
	
func DrawLine(start:Vector2, end:Vector2, color:Color):
	draw_line(start, end, color, 1)

func DrawKochLine(line:KochLine):
	draw_line(line.start,line.end, KochColor,1)	

func DrawTriangle(points):
	draw_polygon(points, [Color.YELLOW])#[RandomColor()])
#endregion

#region Basic Shapes
func DrawCircles(startPos:Vector2, radius:float):
	DrawCircle(startPos, radius)
	if radius > minRadius:
			DrawCircles(Vector2(startPos.x-(radius/step), startPos.y), radius/step)
			DrawCircles(Vector2(startPos.x+(radius/step), startPos.y), radius/step)
			
			DrawCircles(Vector2(startPos.x, startPos.y-(radius/step)), radius/step)
			DrawCircles(Vector2(startPos.x, startPos.y+(radius/step)), radius/step)

func Cantor(start:Vector2, length:int):
	if length > 0:
		DrawLine(start, Vector2(start.x+length, start.y), RandomColor())
		
		Cantor(Vector2(start.x, start.y+spacing), length/3)
		Cantor(Vector2(start.x+(2*length/3), start.y+spacing), length/3)
#endregion

#region Koch
func KochFractal():
	var segments = []
	var A:Vector2 = Vector2(0,center.y)
	var B:Vector2 = Vector2(screenSize.x, center.y)
	var C:Vector2 = Vector2(center.x, screenSize.y)
	
	segments.push_back(KochLine.new(A, B))
	#segments.push_back(KochLine.new(B, C))
	#segments.push_back(KochLine.new(C, A))
	
	for i in KochDepth:
		segments = KochFractalGenerate(segments)
	
	for s in segments:
		DrawKochLine(s)
	pass

func KochFractalGenerate(segments:Array):
	var next = []
	for s in segments:
		var points = s.KochPoints()
		next.push_back(KochLine.new(points[0], points[1]))
		next.push_back(KochLine.new(points[1], points[2]))
		next.push_back(KochLine.new(points[2], points[3]))
		next.push_back(KochLine.new(points[3], points[4]))
	return next

class KochLine:
	var start:Vector2
	var end:Vector2
	
	func _init(s:Vector2, e:Vector2):
		start = s
		end = e
	
	func KochPoints():
		var v:Vector2 = self.end - self.start
		v /= 3
		
		var a = self.start
		var b = a + v
		var d = b + v
		v = v.rotated(-PI/3)
		var c = b+v
		var e = self.end
		
		return [a,b,c,d,e]
		
		pass
#endregion

#region Sierpinksi
func SierpinskiTriangle():
	var triangles = []
	var triangle = Triangle.new(Vector2(0, screenSize.y), Vector2(center.x, 0), Vector2(screenSize.x, screenSize.y))
	var zoomingTriangle = Triangle.new(Vector2(0, - triangleSize), Vector2(-triangleSize, triangleSize), Vector2(triangleSize, triangleSize))
	triangles.push_back(triangle)
	
	for i in sierpinskiDepth:
		var next = []
		for t in triangles:
			var newTriangles = t.Breakdown()
			for nt in newTriangles:
				next.push_back(nt)
		triangles = next
	
	triangles_rotated = triangles
	
	for t in triangles:
		DrawTriangle(t.points)

class Triangle:
	var a:Vector2; var b:Vector2; var c:Vector2
	var points = [a,b,c]
	
	func _init(pa,pb,pc):
		self.a = pa; self.b = pb; self.c = pc
		points = [a,b,c]
	
	func Breakdown():
		var A = self.a; var B = self.b; var C = self.c
		var D = A+((B-A)/2)
		var E = B+((C-B)/2)
		var F = C+((A-C)/2)
		var trA:Triangle = Triangle.new(A,D,F)
		var trB:Triangle = Triangle.new(D,B,E)
		var trC:Triangle = Triangle.new(F,E,C)
		
		return([trA,trB,trC])
	
	func Rotate(theta:float):
		for p in points:
			p.x = (p.x * cos(theta)) - (p.y * sin(theta))
			p.y = (p.x * sin(theta)) + (p.y * cos(theta))
			
#endregion
