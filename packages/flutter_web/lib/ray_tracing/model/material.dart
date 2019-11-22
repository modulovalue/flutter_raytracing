/// Simple material properties, hardness, reflectivity etc used in lighting calculations
class Material {
  /// Ambient coefficient
  final double ka;
  /// Diffuse component
  final double kd;
  /// Specular component
  final double ks;
  final double hardness;
  final double kr;
  final bool no_shade;

  const Material.deflt()
      :
        ka = 0.7,
        kd = 0.8,
        ks = 0.9,
        hardness = 10.0,
        kr = 0.0,
        no_shade = false;

  const Material.init(this.ka, this.kd, this.ks, this.hardness, this.kr,
      this.no_shade);

  factory Material.list(List<num> ml) {
    return Material.init(
      ml[0].toDouble(),
      ml[1].toDouble(),
      ml[2].toDouble(),
      ml[3].toDouble(),
      ml[4].toDouble(),
      ml[5] == 1,
    );
  }
}