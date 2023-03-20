Shader "Unlit/S_Entity"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Amount("Amount", float) = 1
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD1;
            };

            sampler2D _MainTex;
            float _Amount;
            float4 _MainTex_ST;

            float3 _PlayerPosWS;
            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv.xy;

                o.posWS = TransformObjectToWorld(v.vertex);
                float d = smoothstep(.7, 1,  1- distance(float2( o.posWS.x,  o.posWS.z), float2(_PlayerPosWS.x,  _PlayerPosWS.z)) * .0002);
                v.vertex.y -= (1- d) *4000 ;

                //
                // // billboard mesh towards camera
                // float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                // float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23,
                //                            1);
                // float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
                // float4 outPos = mul(UNITY_MATRIX_P, viewPos);

                o.pos = TransformObjectToHClip(v.vertex);
                // o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                if (col.a < 0.5)
                    discard;
                return col;
            }
            ENDHLSL
        }
    }
}