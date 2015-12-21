varying highp vec2 texCoords;
uniform highp float blur;

void main(){
    highp float centerDist = length(texCoords);
    highp float scale = 0.05;
    highp float comp1 = sin((blur+length(texCoords-vec2(-1.0,1.0)))/scale);
    highp float comp2 = sin((blur+length(texCoords-vec2(-1.0,-1.0)))/scale);
    highp float comp3 = sin(-(blur+length(texCoords-vec2(0.0,-1.0)))/scale);
    
    highp float comp4 = sin((blur+length(texCoords-vec2(sin(blur),sin(blur))))/scale);
    highp float green = (comp1+comp2+comp3+comp4)*0.125+0.5;
    highp vec3 color = vec3(1.0,green,0.0)*(1.0-centerDist*centerDist*centerDist);
    //gl_FragColor = vec4(color*min(blur*2.0,1.0),1.0);
    gl_FragColor = vec4(color,1.0);
}