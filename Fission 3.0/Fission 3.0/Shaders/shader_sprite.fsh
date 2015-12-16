varying highp vec2 texCoords;
uniform sampler2D tex0;
void main(){
    highp vec2 realTexCoord = texCoords + vec2(gl_PointCoord.x,gl_PointCoord.y*0.0166667);
    lowp vec4 fragColor = texture2D(tex0, realTexCoord);
    //fragColor.gb *= texCoords.x;
    gl_FragColor = fragColor;
    //gl_FragColor = texture2D(tex0,gl_PointCoord);
    //gl_FragColor = vec4(1.0,1.0,1.0,1.0);
}