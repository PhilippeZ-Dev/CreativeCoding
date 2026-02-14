/********************************************************************
*	SOURCES:														*
*		michaelwalczyk.com/blog-ray-marching.html					*
*		https://iquilezles.org/articles/distfunctions/				*
*********************************************************************/

shader_type canvas_item;

group_uniforms Color;
uniform vec3 _color : source_color = vec3(0.91, 0.333, 0.373);
uniform vec3 _backgroundColor : source_color = vec3(0);
uniform sampler2D _gradient;

group_uniforms Camera;
uniform vec3 _cameraPosition = vec3(0.0,0.0,-5.0);
uniform vec3 _cameraRotation = vec3(0.0);

group_uniforms Light;
uniform float _lightStrength = 1.0;
uniform vec3 _lightPos = vec3(2.0, -5.0, 3.0);
uniform vec3 _lightColor : source_color = vec3(1.0);

group_uniforms Shape_Transform;
uniform vec3 _shapeRotation = vec3(0);
uniform float _shapeLerp : hint_range(0.0, 1.0) = 0.5;

group_uniforms Animation;
uniform float _timeScale = .5;

mat2 Rotate(float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return mat2(vec2(c, -s), vec2(s,c));
}

vec3 ApplyCameraRotation(vec3 rayDir, vec3 rotation)
{
	vec3 rd = rayDir;
	rd.xy *= Rotate(rotation.z);
	rd.yz *= Rotate(rotation.x);
	rd.xz *= Rotate(rotation.y);
	
	return rd;
}

float MixShapes(float a, float b, float m)
{
	float time = (cos(TIME * _timeScale*2.0)+1.0)/2.0;
	return mix(a, b, time);
}
////////////////////////////////////////////////////////////////////////////////////////////////////
// p: point in space
// c: center of sphere
// r: radius of sphere
float sdSphere(vec3 p, vec3 c, float r)
{
	return length(p-c)-r;
}

float sdBox(vec3 p, vec3 b)
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MapScene(vec3 pos)
{
	// rotate all the shapes according to a rotation uniform
	vec3 shapeRotation = _shapeRotation;
	shapeRotation.y += mod(TIME*_timeScale, 6.283185);
	
	pos.xz *= Rotate(shapeRotation.y);
    pos.yz *= Rotate(shapeRotation.x);
    pos.xy *= Rotate(shapeRotation.z);
	
	float displacement = cos(TIME )*.1 + sin(5.0*pos.x) * sin(5.0*pos.y) * sin(5.0*pos.z) * 0.25;	
	
	float sphere_0 = sdSphere(pos,  vec3(0), 1);
	float box_0 = sdBox(pos, vec3(.5));
	
	float time = (cos(TIME) *2.0 -1.0) * _timeScale;
	float shape = MixShapes(sphere_0, box_0, _shapeLerp);
	
	return shape;
	//return sphere_0;// + displacement;
}

vec3 GetShapeColor()
{
	//float time = (cos(TIME)+1.0)/2.0 * _timeScale;
	
	//vec3 gradient = texture(_gradient, vec2(fract(TIME * _timeScale), 0)).xyz;
	//return gradient;
	
	return _color;
}

vec3 CalculateNormal(vec3 p)
{
	const vec3 smallStep = vec3(0.001, 0.0, 0.0);
	float gradient_x = MapScene(p + smallStep.xyy) - MapScene(p - smallStep.xyy);
	float gradient_y = MapScene(p + smallStep.yxy) - MapScene(p - smallStep.yxy);
	float gradient_z = MapScene(p + smallStep.yyx) - MapScene(p - smallStep.yyx);
	
	vec3 normal = vec3(gradient_x, gradient_y, gradient_z);
	
	return normalize(normal);
}

float CalculateLightIntensity(vec3 pos, vec3 norm)
{
	vec3 directionToLight = normalize(pos - _lightPos);
	return max(0, dot(norm, directionToLight));
}

vec3 RayMarch(vec3 ro, vec3 rd)
{
	float totaldistanceTraveled = 0.0;
	const int NumberOfSteps = 32;
	const float MinimumHitDistance = .001;
	const float MaximumTraceDistance = 1000.0;
	
	for(int i = 0; i < NumberOfSteps; ++i)
	{
		// calculate current position along ray
		vec3 currentPos = ro + totaldistanceTraveled * rd;
		
		// we assume that the sphere is centered at the origin and the radius is 1
		//float distanceToClosest = DistanceFromSphere(currentPos, vec3(0), 1.0);
		float distanceToClosest = MapScene(currentPos);
		
		if(distanceToClosest < MinimumHitDistance)
		{
			// return color if we hit something
			vec3 normal = CalculateNormal(currentPos);
			
			return GetShapeColor() * CalculateLightIntensity(currentPos, normal);
		}
		
		// miss
		if(totaldistanceTraveled > MaximumTraceDistance)
		{
			break;
		}
		// accumulate the distance traveled
		totaldistanceTraveled += distanceToClosest;
	}
	
	// if we got here, we hit nothing and return the backgroundcolor
	return _backgroundColor;
}

void fragment()
{
	vec2 uv = UV *2.0 -1.0;
	
	vec3 cameraPosition = _cameraPosition;
	vec3 ro = cameraPosition;	// ray origin
	vec3 rd = normalize(vec3(uv,1.0));		// ray direction
	rd = ApplyCameraRotation(rd, _cameraRotation);
	
	vec3 shadedRay = RayMarch(ro, rd) * _lightColor * _lightStrength;
	
	COLOR = vec4(shadedRay, 1.0);
}