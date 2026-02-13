shader_type canvas_item;

uniform int iterations = 50;
uniform sampler2D gradient;

const vec2 center = vec2(0.5,0.5); // UV center

// Zoom level
uniform float zoom = 2.0;
uniform float speed = 0.5;
uniform float rotation = 0.0;
uniform float rotationSpeed =0.5;

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

vec2 Rotate(vec2 point, vec2 anchor, float angle)
{
	vec2 output;
	output.x = ((point.x - anchor.x)*cos(angle)) - ((point.y - anchor.y)*sin(angle)) + anchor.x;
	output.y = ((point.x - anchor.x)*sin(angle)) - ((point.y - anchor.y)*cos(angle)) + anchor.y;
	return output;
}

void fragment() 
{
	// Map UV coordinates (0 to 1) to complex plane (-zoom to +zoom)
	float angle = rotation + (TIME * rotationSpeed);
	float zoomIn = zoom - (TIME * speed);
	vec2 uv = Rotate(UV, center, angle);
	vec2 z = (uv - 0.5) * 2.0 * zoomIn;
	
	
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