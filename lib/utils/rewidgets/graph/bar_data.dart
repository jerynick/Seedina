import 'package:seedina/utils/rewidgets/graph/individual_bar.dart';

class BarData {
  final num jamPertama;
  final num jamKedua;
  final num jamKetiga;
  final num jamKeempat;
  final num jamKelima;
  final num jamKeenam;
  final num jamKetujuh;
  final num jamKedelapan;

  BarData({
    required this.jamPertama,
    required this.jamKedua,
    required this.jamKetiga,
    required this.jamKeempat,
    required this.jamKelima,
    required this.jamKeenam,
    required this.jamKetujuh,
    required this.jamKedelapan
  });

  List<IndividualBar> barData = [];

  void initializedBarData() {
    barData = [
      IndividualBar(x: 1, y: jamPertama.toDouble()),
      IndividualBar(x: 2, y: jamKedua.toDouble()),
      IndividualBar(x: 3, y: jamKetiga.toDouble()),
      IndividualBar(x: 4, y: jamKeempat.toDouble()),
      IndividualBar(x: 5, y: jamKelima.toDouble()),
      IndividualBar(x: 6, y: jamKeenam.toDouble()),
      IndividualBar(x: 7, y: jamKetujuh.toDouble()),
      IndividualBar(x: 8, y: jamKedelapan.toDouble()),
    ];
  }
}