#version 330

//input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

//input uniform values
uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;


//output vertex attributes (to fragment shader)

out vec3 fragPosition;
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragNormal;


void main(){
  fragPosition = vec3(matModel* vec4(vertexPositon, 1.0));
  fragTexCoord = vertexTexCoord;
  fragColor    = vertexColor;
  fragNormal   = normalize(vec3(matNormal*vec4(vertexNormal, 1.0)));

  //calculate final vertex position
  gl_Position = mvp * vec4(vertexPosition, 1.0);
}
