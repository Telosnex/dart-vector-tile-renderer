import 'package:test/test.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

void main() {
  test('TilesetPreprocessor exposes initializeGeometry for compatibility', () {
    final preprocessor = TilesetPreprocessor(
      Theme(id: 'test', version: '8', layers: []),
      initializeGeometry: true,
    );

    expect(preprocessor.initializeGeometry, isTrue);
  });
}
