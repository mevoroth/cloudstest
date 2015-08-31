Shader "Custom/IQ" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0, 1)) = 0.5
		_Metallic("Metallic", Range(0, 1)) = 0.0
		iChannel0("channel 0", 2D) = "white" {}
		iGlobalTime("global time", Float) = 0.0
		iResolution("resolution", Vector) = (1920, 1080, 0, 0)
		iMouse("mouse", Vector) = (0, 0, 0, 0)
	}
	SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200
			Pass{

				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

				// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 5.0

				sampler2D _MainTex;

				half _Glossiness;
				half _Metallic;
				fixed4 _Color;

				sampler2D iChannel0;
				float iGlobalTime;
				float4 iResolution;
				float4 iMouse;

				float noise(in float3 x)
				{
					float3 p = floor(x);
					float3 f = frac(x);
					f = f*f*(3.0 - 2.0*f);
					float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
					uv = (uv + 0.5) / 256.0;
					float2 rg = tex2Dlod(iChannel0, float4(uv.x, uv.y, 0, 0)).yx;
					return -1.0 + 2.0*lerp(rg.x, rg.y, f.z);
				}

				float map5(in float3 p)
				{
					float3 q = p - float3(0.0, 0.1, 1.0)*iGlobalTime;
					float f;
					f = 0.50000*noise(q); q = q*2.02;
					f += 0.25000*noise(q); q = q*2.03;
					f += 0.12500*noise(q); q = q*2.01;
					f += 0.06250*noise(q); q = q*2.02;
					f += 0.03125*noise(q);
					return clamp(1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0);
				}

				float map4(in float3 p)
				{
					float3 q = p - float3(0.0, 0.1, 1.0)*iGlobalTime;
					float f;
					f = 0.50000*noise(q); q = q*2.02;
					f += 0.25000*noise(q); q = q*2.03;
					f += 0.12500*noise(q); q = q*2.01;
					f += 0.06250*noise(q);
					return clamp(1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0);
				}
				float map3(in float3 p)
				{
					float3 q = p - float3(0.0, 0.1, 1.0)*iGlobalTime;
					float f;
					f = 0.50000*noise(q); q = q*2.02;
					f += 0.25000*noise(q); q = q*2.03;
					f += 0.12500*noise(q);
					return clamp(1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0);
				}
				float map2(in float3 p)
				{
					float3 q = p - float3(0.0, 0.1, 1.0)*iGlobalTime;
					float f;
					f = 0.50000*noise(q); q = q*2.02;
					f += 0.25000*noise(q);;
					return clamp(1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0);
				}

				float3 sundir = normalize(float3(-1.0, 0.0, -1.0));

				float4 integrate(in float4 sum, in float dif, in float den, in float3 bgcol, in float t)
				{
					// lighting
					float3 lin = float3(0.65, 0.68, 0.7)*1.3 + 0.5*float3(0.7, 0.5, 0.3)*dif;
					float4 col = float4(lerp(1.15*float3(1.0, 0.95, 0.8), float3(0.65, 0.65, 0.65), den), den);
					col.xyz *= lin;
					col.xyz = lerp(col.xyz, bgcol, 1.0 - exp(-0.003*t*t));
					// front to back blending    
					col.a *= 0.4;
					col.rgb *= col.a;
					return sum + col*(0.9 - sum.a);
				}

				float4 raymarch(in float3 ro, in float3 rd, in float3 bgcol)
				{
					float4 sum = (0.0);

					float t = 0.0;
					int nbsteps = 10000;

					int i;
					[loop]
					for (i = 0; i<nbsteps; i++)
					{
						float3 pos = ro + t*rd;
						if (pos.y<-3.0 || pos.y>2.0 || sum.a > 0.99)
							break;
						float den = map5(pos);
						if (den>0.01)
						{
							float dif = clamp((den - map5(pos + 0.3*sundir)) / 0.6, 0.0, 1.0);
							sum = integrate(sum, dif, den, bgcol, t);
						}
						t += max(0.1, 0.02*t);
					}

					// [loop]
					// for (i = 0; i<nbsteps; i++)
					// {
					// 	float3  pos = ro + t*rd;
					// 	if (pos.y<-3.0 || pos.y>2.0 || sum.a > 0.99)
					// 		break;
					// 	float den = map4(pos);
					// 	if (den>0.01)
					// 	{
					// 		float dif = clamp((den - map4(pos + 0.3*sundir)) / 0.6, 0.0, 1.0);
					// 		sum = integrate(sum, dif, den, bgcol, t);
					// 	}
					// 	t += max(0.1, 0.02*t);
					// }

					// [loop]
					// for (i = 0; i<nbsteps; i++)
					// {
					// 	float3  pos = ro + t*rd;
					// 	if (pos.y<-3.0 || pos.y>2.0 || sum.a > 0.99)
					// 		break;
					// 	float den = map3(pos);
					// 	if (den>0.01)
					// 	{
					// 		float dif = clamp((den - map3(pos + 0.3*sundir)) / 0.6, 0.0, 1.0);
					// 		sum = integrate(sum, dif, den, bgcol, t);
					// 	}
					// 	t += max(0.1, 0.02*t);
					// }

					// [loop]
					// for (i = 0; i<nbsteps; i++)
					// {
					// 	float3  pos = ro + t*rd;
					// 	if (pos.y<-3.0 || pos.y>2.0 || sum.a > 0.99)
					// 		break;
					// 	float den = map2(pos);
					// 	if (den>0.01)
					// 	{
					// 		float dif = clamp((den - map2(pos + 0.3*sundir)) / 0.6, 0.0, 1.0);
					// 		sum = integrate(sum, dif, den, bgcol, t);
					// 	}
					// 	t += max(0.1, 0.02*t);
					// }

					return clamp(sum, 0.0, 1.0);
				}

				float3x3 setCamera(in float3 ro, in float3 ta, float cr)
				{
					float3 cw = normalize(ta - ro);
					float3 cp = float3(sin(cr), cos(cr), 0.0);
					float3 cu = normalize(cross(cw, cp));
					float3 cv = normalize(cross(cu, cw));
					return float3x3(cu, cv, cw);
				}

				float4 render(in float3 ro, in float3 rd)
				{
					// background sky     
					float sun = clamp(dot(sundir, rd), 0.0, 1.0);
					//float3 col = float3(0.6, 0.71, 0.75) - rd.y*0.2*float3(1.0, 0.5, 1.0) + 0.15*0.5;
					float3 col = float3(0.7, 0, 0);
					col += 0.2*float3(1.0, .6, 0.1)*pow(sun, 8.0);

					// clouds    
					float4 res = raymarch(ro, rd * 0.1, col);
					col = col*(1.0 - res.w) + res.xyz;

					// sun glare    
					col += 0.1*float3(1.0, 0.4, 0.2)*pow(sun, 3.0);

					return float4(col, 1.0);
				}

				void mainImage(out float4 fragColor, in float2 fragCoord)
				{
					float2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.x;

					float2 m = iMouse.xy / iResolution.xy;

					// camera
					float3 ro = 4.0*normalize(float3(sin(3.0*m.x), 0.4*m.y, cos(3.0*m.x)));
					float3 ta = float3(0.0, -1.0, 0.0);
					float3x3 ca = setCamera(ro, ta, 0.0);
					// ray
					float3 rd = mul(ca, normalize(float3(p.x, p.y, 1.5)));

					fragColor = render(ro, rd);
				}

				void mainVR(out float4 fragColor, in float2 fragCoord, in float3 fragRayOri, in float3 fragRayDir)
				{
					fragColor = render(fragRayOri, fragRayDir);
				}
				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				//Vertex Shader
				v2f vert(appdata_img v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.uv.xy = v.texcoord.xy;
					return o;
				}

				float4 frag(v2f i) : SV_Target{
					float4 OUT;
					mainImage(OUT, i.uv);
					return OUT;
				}

					ENDCG
			}
		}
		FallBack "Diffuse"
}
