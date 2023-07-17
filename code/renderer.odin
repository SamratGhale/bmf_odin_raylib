package main


//------------------------------------------------------------------------------------
// Custom Functions Definition
//------------------------------------------------------------------------------------
// Draw cube textured
// NOTE: Cube position is the center position
import rl "vendor:raylib"
import "core:math/linalg"

DrawCubeTexture :: proc(texture : rl.Texture , position: linalg.Vector3f32 , width: f32, height: f32 , length: f32 , color: rl.Color )
{
	using rl
	x :f32= position.x;
	y :f32= position.y;
	z :f32= position.z;

	// Set desired texture to be enabled while drawing following vertex data
    rlSetTexture(texture.id);

    // Vertex data transformation can be defined with the commented lines,
    // but in this example we calculate the transformed vertex data directly when calling rlVertex3f()
    //rlPushMatrix();
        // NOTE: Transformation is applied in inverse order (scale -> rotate -> translate)
        //rlTranslatef(2.0f, 0.0f, 0.0f);
        //rlRotatef(45, 0, 1, 0);
        //rlScalef(2.0f, 2.0f, 2.0f);

        rlBegin(RL_QUADS);
            rlColor4ub(color.r, color.g, color.b, color.a);
            // Front Face
            rlNormal3f(0.0, 0.0, 1.0);       // Normal Pointing Towards Viewer
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x - width/2, y - height/2, z + length/2);  // Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x + width/2, y - height/2, z + length/2);  // Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x + width/2, y + height/2, z + length/2);  // Top Right Of The Texture and Quad
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x - width/2, y + height/2, z + length/2);  // Top Left Of The Texture and Quad
            // Back Face
            rlNormal3f(0.0, 0.0, - 1.0);     // Normal Pointing Away From Viewer
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x - width/2, y - height/2, z - length/2);  // Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x - width/2, y + height/2, z - length/2);  // Top Right Of The Texture and Quad
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x + width/2, y + height/2, z - length/2);  // Top Left Of The Texture and Quad
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x + width/2, y - height/2, z - length/2);  // Bottom Left Of The Texture and Quad
            // Top Face
            rlNormal3f(0.0, 1.0, 0.0);       // Normal Pointing Up
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x - width/2, y + height/2, z - length/2);  // Top Left Of The Texture and Quad
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x - width/2, y + height/2, z + length/2);  // Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x + width/2, y + height/2, z + length/2);  // Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x + width/2, y + height/2, z - length/2);  // Top Right Of The Texture and Quad
            // Bottom Face
            rlNormal3f(0.0, - 1.0, 0.0);     // Normal Pointing Down
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x - width/2, y - height/2, z - length/2);  // Top Right Of The Texture and Quad
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x + width/2, y - height/2, z - length/2);  // Top Left Of The Texture and Quad
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x + width/2, y - height/2, z + length/2);  // Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x - width/2, y - height/2, z + length/2);  // Bottom Right Of The Texture and Quad
            // Right face
            rlNormal3f(1.0, 0.0, 0.0);       // Normal Pointing Right
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x + width/2, y - height/2, z - length/2);  // Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x + width/2, y + height/2, z - length/2);  // Top Right Of The Texture and Quad
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x + width/2, y + height/2, z + length/2);  // Top Left Of The Texture and Quad
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x + width/2, y - height/2, z + length/2);  // Bottom Left Of The Texture and Quad
            // Left Face
            rlNormal3f( - 1.0, 0.0, 0.0);    // Normal Pointing Left
            rlTexCoord2f(0.0, 0.0); rlVertex3f(x - width/2, y - height/2, z - length/2);  // Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0, 0.0); rlVertex3f(x - width/2, y - height/2, z + length/2);  // Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0, 1.0); rlVertex3f(x - width/2, y + height/2, z + length/2);  // Top Right Of The Texture and Quad
            rlTexCoord2f(0.0, 1.0); rlVertex3f(x - width/2, y + height/2, z - length/2);  // Top Left Of The Texture and Quad
        rlEnd();
    //rlPopMatrix();

    rlSetTexture(0);
}

DrawCubeTextureRec :: proc(texture: rl.Texture , source: rl.Rectangle , position: linalg.Vector3f32 , width: f32, height: f32, length: f32, color: rl.Color )
{
	using rl
	x := position.x;
	y := position.y;
	z := position.z;
	texWidth := f32(texture.width)
    texHeight := f32(texture.height)

    // Set desired texture to be enabled while drawing following vertex data
    rlSetTexture(texture.id);

    // We calculate the normalized texture coordinates for the desired texture-source-rectangle
    // It means converting from (tex.width, tex.height) coordinates to [0.0f, 1.0f] equivalent 
    rlBegin(RL_QUADS);
        rlColor4ub(color.r, color.g, color.b, color.a);

        // Front face
        rlNormal3f(0.0, 0.0, 1.0);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y - height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y - height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y + height/2, z + length/2);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y + height/2, z + length/2);

        // Back face
        rlNormal3f(0.0, 0.0, - 1.0);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y - height/2, z - length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y + height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y + height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y - height/2, z - length/2);

        // Top face
        rlNormal3f(0.0, 1.0, 0.0);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y + height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y + height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y + height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y + height/2, z - length/2);

        // Bottom face
        rlNormal3f(0.0, - 1.0, 0.0)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y - height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y - height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y - height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y - height/2, z + length/2);

        // Right face
        rlNormal3f(1.0, 0.0, 0.0);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y - height/2, z - length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y + height/2, z - length/2);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x + width/2, y + height/2, z + length/2);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x + width/2, y - height/2, z + length/2);

        // Left face
        rlNormal3f( - 1.0, 0.0, 0.0);
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y - height/2, z - length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight);
        rlVertex3f(x - width/2, y - height/2, z + length/2);
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y + height/2, z + length/2);
        rlTexCoord2f(source.x/texWidth, source.y/texHeight);
        rlVertex3f(x - width/2, y + height/2, z - length/2);

    rlEnd();

    rlSetTexture(0);
}

