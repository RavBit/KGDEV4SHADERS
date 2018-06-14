Shader "Custom/ToonShader_NoOutline" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range(0, 1)) = .1
		_Ramp("Shading Ramp", 2D) = "gray" {}
	}


			SubShader{
				Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "IgnoreProjector" = "True" }
				LOD 200

				CGPROGRAM
				#pragma surface surf CelShadingForward fullforwardshadows addshadow 
				#pragma target 3.0

				sampler2D _Ramp;
				
		half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			half diff = NdotL * 0.5 + 0.5;
			half3 ramp = tex2D(_Ramp,(diff)).rgb;
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			c.a = s.Alpha;
			return c;

			}
			half4 LightingCelShadingForward(SurfaceOutput s, half3 lightDir, half atten)
			{
				half ToonDot = dot(s.Normal, lightDir);
				if (ToonDot <= 0.0)
				{
					ToonDot = 0;
				}
				else
				{
					ToonDot = 1;
				}

				half4 c;
				c.rgb = s.Albedo * _LightColor0.rgb * (ToonDot * atten * 2);
				c.a = s.Alpha;
				return c;
			}

			sampler2D _MainTex;
			fixed4 _Color;

			struct Input {
				float2 uv_MainTex;
			};

			void surf(Input IN, inout SurfaceOutput o) {
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
			}
			ENDCG
	}	
	FallBack "Diffuse"
}
