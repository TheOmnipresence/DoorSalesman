shader_type canvas_item;

uniform vec4 target_colors [6] : source_color;
uniform vec4 replace_colors [6] : source_color;

//uniform vec4 target_color : source_color;
//uniform vec4 replace_color : source_color; 
//uniform float tolerance : hint_range(0, 1); 
 
void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	for (int i = 0; i < target_colors.length(); i ++) {
		if (tex_color.rgb == target_colors[i].rgb) {
			tex_color.rgb = replace_colors[i].rgb;
			break;
		}
	}
	
	COLOR = tex_color;
}