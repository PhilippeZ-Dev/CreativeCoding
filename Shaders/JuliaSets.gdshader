shader_type canvas_item;

uniform bool isPortrait = false;

uniform vec2 c = vec2(-0.7, 0.27);

uniform vec2 offset = vec2(0.0, 0.0);
uniform float zoom = 1.0;
//uniform float speed = 0.5;
uniform int iterations = 300;
uniform sampler2D gradient;

vec2 Mandelbrot(vec2 input, vec2 C)
{
	vec2 output;
	
	float x = (input.x * input.x - input.y * input.y) + C.x;
	float y = (2.0 * input.x * input.y) + C.y;
	
	output = vec2(x,y);
	
	return output;
}

vec2 BurningShip(vec2 input, vec2 C)
{
	vec2 output;
	
	vec2 absolute = abs(input);
	
	float x = (absolute.x * absolute.x - absolute.y * absolute.y) + C.x;
	float y = (2.0 * absolute.x * absolute.y) + C.y;
	
	output = vec2(x,y);
	
	return output;
}

void fragment() 
{
	float aspect = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    vec2 uv = (UV - 0.5);
    uv.y *= aspect;
	vec2 portraitUV = vec2(UV.y, 1.0 - UV.x);
	portraitUV -= 0.5;
	portraitUV.y *= aspect;
	
	vec2 z = vec2(0.0,0.0);
	if(isPortrait)
	{
		z = (portraitUV/zoom) + offset;
	}
	else
	{
		z = (uv/zoom) + offset;
	}
	
	
	int iter = 0;
	for(int i  = 0; i < iterations; i++)
	{
		z = Mandelbrot(z, c);
		//z = BurningShip(z, c);
		
		if(length(z) > 2.0)
		{
			break;
		}
		iter++;
	}
	
	
	//float orbit = 1000.0; // Start with a huge number
	//for (int i = 0; i < iterations; i++) 
	//{
		////z = Mandelbrot(z, c);
		//z = BurningShip(z, c); 
		//
		//// Orbit Trap: track the minimum distance to the origin
		//orbit = min(orbit, length(z)); 
		//
		//if (length(z) > 2.0) break;
		//iter++;
	//}

	//if (iter == iterations) 
	//{
		//// Instead of solid black, use the 'orbit' value
		//float strength = exp(-orbit); // Exponential falloff looks best
		//COLOR = vec4(vec3(strength * 0.5), 1.0); // Creates a soft internal glow
	//}
	//
	//
	////if(iter == iterations)
	////{
		//////COLOR = vec4(0.0,0.0,0.0,1.0);
		////float edge = clamp(1.0 - (length(z) / 2.0), 0.0, 1.0);
    	////COLOR = vec4(vec3(edge * 0.2), 1.0);
	////}
	//else
	{
		float dist = length(z);
		float smoothIter = float(iter) + 1.0 - log2(log2(dist));
		float t = smoothIter / 40.0;
		
		COLOR = texture(gradient, vec2(fract(t), 0.0));
	}
}