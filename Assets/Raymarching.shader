Shader "Custom/Raymarching" {
	Properties {
		_MainTex ("Texture", 2D) = "red" {}
		_DepthTex ("Depth", 2D) = "white" {}
		_Noise0 ("Noise", 2D) = "white" {}
		_Noise1 ("Noise", 2D) = "white" {}
		_Noise2 ("Noise", 2D) = "white" {}
		_Noise3 ("Noise", 2D) = "white" {}
		_Noise4 ("Noise", 2D) = "white" {}
		_Noise5 ("Noise", 2D) = "white" {}
		_Noise6 ("Noise", 2D) = "white" {}
		_Noise7 ("Noise", 2D) = "white" {}
		_Width ("Width", Float) = 512
		_Height ("Height", Float) = 512
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200
		
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _DepthTex;
			sampler2D _Noise0;
			sampler2D _Noise1;
			sampler2D _Noise2;
			sampler2D _Noise3;
			sampler2D _Noise4;
			sampler2D _Noise5;
			sampler2D _Noise6;
			sampler2D _Noise7;
			uniform float _Width;
			uniform float _Height;
			
			struct v2f {
			   float4 pos : SV_POSITION;
			   half2 uv : TEXCOORD0;
			};

			//Vertex Shader
			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = v.texcoord.xy;
				return o;
			}

			float4 blendClouds(float4 a, float4 b)
			{
				return a + b * a.x;
			}

			//Fragment Shader
			float4 frag (v2f i) : COLOR
			{
				float depth = (1 - tex2D(_DepthTex, i.uv).x);
				float u = 1 / _Width;
				float v = 1 / _Height;
				float u2 = u*2;
				float v2 = v*2;
				half2 uvs[25] = {
					{ -u2, -v2 },	{ -u, -v2 },	{ 0, -v2 },	{ u, -v2 },	{ u2, -v2 },
					{ -u2, -v },	{ -u, -v },		{ 0, -v },	{ u, -v },	{ u2, -v },
					{ -u2, 0 },		{ -u, 0 },		{ 0, -v },	{ u, 0 },	{ -u2, 0 },
					{ -u2, v },		{ -u, v },		{ 0, v },	{ u, v },	{ -u2, v },
					{ -u2, v2 },	{ -u, v2 },		{ 0, v2 },	{ u, v2 },	{ -u2, v2 }
				};

				float kernel[25] = {
					0.015625,	0.125,	0.25,	0.125,		0.015625,
					0.125,		0.25,	0.5,	0.25,		0.125,
					0.25,		0.5,	1,		0.5,		0.25,
					0.125,		0.25,	0.5,	0.25,		0.125,
					0.015625,	0.125,	0.25,	0.125,		0.015625
				};

				float acc = 0;

				for (int kernelIndex = 0; kernelIndex < 25; ++kernelIndex)
				{
					acc += tex2D(_DepthTex, i.uv + uvs[kernelIndex]).x * kernel[kernelIndex];
				}

				float oneMinusAcc = 1 - acc / 6.0625;

				// if (depth > 0)
				// {
					float4 n0 = tex2D(_Noise0, i.uv);
					float4 n1 = tex2D(_Noise1, i.uv);
					float4 n2 = tex2D(_Noise2, i.uv);
					float4 n3 = tex2D(_Noise3, i.uv);
					float4 n4 = tex2D(_Noise4, i.uv);
					float4 n5 = tex2D(_Noise5, i.uv);
					float4 n6 = tex2D(_Noise6, i.uv);
					float4 n7 = tex2D(_Noise7, i.uv);
					
					n0 = blendClouds(n0, n1);
					n0 = blendClouds(n0, n2);
					n0 = blendClouds(n0, n3);
					n0 = blendClouds(n0, n4);
					n0 = blendClouds(n0, n5);
					n0 = blendClouds(n0, n6);
					n0 = blendClouds(n0, n7);
				
				float4 color = tex2D(_MainTex, i.uv);

				if (oneMinusAcc > 0.0000001)
				{
					color.a *= n0 * oneMinusAcc;
					return float4(lerp(color.xyz, n0.xyz, color.a), 1);
				}
				// }
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
