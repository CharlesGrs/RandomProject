Shader "Unlit/EnvironmentShader"
{
    Properties {}
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Transparent"
        }

        Pass
        {
            cull off
            ZWrite on

            HLSLPROGRAM
            //Face Vertices & Uvs for mesh reconstruction
            static const float4 vertices[6] =
            {
                float4(0, 0, 0, 0),
                float4(1, 0, 0, 0),
                float4(0, 1, 0, 0),
                float4(1, 0, 0, 0),
                float4(1, 1, 0, 0),
                float4(0, 1, 0, 0),
            };

            static const float2 UVs[6] =
            {
                float2(0, 0),
                float2(1, 0),
                float2(0, 1),
                float2(1, 0),
                float2(1, 1),
                float2(0, 1),
            };

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "noiseSimplex.cginc"

            #define PLANE_HALF_WIDTH 25.0f
            #define PLANE_HALF_LENGTH 12.5f

            sampler2D _AtlasTexture;
            StructuredBuffer<int4> _AtlasDataBuffer;
            int _atlasWidth;
            int _atlasHeight;

            float _heightNoiseStrength;
            float _heightNoiseFrequency;
            float _heightNoiseOffset;

            float _humidityNoiseFrequency;
            int _plantsAmount;

            struct appdata
            {
                float4 vertex : POSITION;
                uint vid : SV_VertexID;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 posWS : TEXCOORD1;
                float instanceId : TEXCOORD2;
            };

            float hash11(float p)
            {
                p = frac(p * .1031);
                p *= p + 33.33;
                p *= p + p;
                return frac(p);
            }

            float2 hash21(float p)
            {
                float3 p3 = frac(float3(p, p, p) * float3(.1031, .1030, .0973));
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.xx + p3.yz) * p3.zy);
            }

            float3x3 AngleAxis3x3(float angle, float3 axis)
            {
                float c, s;
                sincos(angle, s, c);

                float t = 1 - c;
                float x = axis.x;
                float y = axis.y;
                float z = axis.z;

                return float3x3(
                    t * x * x + c, t * x * y - s * z, t * x * z + s * y,
                    t * x * y + s * z, t * y * y + c, t * y * z - s * x,
                    t * x * z - s * y, t * y * z + s * x, t * z * z + c
                );
            }

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
                float offset = 10000;
                float n0 = snoise(posWS * _humidityNoiseFrequency + offset);
                float n1 = snoise(posWS * _humidityNoiseFrequency * 5 + offset);

                float mask = n0 * 0.9f + n1 * 0.1f;

                return saturate(mask);
            }

            v2f vert(appdata v)
            {
                uint t_idx = v.vid / 3; // triangle Index 
                uint v_idx = v.vid - t_idx * 3; // vertex Index

                float instanceId = v.vid / 6;
                int idx = t_idx % 2 == 0 ? v_idx : v_idx + 3;

                float2 planeScale = float2(25.0f, 12.5f);
                float2 randomPos = (hash21(instanceId * 0.1) - .5) * 2; //-1 to 1
                float3 pos = float3(randomPos.x * planeScale.x, 0, randomPos.y * planeScale.y);
                float3 posWS = mul(unity_ObjectToWorld, pos);

                float heightMask = GetHeightMask(posWS);
                pos.y += heightMask;

                posWS = mul(unity_ObjectToWorld, pos);


                int id = hash11(instanceId * 1) * (_plantsAmount - 1);

                int4 atlasDatas = _AtlasDataBuffer[id];
                int width = atlasDatas.z * 0.01f;
                int height = atlasDatas.w * 0.01f;

                float3 windDirection = float3(1, 0, 0);
                float windFrequency = 0.01f;
                float windNoise = snoise(posWS.xz * windFrequency + _Time.x * 3 * windDirection);

                float3x3 rotationMatrixWind = AngleAxis3x3(windNoise * 0.1f * 6.2831, windDirection.xyz);
                float3x3 rotationMatrixY = AngleAxis3x3(hash11(instanceId) * 6.2831, float3(0, 1, 0));
                v.vertex = vertices[idx] * float4(width, height, 1, 1);
                // v.vertex = float4(mul(v.vertex.xyz, rotationMatrixY), 1);
                v.vertex = float4(mul(v.vertex.xyz, rotationMatrixWind), 1);
                v.vertex += float4(pos.xyz, 1);


                float3 normal = float3(0, 0, -1);
                normal = mul(rotationMatrixY, normal);

                float humidity = GetHumidityMask(posWS);

                float rand = hash11(instanceId * 0.1);

                //Discard a vertices by sending it behing camera
                v.vertex.xyz = rand > humidity * 1.f ? float3(0, 0, -100) : v.vertex.xyz;

                v2f o;
                o.uv = UVs[idx];
                o.posWS = posWS;
                o.normal = heightMask;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.instanceId = id;
                return o;
            }

            //Only Quad Needed For Vegetation
            float4 frag(v2f i) : SV_Target
            {
                int id = hash11(i.instanceId * 1) * (_plantsAmount - 1);


                //contains TopX,TopY,Width,Height   
                int4 atlasDatas = _AtlasDataBuffer[id];

                int TopX = atlasDatas.x;
                int TopY = atlasDatas.y;
                int width = atlasDatas.z;
                int height = atlasDatas.w;


                int posY = _atlasHeight - TopY - height;

                float u = (float)TopX / _atlasWidth;
                float v = (float)posY / _atlasHeight;
                float du = (float)width / _atlasWidth;
                float dv = (float)height / _atlasHeight;

                float4 col = tex2D(_AtlasTexture, i.uv * float2(du, dv) + float2(u, v));

                if (col.a < 0.7) discard;
                return col;
            }
            ENDHLSL
        }
    }
}