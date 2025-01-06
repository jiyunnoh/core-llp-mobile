class OutcomeMeasureInfo {
  String id;
  String overview;
  String population;
  String equipment;
  String instructions;
  String scoreCalculation;
  String scoreInterpretation;
  String mcidMdc;
  String references;
  Map<String, dynamic>? scoreLookupTable;
  List<dynamic>? summaryScore;
  List<dynamic>? images;
  List<dynamic>? dictionary;
  List<dynamic>? groupHeaders;
  double minYValue = 0;
  double maxYValue = 100;
  double yAxisInterval = 20;
  String yAxisLabel = 'Score';
  String? yAxisUnit;
  double? sigDiffPositive;
  double? sigDiffNegative;
  bool shouldReverse = false;
  bool requireCompleteness = false;

  OutcomeMeasureInfo(
      {required this.id,
      required this.overview,
      required this.population,
      required this.equipment,
      required this.instructions,
      required this.scoreCalculation,
      required this.scoreInterpretation,
      required this.mcidMdc,
      required this.references,
      this.scoreLookupTable,
      this.summaryScore,
      this.images});

  factory OutcomeMeasureInfo.fromJson(String id, Map<String, dynamic> data) {
    String overview = data['overview'];
    String population = data['population'];
    String equipment = data['equipment'];
    String instructions = data['instructions'];
    String scoreCalculation = data['score_calculation'];
    String scoreInterpretation = data['score_interpretation'];
    String mcidMdc = data['mcid_mdc'];
    String references = data['references'];
    OutcomeMeasureInfo info = OutcomeMeasureInfo(
        id: id,
        overview: overview,
        population: population,
        equipment: equipment,
        instructions: instructions,
        scoreCalculation: scoreCalculation,
        scoreInterpretation: scoreInterpretation,
        mcidMdc: mcidMdc,
        references: references);
    info.summaryScore = data['summaryScore'];
    info.images = data['images'];
    info.dictionary = data['dictionary'];
    info.groupHeaders = data['groupHeaders'];
    //TODO: JK - maybe we can improve this by making this not dependent on particular outcome measure
    if (info.id == 'pmq' || info.id == 'opus_lefs') {
      List lookupTable = data['score_lookup_table'];
      info.scoreLookupTable = {
        for (var item in lookupTable) lookupTable.indexOf(item).toString(): item
      };
    } else {
      info.scoreLookupTable = data['score_lookup_table'];
    }
    info.minYValue = data['minYValue'] == null
        ? info.minYValue
        : double.parse(data['minYValue']);
    info.maxYValue = double.parse(data['maxYValue']);
    info.yAxisInterval = double.parse(data['yAxisInterval']);
    info.yAxisLabel = data['yAxisLabel'] ?? 'Score';
    info.yAxisUnit = data['yAxisUnit'];
    info.sigDiffPositive = data['sigDiffPositive'] == null
        ? null
        : double.parse(data['sigDiffPositive']);
    info.sigDiffNegative = data['sigDiffNegative'] == null
        ? null
        : double.parse(data['sigDiffNegative']);
    info.shouldReverse = data['shouldReverse'] == null
        ? false
        : bool.parse(data['shouldReverse'], caseSensitive: false);
    return info;
  }
}
