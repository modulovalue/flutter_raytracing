
/// Colour held as a RGBA tuple
/// Range 0.0 - 1.0. Alpha is transparency 0.0 = opaque, 1.0 = fully transparent
class RGB {
  static const RGB black = RGB.init(0.0, 0.0, 0.0, 0.0);
  static const RGB white = RGB.init(1.0, 1.0, 1.0, 0.0);
  static const RGB red = RGB.init(1.0, 0.0, 0.0, 0.0);

  final double r;
  final double g;
  final double b;
  final double a;

  const RGB.zero()
      : this.r = 0.0,
        this.g = 0.0,
        this.b = 0.0,
        this.a = 0.0;

  const RGB.init(this.r, this.g, this.b, this.a);

  factory RGB.list(List<num> cl) {
    return RGB.init(
      cl[0].toDouble(),
      cl[1].toDouble(),
      cl[2].toDouble(),
      cl[3].toDouble(),
    );
  }

  RGB blendF(num f) =>
      RGB.init(r * (1.0 - f) + f, g * (1.0 - f) + f, b * (1.0 - f) + f, a);

  RGB scaleF(double f) =>
      RGB.init(r * f, g * f, b * f, a);

  RGB addF(RGB colour) =>
      RGB.init(r + colour.r, g + colour.g, b + colour.b, a);

  RGB scaleRGBF(RGB color) =>
      RGB.init(r * color.r, g * color.g, b * color.b, a);

  RGB addSomeF(RGB color, double amount) =>
      RGB.init(
        r + color.r * amount,
        g + color.g * amount,
        b + color.b * amount,
        a,
      );

  @override
  String toString() => "[$r, $g, $b, $a]";
}
