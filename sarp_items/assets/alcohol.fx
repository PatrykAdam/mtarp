texture ScreenTexture;	

float Time : TIME;

int drunkLevel = 0;
float2 offset;

sampler ImageSampler = sampler_state
{
	Texture = <ScreenTexture>;
};

float4 main(float2 uv : TEXCOORD) : COLOR
{
    float4 output = tex2D(ImageSampler, uv);  // Defines the output color of a pixel
	int count = 10;

	float2 offset; 
	sincos(Time, offset.y, offset.x);

	offset *= 0.0001;

	for (int i = 0; i < count; i ++)
	{	
		output += tex2D(ImageSampler, uv + (offset * i * drunkLevel) );
	}
	output /= count; // Normalize the color
	return output;
};

technique MotionBlur
{
	pass P1
	{
		PixelShader = compile ps_2_0 main();
	}
}