#include "res://Shaders/ShaderIncludes/MathUtils.gdshaderinc"

// p: point in space | c: center of sphere | r: radius of sphere
float sdSphere(vec3 p, vec3 c, float r)
{
	return length(p-c)-r;
}

float sdBox(vec3 p, vec3 b)
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdHeart(vec3 p, vec3 c, float r, float expansion, float hz_scale)
{
	float radius = r + expansion * pow(0.5 + 0.5* sin(2.0 * PI * TIME + (p.y/25.0)),4.0);
	vec3 point = p;
	float x = abs(p.x);
	x = AlmostIdentity(x, 0.5, 0.01);
	point.z = p.z * hz_scale;
	point.y = hz_scale * point.y + abs(x) * sqrt((20.0 - abs(x))/35.0);
	return length(point-c)-radius;
}