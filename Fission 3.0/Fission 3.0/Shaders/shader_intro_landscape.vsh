attribute vec4 position;

varying highp vec2 texCoords;

uniform vec2 projection2d_a;
uniform lowp float ptSize;
void main(){
    gl_Position = vec4(position.x/projection2d_a.x*2.0-1.0,position.y/projection2d_a.y*2.0-1.0,0.0,1.0);
    texCoords = vec2(gl_Position.x*projection2d_a.x/projection2d_a.y,gl_Position.y);
    gl_Position.xy*=ptSize*(projection2d_a.x/projection2d_a.y*1.2);
}