varying lowp vec2 texCoords;
uniform sampler2D tex0;//Main Texture
void main(){
    lowp vec4 front = texture2D(tex0, texCoords);
    gl_FragColor = front;
}