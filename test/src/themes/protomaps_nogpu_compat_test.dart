import 'dart:ui';

import 'package:test/test.dart';
import 'package:vector_tile_renderer/src/themes/expression/expression.dart';
import 'package:vector_tile_renderer/src/themes/theme_layers.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

void main() {
  final parser = ExpressionParser(const Logger.noop());

  EvaluationContext context(Map<String, Object?> properties) =>
      EvaluationContext(
        () => properties,
        TileFeatureType.linestring,
        const Logger.noop(),
        zoom: 12,
        zoomScaleFactor: 1.0,
        hasImage: (_) => false,
      );

  test('parses protomaps format expressions used for multilingual labels', () {
    final expression = parser.parseOptional([
      'format',
      [
        'coalesce',
        ['get', 'name:en'],
        ['get', 'name']
      ],
      {},
      '\n',
      {},
      [
        'coalesce',
        ['get', 'pgf:name'],
        ['get', 'name']
      ],
      {
        'text-font': [
          'literal',
          ['Noto Sans Regular']
        ],
      },
    ]);

    expect(expression, isNotNull);
    expect(
      expression!.evaluate(context({
        'name': 'Los Angeles',
        'name:en': 'Los Angeles',
        'pgf:name': 'Los Angeles',
      })),
      'Los Angeles\nLos Angeles',
    );
  });

  test('ThemeReader keeps symbol layers with protomaps text-field expressions',
      () {
    final theme = ThemeReader().read({
      'version': 8,
      'layers': [
        {
          'id': 'roads_labels_minor',
          'type': 'symbol',
          'source': 'protomaps',
          'source-layer': 'roads',
          'layout': {
            'symbol-placement': 'line',
            'text-field': [
              'case',
              ['has', 'name'],
              [
                'format',
                [
                  'coalesce',
                  ['get', 'name:en'],
                  ['get', 'name']
                ],
                {},
                '\n',
                {},
                [
                  'coalesce',
                  ['get', 'pgf:name'],
                  ['get', 'name']
                ],
                {
                  'text-font': [
                    'case',
                    [
                      '==',
                      ['get', 'script'],
                      'Devanagari'
                    ],
                    [
                      'literal',
                      ['Noto Sans Devanagari Regular v1']
                    ],
                    [
                      'literal',
                      ['Noto Sans Regular']
                    ]
                  ],
                },
              ],
              ['get', 'name']
            ],
            'text-font': ['Noto Sans Regular'],
            'text-size': 12,
          },
          'paint': {
            'text-color': '#000000',
          },
        },
      ],
    });

    final layer =
        theme.layers.whereType<DefaultLayer>().firstWhere((l) => l.id == 'roads_labels_minor');
    final textLayout = layer.style.symbolLayout!.text;

    expect(textLayout, isNotNull);
    expect(
      textLayout!.text.evaluate(context({
        'name': 'Sunset Boulevard',
        'name:en': 'Sunset Boulevard',
        'pgf:name': 'Sunset Boulevard',
      })),
      'Sunset Boulevard\nSunset Boulevard',
    );
  });

  test('ThemeReader normalizes expression-based text-font for the CPU renderer',
      () {
    final theme = ThemeReader().read({
      'version': 8,
      'layers': [
        {
          'id': 'places_locality',
          'type': 'symbol',
          'source': 'protomaps',
          'source-layer': 'places',
          'layout': {
            'symbol-placement': 'point',
            'text-field': ['get', 'name'],
            'text-font': [
              'case',
              [
                '<=',
                ['get', 'min_zoom'],
                5
              ],
              [
                'literal',
                ['Noto Sans Medium']
              ],
              [
                'literal',
                ['Noto Sans Regular']
              ]
            ],
            'text-size': 12,
          },
          'paint': {
            'text-color': '#000000',
          },
        },
      ],
    });

    final layer =
        theme.layers.whereType<DefaultLayer>().firstWhere((l) => l.id == 'places_locality');
    final textLayout = layer.style.symbolLayout!.text!;

    expect(textLayout.fontFamily, 'Noto Sans');
    expect(textLayout.fontStyle, FontStyle.normal);
  });
}
