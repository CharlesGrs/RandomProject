Shader "Unlit/GroundShader"
{
    Properties
    {
        _MainCol("Main Color", color) = (0,0,0,0)
        _GrassTexture("Grass Texture", 2D) = "white"
        _GroundTexture("Ground Texture", 2D) = "white"
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Cull Off
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "noiseSimplex.cginc"

            #define PLANE_HALF_WIDTH 25.0f
            #define PLANE_HALF_LENGTH 12.5f

            float _heightNoiseStrength;
            float _heightNoiseFrequency;
            float _heightNoiseOffset;

            float _humidityNoiseFrequency;
            float _humidityNoiseOffset;

            float4 _MainCol;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 posWS : TEXCOORD1;
            };

            float GetHeightMask(float3 posWS)
            {
                float n0 = snoise(posWS * _heightNoiseFrequency + _heightNoiseOffset);
                float n1 = snoise(posWS * _heightNoiseFrequency * 5 + _heightNoiseOffset);

                float mask = n0 * 0.9f + n1 * 0.1f;


                return mask * _heightNoiseStrength;
            }

            float GetHumidityMask(float3 posWS)
            {
                float n0 = snoise(posWS * _humidityNoiseFrequency + _humidityNoiseOffset);
                float n1 = snoise(posWS * _humidityNoiseFrequency * 5 + _humidityNoiseOffset);

                float mask = n0 * 0.9f + n1 * 0.1f;

                return saturate(mask);
            }


            float3 _PlayerPosWS;

            v2f vert(appdata v)
            {
                v2f o;
                float3 posWS = TransformObjectToWorld(v.vertex);
                float heightMask = GetHeightMask(posWS);


                float d = smoothstep(
                    .7, 1, 1 - distance(float3(posWS.x, 0, posWS.z), float3(_PlayerPosWS.x, 0, _PlayerPosWS.z)) * .0002);
                v.vertex.y -= (1 - d) * 4000;
                v.vertex.y += round(heightMask*2)/2 *2;
                
                o.posWS = posWS;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _GrassTexture, _GroundTexture;

            float4 frag(v2f i) : SV_Target
            {
                float humidityMask = GetHumidityMask(i.posWS);
                float heightMask = GetHeightMask(i.posWS);

                float scale = 0.1;
                float4 grass = tex2D(_GrassTexture, i.posWS.xz*scale);
                float4 ground = tex2D(_GroundTexture, i.posWS.xz*scale);
                // return _MainCol;

                return lerp(ground, grass, humidityMask);

                return heightMask / _heightNoiseStrength;
            }
            ENDHLSL
        }
    }
}