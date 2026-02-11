shader_type canvas_item;

uniform int iterations = 50;
uniform sampler2D gradient;
// Zoom level
uniform float zoom = 2.0;

uniform vec2 roots[3];

vec2 complex_mul(vec2 a, vec2 b) 
{
	return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}
vec2 complex_div(vec2 a, vec2 b)
{
	float den = dot(b, b);
	return vec2(dot(a, b), a.y * b.x - a.x * b.y) / den;
}

void fragment() 
{
	// Map UV coordinates (0 to 1) to complex plane (-zoom to +zoom)
	vec2 z = (UV - 0.5) * 2.0 * zoom;
	
	vec2 root1 = roots[0];
	vec2 root2 = roots[1];
	vec2 root3 = roots[2];
	
	for (int i = 0; i < iterations; i++) {
	    // z = z - f(z) / f'(z)
	    // For f(z) = z^3 - 1, f'(z) = 3z^2
	    vec2 z2 = complex_mul(z, z);
	    vec2 z3 = complex_mul(z2, z);
	    
	    vec2 f_z = z3 - vec2(1.0, 0.0);
	    vec2 df_z = 3.0 * z2;
	    
	    z = z - complex_div(f_z, df_z);
	}
	
	// Color the pixel based on which root it landed closest to
	float d1 = length(z - root1);
	float d2 = length(z - root2);
	float d3 = length(z - root3);
	
	if (d1 < d2 && d1 < d3) 
	{
		COLOR = texture(gradient, vec2(0,0));
	} 
	else if (d2 < d3) 
	{
        COLOR = texture(gradient, vec2(.5,0));
	}
	else 
	{
		COLOR = texture(gradient, vec2(1,0));
	}
}