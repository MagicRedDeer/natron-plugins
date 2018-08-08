//
//
//                          MMMMMMMMMMMMMMMMMMMMMMMMMMMM
//                        MM.                          .MM
//                       MM.  .MMMMMMMMMMMMMMMMMMMMMM.  .MM
//                      MM.  .MMMMMMMMMMMMMMMMMMMMMMMM.  .MM
//                     MM.  .MMMM        MMMMMMM    MMM.  .MM
//                    MM.  .MMM           MMMMMM     MMM.  .MM
//                   MM.  .MmM              MMMM      MMM.  .MM
//                  MM.  .MMM                 MM       MMM.  .MM
//                 MM.  .MMM                   M        MMM.  .MM
//                MM.  .MMM                              MMM.  .MM
//                 MM.  .MMM                            MMM.  .MM
//                  MM.  .MMM       M                  MMM.  .MM
//                   MM.  .MMM      MM                MMM.  .MM
//                    MM.  .MMM     MMM              MMM.  .MM
//                     MM.  .MMM    MMMM            MMM.  .MM
//                      MM.  .MMMMMMMMMMMMMMMMMMMMMMMM.  .MM
//                       MM.  .MMMMMMMMMMMMMMMMMMMMMM.  .MM
//                        MM.                          .MM
//                          MMMMMMMMMMMMMMMMMMMMMMMMMMMM
//
//
//
//
// Adaptation pour Natron par F. Fernandez
// Code original : crok_ascii_art Matchbox pour Autodesk Flame

// Adapted to Natron by F.Fernandez
// Original code : crok_ascii_art Matchbox for Autodesk Flame


// iChannel0: Source, filter=nearest, wrap=clamp
// iChannel1: Mask, filter=nearest, wrap=clamp
// BBox: iChannel0


// based on https://www.shadertoy.com/view/lsBXzD by CeeJayDK
//A fork of https://www.shadertoy.com/view/lssGDj

/*
ldexp and frexp are available in GLSL with OpenGL 4.0 and up,
in HLSL with SM2.x and up,
but not in OpenGL ES / WebGL.
But we can make our own:
*/




vec2 resolution = vec2(iResolution.x, iResolution.y);
float time = iTime*.01;

uniform float size = 0.5; // Look : (look), min=0.01, max=1.0
uniform float brightness = 0.5; // Brightness : (brightness), min=0.0, max=1.0
uniform bool bw = true;

float ldexp (float mantissa, float exponent)
{
	return exp2(exponent) * mantissa;
}

float frexp (float f, out float exponent)
{
	exponent = ceil(log2(f));
	float mantissa = exp2(-exponent) * f;
	return mantissa;
}

float character(float n, vec2 p) // some compilers have the word "char" reserved
{
  p = floor(p * vec2(8.0,-8.0) + (vec2(-4.0,4.0) + vec2(1.0)) );

	if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 4.0) == p.y)
	{
    	float x = (5.0 * p.y + p.x);
      float signbit = (n < 0.0)
          ? 1.0
          : 0.0 ;
        signbit = (x == 0.0)
          ? signbit
          : 0.0 ;
					return ( fract( abs( n*exp2(-x-1.0))) >= 0.5) ? 1.0 : signbit; //works on AMD and intel
	}
  return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy - 0.5;
	vec2 uv2 = fragCoord.xy / resolution.xy;
  vec2 cursor_position = (floor(uv/8.0)*8.0+0.5)/resolution.xy; //slight blur
	vec4 col = texture2D(iChannel0, cursor_position);
	float m = texture2D(iChannel1, uv2).r;

  float luma = dot(col.rgb,vec3(0.2126, 0.7152, 0.0722)) * m;

	float gray = smoothstep(0.0,1.0,luma); //increase contrast
  float num_of_chars = 16. ;
  float n12   = (gray < (1./num_of_chars))  ? 0.        : 4194304. ; //   or .
	float n34   = (gray < (3./num_of_chars))  ? 131200.   : 324.     ; // : or ^
  float n56   = (gray < (5./num_of_chars))  ? 330.      : 283712.  ; // " or ~
  float n78   = (gray < (7./num_of_chars))  ? 12650880. : 4532768. ; // c or v
  float n910  = (gray < (9./num_of_chars))  ? 13191552. : 10648704.; // o or *
  float n1112 = (gray < (11./num_of_chars)) ? 11195936. : 15218734.; // w or S
  float n1314 = (gray < (13./num_of_chars)) ? 15255086. : 15252014.; // O or 8
  float n1516 = (gray < (15./num_of_chars)) ? 15324974. : 11512810.; // 0 or # //forgot about Q

  float n1234     = (gray < (2./num_of_chars))  ? n12   : n34;
  float n5678     = (gray < (6./num_of_chars))  ? n56   : n78;
  float n9101112  = (gray < (10./num_of_chars)) ? n910  : n1112;
  float n13141516 = (gray < (14./num_of_chars)) ? n1314 : n1516;
  float n12345678 = (gray < (4./num_of_chars)) ? n1234 : n5678;
  float n910111213141516 = (gray < (12./num_of_chars)) ? n9101112 : n13141516;
  float n = (gray < (8./num_of_chars)) ? n12345678 : n910111213141516;

  vec2 p = fract(uv * 0.25 * size);

	col = col *character(n, p) * (brightness + 1.0);
	if ( bw )
		col = mix(vec4(character(n, p)), luma * vec4(character(n, p)), brightness * - 1.0 + 1.0);

	fragColor = col;
}
