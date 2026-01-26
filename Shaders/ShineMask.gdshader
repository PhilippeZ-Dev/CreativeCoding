shader_type canvas_item;

const float frame_count = 17.0;

uniform uint _shine_speed = 20;

uniform bool _animated = false;
uniform sampler2D _base_texture:filter_nearest;
uniform sampler2D _shine_texture:filter_nearest;
uniform sampler2D _mask_array:filter_nearest;

uniform sampler2D _arrow_array:filter_nearest;
uniform sampler2D _arrow_shine_array:filter_nearest;


vec2 flipbook(vec2 uv, vec2 size, float progress){
	progress = floor( mod(progress, (size.x * size.y)) );
	vec2 frame_size = vec2(1.0, 1.0) / vec2(size.x, size.y);
	vec2 frame = fract(uv / size) + frame_size;
	
	frame.x += ( (progress / size.x) - frame_size.x * floor(progress/size.x) * size.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/size.x) ) - frame_size.y ;
	
	return frame;
}

void fragment() 
{
	vec2 mask_size = vec2(frame_count, 1.0);
	vec2 arrow_size = vec2(12.0, 1.0);
	
	vec4 _base_color = texture(_base_texture, UV);
	vec4 _shine_color = texture(_shine_texture, UV);
	
	vec2 arrow_UV = flipbook(UV, arrow_size, floor(TIME * float(_shine_speed)));
	vec4 _arrow_color = texture(_arrow_array, arrow_UV);
	vec4 _arrow_shine_color = texture(_arrow_shine_array, arrow_UV);
	
	vec2 mask_UV = flipbook(UV, mask_size, floor(TIME * float(_shine_speed)));
	vec4 _mask_color = texture(_mask_array, mask_UV);
	
	vec4 col = vec4(1.0,0.0,1.0,1.0);
	vec4 white = vec4(1.0,1.0,1.0,1.0);
	
	if(distance(_mask_color, white) <= .1f)
	{
		if(!_animated)
		{col = _shine_color;}
		else
		{col = _arrow_shine_color;}
	}
	else
	{
		if(!_animated)
		{col = _base_color;}
		else
		{col = _arrow_color;}
	}
	
	COLOR = col;
}