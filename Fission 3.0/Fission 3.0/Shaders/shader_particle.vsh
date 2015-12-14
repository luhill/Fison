attribute vec4 position;
attribute vec2 shortTextureCoords;

varying lowp vec2 texCoords;
varying lowp float minAlpha;
uniform vec2 projection2d_a;
void main(){
    
    gl_Position = vec4(position.x/projection2d_a.x*2.0-1.0,position.y/projection2d_a.y*2.0-1.0,0.0,1.0);
    texCoords = vec2(shortTextureCoords.x/60000.0,shortTextureCoords.y/60000.0);
    gl_PointSize = 4.0;
}