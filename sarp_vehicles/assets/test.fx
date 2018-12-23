texture gTexture0; 
  
//-- Very simple technique 
technique texReplace 
{ 
    pass P0 
    { 
        //-- Set up texture stage 0 
        Texture[0] = gTexture0; 
    } 
} 