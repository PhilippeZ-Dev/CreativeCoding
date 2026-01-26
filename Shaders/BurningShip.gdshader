shader_type canvas_item;

uniform vec2 offset = vec2(-0.5, 0.0); 
uniform float zoom = 1.0;  
uniform float zoomSpeed = 0.0;
uniform int iterations = 200;          

uniform sampler2D gradient;

vec2 BurningShip(vec2 input, vec2 uv)
{
	vec2 output;
	
	vec2 absolute = abs(input);
	
	float x = (absolute.x * absolute.x - absolute.y * absolute.y) + uv.x;
	float y = (2.0 * absolute.x * absolute.y) + uv.y;
	
	output = vec2(x,y);
	
	return output;
}

void fragment() 
{
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	
	float zoomIn = 0.0;
	zoomIn = zoom + (pow(TIME, zoomSpeed));
	
	//vec2 uv = (UV - 0.5) * vec2(1.5, 1.0) / zoomIn + offset;
	
	vec2 adjustedUV = (UV - 0.5);
    adjustedUV.y *= aspect_ratio;
	vec2 adjustedOffset = vec2(offset.x, offset.y / aspect_ratio);
    
    vec2 uv = adjustedUV / zoomIn + adjustedOffset;
	
	

	vec2 z = vec2(0.0);
	int iter = 0;
    for (int i = 0; i < iterations; i++)
	{   
        z = BurningShip(z, uv);
		
		if (length(z) > 2.0)
		{
			break;
		}
		iter++;
	}
	
	
	//if (iter == iterations)
	//{
		//// Points inside the set are black
		//COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	//} 
	//else
	{
		float t = float(iter) / float(iterations);
		vec4 sample = texture(gradient, vec2(t,0));
		COLOR = sample;
	}
}