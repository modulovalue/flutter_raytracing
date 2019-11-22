import 'dart:math';

import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix3;

Matrix3 m;

class TransMatrix {
  static const int X = 0;
  static const int Y = 1;
  static const int Z = 2;
  _TwoDArray _mat;
  static const int SIZE = 4;
  static const double PI180 = pi / 180.0;

  TransMatrix() {
    _mat = _TwoDArray(SIZE);
  }

  TransMatrix.identity() {
    _mat = _TwoDArray(SIZE);

    for (int r = 0; r < _mat.size; r++) {
      for (int c = 0; c < _mat.size; c++) {
        if (r == c) {
          _mat.set(c, r, 1.0);
        }
      }
    }
  }

  TransMatrix.translate(Vector3 p) {
    _mat = _TwoDArray(SIZE);

    for (int r = 0; r < _mat.size; r++) {
      for (int c = 0; c < _mat.size; c++) {
        if (r == c) {
          _mat.set(c, r, 1.0);
        }
      }
    }

    _mat.set(3, 0, p.x);
    _mat.set(3, 1, p.y);
    _mat.set(3, 2, p.z);
  }

  /// Create a rotation transform matrix; to rotate according to the X, Y & Z values of the tuple 's'
  TransMatrix.rotate(double x, double y, double z) {
    _mat = _TwoDArray(4);

    final cosx = cos(toRadians(x));
    final sinx = sin(toRadians(x));
    final cosy = cos(toRadians(y));
    final siny = sin(toRadians(y));
    final cosz = cos(toRadians(z));
    final sinz = sin(toRadians(z));

    // Rotate about x axis
    this._mat.set(1, 1, cosx);
    this._mat.set(2, 2, cosx);
    this._mat.set(1, 2, sinx);
    this._mat.set(2, 1, 0.0 - sinx);

    TransMatrix temp_matrix = TransMatrix.identity();
    // Rotate about y axis
    temp_matrix._mat.set(0, 0, cosy);
    temp_matrix._mat.set(2, 2, cosy);
    temp_matrix._mat.set(0, 2, 0.0 - siny);
    temp_matrix._mat.set(2, 0, siny);
    this.multiply(temp_matrix);

    temp_matrix = TransMatrix.identity();
    // Rotate about z axis
    temp_matrix._mat.set(0, 0, cosz);
    temp_matrix._mat.set(1, 1, cosz);
    temp_matrix._mat.set(0, 1, sinz);
    temp_matrix._mat.set(1, 0, 0.0 - sinz);
    this.multiply(temp_matrix);
  }

  double toRadians(double d) {
    return d * PI180;
  }

  void transformP(Vector3 p) {
    p.x = p.x * _mat.get(0, 0) + p.y * _mat.get(1, 0) + p.z * _mat.get(2, 0) + 1 * _mat.get(3, 0);
    p.y = p.x * _mat.get(0, 1) + p.y * _mat.get(1, 1) + p.z * _mat.get(2, 1) + 1 * _mat.get(3, 1);
    p.z = p.x * _mat.get(0, 2) + p.y * _mat.get(1, 2) + p.z * _mat.get(2, 2) + 1 * _mat.get(3, 2);
  }

  void transformV(Vector3 p) {
    p.x = p.x * _mat.get(0, 0) + p.y * _mat.get(1, 0) + p.z * _mat.get(2, 0);
    p.y = p.x * _mat.get(0, 1) + p.y * _mat.get(1, 1) + p.z * _mat.get(2, 1);
    p.z = p.x * _mat.get(0, 2) + p.y * _mat.get(1, 2) + p.z * _mat.get(2, 2);
  }

  void multiply(TransMatrix tm) {
    final temp_matrix = TransMatrix();

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          double val = temp_matrix._mat.get(i, j);
          temp_matrix._mat.set(i, j, val += this._mat.get(i, k) * tm._mat.get(k, j));
        }
      }
    }

    for (int i = 0; i < SIZE; i++) {
      for (int j = 0; j < SIZE; j++) {
        this._mat.set(i, j, temp_matrix._mat.get(i, j));
      }
    }
  }

  @override
  String toString() {
    String out = "[";

    for (int r = 0; r < _mat.size; r++) {
      for (int c = 0; c < _mat.size; c++) {
        // ignore: use_string_buffers
        out += _mat.get(c, r).toString() + ", ";
      }
      // ignore: use_string_buffers
      out += "\n";
    }
    return out + "]";
  }
}

class _TwoDArray {
  int _size = 1;
  List<double> _data;

  int get size => _size;

  _TwoDArray(int size) {
    _size = size;
    _data = List(size * size);
    for(int i = 0; i < (size * size); i++) {
      _data[i]  = 0.0;
    }
  }

  double get(int c, int r) {
    return _data[r * _size + c];
  }

  void set(int c, int r, double val) {
    _data[r * _size + c] = val;
  }
}