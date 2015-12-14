attribute vec4 position;
uniform mat4 projection;
uniform vec2 projection2d_a;
void main(){
    gl_Position = vec4(position.x/projection2d_a.x*2.0-1.0,position.y/projection2d_a.y*2.0-1.0,0.0,1.0);
    //gl_Position = projection * position;
    gl_Position.z += 0.5;
}