// lib/models/chart_data_model.dart
class ChartDataModel {
  final String chartType;
  final List<ChartSpot> data;
  final ChartMetadata metadata;

  ChartDataModel({
    required this.chartType,
    required this.data,
    required this.metadata,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      chartType: json['chart_type'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => ChartSpot.fromJson(e as Map<String, dynamic>))
              .toList(),
      metadata: ChartMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
    );
  }
}

class ChartSpot {
  final String x;
  final double y;
  final String label;

  ChartSpot({required this.x, required this.y, required this.label});

  factory ChartSpot.fromJson(Map<String, dynamic> json) {
    return ChartSpot(
      x: json['x'] as String,
      y: (json['y'] as num).toDouble(),
      label: json['label'] as String,
    );
  }
}

class ChartMetadata {
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final String color;

  ChartMetadata({
    required this.title,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.color,
  });

  factory ChartMetadata.fromJson(Map<String, dynamic> json) {
    return ChartMetadata(
      title: json['title'] as String,
      xAxisLabel: json['x_axis_label'] as String,
      yAxisLabel: json['y_axis_label'] as String,
      color: json['color'] as String,
    );
  }
}
