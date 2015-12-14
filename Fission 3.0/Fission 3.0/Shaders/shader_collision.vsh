attribute vec2 positionGrid;
attribute vec2 position;

varying lowp vec2 texCoords;
//uniform mat4 projection;
uniform highp float h1,w1,h2,w2;
uniform vec2 projection2d_a;
uniform vec2 projection2d_b;
uniform vec2 projection2d_c;
void main(){
    //positionGrid contains an organized grid index of the particles. This allows the vertex to be mapped to and ordered grid which will be rendered to a texture. Later the texture will be read with readPixels() and the pixel order will be equivelent to the vertex order.
    gl_Position = vec4(positionGrid.x/projection2d_c.x, positionGrid.y/projection2d_c.y,0.0,1.0);
    
    //In order to determine if a collision has occured with a specific particle we examine the color at the actual position of the particle (if the particle is passive, positionCenter stores the center, stationary point of the particle. If the particle is active, positionCenter stores the position of the leading point of the particle line). The actual position of the particle is converted into the texture coordinate range and stored into the texture coordinates of this vertex shader. Then the fragment shader uses those texture coordinates to look at a texture of the rendered particles and renders the color to the collision map texture. Finally the collision map texture is read with readPixels(). A collision can be detected, for example, if the pixel contains the colors of both an active and passive particle.
    
    //The position data must be rounded to whole number values to provide consistent matching between the position data when it was drawn and the texture coordinates used to look up the position.
    texCoords.xy = vec2((floor(position.x/projection2d_a.x*projection2d_b.x)-0.5)/projection2d_b.x,(floor(position.y/projection2d_a.y*projection2d_b.y)-0.5)/projection2d_b.y);
    gl_PointSize = 1.0;
}