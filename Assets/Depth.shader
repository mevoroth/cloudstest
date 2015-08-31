Shader "Custom/Depth" {
	SubShader {
	Tags { "RenderType"="Opaque" }

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _CameraDepthTexture;

			struct v2f {
			   float4 pos : SV_POSITION;
			   float4 scrPos:TEXCOORD1;
			};

			//Vertex Shader
			v2f vert (appdata_base v){
			   v2f o;
			   o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			   o.scrPos=ComputeScreenPos(o.pos);
			   //for some reason, the y position of the depth texture comes out inverted
			   o.scrPos.y = 1 - o.scrPos.y;
			   return o;
			}

			//Fragment Shader
			float frag (v2f i) : SV_Target {
			   float depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
			   return depthValue;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}