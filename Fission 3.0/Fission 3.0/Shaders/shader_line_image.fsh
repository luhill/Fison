varying lowp vec2 texCoords;
uniform sampler2D tex0;
void main(){
    gl_FragColor = texture2D(tex0, texCoords);
}