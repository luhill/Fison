varying lowp vec2 texCoords;
uniform sampler2D tex0,tex1;
void main(){
    //mediump vec2 realTexCoord = texCoords + vec2(gl_PointCoord.x,gl_PointCoord.y/60.0);
    lowp vec4 fragColor = texture2D(tex0, gl_PointCoord);
    lowp vec4 texColor = texture2D(tex1, texCoords);
    gl_FragColor = vec4(texColor.rgb+fragColor.rgb,fragColor.a);
    //gl_FragColor = texture2D(tex0,gl_PointCoord);
    //gl_FragColor = vec4(1.0,1.0,1.0,1.0);
}