import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

import 'package:three_js_math/three_js_math.dart'
    show AdditiveBlending, DoubleSide, LinearFilter, RGBAFormat, UnsignedByteType;

/// Full-screen Limyè 3D backdrop (three_js / ANGLE). Non-interactive; place first in a [Stack].
///
/// Frames and delta time are driven by [three.ThreeJS]'s internal [Ticker] (see `three_viewer.dart`),
/// which calls registered animation callbacks with [Clock.getDelta] each frame.
class LimyeBackground extends StatefulWidget {
  const LimyeBackground({super.key});

  @override
  State<LimyeBackground> createState() => _LimyeBackgroundState();
}

class _LimyeBackgroundState extends State<LimyeBackground> {
  late three.ThreeJS _three;
  final _handles = _LimyeHandles();
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    _three = three.ThreeJS(
      settings: three.Settings(
        clearColor: 0x13161a,
        clearAlpha: 1.0,
        antialias: true,
        alpha: false,
      ),
      onSetupComplete: () {
        if (mounted) setState(() => _inited = true);
      },
      setup: _setupScene,
    );
  }

  Future<void> _setupScene() async {
    _three.camera = three.PerspectiveCamera(
      45,
      _three.width / (_three.height < 1e-6 ? 1 : _three.height),
      0.1,
      100,
    );
    _three.camera.position.setValues(0, 3, 12);
    _three.camera.lookAt(three.Vector3(0, 1.5, 15));

    _three.scene = three.Scene();

    await _buildLimyeScene(_three, _handles);

    _three.addAnimationEvent((dt) {
      _handles.step(dt, _three.camera as three.PerspectiveCamera);
    });
  }

  @override
  void dispose() {
    _three.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: !_inited ? const ColoredBox(color: Color(0xFF13161A)) : _three.build(),
      ),
    );
  }
}

/// Mutable scene handles updated each animation frame.
class _LimyeHandles {
  three.Group? needle;
  three.ShaderMaterial? gridMaterial;
  three.MeshBasicMaterial? beaconGlowMaterial;
  three.BufferGeometry? particleGeometry;
  final List<three.Mesh> constellationMeshes = [];

  final three.Vector3 _beaconWorld = three.Vector3(0, 1.5, 30);

  /// Base [x,y,z] for each constellation node (unanimated).
  final List<List<double>> nodeBases = const [
    [-8.0, 2.0, 25.0],
    [-4.0, 3.5, 20.0],
    [0.0, 4.2, 15.0],
    [4.0, 3.8, 10.0],
    [7.0, 2.5, 5.0],
    [10.0, 1.2, 0.0],
  ];

  final List<double> pR1 = [];
  final List<double> pR2 = [];
  final List<double> pR3 = [];
  final List<double> pBaseX = [];
  final List<double> pBaseY = [];
  final List<double> pBaseZ = [];

  double time = 0;

  void step(double dt, three.PerspectiveCamera camera) {
    time += dt;
    if (needle != null) {
      needle!.rotation.y += dt * math.pi / 180;
    }
    if (beaconGlowMaterial != null) {
      beaconGlowMaterial!.opacity = math.sin(time * 2 * math.pi / 3) * 0.05 + 0.35;
      beaconGlowMaterial!.needsUpdate = true;
    }
    if (gridMaterial != null) {
      final u = gridMaterial!.uniforms['uCameraPos'];
      if (u != null) {
        (u['value'] as three.Vector3).setFrom(camera.position);
      }
    }

    final geo = particleGeometry;
    if (geo != null && pBaseX.isNotEmpty) {
      final posAttr = geo.getAttributeFromString('position') as three.Float32BufferAttribute;
      for (var i = 0; i < pBaseX.length; i++) {
        final tt = time;
        final ox = math.sin(tt * 0.2 * pR1[i] + pR2[i]) * 0.5;
        final oy = math.cos(tt * 0.15 * pR1[i] + pR3[i]) * 0.3;
        final oz = math.sin(tt * 0.1 * pR1[i] + pR2[i] * 1.57) * 0.5;
        var x = pBaseX[i] + ox;
        var y = pBaseY[i] + oy;
        var z = pBaseZ[i] + oz;
        final dx = _beaconWorld.x - x;
        final dy = _beaconWorld.y - y;
        final dz = _beaconWorld.z - z;
        final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
        if (dist < 15) {
          final w = (1 - dist / 15) * 0.02;
          x += dx * w;
          y += dy * w;
          z += dz * w;
        }
        posAttr.setXYZ(i, x, y, z);
      }
      posAttr.needsUpdate = true;
    }

    for (var i = 0; i < constellationMeshes.length; i++) {
      final m = constellationMeshes[i];
      final p = nodeBases[i];
      final bob = math.sin(time + i * 0.77) * 0.3;
      m.position.setValues(p[0], p[1] + bob, p[2]);
    }
  }
}

three.DataTexture _softParticleTexture() {
  const n = 64;
  final data = Uint8List(n * n * 4);
  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      final dx = x / (n - 1) - 0.5;
      final dy = y / (n - 1) - 0.5;
      final d = math.sqrt(dx * dx + dy * dy) * 2;
      final a = ((1 - d.clamp(0.0, 1.0)) * 255).round();
      final i = (y * n + x) * 4;
      data[i] = 255;
      data[i + 1] = 255;
      data[i + 2] = 255;
      data[i + 3] = a;
    }
  }
  final tex = three.DataTexture(data, n, n, RGBAFormat, UnsignedByteType);
  tex.needsUpdate = true;
  tex.generateMipmaps = false;
  tex.minFilter = LinearFilter;
  tex.magFilter = LinearFilter;
  return tex;
}

Future<void> _buildLimyeScene(three.ThreeJS threeJs, _LimyeHandles h) async {
  final scene = threeJs.scene;
  const goldHex = 0xc8964a;
  const fogColor = 0x13161a;

  scene.fog = three.FogExp2(fogColor, 0.015);

  scene.add(three.AmbientLight(0xffffff, 0.06));

  final gridVert = '''
varying vec3 vWorldPosition;
void main() {
  vWorldPosition = (modelMatrix * vec4(position, 1.0)).xyz;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
''';

  final gridFrag = '''
varying vec3 vWorldPosition;
uniform vec3 uGridColor;
uniform vec3 uCameraPos;
uniform vec3 uFogColor;
uniform float uFogNear;
uniform float uFogFar;
uniform float uHalf;
uniform float uStep;
uniform float uFadeR;

void main() {
  vec3 w = vWorldPosition;
  if (abs(w.y + 2.0) > 0.06) discard;
  if (abs(w.x) > uHalf + 0.001 || abs(w.z) > uHalf + 0.001) discard;

  float rad = length(w.xz);
  float radial = 1.0 - rad / uFadeR;
  if (radial < 0.02) discard;

  vec2 xz = w.xz;
  float gx = abs(fract(xz.x / uStep + 0.5) - 0.5) * uStep;
  float gz = abs(fract(xz.y / uStep + 0.5) - 0.5) * uStep;
  float minor = 1.0 - smoothstep(0.0, 0.12, min(gx, gz));
  float stepM = uStep * 5.0;
  float gmx = abs(fract(xz.x / stepM + 0.5) - 0.5) * stepM;
  float gmz = abs(fract(xz.y / stepM + 0.5) - 0.5) * stepM;
  float major = (1.0 - smoothstep(0.0, 0.18, min(gmx, gmz))) * 0.35;
  float alpha = clamp(minor + major, 0.0, 1.0) * radial * 0.5;

  float distCam = distance(w, uCameraPos);
  float fogF = clamp((uFogFar - distCam) / (uFogFar - uFogNear), 0.0, 1.0);
  fogF *= exp(-0.018 * max(distCam - uFogNear, 0.0));
  vec3 rgb = mix(uFogColor, uGridColor, fogF);

  gl_FragColor = vec4(rgb, alpha);
}
''';

  final gridMat = three.ShaderMaterial.fromMap({
    'uniforms': {
      'uGridColor': {'value': three.Vector3(0x23 / 255.0, 0x28 / 255.0, 0x30 / 255.0)},
      'uCameraPos': {'value': three.Vector3.copy(threeJs.camera.position)},
      'uFogColor': {'value': three.Vector3(0x13 / 255.0, 0x16 / 255.0, 0x1a / 255.0)},
      'uFogNear': {'value': 10.0},
      'uFogFar': {'value': 60.0},
      'uHalf': {'value': 100.0},
      'uStep': {'value': 48.0},
      'uFadeR': {'value': 50.0},
    },
    'vertexShader': gridVert,
    'fragmentShader': gridFrag,
    'transparent': true,
    'depthWrite': true,
    'side': DoubleSide,
  });
  h.gridMaterial = gridMat;

  final gridMesh = three.Mesh(three.PlaneGeometry(200, 200, 1, 1), gridMat);
  gridMesh.rotation.x = -math.pi / 2;
  gridMesh.position.y = -2;
  scene.add(gridMesh);

  for (final r in [24.0, 38.8, 62.8, 101.6]) {
    final ring = three.Mesh(
      three.RingGeometry(math.max(0.01, r - 0.03), r + 0.03, 128),
      three.MeshBasicMaterial.fromMap({
        'color': goldHex,
        'transparent': true,
        'opacity': 0.08,
        'side': DoubleSide,
        'depthWrite': false,
      }),
    );
    ring.rotation.x = -math.pi / 2;
    ring.position.y = -1.95;
    scene.add(ring);
  }

  final needleMat = three.MeshStandardMaterial.fromMap({
    'color': goldHex,
    'metalness': 0.8,
    'roughness': 0.3,
    'emissive': goldHex,
    'emissiveIntensity': 0.2,
  });

  final topGeom = three.ConeGeometry(0.2, 1.5, 28)..translate(0, 0.75, 0);
  final botGeom = three.ConeGeometry(0.2, 1.5, 28)
    ..translate(0, -0.75, 0)
    ..rotateX(math.pi);

  final needle = three.Group();
  needle.add(three.Mesh(topGeom, needleMat));
  needle.add(three.Mesh(botGeom, needleMat));
  needle.position.setValues(0, 1.5, 0);

  final needleLight = three.PointLight(goldHex, 1.5, 10);
  needle.add(needleLight);

  scene.add(needle);
  h.needle = needle;

  final beaconCore = three.Mesh(
    three.SphereGeometry(0.3, 24, 18),
    three.MeshBasicMaterial.fromMap({'color': goldHex}),
  );
  beaconCore.position.setValues(0, 1.5, 30);
  scene.add(beaconCore);

  final glowMat = three.MeshBasicMaterial.fromMap({
    'color': goldHex,
    'transparent': true,
    'opacity': 0.35,
    'depthWrite': false,
  });
  glowMat.blending = AdditiveBlending;
  h.beaconGlowMaterial = glowMat;

  final glowMesh = three.Mesh(
    three.SphereGeometry(1.2, 28, 20),
    glowMat,
  );
  glowMesh.position.setValues(0, 1.5, 30);
  scene.add(glowMesh);

  final beaconPl = three.PointLight(goldHex, 2, 20);
  beaconCore.add(beaconPl);

  final lineGeom = three.BufferGeometry().setFromPoints([
    three.Vector3(0, 3, 0),
    three.Vector3.copy(h._beaconWorld),
  ]);
  final lineMat = three.LineBasicMaterial.fromMap({
    'color': goldHex,
    'transparent': true,
    'opacity': 0.15,
    'depthWrite': true,
    'linewidth': 1,
  });
  scene.add(three.Line(lineGeom, lineMat));

  const nPart = 400;
  final rnd = math.Random(42);
  final positions = Float32List(nPart * 3);
  final colors = Float32List(nPart * 3);
  final sizes = Float32List(nPart);
  h.pR1.clear();
  h.pR2.clear();
  h.pR3.clear();
  h.pBaseX.clear();
  h.pBaseY.clear();
  h.pBaseZ.clear();

  const cx = 0.0, cy = 1.5, cz = 15.0;
  for (var i = 0; i < nPart; i++) {
    final u = rnd.nextDouble();
    final v = rnd.nextDouble();
    final theta = 2 * math.pi * u;
    final phi = math.acos(2 * v - 1);
    final rad = 20 * math.pow(rnd.nextDouble(), 1 / 3).toDouble();
    final x = rad * math.sin(phi) * math.cos(theta);
    final yy = rad * math.sin(phi) * math.sin(theta) * 0.35;
    final z = rad * math.cos(phi);
    final bx = cx + x;
    final byy = cy + yy;
    final bz = cz + z;
    h.pBaseX.add(bx);
    h.pBaseY.add(byy);
    h.pBaseZ.add(bz);
    h.pR1.add(rnd.nextDouble() * 2 + 0.2);
    h.pR2.add(rnd.nextDouble() * 6.28318);
    h.pR3.add(rnd.nextDouble() * 6.28318);
    final ix = i * 3;
    positions[ix] = bx;
    positions[ix + 1] = byy;
    positions[ix + 2] = bz;
    sizes[i] = 0.02 + rnd.nextDouble() * 0.08;
    final gold = rnd.nextDouble() < 0.3;
    if (gold) {
      colors[ix] = 0xc8 / 255.0;
      colors[ix + 1] = 0x96 / 255.0;
      colors[ix + 2] = 0x4a / 255.0;
    } else {
      colors[ix] = 0xe6 / 255.0;
      colors[ix + 1] = 0xed / 255.0;
      colors[ix + 2] = 0xf3 / 255.0;
    }
  }

  final pGeo = three.BufferGeometry();
  pGeo.setAttributeFromString('position', three.Float32BufferAttribute.fromList(positions, 3, false));
  pGeo.setAttributeFromString('color', three.Float32BufferAttribute.fromList(colors, 3, false));
  pGeo.setAttributeFromString('size', three.Float32BufferAttribute.fromList(sizes, 1, false));
  h.particleGeometry = pGeo;

  final spriteMap = _softParticleTexture();
  final pMat = three.PointsMaterial.fromMap({
    'size': 0.065,
    'sizeAttenuation': true,
    'vertexColors': true,
    'map': spriteMap,
    'transparent': true,
    'depthWrite': false,
    'opacity': 0.95,
  });
  pMat.blending = AdditiveBlending;
  scene.add(three.Points(pGeo, pMat));

  final nodeMat = three.MeshStandardMaterial.fromMap({
    'color': goldHex,
    'emissive': goldHex,
    'emissiveIntensity': 1.0,
    'metalness': 0.5,
    'roughness': 0.35,
  });

  for (var i = 0; i < h.nodeBases.length; i++) {
    final p = h.nodeBases[i];
    final m = three.Mesh(three.SphereGeometry(0.15, 18, 14), nodeMat.clone());
    m.position.setValues(p[0], p[1], p[2]);
    final nl = three.PointLight(goldHex, 0.5, 5);
    m.add(nl);
    scene.add(m);
    h.constellationMeshes.add(m);
  }

  for (var k = 0; k < h.nodeBases.length - 1; k++) {
    final p0 = h.nodeBases[k];
    final p1 = h.nodeBases[k + 1];
    final midY = math.max(p0[1], p1[1]) + 1.5;
    final c = three.QuadraticBezierCurve3(
      three.Vector3(p0[0], p0[1], p0[2]),
      three.Vector3((p0[0] + p1[0]) * 0.5, midY, (p0[2] + p1[2]) * 0.5),
      three.Vector3(p1[0], p1[1], p1[2]),
    );
    final tube = three.TubeGeometry(c, 56, 0.018, 6, false);
    final tm = three.MeshBasicMaterial.fromMap({
      'color': goldHex,
      'transparent': true,
      'opacity': 0.2,
      'side': DoubleSide,
    });
    scene.add(three.Mesh(tube, tm));
  }
}
