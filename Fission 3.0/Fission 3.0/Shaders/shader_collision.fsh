varying lowp vec2 texCoords;
uniform sampler2D tex0;
void main(){
    lowp vec2 rg = texture2D(tex0, texCoords).rg;
    gl_FragColor = vec4((rg.x+rg.y)*0.5,0.0,0.0,1.0);;
}