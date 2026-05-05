import 'dart:math' as math;
import 'dart:typed_data';

/// Vertex layout: position (3) + normal (3) interleaved.
Float32List buildGridPlaneY({
  required double y,
  required double half,
}) {
  return Float32List.fromList([
    -half, y, -half,
    half, y, -half,
    half, y, half,
    -half, y, -half,
    half, y, half,
    -half, y, half,
  ]);
}

Float32List buildRingLineXZ({
  required double y,
  required double radius,
  int segments = 96,
}) {
  final out = Float32List((segments + 1) * 3);
  for (var i = 0; i <= segments; i++) {
    final t = (i / segments) * math.pi * 2;
    out[i * 3] = radius * math.cos(t);
    out[i * 3 + 1] = y;
    out[i * 3 + 2] = radius * math.sin(t);
  }
  return out;
}

/// Double cone needle in local space: merged at y=0, apex at ±1.5, waist radius 0.2.
(Float32List positions, Float32List normals, Uint16List indices) buildDiamondNeedle({
  int segments = 28,
  double radius = 0.2,
  double halfHeight = 1.5,
}) {
  final nVerts = segments * 2 + 2;
  final pos = Float32List(nVerts * 3);
  final nor = Float32List(nVerts * 3);
  final top = 0;
  final bottom = 1;
  var base = 2;
  pos[top * 3 + 1] = halfHeight;
  nor[top * 3 + 1] = 1;
  pos[bottom * 3 + 1] = -halfHeight;
  nor[bottom * 3 + 1] = -1;
  for (var i = 0; i < segments; i++) {
    final t = (i / segments) * math.pi * 2;
    final c = math.cos(t);
    final s = math.sin(t);
    final bi = base + i;
    pos[bi * 3] = radius * c;
    pos[bi * 3 + 2] = radius * s;
    nor[bi * 3] = c;
    nor[bi * 3 + 2] = s;
    nor[bi * 3 + 1] = radius / halfHeight;
    final ln = math.sqrt(nor[bi * 3] * nor[bi * 3] + nor[bi * 3 + 1] * nor[bi * 3 + 1] + nor[bi * 3 + 2] * nor[bi * 3 + 2]);
    if (ln > 1e-6) {
      nor[bi * 3] /= ln;
      nor[bi * 3 + 1] /= ln;
      nor[bi * 3 + 2] /= ln;
    }
  }
  for (var i = 0; i < segments; i++) {
    final t = (i / segments) * math.pi * 2;
    final c = math.cos(t);
    final s = math.sin(t);
    final bi = base + segments + i;
    pos[bi * 3] = radius * c;
    pos[bi * 3 + 2] = radius * s;
    nor[bi * 3] = c;
    nor[bi * 3 + 2] = s;
    nor[bi * 3 + 1] = -radius / halfHeight;
    final ln = math.sqrt(nor[bi * 3] * nor[bi * 3] + nor[bi * 3 + 1] * nor[bi * 3 + 1] + nor[bi * 3 + 2] * nor[bi * 3 + 2]);
    if (ln > 1e-6) {
      nor[bi * 3] /= ln;
      nor[bi * 3 + 1] /= ln;
      nor[bi * 3 + 2] /= ln;
    }
  }
  final idx = <int>[];
  void tri(int a, int b, int c) {
    idx.addAll([a, b, c]);
  }
  for (var i = 0; i < segments; i++) {
    final i1 = (i + 1) % segments;
    tri(top, base + i, base + i1);
    tri(bottom, base + segments + i1, base + segments + i);
  }
  return (pos, nor, Uint16List.fromList(idx));
}

(Float32List positions, Float32List normals, Uint16List indices) buildUvSphere({
  double radius = 1,
  int latSegments = 18,
  int lonSegments = 28,
}) {
  final verts = <double>[];
  final norms = <double>[];
  for (var lat = 0; lat <= latSegments; lat++) {
    final theta = lat * math.pi / latSegments;
    final st = math.sin(theta);
    final ct = math.cos(theta);
    for (var lon = 0; lon <= lonSegments; lon++) {
      final phi = lon * 2 * math.pi / lonSegments;
      final sp = math.sin(phi);
      final cp = math.cos(phi);
      final nx = st * cp;
      final ny = ct;
      final nz = st * sp;
      verts.addAll([nx * radius, ny * radius, nz * radius]);
      norms.addAll([nx, ny, nz]);
    }
  }
  final idx = <int>[];
  for (var lat = 0; lat < latSegments; lat++) {
    for (var lon = 0; lon < lonSegments; lon++) {
      final a = lat * (lonSegments + 1) + lon;
      final b = a + lonSegments + 1;
      idx.addAll([a, b, a + 1, b, b + 1, a + 1]);
    }
  }
  return (Float32List.fromList(verts), Float32List.fromList(norms), Uint16List.fromList(idx));
}

Float32List buildPolyline3D(List<double> points) {
  return Float32List.fromList(points);
}

List<double> quadraticBezierStrip({
  required List<double> p0,
  required List<double> p1,
  required List<double> c,
  int segments = 48,
}) {
  final out = <double>[];
  for (var i = 0; i <= segments; i++) {
    final u = i / segments;
    final o = 1 - u;
    final x = o * o * p0[0] + 2 * o * u * c[0] + u * u * p1[0];
    final y = o * o * p0[1] + 2 * o * u * c[1] + u * u * p1[1];
    final z = o * o * p0[2] + 2 * o * u * c[2] + u * u * p1[2];
    out.addAll([x, y, z]);
  }
  return out;
}

Float32List buildParticleInterleaved({
  required int count,
  required math.Random rand,
  required List<double> center,
}) {
  final cx = center[0];
  final cy = center[1];
  final cz = center[2];
  final out = Float32List(count * 10);
  var o = 0;
  for (var i = 0; i < count; i++) {
    final u = rand.nextDouble();
    final v = rand.nextDouble();
    final theta = 2 * math.pi * u;
    final phi = math.acos(2 * v - 1);
    final r = 20 * math.pow(rand.nextDouble(), 1 / 3).toDouble();
    final x = r * math.sin(phi) * math.cos(theta);
    final y = r * math.sin(phi) * math.sin(theta) * 0.35;
    final z = r * math.cos(phi);
    out[o++] = cx + x;
    out[o++] = cy + y;
    out[o++] = cz + z;
    final r1 = rand.nextDouble() * 2 + 0.2;
    final r2 = rand.nextDouble() * 6.28318;
    final r3 = rand.nextDouble() * 6.28318;
    out[o++] = r1;
    out[o++] = r2;
    out[o++] = r3;
    final size = 0.02 + rand.nextDouble() * 0.08;
    out[o++] = size;
    final gold = rand.nextDouble() < 0.3;
    if (gold) {
      out[o++] = 0xc8 / 255.0;
      out[o++] = 0x96 / 255.0;
      out[o++] = 0x4a / 255.0;
    } else {
      out[o++] = 0xe6 / 255.0;
      out[o++] = 0xed / 255.0;
      out[o++] = 0xf3 / 255.0;
    }
  }
  return out;
}
