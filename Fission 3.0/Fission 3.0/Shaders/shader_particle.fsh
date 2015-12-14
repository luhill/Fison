varying lowp vec2 texCoords;
varying lowp float minAlpha;
uniform sampler2D tex0;
void main(){
    lowp vec4 texColor = texture2D(tex0, texCoords);
    //lowp vec3 color = vec3(1.0,1.0,1.0);
    //gl_FragColor = vec4(texColor.rgb,max(minAlpha,texColor.a));
    gl_FragColor = texColor;
}