// Upgrade NOTE: upgraded instancing buffer 'SymphonieSlime' to new syntax.

// Made with Amplify Shader Editor v1.9.4.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Symphonie/Slime"
{
	Properties
	{
		[Gamma][Group(Common, 0)]_Color("Color", Color) = (0.3764706,0.4862745,0.7372549,1)
		[Group(Surface, 10)]_SurfaceDiffuseWeight("Surface Diffuse Weight", Range( 0 , 1)) = 0.04
		[Group(Common)]_Smoothness("Smoothness", Range( 0 , 1)) = 1
		[Group(Scattering,10)]_RefractionScatter("Refraction Scatter", Range( 0 , 2)) = 1
		[Group(Common)]_Size("Size", Float) = 1
		[Group(Scattering)]_RefractETA("Refract ETA", Range( 0 , 1)) = 0.85
		[Group(Core,30)][Toggle(_SHOWCORE_ON)] _ShowCore("Enable", Float) = 1
		[NoScaleOffset][Group(Core)]_ScatterLUT("Scatter LUT", 2D) = "white" {}
		[Group(Core)]_CoreRadius("Core Radius", Range( 0 , 1)) = 0.1
		[Group(Core)]_CoreScatterScale("Core Scatter Scale", Float) = 0.005
		[Group(Core)]_CoreScatterCurve("Core Scatter Curve", Float) = 3
		[HDR][Group(Core)]_CoreTint("Core Tint", Color) = (0.4156863,0.4156863,0.4156863,1)
		[PerRendererData][Group(Core)]_CorePosition("Core Position", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
		#pragma multi_compile_instancing
		#pragma shader_feature_local _SHOWCORE_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Smoothness;
		uniform float4 _Color;
		uniform float _RefractETA;
		uniform float _Size;
		uniform float _RefractionScatter;
		uniform float4 _CoreTint;
		uniform sampler2D _ScatterLUT;
		uniform float _CoreRadius;
		uniform float _CoreScatterCurve;
		uniform float _CoreScatterScale;
		uniform float _SurfaceDiffuseWeight;

		UNITY_INSTANCING_BUFFER_START(SymphonieSlime)
			UNITY_DEFINE_INSTANCED_PROP(float3, _CorePosition)
#define _CorePosition_arr SymphonieSlime
		UNITY_INSTANCING_BUFFER_END(SymphonieSlime)

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			SurfaceOutputStandard s114 = (SurfaceOutputStandard ) 0;
			float3 temp_cast_0 = (0.0).xxx;
			s114.Albedo = temp_cast_0;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			s114.Normal = ase_normWorldNormal;
			s114.Emission = float3( 0,0,0 );
			s114.Metallic = 0.0;
			float Smooth_Property32 = _Smoothness;
			s114.Smoothness = Smooth_Property32;
			s114.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi114 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g114 = UnityGlossyEnvironmentSetup( s114.Smoothness, data.worldViewDir, s114.Normal, float3(0,0,0));
			gi114 = UnityGlobalIllumination( data, s114.Occlusion, s114.Normal, g114 );
			#endif

			float3 surfResult114 = LightingStandard ( s114, viewDir, gi114 ).rgb;
			surfResult114 += s114.Emission;

			#ifdef UNITY_PASS_FORWARDADD//114
			surfResult114 -= s114.Emission;
			#endif//114
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g21 = dot( ase_worldNormal , ase_worldlightDir );
			float temp_output_9_0 = (dotResult5_g21*0.5 + 0.5);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			UnityGI gi73 = gi;
			float3 diffNorm73 = ase_normWorldNormal;
			gi73 = UnityGI_Base( data, 1, diffNorm73 );
			float3 indirectDiffuse73 = gi73.indirect.diffuse + diffNorm73 * 0.0001;
			float3 Color_Property31 = (_Color).rgb;
			float3 Surface_Color69 = ( ( ( min( ( temp_output_9_0 * temp_output_9_0 ) , ase_lightAtten ) * ase_lightColor.rgb ) + indirectDiffuse73 ) * Color_Property31 );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult10_g20 = normalize( -refract( -ase_worldViewDir , ase_worldNormal , _RefractETA ) );
			float3 normalizeResult11_g20 = normalize( ase_worldNormal );
			float dotResult8_g20 = dot( normalizeResult10_g20 , normalizeResult11_g20 );
			float temp_output_9_0_g20 = ( dotResult8_g20 * _Size );
			float Est_Refraction_Depth78 = temp_output_9_0_g20;
			float3 temp_cast_1 = (Est_Refraction_Depth78).xxx;
			float3 indirectNormal109 = ase_worldNormal;
			float3 normalizeResult10_g19 = normalize( ase_worldViewDir );
			float3 normalizeResult11_g19 = normalize( ase_worldNormal );
			float dotResult8_g19 = dot( normalizeResult10_g19 , normalizeResult11_g19 );
			float temp_output_9_0_g19 = ( dotResult8_g19 * _Size );
			float Est_Depth79 = temp_output_9_0_g19;
			Unity_GlossyEnvironmentData g109 = UnityGlossyEnvironmentSetup( ( 1.0 - saturate( ( Est_Depth79 * _RefractionScatter ) ) ), data.worldViewDir, indirectNormal109, float3(0,0,0));
			float3 indirectSpecular109 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal109, g109 );
			UnityGI gi14 = gi;
			float3 diffNorm14 = -ase_worldNormal;
			gi14 = UnityGI_Base( data, 1, diffNorm14 );
			float3 indirectDiffuse14 = gi14.indirect.diffuse + diffNorm14 * 0.0001;
			float fresnelNdotV19 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode19 = ( ( 1.0 - Smooth_Property32 ) + 1.0 * pow( 1.0 - fresnelNdotV19, 5.0 ) );
			float3 lerpResult13 = lerp( indirectSpecular109 , indirectDiffuse14 , saturate( fresnelNode19 ));
			float3 Refraction_Color29 = ( pow( Color_Property31 , temp_cast_1 ) * lerpResult13 );
			float Refract_ETA_Property50 = _RefractETA;
			float3 _CorePosition_Instance = UNITY_ACCESS_INSTANCED_PROP(_CorePosition_arr, _CorePosition);
			float3 temp_output_20_0_g22 = _CorePosition_Instance;
			float dotResult26_g22 = dot( -refract( ase_worldViewDir , -ase_worldNormal , Refract_ETA_Property50 ) , ( temp_output_20_0_g22 - ase_worldPos ) );
			float temp_output_2_0_g22 = _CoreRadius;
			float Size_Property49 = _Size;
			float2 appendResult34_g22 = (float2(( 1.0 - ( 4.0 / ( ( distance( ( ( -refract( ase_worldViewDir , -ase_worldNormal , Refract_ETA_Property50 ) * dotResult26_g22 ) + ase_worldPos ) , temp_output_20_0_g22 ) / temp_output_2_0_g22 ) + 4.0 ) ) ) , ( 4.0 / ( ( pow( ( distance( temp_output_20_0_g22 , ase_worldPos ) / temp_output_2_0_g22 ) , _CoreScatterCurve ) * ( _CoreScatterScale * Size_Property49 ) ) + 4.0 ) )));
			float3 lerpResult82 = lerp( float3( 1,1,1 ) , (_CoreTint).rgb , ( _CoreTint.a * (tex2D( _ScatterLUT, appendResult34_g22 )).rgb ));
			#ifdef _SHOWCORE_ON
				float3 staticSwitch53 = ( Refraction_Color29 * lerpResult82 );
			#else
				float3 staticSwitch53 = Refraction_Color29;
			#endif
			float fresnelNdotV60 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode60 = ( _SurfaceDiffuseWeight + 1.0 * pow( 1.0 - fresnelNdotV60, 5.0 ) );
			float3 lerpResult58 = lerp( Surface_Color69 , staticSwitch53 , ( 1.0 - saturate( fresnelNode60 ) ));
			c.rgb = ( surfResult114 + lerpResult58 );
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "Symphonie.StoreAssets.Editor.SlimeMaterialGUI"
}
/*ASEBEGIN
Version=19403
Node;AmplifyShaderEditor.CommentaryNode;3;-3404.447,-1294.673;Inherit;False;1430.473;657.6536;Estimated Depth;13;79;78;77;76;66;50;49;48;34;12;7;6;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;66;-3315.356,-1038.496;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;48;-3011.581,-859.8468;Inherit;False;Property;_Size;Size;4;0;Create;True;0;0;0;True;1;Group(Common);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;76;-2557.656,-886.119;Inherit;False;EstimateSphereDepth;-1;;19;37c209bc3af11864b82b72de1fbd4c27;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;7;FLOAT;1;False;2;FLOAT;0;FLOAT3;13
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-3354.447,-1188.07;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;4;-3712.438,160.4356;Inherit;False;1732.145;1078.55;Refraction Color;23;64;51;33;29;26;25;24;23;22;21;20;19;18;17;16;15;14;13;109;111;110;119;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-2236.178,-886.8054;Inherit;False;Est Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;6;-3132.729,-1244.673;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-3333.751,-887.5735;Inherit;False;Property;_RefractETA;Refract ETA;5;0;Create;True;0;0;0;True;1;Group(Scattering);False;0.85;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-778.1412,-1821.788;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;1;123;0;0;True;1;Group(Common);False;1;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-3568,448;Inherit;False;79;Est Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RefractOpVec;7;-2924.448,-1171.07;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-256.0296,-1822.965;Inherit;False;Smooth Property;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3664,528;Inherit;False;Property;_RefractionScatter;Refraction Scatter;3;0;Create;True;0;0;0;True;1;Group(Scattering,10);False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3344,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-2741.729,-1178.673;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-3552,1088;Inherit;False;32;Smooth Property;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-777.0802,-2021.724;Inherit;False;Property;_Color;Color;0;1;[Gamma];Create;True;0;0;0;True;1;Group(Common, 0);False;0.3764706,0.4862745,0.7372549,1;0.3764706,0.572549,0.8392157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;21;-3152,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;28;-509.9163,-2015.678;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;77;-2580.28,-1094.098;Inherit;False;EstimateSphereDepth;-1;;20;37c209bc3af11864b82b72de1fbd4c27;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;7;FLOAT;1;False;2;FLOAT;0;FLOAT3;13
Node;AmplifyShaderEditor.OneMinusNode;20;-3184,1072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;64;-3488,912;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;1;-1440.482,248.8972;Inherit;False;1535.506;1082.93;Core Color;17;82;81;80;67;47;46;45;44;43;42;41;40;39;38;37;36;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3382.443,-531.2875;Inherit;False;1371.11;633.5644;Surface Color;11;75;74;73;72;71;70;69;11;10;9;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;111;-3184,592;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;119;-2953.001,477.4846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-249.4056,-2011.014;Inherit;False;Color Property;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-2254.178,-1097.805;Inherit;False;Est Refraction Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;17;-3184,880;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;19;-2944,1024;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.04;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-2801.745,-757.2177;Inherit;False;Size Property;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-3253.665,-769.2299;Inherit;False;Refract ETA Property;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;67;-1385.523,467.2215;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;9;-3332.443,-481.2877;Inherit;False;Half Lambert Term;-1;;21;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3542.124,253.7627;Inherit;False;31;Color Property;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-3575.389,339.958;Inherit;False;78;Est Refraction Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;14;-2960,880;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;51;-2624,1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1185.152,941.8539;Inherit;False;49;Size Property;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;43;-1141.7,485.365;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-1207.165,568.468;Inherit;False;50;Refract ETA Property;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;45;-1182.483,298.8972;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-3047.444,-459.2876;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;70;-3323.477,-402.537;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLightEx;109;-2768,656;Inherit;False;World;4;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1190.825,868.5571;Inherit;False;Property;_CoreScatterScale;Core Scatter Scale;9;0;Create;True;0;0;0;False;1;Group(Core);False;0.005;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-3292.422,294.0085;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-959.7343,880.3039;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RefractOpVec;46;-937.4832,445.8972;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;10;-3234.444,-316.2876;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMinOpNode;11;-2881.444,-426.2876;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;13;-2336,592;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;37;-1149.351,1105.827;Inherit;True;Property;_ScatterLUT;Scatter LUT;7;1;[NoScaleOffset];Create;True;0;0;0;True;1;Group(Core);False;fa96176ad89090848ae0c7dd49b93399;fa96176ad89090848ae0c7dd49b93399;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;36;-1143.229,1033.726;Inherit;False;Property;_CoreScatterCurve;Core Scatter Curve;10;0;Create;True;0;0;0;False;1;Group(Core);False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1267.34,788.1969;Inherit;False;Property;_CoreRadius;Core Radius;8;0;Create;True;0;0;0;True;1;Group(Core);False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;39;-1178.712,639.5589;Inherit;False;InstancedProperty;_CorePosition;Core Position;12;1;[PerRendererData];Create;True;0;0;0;True;1;Group(Core);False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;80;-674.4633,652.0727;Inherit;False;CalcCoreScatter;-1;;22;772c1a60e2e34aa43bbb471083420c73;0;7;46;FLOAT3;0,0,0;False;20;FLOAT3;0,0,0;False;2;FLOAT;0;False;41;FLOAT;1;False;43;FLOAT;1;False;10;SAMPLER2D;0;False;12;SAMPLERSTATE;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;73;-3262.95,-203.2562;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2846.444,-321.2876;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2384,336;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;47;-650.6353,455.4785;Inherit;False;Property;_CoreTint;Core Tint;11;1;[HDR];Create;True;0;0;0;True;1;Group(Core);False;0.4156863,0.4156863,0.4156863,1;0.4150943,0.4150943,0.4150943,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-339.9772,602.9944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;81;-392.2682,505.9042;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-3201.778,-115.0256;Inherit;False;31;Color Property;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-2707.95,-203.2562;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-2208,336;Inherit;False;Refraction Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-420.6252,-191.0792;Inherit;False;Property;_SurfaceDiffuseWeight;Surface Diffuse Weight;1;0;Create;True;0;0;0;False;1;Group(Surface, 10);False;0.04;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-281.6602,47.99407;Inherit;False;29;Refraction Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;82;-140.7624,473.7722;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;1,1,1;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2592.334,-147.7233;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;60;-94.80231,-239.1622;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.04;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-34.36243,137.8188;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2384.842,-259.1868;Inherit;False;Surface Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;63;146.7244,-232.7331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;308.2597,-220.3999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;128.9266,-343.8887;Inherit;False;69;Surface Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;116;240,-624;Inherit;False;Constant;_Float1;Float 0;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;192,-800;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;144,-704;Inherit;False;32;Smooth Property;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;53;160.562,24.27606;Inherit;False;Property;_ShowCore;Enable;6;0;Create;False;0;0;0;True;1;Group(Core,30);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;58;542.5072,-282.8906;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;114;448,-784;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;110;-3456,720;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;16;-3184,752;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;800,-496;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;791.7804,-117.8989;Inherit;False;29;Refraction Color;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1200,-720;Float;False;True;-1;3;Symphonie.StoreAssets.Editor.SlimeMaterialGUI;0;0;CustomLighting;Symphonie/Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;120;-2962,606;Inherit;False;594.7026;223.6259;Modified from "Indirect Specular Light" with additional "View Dir" override.;0;Indirect Specular Light Ex;1,1,1,1;0;0
WireConnection;76;5;66;0
WireConnection;76;7;48;0
WireConnection;79;0;76;0
WireConnection;6;0;5;0
WireConnection;7;0;6;0
WireConnection;7;1;66;0
WireConnection;7;2;34;0
WireConnection;32;0;30;0
WireConnection;15;0;22;0
WireConnection;15;1;33;0
WireConnection;12;0;7;0
WireConnection;21;0;15;0
WireConnection;28;0;27;0
WireConnection;77;1;12;0
WireConnection;77;5;66;0
WireConnection;77;7;48;0
WireConnection;20;0;18;0
WireConnection;119;0;21;0
WireConnection;31;0;28;0
WireConnection;78;0;77;0
WireConnection;17;0;64;0
WireConnection;19;1;20;0
WireConnection;49;0;48;0
WireConnection;50;0;34;0
WireConnection;14;0;17;0
WireConnection;51;0;19;0
WireConnection;43;0;67;0
WireConnection;8;0;9;0
WireConnection;8;1;9;0
WireConnection;109;0;111;0
WireConnection;109;1;119;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;42;0;41;0
WireConnection;42;1;40;0
WireConnection;46;0;45;0
WireConnection;46;1;43;0
WireConnection;46;2;44;0
WireConnection;11;0;8;0
WireConnection;11;1;70;0
WireConnection;13;0;109;0
WireConnection;13;1;14;0
WireConnection;13;2;51;0
WireConnection;80;46;46;0
WireConnection;80;20;39;0
WireConnection;80;2;38;0
WireConnection;80;41;42;0
WireConnection;80;43;36;0
WireConnection;80;10;37;0
WireConnection;80;12;37;1
WireConnection;74;0;11;0
WireConnection;74;1;10;1
WireConnection;26;0;24;0
WireConnection;26;1;13;0
WireConnection;35;0;47;4
WireConnection;35;1;80;0
WireConnection;81;0;47;0
WireConnection;75;0;74;0
WireConnection;75;1;73;0
WireConnection;29;0;26;0
WireConnection;82;1;81;0
WireConnection;82;2;35;0
WireConnection;71;0;75;0
WireConnection;71;1;72;0
WireConnection;60;1;61;0
WireConnection;55;0;54;0
WireConnection;55;1;82;0
WireConnection;69;0;71;0
WireConnection;63;0;60;0
WireConnection;62;0;63;0
WireConnection;53;1;54;0
WireConnection;53;0;55;0
WireConnection;58;0;68;0
WireConnection;58;1;53;0
WireConnection;58;2;62;0
WireConnection;114;0;59;0
WireConnection;114;3;59;0
WireConnection;114;4;115;0
WireConnection;114;5;116;0
WireConnection;16;0;110;0
WireConnection;117;0;114;0
WireConnection;117;1;58;0
WireConnection;0;13;117;0
ASEEND*/
//CHKSM=49C030EF065A7990EE68BD429EE8EE36F32FCEBE