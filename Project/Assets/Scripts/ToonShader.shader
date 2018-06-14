Shader "Custom/ToonShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range(0, 1)) = .1
		_Ramp("Shading Ramp", 2D) = "gray" {}
	}

	CGINCLUDE
#include "UnityCG.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};
		struct v2f {
			float4 pos : POSITION;
			float4 color : COLOR;
		};

		uniform float _Outline;
		uniform float4 _OutlineColor;

		v2f vert(appdata v) {
			//Een kopie van de vertexen om daar een outline van te maken. Deze word ook in de kleur gezet van de _OutlineColor
			v2f o;
			v.vertex *= -(1 + _Outline);

			o.pos = UnityObjectToClipPos(v.vertex);
			//Zet de kleur van de copie van de vertexen in de outline color
			o.color = _OutlineColor;
			return o;
		}
		ENDCG

			SubShader{
				Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "IgnoreProjector" = "True" }
				LOD 200
				
				//Zorg bij de CGPROGRAM dat je een extra shadow toevoegd. Anders drawt de shader geen shaduwen.
				CGPROGRAM
				#pragma surface surf CelShadingForward fullforwardshadows addshadow 
				#pragma target 3.0

				sampler2D _Ramp;
		
		// Toon Ramp. Dit om de schaduwen mooier te laten tekenen door de shader (weet niet zeker of ik deze werkend heb gekregen)
		half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			half diff = NdotL * 0.5 + 0.5;
			half3 ramp = tex2D(_Ramp,(diff)).rgb;
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			c.a = s.Alpha;
			return c;

			}
			// Forward Rendering - Hele lichte render pipeline voor als er weinig lichtsources in de scene zijn.
			half4 LightingCelShadingForward(SurfaceOutput s, half3 lightDir, half atten)
			{
				//Hier kijk ik hoeveel licht er op deze cel valt. Daarmee bepaal je het visuele effect van de cel
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
				// Met de output van de vorige functie kan je hiermee de kleur aanpassen. ook de kleur van het object word hierin meegenomen
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
			}
			ENDCG
		Pass {
				//Hier draw je de outline. Je zorgt dat de vertexes die in het object bevinden niet worden gedrawt.
				Name "OUTLINE"
				Tags { "Queue" = "Transparent" "IgnoreProjector" = "True"}
				Cull Back
				ZWrite Off
				Offset 1, 1

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				half4 frag(v2f i) :COLOR { return i.color; }
				ENDCG
			}
	}	
	FallBack "Diffuse"
}
