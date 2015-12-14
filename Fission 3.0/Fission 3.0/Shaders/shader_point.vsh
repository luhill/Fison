attribute vec2 position;


uniform mediump float ptSize;
uniform vec2 projection2d_a;
uniform vec2 projection2d_b;
void main(){
    gl_Position.xy = vec2((floor(position.x/projection2d_a.x*projection2d_b.x))/projection2d_b.x*2.0-1.0, (floor(position.y/projection2d_a.y*projection2d_b.y+0.0))/projection2d_b.y*2.0-1.0);
    gl_Position.zw = vec2(0.0,1.0);
    //gl_PointSize = 3.0;
    gl_PointSize = ptSize;
}