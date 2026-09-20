// BodycamNightVision.fx
// Night-vision-goggle look: light amplification, green phosphor tint, grain,
// glow around bright spots and an optional goggle-tube vignette.
//
// Toggle key: N (rebind in ReShade's Home tab if it clashes with a game bind).
// Put this LAST in your technique order so sharpening happens before the grain is added.
//
// It measures the average brightness of the scene (smoothed over time) and, when
// "Low-Light Only" is up, fades the effect out in bright scenes so lit rooms
// don't get blown out.

#include "ReShade.fxh"

// ------------------------------------------------------------------
// Settings
// ------------------------------------------------------------------

uniform float Strength <
    ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Overall Strength";
    ui_category = "Activation";
> = 1.0;

uniform float LowLightBlend <
    ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Low-Light Only";
    ui_tooltip = "1.0 = effect fades out in bright scenes and only shows in the dark.\n0.0 = effect is always fully on while toggled.";
    ui_category = "Activation";
> = 1.0;

uniform float DarkThreshold <
    ui_type = "slider"; ui_min = 0.02; ui_max = 0.40; ui_step = 0.005;
    ui_label = "Low-Light Threshold";
    ui_tooltip = "Average scene brightness below which the goggles are fully active. Raise it to make the effect kick in earlier.";
    ui_category = "Activation";
> = 0.10;

uniform float AdaptTime <
    ui_type = "slider"; ui_min = 0.1; ui_max = 5.0; ui_step = 0.05;
    ui_label = "Adaptation Time (seconds)";
    ui_tooltip = "How slowly the effect fades in and out as the scene brightness changes.";
    ui_category = "Activation";
> = 1.0;

uniform float Gain <
    ui_type = "slider"; ui_min = 1.0; ui_max = 20.0; ui_step = 0.1;
    ui_label = "Light Amplification";
    ui_category = "Image";
> = 5.0;

uniform float AutoGain <
    ui_type = "slider"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.05;
    ui_label = "Auto Gain (darker = brighter)";
    ui_tooltip = "Boosts amplification further the darker the scene is.";
    ui_category = "Image";
> = 1.0;

uniform float3 TubeColor <
    ui_type = "color";
    ui_label = "Phosphor Color";
    ui_tooltip = "Classic green by default. Set to white/grey for a white-phosphor look.";
    ui_category = "Image";
> = float3(0.20, 1.00, 0.35);

uniform float ColorRetention <
    ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Keep Original Colors";
    ui_category = "Image";
> = 0.0;

uniform float BloomStrength <
    ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Glow";
    ui_category = "Image";
> = 0.35;

uniform float BloomRadius <
    ui_type = "slider"; ui_min = 1.0; ui_max = 12.0; ui_step = 0.1;
    ui_label = "Glow Radius";
    ui_category = "Image";
> = 5.0;

uniform float NoiseAmount <
    ui_type = "slider"; ui_min = 0.0; ui_max = 0.5; ui_step = 0.005;
    ui_label = "Grain";
    ui_category = "Image";
> = 0.12;

uniform float GrainSize <
    ui_type = "slider"; ui_min = 1.0; ui_max = 4.0; ui_step = 0.1;
    ui_label = "Grain Size";
    ui_category = "Image";
> = 1.5;

uniform float MaskStrength <
    ui_type = "slider"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.01;
    ui_label = "Goggle Tube Vignette";
    ui_tooltip = "Darkens the edges of the screen like looking through goggle tubes.";
    ui_category = "Goggle Mask";
> = 0.5;

uniform float MaskRadius <
    ui_type = "slider"; ui_min = 0.3; ui_max = 1.1; ui_step = 0.01;
    ui_label = "Mask Radius";
    ui_category = "Goggle Mask";
> = 0.75;

uniform float MaskSoftness <
    ui_type = "slider"; ui_min = 0.05; ui_max = 0.8; ui_step = 0.01;
    ui_label = "Mask Softness";
    ui_category = "Goggle Mask";
> = 0.35;

uniform float timer < source = "timer"; >;
uniform float frametime < source = "frametime"; >;

// ------------------------------------------------------------------
// Scene brightness measurement (smoothed over time)
// ------------------------------------------------------------------

texture NVG_LumaTex { Width = 128; Height = 128; Format = R16F; MipLevels = 8; };
sampler sNVG_Luma { Texture = NVG_LumaTex; };

texture NVG_AdaptTex { Width = 1; Height = 1; Format = R16F; };
sampler sNVG_Adapt { Texture = NVG_AdaptTex; };

texture NVG_PrevTex { Width = 1; Height = 1; Format = R16F; };
sampler sNVG_Prev { Texture = NVG_PrevTex; };

static const float3 LUMA = float3(0.2126, 0.7152, 0.0722);

static const float2 Ring[8] =
{
    float2( 1.0000,  0.0000), float2( 0.7071,  0.7071),
    float2( 0.0000,  1.0000), float2(-0.7071,  0.7071),
    float2(-1.0000,  0.0000), float2(-0.7071, -0.7071),
    float2( 0.0000, -1.0000), float2( 0.7071, -0.7071)
};

float Hash12(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

float Amplify(float l, float g)
{
    // Exponential response: strongly lifts darks, rolls off smoothly toward white
    return 1.0 - exp(-max(l, 0.0) * g);
}

float PS_LumaDownsample(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 c = tex2D(ReShade::BackBuffer, uv).rgb;
    return dot(c, LUMA);
}

float PS_Adapt(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    // Top mip of the 128x128 texture (level 7) is the average brightness of the whole frame
    float current  = tex2Dlod(sNVG_Luma, float4(0.5, 0.5, 0.0, 7.0)).r;
    float previous = tex2D(sNVG_Prev, float2(0.5, 0.5)).r;
    float t = 1.0 - exp(-frametime * 0.001 / max(AdaptTime, 0.01));
    return lerp(previous, current, t);
}

float PS_StorePrevious(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    return tex2D(sNVG_Adapt, float2(0.5, 0.5)).r;
}

// ------------------------------------------------------------------
// Main effect
// ------------------------------------------------------------------

float4 PS_NightVision(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 col  = tex2D(ReShade::BackBuffer, uv).rgb;
    float  luma = dot(col, LUMA);

    // How dark is the scene overall, and how much of the effect to show
    float sceneLuma = tex2D(sNVG_Adapt, float2(0.5, 0.5)).r;
    float dark   = 1.0 - smoothstep(DarkThreshold * 0.6, DarkThreshold * 1.4, sceneLuma);
    float amount = lerp(1.0, dark, LowLightBlend) * Strength;

    // Image-intensifier response
    float gain = Gain * (1.0 + AutoGain * dark);
    float v = Amplify(luma, gain);

    // Glow around bright spots
    float radius = BloomRadius * BUFFER_HEIGHT / 1080.0;
    float glow = 0.0;
    [unroll]
    for (int i = 0; i < 8; i++)
    {
        float3 s = tex2D(ReShade::BackBuffer, uv + Ring[i] * ReShade::PixelSize * radius).rgb;
        glow += Amplify(dot(s, LUMA), gain);
    }
    glow *= 0.125;
    v += BloomStrength * max(glow - 0.5, 0.0);

    // Grain: stronger in the darker parts of the image
    float2 seed = floor(uv * float2(BUFFER_WIDTH, BUFFER_HEIGHT) / GrainSize) + frac(timer * 0.001) * 1000.0;
    float n = Hash12(seed) + Hash12(seed + 17.0) - 1.0;
    v += n * NoiseAmount * lerp(1.0, 0.3, saturate(v));
    v = saturate(v);

    // Goggle tube vignette (aspect-corrected so it stays circular)
    float aspect = (float)BUFFER_WIDTH / (float)BUFFER_HEIGHT;
    float r = length((uv - 0.5) * float2(aspect, 1.0));
    float mask = 1.0 - smoothstep(MaskRadius, MaskRadius + MaskSoftness, r);
    v *= lerp(1.0, mask, MaskStrength);

    // Phosphor tint, optionally blended with the original colors
    float3 nvg  = v * TubeColor;
    float3 keep = saturate(col * (v / max(luma, 0.02)));
    nvg = lerp(nvg, keep, ColorRetention);

    return float4(saturate(lerp(col, nvg, amount)), 1.0);
}

technique BodycamNightVision <
    ui_label = "Bodycam Night Vision";
    ui_tooltip = "Green night-vision-goggle look that fades in when the scene is dark.\nToggle key: N (rebind in the Home tab).";
    toggle = 0x4E;
>
{
    pass LumaDownsample
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_LumaDownsample;
        RenderTarget = NVG_LumaTex;
    }
    pass Adapt
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_Adapt;
        RenderTarget = NVG_AdaptTex;
    }
    pass StorePrevious
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_StorePrevious;
        RenderTarget = NVG_PrevTex;
    }
    pass Apply
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_NightVision;
    }
}
