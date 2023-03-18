Shader "Unlit/GroundShader"
{
    Properties
    {
        _MainCol("Main Color", color) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

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
                float uvZ = smoothstep(-PLANE_HALF_LENGTH,PLANE_HALF_LENGTH, posWS.z);
                mask *= smoothstep(0.4f, 1.0f, uvZ);


                return saturate(mask) * _heightNoiseStrength;
            }

            float GetHumidityMask(float3 posWS)
            {
                float n0 = snoise(posWS * _humidityNoiseFrequency + _humidityNoiseOffset);
                float n1 = snoise(posWS * _humidityNoiseFrequency * 5 + _humidityNoiseOffset);

                float mask = n0 * 0.9f + n1 * 0.1f;

                return saturate(mask);
            }

            v2f vert(appdata v)
            {
                float3 posWS = TransformObjectToWorld(v.vertex);
                float heightMask = GetHeightMask(posWS);

                v.vertex.y += heightMask;
                // posWS.y += heightMask;

                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.posWS = posWS;
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float humidityMask = GetHumidityMask(i.posWS);
                float heightMask = GetHeightMask(i.posWS);

                // return _MainCol;

                return humidityMask;

                return heightMask / _heightNoiseStrength;
            }
            ENDHLSL
        }
    }
}