import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'limye_geometry.dart';
import 'shaders/limye_shader_sources.dart';

// ignore_for_file: avoid_dynamic_calls

const _bgRgb = [0x13 / 255.0, 0x16 / 255.0, 0x1a / 255.0];
const _gridRgb = [0x23 / 255.0, 0x28 / 255.0, 0x30 / 255.0];
const _goldRgb = [0xc8 / 255.0, 0x96 / 255.0, 0x4a / 255.0];

const _camEye = [0.0, 3.0, 12.0];
const _camTarget = [0.0, 1.5, 15.0];
const _needleCenter = [0.0, 1.5, 0.0];
const _beaconPos = [0.0, 1.5, 30.0];
const _needleTip = [0.0, 3.0, 0.0];
const _particleCenter = [0.0, 1.5, 15.0];

const _ringRadii = [24.0, 38.8, 62.8, 101.6];

const _nodesBase = [
  [-8.0, 2.0, 25.0],
  [-4.0, 3.5, 20.0],
  [0.0, 4.2, 15.0],
  [4.0, 3.8, 10.0],
  [7.0, 2.5, 5.0],
  [10.0, 1.2, 0.0],
];

List<double> _m4(Matrix4 m) => List<double>.generate(16, (i) => m.storage[i]);

List<double> _m3(Matrix3 m) => List<double>.generate(9, (i) => m.storage[i]);

Matrix4 _view() {
  return makeViewMatrix(
    Vector3(_camEye[0], _camEye[1], _camEye[2]),
    Vector3(_camTarget[0], _camTarget[1], _camTarget[2]),
    Vector3(0, 1, 0),
  );
}

Matrix4 _proj(double aspect) {
  return makePerspectiveMatrix(math.pi / 4, aspect, 0.1, 100.0);
}

Matrix3 _normalMat(Matrix4 model) {
  final m3 = model.getRotation().clone();
  m3.invert();
  m3.transpose();
  return m3;
}

Float32List _interleavePosNorm(Float32List pos, Float32List nor) {
  final n = pos.length ~/ 3;
  final o = Float32List(n * 6);
  for (var i = 0; i < n; i++) {
    o[i * 6] = pos[i * 3];
    o[i * 6 + 1] = pos[i * 3 + 1];
    o[i * 6 + 2] = pos[i * 3 + 2];
    o[i * 6 + 3] = nor[i * 3];
    o[i * 6 + 4] = nor[i * 3 + 1];
    o[i * 6 + 5] = nor[i * 3 + 2];
  }
  return o;
}

Float32List _expandTriIndexed(Float32List inter6, Uint16List idx) {
  final out = Float32List(idx.length * 6);
  for (var i = 0; i < idx.length; i++) {
    final vi = idx[i];
    for (var k = 0; k < 6; k++) {
      out[i * 6 + k] = inter6[vi * 6 + k];
    }
  }
  return out;
}

int _compileProgram(dynamic gl, String vs, String fs) {
  final vsh = gl.createShader(gl.VERTEX_SHADER);
  gl.shaderSource(vsh, vs);
  gl.compileShader(vsh);
  if (gl.getShaderParameter(vsh, gl.COMPILE_STATUS) == 0) {
    throw Exception('VS: ${gl.getShaderInfoLog(vsh)}');
  }
  final fsh = gl.createShader(gl.FRAGMENT_SHADER);
  gl.shaderSource(fsh, fs);
  gl.compileShader(fsh);
  if (gl.getShaderParameter(fsh, gl.COMPILE_STATUS) == 0) {
    throw Exception('FS: ${gl.getShaderInfoLog(fsh)}');
  }
  final p = gl.createProgram();
  gl.attachShader(p, vsh);
  gl.attachShader(p, fsh);
  gl.linkProgram(p);
  if (gl.getProgramParameter(p, gl.LINK_STATUS) == 0) {
    throw Exception(gl.getProgramInfoLog(p));
  }
  gl.deleteShader(vsh);
  gl.deleteShader(fsh);
  return p;
}

class LimyeGlRenderer {
  LimyeGlRenderer(this._plugin);

  final FlutterGlPlugin _plugin;
  dynamic get _gl => _plugin.gl;

  int? _fbo;
  int? _fboTex;
  int? _depthRb;

  double _lw = 1;
  double _dpr = 1;
  int _pw = 1;
  int _ph = 1;

  late int _progGrid;
  late int _progLine;
  late int _progPhong;
  late int _progGlow;
  late int _progParticle;

  late dynamic _vaoGrid;
  late dynamic _vaoRings;
  late List<int> _ringVertsCount;
  late dynamic _vaoBezier;
  late int _bezierCount;
  late dynamic _vaoNeedleLine;
  late dynamic _vaoNeedle;
  late int _needleTriVerts;
  late dynamic _vaoSphere;
  late dynamic _vaoSpherePos;
  late dynamic _bufSphere;
  late int _sphereTriVerts;
  late dynamic _vaoParticles;
  late int _particleCount;

  bool ready = false;

  Future<void> init({
    required double width,
    required double height,
    required num dpr,
  }) async {
    _dpr = dpr.toDouble();
    _pw = (width * _dpr).toInt().clamp(1, 8192);
    _ph = (height * _dpr).toInt().clamp(1, 8192);
    if (!kIsWeb) {
      await _plugin.prepareContext();
    }
    final gl = _gl;
    try {
      _lw = (Platform.isIOS || Platform.isAndroid) ? 2.0 : 1.0;
    } catch (_) {
      _lw = 1.0;
    }

    _fbo = gl.createFramebuffer();
    _fboTex = gl.createTexture();
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, _fboTex);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, _pw, _ph, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    _depthRb = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, _depthRb);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, _pw, _ph);

    gl.bindFramebuffer(gl.FRAMEBUFFER, _fbo);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, _fboTex, 0);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, _depthRb);
    if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE) {
      throw Exception('Framebuffer incomplete');
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    _progGrid = _compileProgram(_gl, limyeGridVertex(), limyeGridFragment());
    _progLine = _compileProgram(_gl, limyeLineVertex(), limyeLineFragment());
    _progPhong = _compileProgram(_gl, limyePhongVertex(), limyePhongFragment());
    _progGlow = _compileProgram(_gl, limyeGlowVertex(), limyeGlowFragment());
    _progParticle = _compileProgram(_gl, limyeParticleVertex(), limyeParticleFragment());

    _buildGeometry(gl);
    ready = true;
  }

  void _buildGeometry(dynamic gl) {
    final gridPos = buildGridPlaneY(y: -2, half: 100);
    _vaoGrid = gl.createVertexArray();
    gl.bindVertexArray(_vaoGrid);
    var buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, gridPos.length, gridPos, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, gridPos.lengthInBytes, gridPos, gl.STATIC_DRAW);
    }
    final ag = gl.getAttribLocation(_progGrid, 'a_pos');
    gl.vertexAttribPointer(ag, 3, gl.FLOAT, false, 12, 0);
    gl.enableVertexAttribArray(ag);
    gl.bindVertexArray(null);

    final ringCounts = <int>[];
    final ringVerts = <double>[];
    for (final rad in _ringRadii) {
      final r = buildRingLineXZ(y: -1.95, radius: rad, segments: 112);
      ringCounts.add(r.length ~/ 3);
      ringVerts.addAll(r);
    }
    _ringVertsCount = ringCounts;
    final ringData = Float32List.fromList(ringVerts);
    _vaoRings = gl.createVertexArray();
    gl.bindVertexArray(_vaoRings);
    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, ringData.length, ringData, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, ringData.lengthInBytes, ringData, gl.STATIC_DRAW);
    }
    final ar = gl.getAttribLocation(_progLine, 'a_pos');
    gl.vertexAttribPointer(ar, 3, gl.FLOAT, false, 12, 0);
    gl.enableVertexAttribArray(ar);
    gl.bindVertexArray(null);

    final bezPts = <double>[];
    for (var k = 0; k < _nodesBase.length - 1; k++) {
      final p0 = _nodesBase[k];
      final p1 = _nodesBase[k + 1];
      final cy = math.max(p0[1], p1[1]) + 1.5;
      final c = [(p0[0] + p1[0]) * 0.5, cy, (p0[2] + p1[2]) * 0.5];
      bezPts.addAll(quadraticBezierStrip(p0: p0, p1: p1, c: c, segments: 56));
    }
    final bezData = Float32List.fromList(bezPts);
    _bezierCount = bezData.length ~/ 3;
    _vaoBezier = gl.createVertexArray();
    gl.bindVertexArray(_vaoBezier);
    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, bezData.length, bezData, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, bezData.lengthInBytes, bezData, gl.STATIC_DRAW);
    }
    final ab = gl.getAttribLocation(_progLine, 'a_pos');
    gl.vertexAttribPointer(ab, 3, gl.FLOAT, false, 12, 0);
    gl.enableVertexAttribArray(ab);
    gl.bindVertexArray(null);

    final nl = Float32List.fromList([..._needleTip, ..._beaconPos]);
    _vaoNeedleLine = gl.createVertexArray();
    gl.bindVertexArray(_vaoNeedleLine);
    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, nl.length, nl, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, nl.lengthInBytes, nl, gl.STATIC_DRAW);
    }
    final anl = gl.getAttribLocation(_progLine, 'a_pos');
    gl.vertexAttribPointer(anl, 3, gl.FLOAT, false, 12, 0);
    gl.enableVertexAttribArray(anl);
    gl.bindVertexArray(null);

    final needle = buildDiamondNeedle();
    final needleInter = _interleavePosNorm(needle.$1, needle.$2);
    final needleExp = _expandTriIndexed(needleInter, needle.$3);
    _needleTriVerts = needleExp.length ~/ 6;
    _vaoNeedle = gl.createVertexArray();
    gl.bindVertexArray(_vaoNeedle);
    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, needleExp.length, needleExp, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, needleExp.lengthInBytes, needleExp, gl.STATIC_DRAW);
    }
    final ap0 = gl.getAttribLocation(_progPhong, 'a_pos');
    final ap1 = gl.getAttribLocation(_progPhong, 'a_nor');
    gl.vertexAttribPointer(ap0, 3, gl.FLOAT, false, 24, 0);
    gl.enableVertexAttribArray(ap0);
    gl.vertexAttribPointer(ap1, 3, gl.FLOAT, false, 24, 12);
    gl.enableVertexAttribArray(ap1);
    gl.bindVertexArray(null);

    final sph = buildUvSphere(radius: 1, latSegments: 20, lonSegments: 28);
    final sphInter = _interleavePosNorm(sph.$1, sph.$2);
    final sphExp = _expandTriIndexed(sphInter, sph.$3);
    _sphereTriVerts = sphExp.length ~/ 6;
    _vaoSphere = gl.createVertexArray();
    gl.bindVertexArray(_vaoSphere);
    _bufSphere = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, _bufSphere);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, sphExp.length, sphExp, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, sphExp.lengthInBytes, sphExp, gl.STATIC_DRAW);
    }
    final as0 = gl.getAttribLocation(_progPhong, 'a_pos');
    final as1 = gl.getAttribLocation(_progPhong, 'a_nor');
    gl.vertexAttribPointer(as0, 3, gl.FLOAT, false, 24, 0);
    gl.enableVertexAttribArray(as0);
    gl.vertexAttribPointer(as1, 3, gl.FLOAT, false, 24, 12);
    gl.enableVertexAttribArray(as1);
    gl.bindVertexArray(null);

    _vaoSpherePos = gl.createVertexArray();
    gl.bindVertexArray(_vaoSpherePos);
    gl.bindBuffer(gl.ARRAY_BUFFER, _bufSphere);
    final agp = gl.getAttribLocation(_progGlow, 'a_pos');
    gl.vertexAttribPointer(agp, 3, gl.FLOAT, false, 24, 0);
    gl.enableVertexAttribArray(agp);
    gl.bindVertexArray(null);

    final pData = buildParticleInterleaved(
      count: 400,
      rand: math.Random(42),
      center: _particleCenter,
    );
    _particleCount = 400;
    _vaoParticles = gl.createVertexArray();
    gl.bindVertexArray(_vaoParticles);
    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    if (kIsWeb) {
      gl.bufferData(gl.ARRAY_BUFFER, pData.length, pData, gl.STATIC_DRAW);
    } else {
      gl.bufferData(gl.ARRAY_BUFFER, pData.lengthInBytes, pData, gl.STATIC_DRAW);
    }
    const stride = 40;
    final pp = gl.getAttribLocation(_progParticle, 'a_base');
    final pr = gl.getAttribLocation(_progParticle, 'a_rand');
    final ps = gl.getAttribLocation(_progParticle, 'a_size');
    final pc = gl.getAttribLocation(_progParticle, 'a_color');
    gl.vertexAttribPointer(pp, 3, gl.FLOAT, false, stride, 0);
    gl.enableVertexAttribArray(pp);
    gl.vertexAttribPointer(pr, 3, gl.FLOAT, false, stride, 12);
    gl.enableVertexAttribArray(pr);
    gl.vertexAttribPointer(ps, 1, gl.FLOAT, false, stride, 24);
    gl.enableVertexAttribArray(ps);
    gl.vertexAttribPointer(pc, 3, gl.FLOAT, false, stride, 28);
    gl.enableVertexAttribArray(pc);
    gl.bindVertexArray(null);
  }

  List<List<double>> _animatedNodes(double time) {
    final out = <List<double>>[];
    for (var i = 0; i < _nodesBase.length; i++) {
      final p = _nodesBase[i];
      final bob = math.sin(time * 1.0 + i * 0.7) * 0.3;
      final wx = math.sin(time * 1.1 + i) * 0.08;
      final wz = math.cos(time * 0.9 + i * 0.5) * 0.08;
      out.add([p[0] + wx, p[1] + bob, p[2] + wz]);
    }
    return out;
  }

  void _setPhongLights(dynamic gl, List<List<double>> nodesWorld) {
    final locN = gl.getUniformLocation(_progPhong, 'u_numLights');
    final locP = gl.getUniformLocation(_progPhong, 'u_lightPos');
    final locC = gl.getUniformLocation(_progPhong, 'u_lightColor');
    final locR = gl.getUniformLocation(_progPhong, 'u_lightRange');
    final locI = gl.getUniformLocation(_progPhong, 'u_lightIntensity');

    final pos = <double>[];
    final col = <double>[];
    final rng = <double>[];
    final intens = <double>[];

    void addL(List<double> p, List<double> c, double range, double inx) {
      pos.addAll(p);
      col.addAll(c);
      rng.add(range);
      intens.add(inx);
    }

    addL(_needleCenter, _goldRgb, 10.0, 1.5);
    addL(_beaconPos, _goldRgb, 20.0, 2.0);
    for (final n in nodesWorld) {
      addL(n, _goldRgb, 5.0, 0.5);
    }

    final nL = pos.length ~/ 3;
    gl.uniform1i(locN, nL);
    gl.uniform3fv(locP, pos);
    gl.uniform3fv(locC, col);
    gl.uniform1fv(locR, rng);
    gl.uniform1fv(locI, intens);
  }

  Future<void> render({
    required double time,
    required double dt,
  }) async {
    if (!ready) return;
    final gl = _gl;
    gl.viewport(0, 0, _pw, _ph);
    gl.bindFramebuffer(gl.FRAMEBUFFER, _fbo);

    gl.clearColor(_bgRgb[0], _bgRgb[1], _bgRgb[2], 1);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.enable(gl.DEPTH_TEST);
    gl.depthFunc(gl.LEQUAL);

    final aspect = _pw / _ph;
    final proj = _proj(aspect);
    final view = _view();
    final vp = proj * view;

    final nodes = _animatedNodes(time);

    void setFogLine(dynamic p) {
      gl.useProgram(p);
      gl.uniform3f(gl.getUniformLocation(p, 'u_camera'), _camEye[0], _camEye[1], _camEye[2]);
      gl.uniform3f(gl.getUniformLocation(p, 'u_fogColor'), _bgRgb[0], _bgRgb[1], _bgRgb[2]);
      gl.uniform1f(gl.getUniformLocation(p, 'u_fogNear'), 10);
      gl.uniform1f(gl.getUniformLocation(p, 'u_fogFar'), 60);
    }

    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    gl.useProgram(_progGrid);
    final uMvpG = gl.getUniformLocation(_progGrid, 'u_mvp');
    final mGrid = vp * Matrix4.identity();
    gl.uniformMatrix4fv(uMvpG, false, _m4(mGrid));
    gl.uniform3f(gl.getUniformLocation(_progGrid, 'u_camera'), _camEye[0], _camEye[1], _camEye[2]);
    gl.uniform3f(gl.getUniformLocation(_progGrid, 'u_fogColor'), _bgRgb[0], _bgRgb[1], _bgRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progGrid, 'u_fogNear'), 10);
    gl.uniform1f(gl.getUniformLocation(_progGrid, 'u_fogFar'), 60);
    gl.uniform3f(gl.getUniformLocation(_progGrid, 'u_gridColor'), _gridRgb[0], _gridRgb[1], _gridRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progGrid, 'u_half'), 100);
    gl.uniform1f(gl.getUniformLocation(_progGrid, 'u_step'), 48);
    gl.uniform1f(gl.getUniformLocation(_progGrid, 'u_fadeRadius'), 50);
    gl.bindVertexArray(_vaoGrid);
    gl.drawArrays(gl.TRIANGLES, 0, 6);

    setFogLine(_progLine);
    gl.useProgram(_progLine);
    final uMvpL = gl.getUniformLocation(_progLine, 'u_mvp');
    gl.uniformMatrix4fv(uMvpL, false, _m4(vp));
    var ringOffset = 0;
    gl.bindVertexArray(_vaoRings);
    gl.lineWidth(_lw * 0.5);
    for (final c in _ringVertsCount) {
      gl.uniform4f(gl.getUniformLocation(_progLine, 'u_color'), _goldRgb[0], _goldRgb[1], _goldRgb[2], 0.08);
      gl.drawArrays(gl.LINE_STRIP, ringOffset, c);
      ringOffset += c;
    }

    gl.lineWidth(_lw * 1.5);
    gl.uniform4f(gl.getUniformLocation(_progLine, 'u_color'), _goldRgb[0], _goldRgb[1], _goldRgb[2], 0.2);
    gl.bindVertexArray(_vaoBezier);
    gl.drawArrays(gl.LINE_STRIP, 0, _bezierCount);

    gl.lineWidth(_lw);
    gl.uniform4f(gl.getUniformLocation(_progLine, 'u_color'), _goldRgb[0], _goldRgb[1], _goldRgb[2], 0.15);
    gl.bindVertexArray(_vaoNeedleLine);
    gl.drawArrays(gl.LINES, 0, 2);

    final needleAngle = time * math.pi / 180;
    final needleModel =
        Matrix4.translation(Vector3(_needleCenter[0], _needleCenter[1], _needleCenter[2])) *
        Matrix4.rotationY(needleAngle);
    final needleMvp = vp * needleModel;
    final needleNorm = _normalMat(needleModel);

    gl.disable(gl.BLEND);
    gl.useProgram(_progPhong);
    final uMvpP = gl.getUniformLocation(_progPhong, 'u_mvp');
    final uMod = gl.getUniformLocation(_progPhong, 'u_model');
    final uNor = gl.getUniformLocation(_progPhong, 'u_normalMat');
    gl.uniform3f(gl.getUniformLocation(_progPhong, 'u_camera'), _camEye[0], _camEye[1], _camEye[2]);
    gl.uniform3f(gl.getUniformLocation(_progPhong, 'u_fogColor'), _bgRgb[0], _bgRgb[1], _bgRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_fogNear'), 10);
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_fogFar'), 60);
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_shininess'), 32);
    gl.uniform1i(gl.getUniformLocation(_progPhong, 'u_unlit'), 0);

    _setPhongLights(gl, nodes);

    gl.uniformMatrix4fv(uMvpP, false, _m4(needleMvp));
    gl.uniformMatrix4fv(uMod, false, _m4(needleModel));
    gl.uniformMatrix3fv(uNor, false, _m3(needleNorm));
    gl.uniform3f(gl.getUniformLocation(_progPhong, 'u_baseColor'), _goldRgb[0], _goldRgb[1], _goldRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_emissive'), 0.08);
    gl.bindVertexArray(_vaoNeedle);
    gl.drawArrays(gl.TRIANGLES, 0, _needleTriVerts);

    final beaconModel = Matrix4.translation(Vector3(_beaconPos[0], _beaconPos[1], _beaconPos[2]))
      ..scale(0.3, 0.3, 0.3);
    gl.uniformMatrix4fv(uMvpP, false, _m4(vp * beaconModel));
    gl.uniformMatrix4fv(uMod, false, _m4(beaconModel));
    gl.uniformMatrix3fv(uNor, false, _m3(_normalMat(beaconModel)));
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_shininess'), 16);
    gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_emissive'), 0.55);
    gl.bindVertexArray(_vaoSphere);
    gl.drawArrays(gl.TRIANGLES, 0, _sphereTriVerts);

    for (final np in nodes) {
      final nm = Matrix4.translation(Vector3(np[0], np[1], np[2]))..scale(0.15, 0.15, 0.15);
      gl.uniformMatrix4fv(uMvpP, false, _m4(vp * nm));
      gl.uniformMatrix4fv(uMod, false, _m4(nm));
      gl.uniformMatrix3fv(uNor, false, _m3(_normalMat(nm)));
      gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_shininess'), 24);
      gl.uniform1f(gl.getUniformLocation(_progPhong, 'u_emissive'), 0.25);
      gl.drawArrays(gl.TRIANGLES, 0, _sphereTriVerts);
    }

    final glowModel = Matrix4.translation(Vector3(_beaconPos[0], _beaconPos[1], _beaconPos[2]))
      ..scale(1.2, 1.2, 1.2);
    final glowAlpha = 0.35 + 0.05 * math.sin(time * 2 * math.pi / 3);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
    gl.depthMask(false);
    gl.useProgram(_progGlow);
    gl.uniformMatrix4fv(gl.getUniformLocation(_progGlow, 'u_mvp'), false, _m4(vp * glowModel));
    gl.uniform3f(gl.getUniformLocation(_progGlow, 'u_camera'), _camEye[0], _camEye[1], _camEye[2]);
    gl.uniform3f(gl.getUniformLocation(_progGlow, 'u_worldCenter'), _beaconPos[0], _beaconPos[1], _beaconPos[2]);
    gl.uniform3f(gl.getUniformLocation(_progGlow, 'u_color'), _goldRgb[0], _goldRgb[1], _goldRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progGlow, 'u_alpha'), glowAlpha);
    gl.uniform3f(gl.getUniformLocation(_progGlow, 'u_fogColor'), _bgRgb[0], _bgRgb[1], _bgRgb[2]);
    gl.uniform1f(gl.getUniformLocation(_progGlow, 'u_fogNear'), 10);
    gl.uniform1f(gl.getUniformLocation(_progGlow, 'u_fogFar'), 60);
    gl.bindVertexArray(_vaoSpherePos);
    gl.drawArrays(gl.TRIANGLES, 0, _sphereTriVerts);

    gl.useProgram(_progParticle);
    gl.uniformMatrix4fv(gl.getUniformLocation(_progParticle, 'u_mvp'), false, _m4(vp));
    gl.uniform1f(gl.getUniformLocation(_progParticle, 'u_time'), time);
    gl.uniform1f(gl.getUniformLocation(_progParticle, 'u_dt'), dt);
    gl.uniform3f(gl.getUniformLocation(_progParticle, 'u_beacon'), _beaconPos[0], _beaconPos[1], _beaconPos[2]);
    gl.uniform3f(gl.getUniformLocation(_progParticle, 'u_camera'), _camEye[0], _camEye[1], _camEye[2]);
    gl.uniform1f(gl.getUniformLocation(_progParticle, 'u_pointScale'), 420 * _dpr);
    gl.bindVertexArray(_vaoParticles);
    gl.drawArrays(gl.POINTS, 0, _particleCount);

    gl.depthMask(true);
    gl.disable(gl.BLEND);
    gl.finish();

    if (!kIsWeb) {
      await _plugin.updateTexture(_fboTex);
    }
  }

  int? get outputTexture => _fboTex;

  void dispose() {
    ready = false;
  }
}
