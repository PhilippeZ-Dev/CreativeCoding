shader_type canvas_item;

struct Sphere
{
	vec3 center;
	float radius;
};

Sphere MakeSphere(vec3 center, float radius)
{
	Sphere sphere;
	sphere.center  = center;
	sphere.radius = radius;
	return sphere;
}

uniform vec3 _color : source_color = vec3(1.0,0.0,0.0);
uniform vec3 _cameraPosition = vec3(0.0,0.0,-5.0);
uniform vec3 _lightPos = vec3(2.0, -5.0, 3.0);

// p: point in space
// c: center of sphere
// r: radius of sphere
float _DistanceFromSphere(vec3 p, vec3 c, float r)
{
	return length(p-c)-r;
}

float DistanceFromSphere(vec3 p, Sphere s)
{
	return length(p-s.center)-s.radius;
}

float MapTheWorld(vec3 pos)
{
	float sphere_0 = _DistanceFromSphere(pos,  vec3(0), 1);
	
	// add other spheres
	
	return sphere_0;
}

vec3 CalculateNormal(vec3 p)
{
	const vec3 smallStep = vec3(0.001, 0.0, 0.0);
	float gradient_x = MapTheWorld(p + smallStep.xyy) - MapTheWorld(p - smallStep.xyy);
	float gradient_y =  MapTheWorld(p + smallStep.yxy) - MapTheWorld(p - smallStep.yxy);
	float gradient_z =  MapTheWorld(p + smallStep.yyx) - MapTheWorld(p - smallStep.yyx);
	
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
		//float distanceToClosest = _DistanceFromSphere(currentPos, vec3(0), 1.0);
		float distanceToClosest = MapTheWorld(currentPos);
		
		if(distanceToClosest < MinimumHitDistance)
		{
			// return color if we hit something
			vec3 normal = CalculateNormal(currentPos);
			return _color * CalculateLightIntensity(currentPos, normal);
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
	return vec3(0);
}

void fragment()
{
	vec2 uv = UV *2.0 -1.0;
	
	vec3 cameraPosition = _cameraPosition;
	vec3 ro = cameraPosition;
	vec3 rd = vec3(uv,1.0);
	
	vec3 shadedRay = RayMarch(ro, rd);
	
	COLOR = vec4(shadedRay, 1.0);
}