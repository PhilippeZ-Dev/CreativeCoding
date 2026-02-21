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

// used to smoth the lighting
float AlmostIdentity( float x, float m, float e ) // https://iquilezles.org/articles/functions/
{
	if(x>m) return x;
	float a = 2.0*e - m;
	float b = 2.0*m - 3.0*e;
	float t = x/m;
	return (a*t+b)*t*t + e;
}