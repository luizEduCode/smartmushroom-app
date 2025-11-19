enum ChartAggregation { last24h, daily, weekly, monthly }

extension ChartAggregationExt on ChartAggregation {
  String get label {
    switch (this) {
      case ChartAggregation.last24h:
        return '24h';
      case ChartAggregation.daily:
        return 'Diário';
      case ChartAggregation.weekly:
        return 'Semanal';
      case ChartAggregation.monthly:
        return 'Mensal';
    }
  }

  String get apiValue {
    switch (this) {
      case ChartAggregation.last24h:
        return '24h';
      case ChartAggregation.daily:
        return 'daily';
      case ChartAggregation.weekly:
        return 'weekly';
      case ChartAggregation.monthly:
        return 'monthly';
    }
  }
}
