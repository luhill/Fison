varying lowp vec2 texCoords;
uniform mediump float blur;

void main(){
    lowp float centerDist = length(texCoords);
    lowp float scale = 0.05;
    lowp float comp1 = sin((blur+length(texCoords-vec2(-1.0,1.0)))/scale);
    lowp float comp2 = sin((blur+length(texCoords-vec2(-1.0,-1.0)))/scale);
    lowp float comp3 = sin(-(blur+length(texCoords-vec2(0.0,-1.0)))/scale);
    
    lowp float comp4 = sin((blur+length(texCoords-vec2(sin(blur),sin(blur))))/scale);
    lowp float green = (comp1+comp2+comp3+comp4)*0.125+0.5;
    lowp vec3 color = vec3(1.0,green,0.0)*(1.0-centerDist*centerDist*centerDist);
    gl_FragColor = vec4(color*min(blur*2.0,1.0),1.0);
}