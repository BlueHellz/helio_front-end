// GLSL sources for Limyè OpenGL backdrop (GLES 3.0 / GLSL 1.50).

import 'dart:io';

import 'package:flutter/foundation.dart';

String limyeShaderVersion() {
  if (kIsWeb) return '#version 300 es';
  if (Platform.isMacOS || Platform.isWindows) return '#version 150';
  return '#version 300 es';
}

String limyePrecisionFloat() {
  final v = limyeShaderVersion();
  return v.contains('es') ? 'precision highp float;\n' : '';
}

String limyeGridVertex() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  return '''
$v
$prec
uniform mat4 u_mvp;
in vec3 a_pos;
out vec3 v_world;
void main() {
  v_world = a_pos;
  gl_Position = u_mvp * vec4(a_pos, 1.0);
}
''';
}

String limyeGridFragment() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  final fragOut = v.contains('es') ? 'out highp vec4 o_fragColor;' : 'out vec4 o_fragColor;';
  return '''
$v
$prec
$fragOut
in vec3 v_world;
uniform vec3 u_camera;
uniform vec3 u_fogColor;
uniform float u_fogNear;
uniform float u_fogFar;
uniform vec3 u_gridColor;
uniform float u_half;
uniform float u_step;
uniform float u_fadeRadius;

float gridLine(float coord, float stepv) {
  float q = coord / stepv;
  float d = min(abs(q - floor(q + 0.5)), abs(q - ceil(q - 0.5)));
  return abs(d * stepv);
}

float maskLine(float distToLine, float w) {
  return 1.0 - smoothstep(0.0, w, distToLine);
}

void main() {
  vec3 w = v_world;
  float xz = w.x * w.x + w.z * w.z;
  if (abs(w.y + 2.0) > 0.05 || abs(w.x) > u_half + 0.001 || abs(w.z) > u_half + 0.001) discard;

  float rad = sqrt(xz);
  float radialAlpha = clamp(1.0 - rad / u_fadeRadius, 0.0, 1.0);
  if (radialAlpha < 0.01) discard;

  float dx = gridLine(w.x, u_step);
  float dz = gridLine(w.z, u_step);
  float minor = maskLine(min(dx, dz), 0.075);

  float dxM = gridLine(w.x, u_step * 5.0);
  float dzM = gridLine(w.z, u_step * 5.0);
  float major = maskLine(min(dxM, dzM), 0.11) * 0.35;

  float lineA = clamp(minor + major, 0.0, 1.0) * radialAlpha * 0.55;

  float distCam = length(u_camera - w);
  float fog = clamp((u_fogFar - distCam) / (u_fogFar - u_fogNear), 0.0, 1.0);
  fog *= exp(-0.018 * max(distCam - u_fogNear, 0.0));

  vec3 col = u_gridColor;
  o_fragColor = vec4(col, lineA * fog);
}
''';
}

String limyeLineVertex() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  return '''
$v
$prec
uniform mat4 u_mvp;
in vec3 a_pos;
out vec3 v_world;
void main() {
  v_world = a_pos;
  gl_Position = u_mvp * vec4(a_pos, 1.0);
}
''';
}

String limyeLineFragment() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  final fragOut = v.contains('es') ? 'out highp vec4 o_fragColor;' : 'out vec4 o_fragColor;';
  return '''
$v
$prec
$fragOut
in vec3 v_world;
uniform vec3 u_camera;
uniform vec3 u_fogColor;
uniform float u_fogNear;
uniform float u_fogFar;
uniform vec4 u_color;

void main() {
  float distCam = length(u_camera - v_world);
  float fog = clamp((u_fogFar - distCam) / (u_fogFar - u_fogNear), 0.0, 1.0);
  fog *= exp(-0.018 * max(distCam - u_fogNear, 0.0));
  vec3 rgb = mix(u_fogColor, u_color.rgb, fog);
  o_fragColor = vec4(rgb, u_color.a * fog);
}
''';
}

String limyePhongVertex() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  return '''
$v
$prec
uniform mat4 u_mvp;
uniform mat4 u_model;
uniform mat3 u_normalMat;
in vec3 a_pos;
in vec3 a_nor;
out vec3 v_world;
out vec3 v_normal;
void main() {
  vec4 wp = u_model * vec4(a_pos, 1.0);
  v_world = wp.xyz;
  v_normal = normalize(u_normalMat * a_nor);
  gl_Position = u_mvp * vec4(a_pos, 1.0);
}
''';
}

String limyePhongFragment() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  final fragOut = v.contains('es') ? 'out highp vec4 o_fragColor;' : 'out vec4 o_fragColor;';
  return '''
$v
$prec
$fragOut
in vec3 v_world;
in vec3 v_normal;

uniform vec3 u_camera;
uniform vec3 u_baseColor;
uniform vec3 u_fogColor;
uniform float u_fogNear;
uniform float u_fogFar;
uniform float u_shininess;
uniform float u_emissive;
uniform int u_unlit;

#define MAX_LIGHTS 8
uniform int u_numLights;
uniform vec3 u_lightPos[MAX_LIGHTS];
uniform vec3 u_lightColor[MAX_LIGHTS];
uniform float u_lightRange[MAX_LIGHTS];
uniform float u_lightIntensity[MAX_LIGHTS];

float atten(float d, float range) {
  if (range <= 0.001) return 0.0;
  return pow(clamp(1.0 - d / range, 0.0, 1.0), 2.0);
}

void main() {
  vec3 N = normalize(v_normal);
  vec3 V = normalize(u_camera - v_world);
  vec3 color = u_baseColor;

  if (u_unlit == 1) {
    color = u_baseColor;
  } else {
    vec3 lit = vec3(0.0);
    for (int i = 0; i < MAX_LIGHTS; i++) {
      if (i < u_numLights) {
      vec3 Lp = u_lightPos[i];
      vec3 L = Lp - v_world;
      float dist = length(L);
      if (dist > 1e-4) {
      L /= dist;
      float att = atten(dist, u_lightRange[i]) * u_lightIntensity[i];
      float NdL = max(dot(N, L), 0.0);
      vec3 diffuse = u_lightColor[i] * NdL * att;
      vec3 H = normalize(L + V);
      float spec = pow(max(dot(N, H), 0.0), u_shininess);
      vec3 specular = u_lightColor[i] * spec * att * 0.35;
      lit += diffuse + specular;
      }
      }
    }
    color = u_baseColor * (0.14 + lit) + vec3(u_emissive);
  }

  float distCam = length(u_camera - v_world);
  float fog = clamp((u_fogFar - distCam) / (u_fogFar - u_fogNear), 0.0, 1.0);
  fog *= exp(-0.018 * max(distCam - u_fogNear, 0.0));
  vec3 outc = mix(u_fogColor, color, fog);
  o_fragColor = vec4(outc, 1.0);
}
''';
}

String limyeGlowVertex() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  return '''
$v
$prec
uniform mat4 u_mvp;
in vec3 a_pos;
void main() {
  gl_Position = u_mvp * vec4(a_pos, 1.0);
}
''';
}

String limyeGlowFragment() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  final fragOut = v.contains('es') ? 'out highp vec4 o_fragColor;' : 'out vec4 o_fragColor;';
  return '''
$v
$prec
$fragOut
uniform vec3 u_camera;
uniform vec3 u_worldCenter;
uniform vec3 u_color;
uniform float u_alpha;
uniform vec3 u_fogColor;
uniform float u_fogNear;
uniform float u_fogFar;

void main() {
  vec3 w = u_worldCenter;
  float distCam = length(u_camera - w);
  float fog = clamp((u_fogFar - distCam) / (u_fogFar - u_fogNear), 0.0, 1.0);
  vec3 c = u_color * u_alpha * fog;
  o_fragColor = vec4(c, u_alpha * fog);
}
''';
}

String limyeParticleVertex() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  return '''
$v
$prec
uniform mat4 u_mvp;
uniform float u_time;
uniform float u_dt;
uniform vec3 u_beacon;
uniform vec3 u_camera;
uniform float u_pointScale;

in vec3 a_base;
in vec3 a_rand;
in float a_size;
in vec3 a_color;

out vec3 v_color;
out float v_size;

void main() {
  float t = u_time;
  float ox = sin(t * 0.2 * a_rand.x + a_rand.y) * 0.5;
  float oy = cos(t * 0.15 * a_rand.x + a_rand.z) * 0.3;
  float oz = sin(t * 0.1 * a_rand.x + a_rand.y * 1.57) * 0.5;
  vec3 p = a_base + vec3(ox, oy, oz);
  vec3 toB = u_beacon - p;
  float dist = length(toB);
  if (dist < 15.0 && dist > 1e-5) {
    p += normalize(toB) * (1.0 - dist / 15.0) * 0.02 * u_dt;
  }
  vec4 clip = u_mvp * vec4(p, 1.0);
  gl_Position = clip;
  float distCam = length(u_camera - p);
  gl_PointSize = max(a_size * u_pointScale / max(distCam, 0.5), 1.0);
  v_color = a_color;
  v_size = a_size;
}
''';
}

String limyeParticleFragment() {
  final v = limyeShaderVersion();
  final prec = limyePrecisionFloat();
  final fragOut = v.contains('es') ? 'out highp vec4 o_fragColor;' : 'out vec4 o_fragColor;';
  return '''
$v
$prec
$fragOut
in vec3 v_color;
in float v_size;

void main() {
  vec2 q = gl_PointCoord.xy - vec2(0.5);
  float r = length(q) * 2.0;
  float a = 1.0 - smoothstep(0.85, 1.0, r);
  o_fragColor = vec4(v_color, a);
}
''';
}
