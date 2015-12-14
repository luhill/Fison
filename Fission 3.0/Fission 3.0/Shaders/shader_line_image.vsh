attribute vec4 position;
varying lowp vec2 texCoords;
uniform vec2 projection2d_a;
void main(){
    texCoords = vec2(position.x/projection2d_a.x,position.y/projection2d_a.y);
    gl_Position = vec4(texCoords.x/0.5-1.0,texCoords.y/0.5-1.0,0.0,1.0);
}