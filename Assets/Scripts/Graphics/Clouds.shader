Shader "Skies/Clouds"
{
	Properties
	{
		_MainTex("Screen Texture", 2D) = "white" {}
		CloudsHeightmap("Clouds Heightmap", 2D) = "white" {}
		DummyFloat("DummyFloat", Float) = 0
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}
		LOD 200
		
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 5.0

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D CloudsHeightmap;
			float DummyFloat;
			float4x4 MVPInverseMatrix;

			struct VS_PS
			{
				float4 Pos : SV_POSITION;
				float2 UV : TEXCOORD0;
				float4 Dummy : TEXCOORD1;
			};

			float2 ScreenUVToScreenPos(float2 ScreenUV)
			{
				return float2(
					ScreenUV.x,
					ScreenUV.y
				) * _ScreenParams.xy;
			}

			float3 ScreenToWorldPos(float2 ScreenPos)
			{
				return mul(UNITY_MATRIX_IT_MV, float4(ScreenPos, 0, 1)).xyz;
			}

			void RenderImage(float2 UV, out float4 OUTColor)
			{
				//float Height = tex2D(CloudsHeightmap, UV).x;

				//float4 
				//for ()

				float3 Dir = ScreenToWorldPos(ScreenUVToScreenPos(UV)) - _WorldSpaceCameraPos;
				
				Dir = normalize(Dir);
				
				float MaxSteps = 100;
				float Step = 0;
				for (; Step < MaxSteps; ++Step)
				{
					float3 CurrentPos = _WorldSpaceCameraPos + Dir * Step;
					//CurrentPos.xy;
					float Height = tex2Dlod(CloudsHeightmap, float4(CurrentPos.xy, 0, 0)).x;
					if (Height <= CurrentPos.z)
					{
						break;
					}
				}

				OUTColor = Step / DummyFloat;

				//OUTColor = (_WorldSpaceCameraPos + Dir * Step).z / DummyFloat;
				//OUTColor = mul(UNITY_MATRIX_MVP, float4(_WorldSpaceCameraPos + Dir * Step, 1));
			}

			VS_PS VS(appdata_img IN)
			{
				VS_PS OUT;

				OUT.Pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.UV = IN.texcoord.xy;
				OUT.Dummy = IN.vertex;

				return OUT;
			}

			float4 PS(VS_PS IN) : SV_Target
			{
				//return float4(IN.Pos.xy / _ScreenParams.xy, 0, 1);
				//float4 Col = mul(UNITY_MATRIX_IT_MV, float4(ScreenUVToScreenPos(IN.UV), _ProjectionParams.y, 1));
				//float4 Col = mul(UNITY_MATRIX_IT_MV, float4(_ScreenParams / float2(2,2), 0, 1));
				//return Col;
				//return float4(, 0, 1);
				
				float4 OUTColor;
				RenderImage(IN.UV, OUTColor);
				return (MVPInverseMatrix[0][0] - (UNITY_MATRIX_IT_MV)[0][0]) ? 1 : 0;
				return OUTColor;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
