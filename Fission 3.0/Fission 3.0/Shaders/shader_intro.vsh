attribute vec4 position;

varying lowp vec2 texCoords;

uniform vec2 projection2d_a;
uniform lowp float ptSize;
void main(){
    gl_Position = vec4(position.x/projection2d_a.x*2.0-1.0,position.y/projection2d_a.y*2.0-1.0,0.0,1.0);
    texCoords = vec2(gl_Position.x, gl_Position.y*projection2d_a.y/projection2d_a.x);
    gl_Position.xy*=ptSize/0.5;
}