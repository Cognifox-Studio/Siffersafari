part of 'question_generator_service.dart';

mixin _QuestionGeneratorServiceImpl on _QuestionGeneratorServiceHelpers {
  Uuid get _uuid;

  // region M4 Generators (Åk 4-6 Special Topics)

  Question _generateM4StatisticsQuestion(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int difficultyStep,
    int? gradeLevel,
  }) {
    // M4 (Åk 4–6, quiz-format utan ny UI): enkel statistik som alltid ger
    // heltalssvar.
    // Vi inkluderar '=' i prompten för att UI ska dölja operationssymbolen.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final isGrade6 = gradeLevel == 6;

    final valueCap = step <= 3
        ? min(range.max, 200)
        : step <= 6
            ? min(range.max, 1000)
            : min(range.max, 10000);
    final valueRange =
        DifficultyNumberRange(max(1, range.min), max(1, valueCap));

    // M4 full (del 1): enkel visualiserad statistik i tabellformat.
    // Vi introducerar detta från step 6 och uppåt.
    if (step >= 6 && _random.nextDouble() < 0.22) {
      return _generateM4StatisticsTableQuestion(
        valueRange,
        difficulty,
        difficultyStep: step,
      );
    }

    // ASCII-stapeldiagram: Åk 6 earlier/heavier (ROI #37); others from step 7.
    final barMinStep = isGrade6 ? 5 : 7;
    final barChance = isGrade6 ? (step >= 8 ? 0.42 : 0.28) : 0.15;
    if (step >= barMinStep && _random.nextDouble() < barChance) {
      return _generateM4BarChartQuestion(
        valueRange,
        difficulty,
        difficultyStep: step,
        gradeLevel: gradeLevel,
      );
    }

    // M4 full (del 2b): sannolikhetsvisualising med färgade bollar.
    // Från step 8 och uppåt med låg sannolikhet.
    if (step >= 8 && _random.nextDouble() < 0.12) {
      return _generateM4ProbabilityDiagramQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    // M4 full (del 3): geometri/mätning — enhetskonverteringar och formfrågor.
    // Från step 6 och uppåt med låg sannolikhet.
    if (step >= 6 && _random.nextDouble() < 0.10) {
      final roll = _random.nextDouble();
      if (roll < 0.60) {
        return _generateM4MeasurementUnitQuestion(
          difficulty,
          difficultyStep: step,
        );
      } else if (roll < 0.85) {
        return _generateM4ShapeAreaQuestion(difficulty, difficultyStep: step);
      } else {
        return _generateM4ShapePerimeterQuestion(
          difficulty,
          difficultyStep: step,
        );
      }
    }

    // Deterministic progression by step (simpler early):
    // 1–3: typvärde, 4–6: median, 7–9: medelvärde (heltal), 10: variationsbredd.
    if (step <= 3) {
      final modeVal = _randomInRange(valueRange);
      var other1 = _randomInRange(valueRange);
      var other2 = _randomInRange(valueRange);
      for (var i = 0; i < 40; i++) {
        if (other1 == modeVal) other1 = _randomInRange(valueRange);
        if (other2 == modeVal || other2 == other1) {
          other2 = _randomInRange(valueRange);
        }
        if (other1 != modeVal && other2 != modeVal && other2 != other1) break;
      }

      final values = <int>[modeVal, modeVal, modeVal, other1, other2];
      values.shuffle(_random);

      final prompt = 'Typvärde = ?\nTalen: ${values.join(', ')}';
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: 0,
        operand2: 0,
        correctAnswer: modeVal,
        wrongAnswers: _generateWrongAnswers(modeVal, 3),
        promptText: prompt,
        explanation: 'Typvärde är det tal som förekommer flest gånger.',
      );
    }

    if (step <= 6) {
      final count = step <= 5 ? 5 : 7;
      final values =
          List<int>.generate(count, (_) => _randomInRange(valueRange));
      final sorted = _sortedCopy(values);
      final median = sorted[sorted.length ~/ 2];

      final prompt = 'Median = ?\nTalen: ${values.join(', ')}';
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: 0,
        operand2: 0,
        correctAnswer: median,
        wrongAnswers: _generateWrongAnswers(median, 3),
        promptText: prompt,
        explanation: 'Sortera talen. Medianen är det mittersta talet.',
      );
    }

    if (step >= 10) {
      // Variationsbredd = max - min.
      List<int> values;
      for (var attempt = 0; attempt < 120; attempt++) {
        values = List<int>.generate(6, (_) => _randomInRange(valueRange));
        final sorted = _sortedCopy(values);
        final minVal = sorted.first;
        final maxVal = sorted.last;
        if (maxVal != minVal) {
          final spread = maxVal - minVal;
          final prompt = 'Variationsbredd = ?\nTalen: ${values.join(', ')}';
          return Question(
            id: _uuid.v4(),
            operationType: OperationType.mixed,
            difficulty: difficulty,
            operand1: 0,
            operand2: 0,
            correctAnswer: spread,
            wrongAnswers: _generateWrongAnswers(spread, 3),
            promptText: prompt,
            explanation:
                'Variationsbredd = största talet - minsta talet. $maxVal - $minVal = $spread.',
          );
        }
      }
    }

    // step 7–10: medelvärde (heltal).
    // Rejection sampling: 4 tal där summan är delbar med 4.
    List<int> values;
    int mean;
    for (var attempt = 0; attempt < 120; attempt++) {
      values = List<int>.generate(4, (_) => _randomInRange(valueRange));
      final sum = values.fold<int>(0, (acc, v) => acc + v);
      if (sum % values.length == 0) {
        mean = sum ~/ values.length;
        final prompt = 'Medelvärde = ?\nTalen: ${values.join(', ')}';
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: mean,
          wrongAnswers: _generateWrongAnswers(mean, 3),
          promptText: prompt,
          explanation:
              'Medelvärde = summa / antal tal. Summa=$sum, antal=${values.length}.',
        );
      }
    }

    // Fallback (should be rare): use median.
    final fallback = List<int>.generate(5, (_) => _randomInRange(valueRange));
    final median = _sortedCopy(fallback)[2];
    final prompt = 'Median = ?\nTalen: ${fallback.join(', ')}';
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: median,
      wrongAnswers: _generateWrongAnswers(median, 3),
      promptText: prompt,
      explanation: 'Sortera talen. Medianen är det mittersta talet.',
    );
  }

  Question _generateM4StatisticsTableQuestion(
    DifficultyNumberRange valueRange,
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final labels = <String>['A', 'B', 'C'];
    final minVal = max(2, valueRange.min);
    final maxVal = max(minVal + 2, valueRange.max);

    int a = _randomInRange(DifficultyNumberRange(minVal, maxVal));
    int b = _randomInRange(DifficultyNumberRange(minVal, maxVal));
    int c = _randomInRange(DifficultyNumberRange(minVal, maxVal));

    // Avoid degenerate all-equal values to keep interpretation meaningful.
    for (var i = 0; i < 60; i++) {
      if (!(a == b && b == c)) break;
      b = _randomInRange(DifficultyNumberRange(minVal, maxVal));
      c = _randomInRange(DifficultyNumberRange(minVal, maxVal));
    }

    final values = <int>[a, b, c];
    final sorted = _sortedCopy(values);

    final int correct;
    final String questionLine;
    final String explanation;

    if (step <= 7) {
      final maxValEntry = values.reduce((x, y) => x > y ? x : y);
      correct = maxValEntry;
      questionLine = 'Vilket värde är störst?';
      explanation =
          'Jämför alla värden i tabellen och välj det största: $correct.';
    } else if (step <= 9) {
      final diff = sorted.last - sorted.first;
      correct = diff;
      questionLine = 'Vad är skillnaden mellan största och minsta värdet?';
      explanation =
          'Skillnad = största - minsta = ${sorted.last} - ${sorted.first} = $correct.';
    } else {
      final sum = values.fold<int>(0, (acc, v) => acc + v);
      // Keep integer mean in step 10 table mode.
      if (sum % values.length == 0) {
        correct = sum ~/ values.length;
      } else {
        // Snap to a nearby divisible setup by adjusting C.
        final remainder = sum % values.length;
        c += (values.length - remainder);
        values[2] = c;
        final adjustedSum = values.fold<int>(0, (acc, v) => acc + v);
        correct = adjustedSum ~/ values.length;
      }
      questionLine = 'Vad är medelvärdet?';
      explanation =
          'Medelvärde = summa / antal = ${values.fold<int>(0, (acc, v) => acc + v)} / ${values.length} = $correct.';
    }

    final prompt =
        'Tabell (statistik) = ?\nKategori | Värde\n${labels[0]} | ${values[0]}\n${labels[1]} | ${values[1]}\n${labels[2]} | ${values[2]}\nFråga: $questionLine';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: explanation,
    );
  }

  Question _generateM4BarChartQuestion(
    DifficultyNumberRange valueRange,
    DifficultyLevel difficulty, {
    required int difficultyStep,
    int? gradeLevel,
  }) {
    // M4 full (del 2a): ASCII-stapeldiagram med tolkning-frågor.
    // Visa ett enkelt diagram med asterisker och ställ frågor om högsta/lägsta.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final isGrade6 = gradeLevel == 6;

    // Keep printed bars short even when values are large (scale + label).
    final barCount = isGrade6 ? (step >= 7 ? 5 : 4) : 3;
    final displayCap = isGrade6 ? min(40, max(8, valueRange.max)) : null;
    final minVal = max(2, valueRange.min);
    final maxVal = displayCap != null
        ? max(minVal + 2, displayCap)
        : max(minVal + 2, min(valueRange.max, 20));

    final values = <int>[];
    for (var i = 0; i < barCount; i++) {
      values.add(_randomInRange(DifficultyNumberRange(minVal, maxVal)));
    }
    for (var i = 0; i < 80; i++) {
      if (values.toSet().length >= 2) break;
      values[i % barCount] =
          _randomInRange(DifficultyNumberRange(minVal, maxVal));
    }

    final labels = isGrade6
        ? List<String>.generate(barCount, (i) => 'Dag ${i + 1}')
        : <String>['X', 'Y', 'Z'].take(barCount).toList(growable: false);

    final peak = values.reduce(max);
    final starScale = max(1, (peak / 12).ceil());

    final diagramLines = <String>[];
    for (var i = 0; i < labels.length; i++) {
      final stars = max(1, (values[i] / starScale).round());
      diagramLines.add('${labels[i]}: ${'*' * stars} (${values[i]})');
    }
    final diagram = diagramLines.join('\n');

    final sorted = _sortedCopy(values);
    final int correct;
    final String questionLine;
    final String explanation;

    final modeRoll = _random.nextDouble();
    if (isGrade6 && modeRoll < 0.28) {
      final maxIdx = values.indexOf(sorted.last);
      correct = maxIdx + 1;
      questionLine = 'Vilken dag hade högst värde? Svara med dagnummer.';
      explanation = 'Dag $correct har högst stapel (${sorted.last}).';
    } else if (isGrade6 && modeRoll < 0.48) {
      final minIdx = values.indexOf(sorted.first);
      correct = minIdx + 1;
      questionLine = 'Vilken dag hade lägst värde? Svara med dagnummer.';
      explanation = 'Dag $correct har lägst stapel (${sorted.first}).';
    } else if (isGrade6 && modeRoll < 0.68 && barCount >= 3) {
      final i = _random.nextInt(barCount - 1);
      final delta = values[i + 1] - values[i];
      correct = delta.abs();
      questionLine = delta >= 0
          ? 'Hur mycket ökade mellan dag ${i + 1} och dag ${i + 2}?'
          : 'Hur mycket minskade mellan dag ${i + 1} och dag ${i + 2}?';
      explanation =
          'Skillnad = |${values[i + 1]} − ${values[i]}| = $correct.';
    } else if (step <= 7 && !isGrade6) {
      correct = sorted.last;
      questionLine = 'Vilket värde är störst?';
      explanation =
          'Jämför alla staplar i diagrammet och välj det största: $correct.';
    } else if (step <= 9 || (isGrade6 && modeRoll < 0.85)) {
      correct = sorted.last - sorted.first;
      questionLine = 'Vad är skillnaden mellan största och minsta värdet?';
      explanation =
          'Skillnad = största - minsta = ${sorted.last} - ${sorted.first} = $correct.';
    } else {
      var sum = values.fold<int>(0, (acc, v) => acc + v);
      final rem = sum % values.length;
      if (rem != 0) {
        values[values.length - 1] += values.length - rem;
        sum = values.fold<int>(0, (acc, v) => acc + v);
      }
      correct = sum ~/ values.length;
      questionLine = 'Vad är medelvärdet?';
      explanation =
          'Medelvärde = summa / antal = $sum / ${values.length} = $correct.';
    }

    final prompt = 'Diagram (stapel) = ?\n$diagram\nFråga: $questionLine';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: sorted.first,
      operand2: sorted.last,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: explanation,
    );
  }

  Question _generateM4ProbabilityDiagramQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M4 full (del 2b): sannolikhetsvisualising med färgade bollar i en påse.
    // Visar en enkel grafisk description och frågor om sannolikhet i procent.
    final bag = _pickM4Bag(difficultyStep: difficultyStep);

    final visualization =
        'Påse:\n${_createBallVisualization(bag.red, bag.blue)}';

    final prompt = 'Sannolikhet (diagram) = ?\n$visualization\n'
        'Om du tar en boll slumpmässigt, vad är sannolikheten att få röd?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: bag.percent,
      wrongAnswers: _generateWrongPercentAnswers(bag.percent, 3),
      promptText: prompt,
      explanation:
          'Röda bollar: ${bag.red}, Totalt: ${bag.total}. Sannolikhet = (${bag.red}/${bag.total}) × 100 = ${bag.percent}%.',
    );
  }

  String _createBallVisualization(int red, int blue) {
    // Skapa en enkel text-visualisering av bollar.
    // Begränsa till max 20 bollar för läsbarhet.
    final totalShown = min(20, red + blue);
    final redShown = (red * totalShown) ~/ (red + blue);
    final blueShown = totalShown - redShown;

    final redBalls = '🔴' * redShown;
    final blueBalls = '🔵' * blueShown;
    return '$redBalls $blueBalls (Röda: $red, Blå: $blue)';
  }

  Question _generateM4MeasurementUnitQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M4 full (del 3a): enhetskonverteringar — längd, volym, tid.
    final conversionTypes = <String, Map<String, dynamic>>{
      'längd_cm_dm': {'from': 'cm', 'to': 'dm', 'factor': 10, 'range': (2, 60)},
      'längd_m_cm': {'from': 'm', 'to': 'cm', 'factor': 100, 'range': (1, 20)},
      'längd_dm_cm': {'from': 'dm', 'to': 'cm', 'factor': 10, 'range': (3, 50)},
      'volym_ml_cl': {
        'from': 'ml',
        'to': 'cl',
        'factor': 10,
        'range': (10, 100),
      },
      'volym_cl_l': {
        'from': 'cl',
        'to': 'l',
        'factor': 100,
        'range': (50, 500),
      },
      'volym_l_ml': {'from': 'l', 'to': 'ml', 'factor': 1000, 'range': (1, 10)},
      'tid_min_s': {'from': 'min', 'to': 's', 'factor': 60, 'range': (2, 10)},
      'tid_h_min': {'from': 'h', 'to': 'min', 'factor': 60, 'range': (1, 12)},
    };

    final typeKey =
        conversionTypes.keys.toList()[_random.nextInt(conversionTypes.length)];
    final convType = conversionTypes[typeKey]!;

    final from = convType['from'] as String;
    final to = convType['to'] as String;
    final factor = convType['factor'] as int;
    final range = convType['range'] as (int, int);

    final inputValue = range.$1 + _random.nextInt(range.$2 - range.$1 + 1);
    final correctAnswer = inputValue * factor;

    final prompt = 'Enhetskonvertering = ?\n$inputValue $from = ? $to';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(correctAnswer, 3),
      promptText: prompt,
      explanation:
          '$inputValue $from = $inputValue × $factor = $correctAnswer $to.',
    );
  }

  Question _generateM4ShapeAreaQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M4 full (del 3b): area av enkla former (kvadrat, rektangel, triangel).
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final shapeType =
        _random.nextInt(3); // 0: square, 1: rectangle, 2: triangle
    final int correct;
    String prompt;
    String explanation;

    if (shapeType == 0) {
      // Kvadrat: area = sida²
      final side = 2 +
          _random.nextInt(
            step <= 3
                ? 6
                : step <= 6
                    ? 10
                    : 15,
          );
      correct = side * side;
      prompt = 'Area (kvadrat) = ?\nEn kvadrat har sida $side cm. Area = ?';
      explanation = 'Area av kvadrat = sida² = $side × $side = $correct cm².';
    } else if (shapeType == 1) {
      // Rektangel: area = längd × bredd
      final length = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 12
                    : 15,
          );
      final width = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 12
                    : 15,
          );
      correct = length * width;
      prompt =
          'Area (rektangel) = ?\nEn rektangel är $length cm × $width cm. Area = ?';
      explanation =
          'Area av rektangel = längd × bredd = $length × $width = $correct cm².';
    } else {
      // Triangel: area = (bas × höjd) / 2
      final base = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 10
                    : 12,
          );
      final height = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 10
                    : 12,
          );
      correct = (base * height) ~/ 2;
      prompt =
          'Area (triangel) = ?\nEn triangel har bas $base cm och höjd $height cm. Area = ?';
      explanation =
          'Area av triangel = (bas × höjd) / 2 = ($base × $height) / 2 = $correct cm².';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: explanation,
    );
  }

  Question _generateM4ShapePerimeterQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M4 full (del 3c): omkrets av enkla former (kvadrat, rektangel).
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final isSquare = _random.nextBool();
    final int correct;
    String prompt;
    String explanation;

    if (isSquare) {
      // Kvadrat: omkrets = 4 × sida
      final side = 2 +
          _random.nextInt(
            step <= 3
                ? 6
                : step <= 6
                    ? 10
                    : 15,
          );
      correct = 4 * side;
      prompt =
          'Omkrets (kvadrat) = ?\nEn kvadrat har sida $side cm. Omkrets = ?';
      explanation = 'Omkrets av kvadrat = 4 × sida = 4 × $side = $correct cm.';
    } else {
      // Rektangel: omkrets = 2 × (längd + bredd)
      final length = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 12
                    : 15,
          );
      final width = 2 +
          _random.nextInt(
            step <= 3
                ? 8
                : step <= 6
                    ? 12
                    : 15,
          );
      correct = 2 * (length + width);
      prompt =
          'Omkrets (rektangel) = ?\nEn rektangel är $length cm × $width cm. Omkrets = ?';
      explanation =
          'Omkrets av rektangel = 2 × (längd + bredd) = 2 × ($length + $width) = $correct cm.';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: explanation,
    );
  }

  Question _generateM4ProbabilityQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M4 (Åk 4–6, quiz-format utan ny UI):
    // - Sannolikhet i procent (heltal 0–100)
    // - Jämförelse av sannolikhet (skillnad i procentenheter)
    // - Enkel kombinatorik (antal kombinationer)
    // Vi inkluderar '=' i prompten för att UI ska dölja operationssymbolen.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final roll = _random.nextDouble();
    if (step <= 3) {
      return roll < 0.75
          ? _generateM4ProbabilityPercentQuestion(
              difficulty,
              difficultyStep: step,
            )
          : _generateM4ProbabilityCompareQuestion(
              difficulty,
              difficultyStep: step,
            );
    }
    if (step <= 6) {
      if (roll < 0.50) {
        return _generateM4ProbabilityPercentQuestion(
          difficulty,
          difficultyStep: step,
        );
      }
      if (roll < 0.80) {
        return _generateM4ProbabilityCompareQuestion(
          difficulty,
          difficultyStep: step,
        );
      }
      return _generateM4CombinatoricsQuestion(difficulty, difficultyStep: step);
    }

    if (roll < 0.40) {
      return _generateM4ProbabilityPercentQuestion(
        difficulty,
        difficultyStep: step,
      );
    }
    if (roll < 0.70) {
      return _generateM4ProbabilityCompareQuestion(
        difficulty,
        difficultyStep: step,
      );
    }
    return _generateM4CombinatoricsQuestion(difficulty, difficultyStep: step);
  }

  ({int total, int red, int blue, int percent}) _pickM4Bag({
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final denominators = step <= 3
        ? const <int>[2, 4, 5, 10]
        : step <= 6
            ? const <int>[4, 5, 10, 20]
            : const <int>[10, 20, 25, 50, 100];

    final total = denominators[_random.nextInt(denominators.length)];
    var red = 1 + _random.nextInt(total - 1);

    // Ensure percent is an integer.
    for (var i = 0; i < 60; i++) {
      if ((red * 100) % total == 0) break;
      red = 1 + _random.nextInt(total - 1);
    }

    final blue = total - red;
    final percent = (red * 100) ~/ total;
    return (total: total, red: red, blue: blue, percent: percent);
  }

  Question _generateM4ProbabilityPercentQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final bag = _pickM4Bag(difficultyStep: difficultyStep);

    final prompt =
        'Chans (%) = ?\nRöda: ${bag.red}, Blå: ${bag.blue}, Totalt: ${bag.total}';
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: bag.percent,
      wrongAnswers: _generateWrongPercentAnswers(bag.percent, 3),
      promptText: prompt,
      explanation:
          'Chans = (gynnsamma / alla) × 100 = (${bag.red} / ${bag.total}) × 100 = ${bag.percent}%.',
    );
  }

  Question _generateM4ProbabilityCompareQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Skillnad i procentenheter mellan två påsar.
    // Vi vill undvika negativt svar i quiz-UI, så vi säkrar att A >= B.
    var a = _pickM4Bag(difficultyStep: difficultyStep);
    var b = _pickM4Bag(difficultyStep: difficultyStep);

    for (var i = 0; i < 80; i++) {
      if (a.percent != b.percent) break;
      b = _pickM4Bag(difficultyStep: difficultyStep);
    }

    if (b.percent > a.percent) {
      final tmp = a;
      a = b;
      b = tmp;
    }

    final diff = (a.percent - b.percent).clamp(0, 100);
    final prompt = 'Skillnad i chans (procentenheter) = ?\n'
        'Påse A: Röda: ${a.red}, Blå: ${a.blue}, Totalt: ${a.total}\n'
        'Påse B: Röda: ${b.red}, Blå: ${b.blue}, Totalt: ${b.total}';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: diff,
      wrongAnswers: _generateWrongPercentAnswers(diff, 3),
      promptText: prompt,
      explanation:
          'Räkna chans i % för A och B. Skillnad = ${a.percent}% - ${b.percent}% = $diff procentenheter.',
    );
  }

  Question _generateM4CombinatoricsQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Enkel kombinatorik: antal kombinationer när man väljer 1 sak ur varje
    // kategori (multiplikationsprincipen).
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final maxA = step <= 3
        ? 4
        : step <= 6
            ? 7
            : 10;
    final maxB = step <= 3
        ? 4
        : step <= 6
            ? 8
            : 12;

    final a = 2 + _random.nextInt(max(1, maxA - 1));
    final b = 2 + _random.nextInt(max(1, maxB - 1));
    final combos = a * b;

    final prompt = 'Kombinationer = ?\nTröjor: $a, Byxor: $b';
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: combos,
      wrongAnswers: _generateWrongAnswers(combos, 3),
      promptText: prompt,
      explanation:
          'Om du väljer 1 tröja och 1 byxa: $a × $b = $combos kombinationer.',
    );
  }

  Question _generateM4NegativeNumbersQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Skolverket (Åk 4–6) inkluderar negativa tal. Vi håller detta väldigt
    // enkelt i quiz-format och med heltalssvar.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final maxAbs = step <= 9 ? 30 : 50;

    // Ensure at least one negative operand.
    var a = -1;
    var b = 1;
    for (var attempt = 0; attempt < 60; attempt++) {
      a = _random.nextInt(2 * maxAbs + 1) - maxAbs;
      b = _random.nextInt(2 * maxAbs + 1) - maxAbs;
      if (a == 0 && b == 0) continue;
      if (a < 0 || b < 0) break;
    }

    final useAddition = _random.nextBool();
    final correct = useAddition ? (a + b) : (a - b);
    final expr = useAddition ? '$a + $b' : '$a - $b';

    final prompt = 'Negativa tal = ?\nVad är $expr?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: useAddition
          ? 'När du adderar kan du tänka att du går åt höger (+) och vänster (−) på tallinjen.'
          : 'När du subtraherar kan du tänka att du tar bort ett tal (eller lägger till motsatsen).',
    );
  }

  // endregion

  // region M5a Generators (Åk 7-9 Core Topics)

  Question _generateM4MultiStepWordQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Åk 6 policy: every multi-step prompt asks for one final integer.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final templates = step <= 7
        ? const <({String prompt, int answer, String explanation})>[
            (
              prompt:
                  'Flerstegsproblem = ?\nEn klass samlar 450 burkar. Nästa vecka 30% fler. Hur många burkar totalt då?',
              answer: 585,
              explanation: '450 × 1,30 = 585 burkar.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn cykel kostar 4000 kr. Priset höjs med 15% och sänks sedan med 10%. Vad kostar den då?',
              answer: 4140,
              explanation: '4000 × 1,15 × 0,90 = 4140 kr.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn klass har 25 elever. 20% är sjuka och 3 går hem. Hur många är kvar i skolan?',
              answer: 17,
              explanation: '25 − 5 sjuka − 3 hem = 17.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn elev springer 2 km, sedan 50% längre, sedan 1 km till. Hur långt totalt?',
              answer: 4,
              explanation: '2 + 1 + 1 = 4 km.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn sträcka ökar från 120 km till 150 km. Hur många procent ökar den?',
              answer: 25,
              explanation: '(150 − 120) / 120 × 100 = 25%.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn klass ökar från 20 till 25 elever. Hur många procent ökar den?',
              answer: 25,
              explanation: '(25 − 20) / 20 × 100 = 25%.',
            ),
          ]
        : const <({String prompt, int answer, String explanation})>[
            (
              prompt:
                  'Flerstegsproblem = ?\nEn butik sänker ett pris på 1000 kr med 20% och sedan ytterligare 10%. Vad blir priset?',
              answer: 720,
              explanation: '1000 × 0,80 × 0,90 = 720 kr.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn bok kostar 200 kr. Rabatt 15%, sedan höjs priset med 10%. Vad kostar den då?',
              answer: 187,
              explanation: '200 × 0,85 × 1,10 = 187 kr.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn bil kör 120 km, sedan 25% längre och sedan 10 km till. Hur långt totalt?',
              answer: 160,
              explanation: '120 × 1,25 + 10 = 160 km.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn vara kostar 500 kr. Priset höjs 10% och sedan 10% igen. Vad kostar den då?',
              answer: 605,
              explanation: '500 × 1,10 × 1,10 = 605 kr.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn vara kostar 800 kr. Priset sänks 25% och sedan 10%. Vad kostar den då?',
              answer: 540,
              explanation: '800 × 0,75 × 0,90 = 540 kr.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn butik har 500 varor. 20% säljs och 10% av resten reas ut. Hur många varor är kvar?',
              answer: 360,
              explanation: '500 − 100 − 40 = 360 kvar.',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEtt pris på 100 kr höjs med 20% och sänks sedan med 20%. Vad blir priset?',
              answer: 96,
              explanation: '100 × 1,20 × 0,80 = 96 kr (inte samma som start).',
            ),
            (
              prompt:
                  'Flerstegsproblem = ?\nEn klass minskar från 30 till 24 elever. Hur många procent minskar den?',
              answer: 20,
              explanation: '(30 − 24) / 30 × 100 = 20%.',
            ),
          ];

    final picked = templates[_random.nextInt(templates.length)];
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: picked.answer,
      wrongAnswers: _generateWrongAnswers(picked.answer, 3),
      promptText: picked.prompt,
      explanation: picked.explanation,
    );
  }

  Question _generateM4PercentageChangeQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Åk 6 policy (fixed integer answer):
    // - Apply-% prompts ask for the new price (final value).
    // - Before→after prompts ask for the percent change magnitude.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final askFinalValue = _random.nextBool();

    if (askFinalValue) {
      final percents = step <= 6
          ? const <int>[10, 20, 25, 50]
          : const <int>[5, 10, 15, 20, 25, 30, 40, 50];
      final percent = percents[_random.nextInt(percents.length)];
      final bases = step <= 6
          ? const <int>[100, 200, 400, 500, 800, 1000]
          : const <int>[80, 120, 250, 300, 600, 750, 1200, 1500];
      final base = bases[_random.nextInt(bases.length)];
      final decrease = _random.nextBool();
      final correct =
          decrease ? (base * (100 - percent)) ~/ 100 : (base * (100 + percent)) ~/ 100;
      final verb = decrease ? 'sänks' : 'höjs';
      final prompt =
          'Procentuell förändring = ?\nPriset $verb med $percent% från $base. Vad blir nya priset?';

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: base,
        operand2: percent,
        correctAnswer: correct,
        wrongAnswers: _generateWrongAnswers(correct, 3),
        promptText: prompt,
        explanation: decrease
            ? 'Nytt pris = $base − $percent% = $base × ${100 - percent}/100 = $correct.'
            : 'Nytt pris = $base + $percent% = $base × ${100 + percent}/100 = $correct.',
      );
    }

    final pairs = step <= 6
        ? const <(int, int)>[
            (1000, 750),
            (400, 500),
            (900, 810),
            (250, 200),
            (600, 720),
            (200, 160),
            (500, 450),
            (80, 100),
          ]
        : const <(int, int)>[
            (1200, 960),
            (1500, 1800),
            (2000, 1500),
            (300, 390),
            (800, 640),
            (1000, 1100),
            (120, 96),
            (75, 90),
          ];
    final pair = pairs[_random.nextInt(pairs.length)];
    final before = pair.$1;
    final after = pair.$2;
    final correct = (((after - before).abs() * 100) ~/ before);
    final direction = after >= before ? 'ökar' : 'minskar';
    final prompt =
        'Procentuell förändring = ?\nPriset går från $before till $after. Hur många procent $direction det?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: before,
      operand2: after,
      correctAnswer: correct,
      wrongAnswers: _generateWrongPercentAnswers(correct, 3),
      promptText: prompt,
      explanation:
          'Förändring = |$after − $before| / $before × 100 = $correct%.',
    );
  }

  Question _generateM5aCompoundPercentQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Åk 8 policy: two sequential %-changes → final integer price.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final templates = step <= 7
        ? const <({String prompt, int answer, String explanation})>[
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 200 kr får 25% rabatt och sedan 10% rabatt. Vad kostar det då?',
              answer: 135,
              explanation: '200 × 0,75 × 0,90 = 135 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr höjs med 20% och sedan 10%. Vad kostar det då?',
              answer: 132,
              explanation: '100 × 1,20 × 1,10 = 132 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 50% rabatt och sedan 20% rabatt. Vad kostar det då?',
              answer: 40,
              explanation: '100 × 0,50 × 0,80 = 40 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr höjs med 10% och sänks sedan med 10%. Vad kostar det då?',
              answer: 99,
              explanation: '100 × 1,10 × 0,90 = 99 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 10% rabatt två gånger. Vad kostar det då?',
              answer: 81,
              explanation: '100 × 0,90 × 0,90 = 81 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 20% rabatt två gånger. Vad kostar det då?',
              answer: 64,
              explanation: '100 × 0,80 × 0,80 = 64 kr.',
            ),
          ]
        : const <({String prompt, int answer, String explanation})>[
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 30% rabatt två gånger. Vad kostar det då?',
              answer: 49,
              explanation: '100 × 0,70 × 0,70 = 49 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 400 kr höjs med 5% två gånger. Vad kostar det då?',
              answer: 441,
              explanation: '400 × 1,05 × 1,05 = 441 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 400 kr höjs med 25% två gånger. Vad kostar det då?',
              answer: 625,
              explanation: '400 × 1,25 × 1,25 = 625 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr höjs med 50% och sedan 10%. Vad kostar det då?',
              answer: 165,
              explanation: '100 × 1,50 × 1,10 = 165 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 10% rabatt och sedan 20% rabatt. Vad kostar det då?',
              answer: 72,
              explanation: '100 × 0,90 × 0,80 = 72 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr höjs med 30% och sänks sedan med 10%. Vad kostar det då?',
              answer: 117,
              explanation: '100 × 1,30 × 0,90 = 117 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 400 kr får 15% rabatt två gånger. Vad kostar det då?',
              answer: 289,
              explanation: '400 × 0,85 × 0,85 = 289 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 400 kr får 5% rabatt två gånger. Vad kostar det då?',
              answer: 361,
              explanation: '400 × 0,95 × 0,95 = 361 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 200 kr får 40% rabatt och höjs sedan med 10%. Vad kostar det då?',
              answer: 132,
              explanation: '200 × 0,60 × 1,10 = 132 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 100 kr får 60% rabatt och sedan 10% rabatt. Vad kostar det då?',
              answer: 36,
              explanation: '100 × 0,40 × 0,90 = 36 kr.',
            ),
            (
              prompt:
                  'Sammansatt procent = ?\nEtt pris på 200 kr får 75% rabatt och sedan 10% rabatt. Vad kostar det då?',
              answer: 45,
              explanation: '200 × 0,25 × 0,90 = 45 kr.',
            ),
          ];

    final picked = templates[_random.nextInt(templates.length)];
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: picked.answer,
      wrongAnswers: _generateWrongAnswers(picked.answer, 3),
      promptText: picked.prompt,
      explanation: picked.explanation,
    );
  }

  Question _generateM5aPercentQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M5a (Åk 7–9, utan ny UI): procent i textformat med heltalssvar.
    // Vi håller oss till "x % av y" i första steget.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final percents = step <= 3
        ? const <int>[10, 20, 25, 50]
        : step <= 6
            ? const <int>[5, 10, 20, 25, 50, 75]
            : const <int>[
                1,
                2,
                4,
                5,
                8,
                10,
                12,
                15,
                20,
                25,
                40,
                50,
                60,
                75,
                80,
                90,
              ];

    final percent = percents[_random.nextInt(percents.length)];
    final denominator = 100 ~/ _gcd(100, percent);

    final multiplierMax = step <= 3
        ? 10
        : step <= 6
            ? 30
            : 100;
    final multiplier = 1 + _random.nextInt(multiplierMax);
    final base = denominator * multiplier;
    final correct = (percent * base) ~/ 100;

    final prompt = 'Procent = ?\nVad är $percent% av $base?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: '$percent% av $base = ($percent/100) × $base = $correct.',
    );
  }

  Question _generateM5aPowerQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M5a (Åk 8–9, utan ny UI): potenser i textformat med heltalssvar.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final exponent = step <= 3
        ? 2
        : step <= 6
            ? (2 + _random.nextInt(2))
            : (2 + _random.nextInt(3));

    final maxBase = step <= 3
        ? 12
        : step <= 6
            ? 10
            : 8;
    final base = 2 + _random.nextInt(max(1, maxBase - 1));

    final correct = pow(base, exponent).toInt();
    final prompt = 'Potenser = ?\nVad är $base^$exponent?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation: '$base^$exponent = $correct.',
    );
  }

  Question _generateM5aProportionalityQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final roll = _random.nextDouble();

    if (step >= 8 && roll < 0.28) {
      return _generateM5aProportionalityWordProblemQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    if (step >= 9 && roll < 0.42) {
      return _generateM5aProportionalityScaleQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    if (roll < 0.70) {
      return _generateM5aProportionalityForwardQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    return _generateM5aProportionalityInverseQuestion(
      difficulty,
      difficultyStep: step,
    );
  }

  Question _generateM5aProportionalityForwardQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final maxCoefficient = difficultyStep <= 8 ? 12 : 15;
    final coefficient = 2 + _random.nextInt(maxCoefficient - 1);
    final xValue =
        difficultyStep <= 8 ? _random.nextInt(11) : 1 + _random.nextInt(12);
    final correct = coefficient * xValue;
    final prompt =
        'Proportionalitet = ?\ny = ${coefficient}x\nOm x = $xValue, vad är y?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: coefficient,
      operand2: xValue,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: prompt,
      explanation:
          'I proportionalitet gäller y = kx. Här är k = $coefficient.\ny = $coefficient × $xValue = $correct.',
    );
  }

  Question _generateM5aProportionalityInverseQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final maxCoefficient = difficultyStep <= 8 ? 12 : 15;
    final coefficient = 2 + _random.nextInt(maxCoefficient - 1);
    final solution = 1 + _random.nextInt(difficultyStep <= 8 ? 12 : 15);
    final yValue = coefficient * solution;
    final prompt =
        'Proportionalitet = ?\ny = ${coefficient}x\nOm y = $yValue, vad är x?';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: coefficient,
      operand2: yValue,
      correctAnswer: solution,
      wrongAnswers: _generateWrongAnswers(solution, 3),
      promptText: prompt,
      explanation:
          'I proportionalitet gäller y = kx. Här är k = $coefficient.\nx = $yValue ÷ $coefficient = $solution.',
    );
  }

  Question _generateM5aProportionalityWordProblemQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final unitValue =
        difficultyStep <= 9 ? 4 + _random.nextInt(12) : 6 + _random.nextInt(18);
    final quantity =
        difficultyStep <= 9 ? 2 + _random.nextInt(8) : 3 + _random.nextInt(10);
    final correct = unitValue * quantity;

    final templateIndex = _random.nextInt(5);
    late final String body;
    late final String explanation;

    switch (templateIndex) {
      case 0:
        body = '1 liter kostar $unitValue kr. Vad kostar $quantity liter?';
        explanation =
            '$quantity liter kostar $quantity × $unitValue = $correct kr.';
      case 1:
        body = '1 timme = $unitValue km. Hur långt på $quantity timmar?';
        explanation =
            'Vid proportionell fart blir sträckan $quantity × $unitValue = $correct km.';
      case 2:
        body = '1 burk kostar $unitValue kr. Vad kostar $quantity burkar?';
        explanation =
            '$quantity burkar kostar $quantity × $unitValue = $correct kr.';
      case 3:
        body = '1 äggpaket kostar $unitValue kr. Vad kostar $quantity paket?';
        explanation =
            '$quantity paket kostar $quantity × $unitValue = $correct kr.';
      default:
        body =
            '1 meter tyg kostar $unitValue kr. Vad kostar $quantity meter?';
        explanation =
            '$quantity meter kostar $quantity × $unitValue = $correct kr.';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: unitValue,
      operand2: quantity,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: 'Proportionalitet = ?\n$body',
      explanation: explanation,
    );
  }

  Question _generateM5aProportionalityScaleQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Known pair → scale to another quantity (integer unit rate).
    final unitValue =
        difficultyStep <= 9 ? 3 + _random.nextInt(10) : 4 + _random.nextInt(14);
    final knownQty = 2 + _random.nextInt(5);
    final knownTotal = unitValue * knownQty;
    final askQty = knownQty + 1 + _random.nextInt(6);
    final correct = unitValue * askQty;

    final bodies = <String>[
      '$knownQty kg kostar $knownTotal kr. Vad kostar $askQty kg?',
      '$knownQty meter kostar $knownTotal kr. Vad kostar $askQty meter?',
      '$knownQty burkar kostar $knownTotal kr. Vad kostar $askQty burkar?',
    ];
    final body = bodies[_random.nextInt(bodies.length)];

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: knownTotal,
      operand2: askQty,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: 'Proportionalitet = ?\n$body',
      explanation:
          'Enhetspris = $knownTotal ÷ $knownQty = $unitValue. '
          'Sedan $askQty × $unitValue = $correct.',
    );
  }

  Question _generateM5aEquationQuestion(
    DifficultyLevel difficulty, {
    required int gradeLevel,
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    // ROI #51: Åk 7 simplify bank → evaluate-at-x integer bridge.
    if (gradeLevel == 7 && _random.nextDouble() < 0.45) {
      return _generateM5aSimplifyEvaluateAtXQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    if (gradeLevel >= 9 && step >= 7 && _random.nextDouble() < 0.35) {
      return _generateM5aDivisionEquationQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    if (step >= 7 && _random.nextBool()) {
      return _generateM5aGroupedEquationQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    return _generateM5aLinearEquationQuestion(
      difficulty,
      difficultyStep: step,
    );
  }

  Question _generateM5aSimplifyEvaluateAtXQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final x = 1 + _random.nextInt(step <= 6 ? 6 : 10);
    final mode = _random.nextInt(3);

    late final String expression;
    late final int value;
    late final String explanation;

    if (mode == 0) {
      final a = 1 + _random.nextInt(6);
      final b = 1 + _random.nextInt(6);
      final c = _random.nextInt(9);
      final subtractC = _random.nextBool();
      expression = subtractC ? '${a}x + ${b}x − $c' : '${a}x + ${b}x + $c';
      value = (a + b) * x + (subtractC ? -c : c);
      explanation =
          'Först ${a}x + ${b}x = ${(a + b)}x. Sedan ${(a + b)}·$x ${subtractC ? '−' : '+'} $c = $value.';
    } else if (mode == 1) {
      final a = 2 + _random.nextInt(5);
      final b = 1 + _random.nextInt(8);
      expression = '$a(x + $b)';
      value = a * (x + b);
      explanation = '$a·($x + $b) = $a·${x + b} = $value.';
    } else {
      final a = 2 + _random.nextInt(5);
      final b = 1 + _random.nextInt(6);
      final c = 1 + _random.nextInt(8);
      expression = '$a(x − $b) + $c';
      value = a * (x - b) + c;
      explanation = '$a·($x − $b) + $c = $a·${x - b} + $c = $value.';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: x,
      operand2: value,
      correctAnswer: value,
      wrongAnswers: _generateWrongAnswers(value, 3),
      promptText:
          'Förenkla = ?\nUttryck: $expression\nVad blir värdet när x = $x?',
      explanation: explanation,
    );
  }

  Question _generateM5aLinearEquationQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final maxSolution = difficultyStep <= 6
        ? 12
        : difficultyStep <= 8
            ? 18
            : 24;
    final solution = 2 + _random.nextInt(maxSolution - 1);

    final maxCoefficient = difficultyStep <= 6
        ? 12
        : difficultyStep <= 8
            ? 20
            : 30;
    final coefficient = 2 + _random.nextInt(maxCoefficient - 1);

    final maxOffset = difficultyStep <= 6
        ? 18
        : difficultyStep <= 8
            ? 30
            : 60;
    final offset = 1 + _random.nextInt(maxOffset);
    final useAddition = _random.nextBool();

    final rhs = useAddition
        ? coefficient * solution + offset
        : coefficient * solution - offset;
    final operator = useAddition ? '+' : '−';
    final prompt = 'Ekvation = ?\n${coefficient}x $operator $offset = $rhs';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: coefficient,
      operand2: offset,
      correctAnswer: solution,
      wrongAnswers: _generateWrongAnswers(solution, 3),
      promptText: prompt,
      explanation: useAddition
          ? '${coefficient}x + $offset = $rhs\n${coefficient}x = ${rhs - offset}\nx = $solution'
          : '${coefficient}x − $offset = $rhs\n${coefficient}x = ${rhs + offset}\nx = $solution',
    );
  }

  Question _generateM5aGroupedEquationQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final maxSolution = difficultyStep <= 7 ? 10 : 16;
    final solution = 2 + _random.nextInt(maxSolution - 1);
    final coefficient = 2 + _random.nextInt(10);
    final inner = 1 + _random.nextInt(difficultyStep <= 7 ? 8 : 12);
    final useAddition = _random.nextBool();

    final rhs = useAddition
        ? coefficient * (solution + inner)
        : coefficient * (solution - inner);
    final operator = useAddition ? '+' : '−';
    final prompt = 'Ekvation = ?\n$coefficient(x $operator $inner) = $rhs';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: coefficient,
      operand2: inner,
      correctAnswer: solution,
      wrongAnswers: _generateWrongAnswers(solution, 3),
      promptText: prompt,
      explanation: useAddition
          ? '$coefficient(x + $inner) = $rhs\nx + $inner = ${rhs ~/ coefficient}\nx = $solution'
          : '$coefficient(x − $inner) = $rhs\nx − $inner = ${rhs ~/ coefficient}\nx = $solution',
    );
  }

  Question _generateM5aDivisionEquationQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final useBareDivision = _random.nextBool();

    if (useBareDivision) {
      final divisor = 2 + _random.nextInt(5);
      final solution = divisor * (2 + _random.nextInt(8));
      final offset = 1 + _random.nextInt(difficultyStep <= 8 ? 8 : 12);
      final useAddition = _random.nextBool();
      final rhs = useAddition
          ? (solution ~/ divisor) + offset
          : (solution ~/ divisor) - offset;
      final operator = useAddition ? '+' : '−';
      final prompt = 'Ekvation = ?\nx/$divisor $operator $offset = $rhs';

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: divisor,
        operand2: offset,
        correctAnswer: solution,
        wrongAnswers: _generateWrongAnswers(solution, 3),
        promptText: prompt,
        explanation: useAddition
            ? 'x/$divisor + $offset = $rhs\nx/$divisor = ${rhs - offset}\nx = $solution'
            : 'x/$divisor − $offset = $rhs\nx/$divisor = ${rhs + offset}\nx = $solution',
      );
    }

    final divisor = 2 + _random.nextInt(4);
    final coefficient = 2 + _random.nextInt(6);
    final solution = divisor * (2 + _random.nextInt(8));
    final offset = coefficient * solution;
    final constant = divisor * (difficultyStep <= 8 ? 3 : 5);
    final rhs = (offset + constant) ~/ divisor;
    final prompt =
        'Ekvation = ?\n($coefficient' 'x + $constant)/$divisor = $rhs';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: coefficient,
      operand2: divisor,
      correctAnswer: solution,
      wrongAnswers: _generateWrongAnswers(solution, 3),
      promptText: prompt,
      explanation: '($coefficient'
          'x + $constant)/$divisor = $rhs\n$coefficient'
          'x + $constant = ${rhs * divisor}\n$coefficient'
          'x = ${(rhs * divisor) - constant}\nx = $solution',
    );
  }

  Question _generateM5aPrecedenceQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M5a (Åk 7–9, utan ny UI): prioriteringsregler med + och ×,
    // med/utan parenteser beroende på step.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final maxA = step <= 3
        ? 20
        : step <= 6
            ? 40
            : 80;

    final a = 2 + _random.nextInt(maxA - 1);
    final b = 2 + _random.nextInt(maxA - 1);
    final c = 2 + _random.nextInt(maxA - 1);

    final allowParentheses = step >= 5;
    final useParentheses = allowParentheses && _random.nextBool();
    final preferMulFirst = _random.nextBool();

    late final String expression;
    late final int correct;
    late final int commonWrong;

    if (useParentheses) {
      if (preferMulFirst) {
        expression = '($a + $b) × $c';
        correct = (a + b) * c;
        commonWrong = a + (b * c);
      } else {
        expression = '$a × ($b + $c)';
        correct = a * (b + c);
        commonWrong = (a * b) + c;
      }
    } else {
      if (preferMulFirst) {
        expression = '$a + $b × $c';
        correct = a + (b * c);
        commonWrong = (a + b) * c;
      } else {
        expression = '$a × $b + $c';
        correct = (a * b) + c;
        commonWrong = a * (b + c);
      }
    }

    final wrong = <int>{};
    if (commonWrong != correct) {
      wrong.add(commonWrong);
    }
    for (final candidate in _generateWrongAnswers(correct, 6)) {
      if (candidate != correct) {
        wrong.add(candidate);
      }
      if (wrong.length >= 3) break;
    }

    final prompt = 'Prioriteringsregler = ?\n$expression';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correct,
      wrongAnswers: wrong.take(3).toList(),
      promptText: prompt,
      explanation:
          'Räkna multiplikation före addition, och räkna alltid parenteser först.',
    );
  }

  // endregion

  // region M5b Generators (Åk 7-9 Advanced Topics)

  Question _generateM5bLinearFunctionQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
    int? gradeLevel,
  }) {
    // Integer text-bridge for y = kx + m (ROI #39) — no graph UI.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final grade = gradeLevel ?? 8;

    final maxSlope = step <= 3
        ? 3
        : step <= 6
            ? 5
            : 10;
    var slope = 1 + _random.nextInt(maxSlope);
    if (_random.nextBool() && grade >= 8) {
      slope = -slope;
    }

    final maxIntercept = step <= 3
        ? 5
        : step <= 6
            ? 10
            : 20;
    final intercept = _random.nextInt(2 * maxIntercept + 1) - maxIntercept;

    final maxX = step <= 3
        ? 5
        : step <= 6
            ? 10
            : 20;

    String formatLine(int k, int m) {
      final kPart = k == 1
          ? 'x'
          : k == -1
              ? '−x'
              : '${k}x';
      if (m == 0) return 'y = $kPart';
      if (m > 0) return 'y = $kPart + $m';
      return 'y = $kPart − ${-m}';
    }

    final line = formatLine(slope, intercept);
    final mode = _random.nextInt(grade >= 9 ? 5 : 4);

    if (mode == 0) {
      // Bestäm k
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: slope,
        operand2: intercept,
        correctAnswer: slope,
        wrongAnswers: _generateWrongAnswers(slope, 3),
        promptText: 'Linjär funktion = ?\n$line\nBestäm k (lutningen).',
        explanation: 'I y = kx + m är k = $slope.',
      );
    }

    if (mode == 1) {
      // Bestäm m
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: slope,
        operand2: intercept,
        correctAnswer: intercept,
        wrongAnswers: _generateWrongAnswers(intercept, 3),
        promptText: 'Linjär funktion = ?\n$line\nBestäm m (skärningen med y-axeln).',
        explanation: 'I y = kx + m är m = $intercept.',
      );
    }

    if (mode == 2 && slope != 0 && intercept % slope == 0) {
      // När är y = 0?
      final root = -intercept ~/ slope;
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: slope,
        operand2: intercept,
        correctAnswer: root,
        wrongAnswers: _generateWrongAnswers(root, 3),
        promptText: 'Linjär funktion = ?\n$line\nNär är y = 0? Svara med x.',
        explanation: '0 = $slope·x + $intercept ⇒ x = $root.',
      );
    }

    if (mode == 4 || (mode == 3 && grade >= 9 && _random.nextBool())) {
      // Steeper slope compare
      var otherSlope = 1 + _random.nextInt(maxSlope);
      if (otherSlope == slope.abs()) {
        otherSlope = slope.abs() + 1;
      }
      if (_random.nextBool()) otherSlope = -otherSlope;
      final otherIntercept =
          _random.nextInt(2 * maxIntercept + 1) - maxIntercept;
      final steeper = slope.abs() >= otherSlope.abs() ? 1 : 2;
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: slope,
        operand2: otherSlope,
        correctAnswer: steeper,
        wrongAnswers: steeper == 1 ? const [2, 3, 0] : const [1, 3, 0],
        promptText:
            'Linjär funktion = ?\n1) ${formatLine(slope, intercept)}\n2) ${formatLine(otherSlope, otherIntercept)}\nVilken har störst lutning (absolutvärde)? Svara 1 eller 2.',
        explanation:
            '|k₁|=${slope.abs()}, |k₂|=${otherSlope.abs()} ⇒ funktion $steeper.',
      );
    }

    // Evaluate y at x (with optional small table).
    final testX = 1 + _random.nextInt(maxX);
    final correct = slope * testX + intercept;
    final coordinatePoints = <String>[];
    for (var x = 0; x <= min(3, testX); x++) {
      coordinatePoints.add('  x=$x, y=${slope * x + intercept}');
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: testX,
      operand2: slope,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: '''Linjär funktion = ?
$line

Koordinater:
${coordinatePoints.join('\n')}

Beräkna y när x = $testX''',
      explanation:
          'y = $slope·$testX + $intercept = $correct',
    );
  }

  Question _generateM5bGeometricTransformationQuestion(
    DifficultyLevel difficulty, {
    required int gradeLevel,
    required int difficultyStep,
  }) {
    if (gradeLevel >= 9) {
      return _generateM5bGeometryQuestion(
        difficulty,
        difficultyStep: difficultyStep,
      );
    }

    // M5b (Åk 7–9, delstep 2): Geometriska transformationer
    // Spegling, rotation och translation i koordinatsystem.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    // Välj transformationstyp
    final maxCoord = step <= 3
        ? 10
        : step <= 6
            ? 15
            : 20;

    final beforeX = _random.nextInt(maxCoord + 1) - (maxCoord ~/ 2);
    final beforeY = _random.nextInt(maxCoord + 1) - (maxCoord ~/ 2);

    // Undvik (0, 0)
    if (beforeX == 0 && beforeY == 0) {
      return _generateM5bGeometricTransformationQuestion(
        difficulty,
        gradeLevel: gradeLevel,
        difficultyStep: difficultyStep,
      );
    }

    final transformType = _random.nextInt(6); // 0-5 för 6 transformationer

    late final int afterX;
    late final int afterY;
    late final String transformName;
    late final String axis;
    late final int answerValue;
    late final String answerType;

    switch (transformType) {
      case 0:
        // Spegling över x-axel: (x, y) → (x, -y)
        afterX = beforeX;
        afterY = -beforeY;
        transformName = 'Spegling över x-axel';
        axis = '(horisontell linje)';
        answerValue = afterY;
        answerType = 'y-värde';
        break;
      case 1:
        // Spegling över y-axel: (x, y) → (-x, y)
        afterX = -beforeX;
        afterY = beforeY;
        transformName = 'Spegling över y-axel';
        axis = '(vertikal linje)';
        answerValue = afterX;
        answerType = 'x-värde';
        break;
      case 2:
        // Spegling över y=x (diagonal): (x, y) → (y, x)
        afterX = beforeY;
        afterY = beforeX;
        transformName = 'Spegling över diagonalen y=x';
        axis = '(diagonal)';
        answerValue = afterY;
        answerType = 'y-värde';
        break;
      case 3:
        // Rotation 90° moturs runt origo: (x, y) → (-y, x)
        afterX = -beforeY;
        afterY = beforeX;
        transformName = 'Rotation 90° moturs';
        axis = '(moturs runt origo)';
        answerValue = afterX;
        answerType = 'x-värde';
        break;
      case 4:
        // Rotation 180° runt origo: (x, y) → (-x, -y)
        afterX = -beforeX;
        afterY = -beforeY;
        transformName = 'Rotation 180°';
        axis = '(runt origo)';
        answerValue = afterY;
        answerType = 'y-värde';
        break;
      case 5:
        // Translation: (x, y) → (x+dx, y+dy)
        final dx = _random.nextInt(10) - 5; // -5 till 4
        final dy = _random.nextInt(10) - 5;
        afterX = beforeX + dx;
        afterY = beforeY + dy;
        transformName = 'Translation (förflyttning)';
        axis = 'förskjutning ($dx, $dy)';
        // För translation frågar vi bara efter ett värde
        answerValue = _random.nextBool() ? afterX : afterY;
        answerType = _random.nextBool() ? 'x-värde' : 'y-värde';
        break;
    }

    final prompt = '''Geometrisk transformation = ?
Transformation: $transformName $axis
Punkt före: ($beforeX, $beforeY)
Punkt efter: ($afterX, $afterY)

Vad är $answerType efter transformationen?''';

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: answerValue,
      wrongAnswers: _generateWrongAnswers(answerValue, 3),
      promptText: prompt,
      explanation:
          '$transformName: ($beforeX, $beforeY) → ($afterX, $afterY)\nSvar: $answerType Efter transformationen är det $answerValue',
    );
  }

  Question _generateM5bGeometryQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final roll = _random.nextDouble();

    if (roll < 0.34) {
      return _generateM5bPythagorasQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    if (roll < 0.7) {
      return _generateM5bAreaOrPerimeterQuestion(
        difficulty,
        difficultyStep: step,
      );
    }

    return _generateM5bVolumeQuestion(
      difficulty,
      difficultyStep: step,
    );
  }

  Question _generateM5bPythagorasQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    const triples = <(int, int, int)>[
      (6, 8, 10),
      (9, 12, 15),
      (5, 12, 13),
      (8, 15, 17),
      (7, 24, 25),
      (10, 24, 26),
      (12, 16, 20),
      (18, 24, 30),
      (20, 21, 29),
      (9, 40, 41),
    ];

    final triple = triples[_random.nextInt(triples.length)];
    final a = triple.$1;
    final b = triple.$2;
    final c = triple.$3;
    final variant =
        difficultyStep >= 9 ? _random.nextInt(3) : _random.nextInt(2);

    late final String body;
    late final int correct;
    late final String explanation;

    switch (variant) {
      case 0:
        body = 'Pythagoras: c = ? när a = $a, b = $b';
        correct = c;
        explanation =
            '$a^2 + $b^2 = c^2\n${a * a} + ${b * b} = ${c * c}\nc = $c';
      case 1:
        body = 'Pythagoras: a = ? när b = $b, c = $c';
        correct = a;
        explanation =
            'a^2 + $b^2 = $c^2\na^2 = ${c * c} - ${b * b} = ${a * a}\na = $a';
      default:
        body = 'Pythagoras: b = ? när a = $a, c = $c';
        correct = b;
        explanation =
            '$a^2 + b^2 = $c^2\nb^2 = ${c * c} - ${a * a} = ${b * b}\nb = $b';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: a,
      operand2: b,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: 'Geometri = ?\n$body',
      explanation: explanation,
    );
  }

  Question _generateM5bAreaOrPerimeterQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final variant = _random.nextInt(8);

    late final String body;
    late final int correct;
    late final int operand1;
    late final int operand2;
    late final String explanation;

    switch (variant) {
      case 0:
        final width = 8 + _random.nextInt(difficultyStep >= 9 ? 15 : 10);
        final height = 6 + _random.nextInt(difficultyStep >= 9 ? 12 : 8);
        body = 'Area av rektangel: $width × $height';
        correct = width * height;
        operand1 = width;
        operand2 = height;
        explanation =
            'Arean av en rektangel är längd × bredd.\n$width × $height = $correct.';
      case 1:
        final side = 10 + _random.nextInt(difficultyStep >= 9 ? 16 : 10);
        body = 'Area av kvadrat: sida = $side';
        correct = side * side;
        operand1 = side;
        operand2 = side;
        explanation =
            'Arean av en kvadrat är sida × sida.\n$side × $side = $correct.';
      case 2:
        final side = 10 + _random.nextInt(difficultyStep >= 9 ? 16 : 10);
        body = 'Omkrets av kvadrat: sida = $side';
        correct = 4 * side;
        operand1 = side;
        operand2 = 4;
        explanation =
            'Omkretsen av en kvadrat är 4 × sida.\n4 × $side = $correct.';
      case 3:
        final base = 8 + 2 * _random.nextInt(difficultyStep >= 9 ? 8 : 6);
        final height = 4 + _random.nextInt(difficultyStep >= 9 ? 10 : 6);
        body = 'Area av triangel: b = $base, h = $height';
        correct = (base * height) ~/ 2;
        operand1 = base;
        operand2 = height;
        explanation =
            'Arean av en triangel är b × h / 2.\n$base × $height / 2 = $correct.';
      case 4:
        final base = 10 + _random.nextInt(difficultyStep >= 9 ? 12 : 8);
        final height = 6 + _random.nextInt(difficultyStep >= 9 ? 10 : 6);
        body = 'Area av parallellogram: b = $base, h = $height';
        correct = base * height;
        operand1 = base;
        operand2 = height;
        explanation =
            'Arean av en parallellogram är bas × höjd.\n$base × $height = $correct.';
      case 5:
        final width = 8 + _random.nextInt(difficultyStep >= 9 ? 14 : 9);
        final height = 5 + _random.nextInt(difficultyStep >= 9 ? 12 : 8);
        body = 'Omkrets av rektangel: $width × $height';
        correct = 2 * (width + height);
        operand1 = width;
        operand2 = height;
        explanation =
            'Omkretsen av en rektangel är 2 × (längd + bredd).\n'
            '2 × ($width + $height) = $correct.';
      case 6:
        final side = 4 + _random.nextInt(difficultyStep >= 9 ? 10 : 7);
        body = 'Ytarea av kub: sida = $side';
        correct = 6 * side * side;
        operand1 = side;
        operand2 = 6;
        explanation =
            'Ytan på en kub är 6 × sida².\n6 × $side × $side = $correct.';
      default:
        const triangles = <(int, int, int)>[
          (7, 9, 12),
          (9, 12, 15),
          (8, 15, 17),
          (6, 8, 10),
          (5, 12, 13),
        ];
        final triangle = triangles[_random.nextInt(triangles.length)];
        body =
            'Omkrets av triangel: ${triangle.$1} + ${triangle.$2} + ${triangle.$3}';
        correct = triangle.$1 + triangle.$2 + triangle.$3;
        operand1 = triangle.$1;
        operand2 = triangle.$2;
        explanation =
            'Omkretsen är summan av alla sidor.\n${triangle.$1} + ${triangle.$2} + ${triangle.$3} = $correct.';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: 'Geometri = ?\n$body',
      explanation: explanation,
    );
  }

  Question _generateM5bVolumeQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final variant = _random.nextInt(3);

    late final String body;
    late final int correct;
    late final int operand1;
    late final int operand2;
    late final String explanation;

    switch (variant) {
      case 0:
        final side = 4 + _random.nextInt(difficultyStep >= 9 ? 7 : 5);
        body = 'Volym av kub: sida = $side';
        correct = side * side * side;
        operand1 = side;
        operand2 = side;
        explanation =
            'Volymen av en kub är sida^3.\n$side × $side × $side = $correct.';
      case 1:
        final length = 4 + _random.nextInt(difficultyStep >= 9 ? 7 : 5);
        final width = 5 + _random.nextInt(difficultyStep >= 9 ? 8 : 5);
        final height = 6 + _random.nextInt(difficultyStep >= 9 ? 8 : 5);
        body = 'Volym av rätblock: $length × $width × $height';
        correct = length * width * height;
        operand1 = length;
        operand2 = width;
        explanation =
            'Volymen av ett rätblock är längd × bredd × höjd.\n$length × $width × $height = $correct.';
      default:
        final baseArea = 20 + 5 * _random.nextInt(difficultyStep >= 9 ? 8 : 5);
        final height = 6 + _random.nextInt(difficultyStep >= 9 ? 10 : 6);
        body = 'Volym av prisma: basarea = $baseArea, höjd = $height';
        correct = baseArea * height;
        operand1 = baseArea;
        operand2 = height;
        explanation =
            'Volymen av ett prisma är basarea × höjd.\n$baseArea × $height = $correct.';
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
      promptText: 'Geometri = ?\n$body',
      explanation: explanation,
    );
  }

  /// Åk 9 probability bag/table/dice — integer percent answers (ROI #40).
  Question _generateM5bProbabilityBagTableQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final mode = _random.nextInt(3);

    if (mode == 0) {
      // Bag with colors that yield exact percent.
      final totals = <int>[4, 5, 10, 20, 25];
      final total = totals[_random.nextInt(totals.length)];
      final red = 1 + _random.nextInt(total - 1);
      final blue = _random.nextInt(total - red + 1);
      final green = total - red - blue;
      final percent = (red * 100) ~/ total;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: red,
        operand2: total,
        correctAnswer: percent,
        wrongAnswers: _generateWrongPercentAnswers(percent, 3),
        promptText:
            'Sannolikhet = ?\nPåse: $red röda, $blue blå, $green gröna (totalt $total).\nHur stor är chansen (%) att dra röd?',
        explanation:
            'Chans = $red/$total × 100 = $percent%.',
      );
    }

    if (mode == 1) {
      // Two-way table style.
      final boysYes = 2 + _random.nextInt(step <= 8 ? 6 : 10);
      final boysNo = 2 + _random.nextInt(step <= 8 ? 6 : 10);
      final girlsYes = 2 + _random.nextInt(step <= 8 ? 6 : 10);
      final girlsNo = 2 + _random.nextInt(step <= 8 ? 6 : 10);
      final total = boysYes + boysNo + girlsYes + girlsNo;
      // Force percent-friendly total by adjusting girlsNo.
      final targetTotals = <int>[10, 20, 25, 50];
      final target = targetTotals[_random.nextInt(targetTotals.length)];
      var gNo = girlsNo;
      final withoutGNo = boysYes + boysNo + girlsYes;
      if (withoutGNo >= target) {
        // Fallback bag already handled; use simple percent of yes.
        final yes = boysYes + girlsYes;
        final all = withoutGNo + gNo;
        final percent = (yes * 100) ~/ all;
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: yes,
          operand2: all,
          correctAnswer: percent,
          wrongAnswers: _generateWrongPercentAnswers(percent, 3),
          promptText:
              'Sannolikhet = ?\nTabell (gillar matte):\nPojkar ja:$boysYes nej:$boysNo\nFlickor ja:$girlsYes nej:$gNo\nHur stor är chansen (%) att en slumpvald elev svarade ja?',
          explanation: 'Ja = $yes av $all ⇒ $percent%.',
        );
      }
      gNo = target - withoutGNo;
      final yes = boysYes + girlsYes;
      final percent = (yes * 100) ~/ target;
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: yes,
        operand2: target,
        correctAnswer: percent,
        wrongAnswers: _generateWrongPercentAnswers(percent, 3),
        promptText:
            'Sannolikhet = ?\nTabell (gillar matte):\nPojkar ja:$boysYes nej:$boysNo\nFlickor ja:$girlsYes nej:$gNo\nHur stor är chansen (%) att en slumpvald elev svarade ja?',
        explanation: 'Ja = $yes av $target ⇒ $percent%.',
      );
    }

    // Dice with exact percents.
    final dieRoll = _random.nextInt(3);
    if (dieRoll == 0) {
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: 3,
        operand2: 6,
        correctAnswer: 50,
        wrongAnswers: const [33, 25, 75],
        promptText:
            'Sannolikhet = ?\nEn tärning kastas. Hur stor är chansen (%) för jämnt tal?',
        explanation: 'Jämna: 2,4,6 → 3/6 = 50%.',
      );
    }
    if (dieRoll == 1) {
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: 2,
        operand2: 6,
        correctAnswer: 50,
        wrongAnswers: const [33, 25, 17],
        promptText:
            'Sannolikhet = ?\nEn tärning kastas. Hur stor är chansen (%) för tal > 3?',
        explanation: '4,5,6 → 3/6 = 50%.',
      );
    }
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 6,
      operand2: 36,
      correctAnswer: 17,
      wrongAnswers: const [14, 20, 25],
      promptText:
          'Sannolikhet = ?\nTvå tärningar kastas. Ungefär hur stor är chansen (%) för summa 7? (6 av 36 utfall)',
      explanation: '6/36 ≈ 16,7% ≈ 17%.',
    );
  }

  Question _generateM5bAdvancedStatisticsQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // M5b (Åk 7–9, delstep 3): Avancerad statistik
    // Distributioner, outliers och korrelationer i textformat.
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    final questionType =
        _random.nextInt(3); // 0=outlier, 1=distribution, 2=correlation

    late final String prompt;
    late final int correctAnswer;

    if (questionType == 0) {
      // Outlier-fråga: identifiera värdet som avviker mycket
      final dataSize = step <= 3
          ? 5
          : step <= 6
              ? 7
              : 9;
      final baseValue = 10 + _random.nextInt(30);
      final variance = step <= 3
          ? 2
          : step <= 6
              ? 3
              : 4;

      final data = <int>[];
      for (int i = 0; i < dataSize - 1; i++) {
        final val = baseValue + _random.nextInt(2 * variance + 1) - variance;
        data.add(max(1, val));
      }

      // Lägg till en tydlig outlier
      final outlier = baseValue + (10 + _random.nextInt(20));
      data.add(outlier);
      data.shuffle(_random);

      final dataStr = data.join(', ');
      correctAnswer = outlier;

      prompt = '''Statistik = ?
Datasätt: $dataStr

Vilket värde är en outlier (avviker mycket från övriga)?''';
    } else if (questionType == 1) {
      // Distribution-fråga: ge ett datasätt och fråga om mode (vanligaste värde)
      final dataSize = step <= 3
          ? 6
          : step <= 6
              ? 8
              : 10;
      final mode = 5 + _random.nextInt(15);

      final data = <int>[];
      // Lägg till mode flera gånger
      final modeCount = step <= 3
          ? 2
          : step <= 6
              ? 2
              : 3;
      for (int i = 0; i < modeCount; i++) {
        data.add(mode);
      }

      // Lägg till andra värden
      for (int i = data.length; i < dataSize; i++) {
        var val = 5 + _random.nextInt(20);
        while (val == mode && i < dataSize - 1) {
          val = 5 + _random.nextInt(20);
        }
        data.add(val);
      }
      data.shuffle(_random);

      final dataStr = data.join(', ');
      correctAnswer = mode;

      prompt = '''Statistik = ?
Datasätt: $dataStr

Vad är typvärdet (det värde som förekommer oftast)?''';
    } else {
      // Korrelation-fråga: två variabler och fråga om de är positivt/negativt korrelerade
      // Vi kodar svaret som: 1 = positiv korrelation, -1 = negativ korrelation
      final isPositive = _random.nextBool();

      final var1Values = <int>[];
      final var2Values = <int>[];

      final dataSize = step <= 3
          ? 4
          : step <= 6
              ? 5
              : 6;
      for (int i = 0; i < dataSize; i++) {
        final x = 10 + i * 5 + _random.nextInt(3);
        var1Values.add(x);

        if (isPositive) {
          // Positivt korrelerad: y ökar när x ökar
          var2Values.add(x + _random.nextInt(10) - 2);
        } else {
          // Negativt korrelerad: y minskar när x ökar
          var2Values.add(50 - x + _random.nextInt(10) - 5);
        }
      }

      final var1Str = var1Values.join(', ');
      final var2Str = var2Values.join(', ');
      correctAnswer = isPositive ? 1 : -1;

      final prompt1 = '''Statistik = ?
Variabel A: $var1Str
Variabel B: $var2Str

Vilken typ av korrelation har variablerna?
(Svar: 1 för positiv, -1 för negativ)''';

      prompt = prompt1;
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(correctAnswer, 3),
      promptText: prompt,
      explanation:
          'Analysera datasättets egenskaper: outliers är värden långt från genomsnittet, typvärde är det vanligaste värdet, och korrelation beskriver sambandet mellan variabler.',
    );
  }

  // endregion

  // region Operation Selection

  OperationType _getRandomOperation({
    required int? gradeLevel,
    int? mixBaselineStep,
  }) {
    // IMPORTANT: In Mix mode, we must respect grade shaping.
    // Otherwise low grades can unexpectedly get too much ×/÷ too early.
    final allowed = gradeLevel == null
        ? const <OperationType>{
            OperationType.addition,
            OperationType.subtraction,
            OperationType.multiplication,
            OperationType.division,
          }
        : DifficultyConfig.visibleOperationsForGrade(gradeLevel);

    final grade = gradeLevel;
    final step = mixBaselineStep == null
        ? null
        : DifficultyConfig.clampDifficultyStep(mixBaselineStep);

    // Åk 2: open ×/÷ carefully.
    // Direct operation choice is allowed from grade config, but Mix should still
    // feel mostly +/− until the internal step has climbed a bit.
    if (grade == 2 && step != null) {
      List<OperationType> weighted;
      if (step <= 3) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
        ];
      } else if (step <= 6) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
        ];
      } else if (step <= 8) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
          OperationType.multiplication,
          OperationType.division,
        ];
      } else {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
          OperationType.division,
        ];
      }

      final filtered = weighted.where(allowed.contains).toList(growable: false);
      if (filtered.isNotEmpty) {
        return filtered[_random.nextInt(filtered.length)];
      }
    }

    // Åk 3: make Mix feel smoother when ×/÷ is introduced.
    // Default Mix ordering stays stable; we only adjust weights in Åk 3 when
    // we know the Mix baseline step.
    if (grade == 3 && step != null) {
      List<OperationType> weighted;
      if (step <= 3) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
        ];
      } else if (step <= 6) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
        ];
      } else if (step <= 8) {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
          OperationType.multiplication,
          OperationType.division,
        ];
      } else {
        weighted = <OperationType>[
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
          OperationType.division,
        ];
      }

      final filtered = weighted.where(allowed.contains).toList(growable: false);
      if (filtered.isNotEmpty) {
        return filtered[_random.nextInt(filtered.length)];
      }
    }

    // Keep stable ordering (helps deterministic tests).
    final ordered = <OperationType>[
      if (allowed.contains(OperationType.addition)) OperationType.addition,
      if (allowed.contains(OperationType.subtraction))
        OperationType.subtraction,
      if (allowed.contains(OperationType.multiplication))
        OperationType.multiplication,
      if (allowed.contains(OperationType.division)) OperationType.division,
    ];

    if (ordered.isEmpty) {
      return OperationType.addition;
    }

    return ordered[_random.nextInt(ordered.length)];
  }

  // endregion

  // region Low-grade Mix Generators (Åk 2-3)

  Question _generateLowGradeDoubleHalfQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final askHalf = _random.nextBool();
    final maxBase = step <= 4
        ? 10
        : step <= 7
            ? 20
            : 40;

    if (askHalf) {
      final half = 1 + _random.nextInt(maxBase ~/ 2);
      final whole = half * 2;
      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: whole,
        operand2: 2,
        correctAnswer: half,
        wrongAnswers: _generateWrongAnswers(half, 3),
        promptText: 'Dubbelt/hälften = ?\nVad är hälften av $whole?',
        explanation: 'Hälften av $whole är $whole ÷ 2 = $half.',
      );
    }

    final base = 1 + _random.nextInt(maxBase);
    final doubled = base * 2;
    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: base,
      operand2: 2,
      correctAnswer: doubled,
      wrongAnswers: _generateWrongAnswers(doubled, 3),
      promptText: 'Dubbelt/hälften = ?\nVad är dubbelt så mycket som $base?',
      explanation: 'Dubbelt så mycket som $base är $base × 2 = $doubled.',
    );
  }

  /// Reasonableness / estimate: round then multiply (ROI #38).
  Question _generateReasonablenessEstimateQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
    required int? gradeLevel,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final grade = gradeLevel ?? 4;

    final tensRound = grade <= 4 || step <= 5;
    final aRaw = tensRound
        ? (11 + _random.nextInt(grade <= 3 ? 40 : 80))
        : (21 + _random.nextInt(grade <= 6 ? 150 : 400));
    final bRaw = tensRound
        ? (11 + _random.nextInt(grade <= 3 ? 30 : 60))
        : (11 + _random.nextInt(grade <= 6 ? 80 : 200));

    int roundToNice(int n) {
      if (tensRound) {
        return ((n + 5) ~/ 10) * 10;
      }
      if (n < 100) return ((n + 5) ~/ 10) * 10;
      return ((n + 50) ~/ 100) * 100;
    }

    final aEst = max(10, roundToNice(aRaw));
    final bEst = max(10, roundToNice(bRaw));
    final estimate = aEst * bEst;
    final exact = aRaw * bRaw;

    final askNearest = _random.nextBool();
    if (askNearest) {
      // Pick nearest "nice" landmark among distractors around the exact product.
      final landmarks = <int>{
        estimate,
        roundToNice(exact),
        ((exact + 50) ~/ 100) * 100,
        ((exact + 500) ~/ 1000) * 1000,
        estimate ~/ 2,
        estimate * 2,
      }..removeWhere((n) => n <= 0);

      var best = landmarks.first;
      var bestDist = (exact - best).abs();
      for (final n in landmarks) {
        final d = (exact - n).abs();
        if (d < bestDist) {
          best = n;
          bestDist = d;
        }
      }

      final wrong = landmarks.where((n) => n != best).take(3).toList();
      while (wrong.length < 3) {
        wrong.addAll(_generateWrongAnswers(best, 3));
        wrong.remove(best);
      }

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.mixed,
        difficulty: difficulty,
        operand1: aRaw,
        operand2: bRaw,
        correctAnswer: best,
        wrongAnswers: wrong.take(3).toList(growable: false),
        promptText:
            'Rimlighet = ?\n$aRaw × $bRaw är närmast vilket tal?',
        explanation:
            'Exakt $aRaw × $bRaw = $exact. Närmast bland alternativen är $best.',
      );
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: aRaw,
      operand2: bRaw,
      correctAnswer: estimate,
      wrongAnswers: _generateWrongAnswers(estimate, 3),
      promptText: tensRound
          ? 'Rimlighet = ?\nUppskatta $aRaw × $bRaw genom att avrunda till tiotal. Vad blir uppskattningen?'
          : 'Rimlighet = ?\nUppskatta $aRaw × $bRaw genom att avrunda till närmaste tiotal/hundratal. Vad blir uppskattningen?',
      explanation:
          'Avrunda till $aEst och $bEst. Uppskattning: $aEst × $bEst = $estimate (exakt $exact).',
    );
  }

  /// Pre-SEN fraction bridge: “½ of n” with integer answer (ROI #36).
  Question _generateHalfOfNTextBridgeQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
    required int? gradeLevel,
  }) {
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final grade = gradeLevel ?? 4;
    final maxWhole = grade <= 3
        ? (step <= 5 ? 20 : 40)
        : grade <= 4
            ? (step <= 5 ? 40 : 80)
            : grade <= 5
                ? (step <= 5 ? 60 : 120)
                : (step <= 5 ? 80 : 200);

    final half = 1 + _random.nextInt(max(1, maxWhole ~/ 2));
    final whole = half * 2;

    final askVariants = <String>[
      'Vad är ½ av $whole?',
      'Hur mycket är hälften av $whole?',
      'En pizza delas i två lika stora bitar. Hur många bitar är ½ av $whole bitar?',
    ];
    final ask = askVariants[_random.nextInt(askVariants.length)];

    final wrong = <int>{
      whole,
      half + 1,
      half - 1,
      whole ~/ 4,
      (whole * 3) ~/ 4,
      half * 2 ~/ 3,
    }
      ..remove(half)
      ..removeWhere((n) => n <= 0);

    while (wrong.length < 3) {
      wrong.addAll(_generateWrongAnswers(half, 3));
      wrong.remove(half);
    }

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: whole,
      operand2: 2,
      correctAnswer: half,
      wrongAnswers: wrong.take(3).toList(growable: false),
      promptText: 'Bråk (½) = ?\n$ask',
      explanation: '½ av $whole betyder $whole ÷ 2 = $half.',
    );
  }

  Question _generateLowGradeStatisticsQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final cappedMax = difficultyStep <= 6 ? 10 : 20;
    return _generateM4StatisticsTableQuestion(
      DifficultyNumberRange(1, cappedMax),
      difficulty,
      difficultyStep: 2,
    );
  }

  Question _generateLowGradeChanceQuestion(
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final candidateSets = <List<({int red, int blue})>>[
      [
        (red: 4, blue: 1),
        (red: 3, blue: 2),
        (red: 2, blue: 3),
        (red: 1, blue: 4),
      ],
      [
        (red: 3, blue: 1),
        (red: 2, blue: 2),
        (red: 2, blue: 3),
        (red: 1, blue: 3),
      ],
      [
        (red: 5, blue: 1),
        (red: 3, blue: 3),
        (red: 2, blue: 4),
        (red: 1, blue: 5),
      ],
    ];

    final bags = List<({int red, int blue})>.from(
      candidateSets[_random.nextInt(candidateSets.length)],
    )..shuffle(_random);

    var bestIndex = 0;
    var bestScore = -1.0;
    for (var index = 0; index < bags.length; index++) {
      final bag = bags[index];
      final score = bag.red / (bag.red + bag.blue);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = index;
      }
    }

    final prompt = 'Sannolikhet (konkret) = ?\n'
        'Påse 1: Röda: ${bags[0].red}, Blå: ${bags[0].blue}\n'
        'Påse 2: Röda: ${bags[1].red}, Blå: ${bags[1].blue}\n'
        'Påse 3: Röda: ${bags[2].red}, Blå: ${bags[2].blue}\n'
        'Påse 4: Röda: ${bags[3].red}, Blå: ${bags[3].blue}\n'
        'I vilken påse är chansen störst att få röd? Svara med påsens nummer.';

    final correctAnswer = bestIndex + 1;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.mixed,
      difficulty: difficulty,
      operand1: 0,
      operand2: 0,
      correctAnswer: correctAnswer,
      wrongAnswers: <int>[1, 2, 3, 4]
          .where((value) => value != correctAnswer)
          .toList(growable: false),
      promptText: prompt,
      explanation:
          'Jämför andelen röda bollar i varje påse. Påse $correctAnswer har störst andel röda och därför störst chans.',
    );
  }

  // endregion

  // region Arithmetic Generators (Addition)

  Question _generateAddition(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    // Simple curriculum shaping:
    // - Åk 1: early steps focus on sums within 10 + tiokompisar.
    // - Åk 2: early steps avoid carry (no tiotalsövergång).
    final isGrade1 = gradeLevel == 1;
    final isGrade2 = gradeLevel == 2;
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    // Åk 1: stay within 10 a bit longer; it reduces cognitive load a lot.
    final enforceSumWithin10 = isGrade1 && difficultyStep <= 6;

    // Åk 2: tiotalsövergång i lugn progression.
    // - step 1–2: alltid utan tiotalsövergång (ental)
    // - step 3–4: oftast utan
    // - step 5–6: ibland utan
    // - step 7+: fritt
    final carryAvoidChance = isGrade2
        ? step <= 2
            ? 1.0
            : step <= 4
                ? 0.75
                : step <= 6
                    ? 0.35
                    : 0.0
        : 0.0;
    final avoidCarryOnes = isGrade2 && _random.nextDouble() < carryAvoidChance;

    // Åk 1–3: keep results inside the current number range.
    // Without this, Åk 1 can get e.g. 18+19 even though the intended domain is 0–20.
    final enforceAnswerWithinRange =
        gradeLevel != null && gradeLevel >= 1 && gradeLevel <= 3;

    // M3 (Åk 4–6): bigger numbers but introduce carry gradually.
    final isM3Grade = gradeLevel != null && gradeLevel >= 4 && gradeLevel <= 6;
    final isM5aGrade = gradeLevel != null && gradeLevel >= 7 && gradeLevel <= 9;
    final allowSignedArithmetic = isM5aGrade && step >= 4;
    final avoidCarryAllDigits = isM3Grade && difficultyStep <= 3;
    final requireCarrySomewhere = isM3Grade && difficultyStep >= 8;

    int operand1;
    int operand2;

    // Åk 7–9 (M5a): introduce signed operands after the earliest steps.
    if (allowSignedArithmetic) {
      final maxAbs = difficultyStep <= 3
          ? min(20, max(1, range.max))
          : difficultyStep <= 6
              ? min(100, max(1, range.max))
              : min(1000, max(1, range.max));

      final minAbs = (maxAbs * 0.25).floor();
      operand1 = _randomSignedValue(maxAbs, minAbs: minAbs);
      operand2 = _randomSignedValue(maxAbs, minAbs: minAbs);
      if (operand1 == 0 && operand2 == 0) {
        operand2 = 1;
      }
    }
    // Bias: tiokompisar in Åk 1 when range allows.
    else if (isGrade1 && range.max >= 10 && _random.nextDouble() < 0.35) {
      operand1 = _randomInRange(const DifficultyNumberRange(0, 10));
      operand2 = 10 - operand1;
    } else {
      // Rejection sampling with a small cap for stability.
      operand1 = _randomInRange(range);
      operand2 = _randomInRange(range);
      for (var i = 0; i < 120; i++) {
        if (enforceAnswerWithinRange && operand1 + operand2 > range.max) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        if (enforceSumWithin10 && operand1 + operand2 > 10) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        if (avoidCarryOnes && (operand1 % 10) + (operand2 % 10) >= 10) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        if (avoidCarryAllDigits && _hasCarry(operand1, operand2)) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        if (requireCarrySomewhere && !_hasCarry(operand1, operand2)) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        if ((operand1 == 0 || operand2 == 0) && operand1 + operand2 > 10) {
          operand1 = _randomInRange(range);
          operand2 = _randomInRange(range);
          continue;
        }

        break;
      }
    }
    if (operand1 == 0 && operand2 > 10) {
      operand1 = 1;
    }
    if (operand2 == 0 && operand1 > 10) {
      operand2 = 1;
    }
    final correctAnswer = operand1 + operand2;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.addition,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(
        correctAnswer,
        3,
        allowNegative: isM5aGrade,
      ),
      explanation: '$operand1 + $operand2 = $correctAnswer',
    );
  }

  Question _generateAdditionWordProblem(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateAddition(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final prompt = _pickAdditionPrompt(
      a: base.operand1,
      b: base.operand2,
    );

    return base.copyWith(
      promptText: prompt,
      explanation:
          '${base.operand1} + ${base.operand2} = ${base.correctAnswer}',
    );
  }

  Question _generateAdditionMissingNumber(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateAddition(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final sum = base.correctAnswer;
    final missingLeft = _random.nextBool();

    final prompt = missingLeft
        ? '? + ${base.operand2} = $sum'
        : '${base.operand1} + ? = $sum';
    final correctMissing = missingLeft ? base.operand1 : base.operand2;

    return base.copyWith(
      promptText: prompt,
      correctAnswer: correctMissing,
      wrongAnswers: _generateWrongAnswers(correctMissing, 3),
      explanation: '${base.operand1} + ${base.operand2} = $sum',
    );
  }

  Question _generateGrade1AdditionNumberSenseQuestion(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final variantRoll = _random.nextDouble();
    final usesAfterPrompt = difficultyStep <= 3 || variantRoll < 0.40;

    if (usesAfterPrompt) {
      final target = _randomInRange(
        DifficultyNumberRange(range.min, max(range.min, range.max - 1)),
      );
      final answer = target + 1;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.addition,
        difficulty: difficulty,
        operand1: target,
        operand2: 1,
        correctAnswer: answer,
        wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
        promptText: 'Vilket tal kommer efter $target?',
        explanation: 'Talet efter $target är $answer.',
      );
    }

    // MC order: no drag-sort UI — ask which number lands in a sorted slot.
    if (variantRoll < 0.62) {
      return _generateSortOrderMcQuestion(
        range: range,
        difficulty: difficulty,
        operationType: OperationType.addition,
      );
    }

    if (variantRoll < 0.82) {
      final start = _randomInRange(
        DifficultyNumberRange(range.min, max(range.min, range.max - 3)),
      );
      final answer = start + 2;
      final end = start + 3;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.addition,
        difficulty: difficulty,
        operand1: start,
        operand2: end,
        correctAnswer: answer,
        wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
        promptText:
            'Vilket tal saknas i ordningen: $start, ${start + 1}, __, $end',
        explanation:
            'Talföljden ökar med 1: $start, ${start + 1}, $answer, $end.',
      );
    }

    final left = _randomInRange(range);
    int right = _randomInRange(range);
    for (var attempt = 0; attempt < 40 && right == left; attempt++) {
      right = _randomInRange(range);
    }

    final answer = max(left, right);

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.addition,
      difficulty: difficulty,
      operand1: left,
      operand2: right,
      correctAnswer: answer,
      wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
      promptText: 'Vilket är störst: $left eller $right?',
      explanation: '$answer är större än ${answer == left ? right : left}.',
    );
  }

  /// "Sortera" as multiple-choice order (ROI #35): list four numbers, ask
  /// which lands first / second / last after sorting ascending.
  Question _generateSortOrderMcQuestion({
    required DifficultyNumberRange range,
    required DifficultyLevel difficulty,
    required OperationType operationType,
  }) {
    final values = <int>{};
    for (var attempt = 0; attempt < 80 && values.length < 4; attempt++) {
      values.add(_randomInRange(range));
    }
    while (values.length < 4) {
      values.add(range.min + values.length);
    }

    final shown = values.toList(growable: false)..shuffle(_random);
    final sorted = [...shown]..sort();

    final mode = _random.nextInt(3);
    final int answer;
    final String askLine;
    switch (mode) {
      case 0:
        answer = sorted.first;
        askLine = 'Vilket tal kommer först?';
      case 1:
        answer = sorted.last;
        askLine = 'Vilket tal kommer sist?';
      default:
        answer = sorted[1];
        askLine = 'Vilket tal kommer på plats 2?';
    }

    final distractors =
        shown.where((n) => n != answer).take(3).toList(growable: false);

    return Question(
      id: _uuid.v4(),
      operationType: operationType,
      difficulty: difficulty,
      operand1: sorted.first,
      operand2: sorted.last,
      correctAnswer: answer,
      wrongAnswers: distractors,
      promptText: 'Sortera minst till störst: ${shown.join(', ')}\n$askLine',
      explanation:
          'Ordning: ${sorted.join(', ')}. $askLine Svar: $answer.',
    );
  }

  // endregion

  // region Arithmetic Generators (Subtraction)

  Question _generateSubtraction(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    // Ensure no negative results for younger children
    final isGrade1 = gradeLevel == 1;
    final isGrade2 = gradeLevel == 2;
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    // Åk 2: tiotalsövergång/lån i lugn progression.
    // - step 1–2: alltid utan lån (ental)
    // - step 3–4: oftast utan
    // - step 5–6: ibland utan
    // - step 7+: fritt
    final borrowAvoidChance = isGrade2
        ? step <= 2
            ? 1.0
            : step <= 4
                ? 0.75
                : step <= 6
                    ? 0.35
                    : 0.0
        : 0.0;
    final avoidBorrowOnes =
        isGrade2 && _random.nextDouble() < borrowAvoidChance;
    // Åk 1: keep within 0–10-ish a bit longer and bias towards 10-x.
    final keepSmall = isGrade1 && difficultyStep <= 6;
    // Åk 1 early: also avoid borrowing to keep it predictable.
    final avoidBorrowGrade1 = isGrade1 && difficultyStep <= 6;

    // M3 (Åk 4–6): bigger numbers but introduce borrowing gradually.
    final isM3Grade = gradeLevel != null && gradeLevel >= 4 && gradeLevel <= 6;
    final isM5aGrade = gradeLevel != null && gradeLevel >= 7 && gradeLevel <= 9;
    final allowSignedArithmetic = isM5aGrade && step >= 4;
    final avoidBorrowAllDigits = isM3Grade && difficultyStep <= 3;
    final requireBorrowSomewhere = isM3Grade && difficultyStep >= 8;

    var operand1 = _randomInRange(range);
    var operand2 = _randomInRange(range);

    if (allowSignedArithmetic) {
      final maxAbs = difficultyStep <= 3
          ? min(20, max(1, range.max))
          : difficultyStep <= 6
              ? min(100, max(1, range.max))
              : min(1000, max(1, range.max));

      final minAbs = (maxAbs * 0.25).floor();
      operand1 = _randomSignedValue(maxAbs, minAbs: minAbs);
      // Keep operand2 positive/non-zero to avoid "a - -b" at this stage.
      operand2 = _randomInRange(DifficultyNumberRange(max(1, minAbs), maxAbs));
    } else if (isGrade1 && range.max >= 10 && _random.nextDouble() < 0.35) {
      operand1 = 10;
      operand2 = _randomInRange(const DifficultyNumberRange(0, 10));
    }

    for (var i = 0; i < 120; i++) {
      if (!allowSignedArithmetic && operand2 > operand1) {
        final temp = operand1;
        operand1 = operand2;
        operand2 = temp;
      }

      if (keepSmall && operand1 > 10) {
        operand1 = _randomInRange(range);
        operand2 = _randomInRange(range);
        continue;
      }

      if (avoidBorrowOnes && (operand1 % 10) < (operand2 % 10)) {
        operand1 = _randomInRange(range);
        operand2 = _randomInRange(range);
        continue;
      }

      if (avoidBorrowGrade1 && (operand1 % 10) < (operand2 % 10)) {
        operand1 = _randomInRange(range);
        operand2 = _randomInRange(range);
        continue;
      }

      if (avoidBorrowAllDigits && _hasBorrow(operand1, operand2)) {
        operand1 = _randomInRange(range);
        operand2 = _randomInRange(range);
        continue;
      }

      if (requireBorrowSomewhere && !_hasBorrow(operand1, operand2)) {
        operand1 = _randomInRange(range);
        operand2 = _randomInRange(range);
        continue;
      }

      if (operand2 == 0 && operand1 > 10) {
        operand2 = _randomInRange(range);
        continue;
      }

      break;
    }

    if (operand2 == 0 && operand1 > 10) {
      operand2 = 1;
    }
    final correctAnswer = operand1 - operand2;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.subtraction,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(
        correctAnswer,
        3,
        allowNegative: isM5aGrade,
      ),
      explanation: '$operand1 - $operand2 = $correctAnswer',
    );
  }

  Question _generateSubtractionWordProblem(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateSubtraction(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final prompt = _pickSubtractionPrompt(
      a: base.operand1,
      b: base.operand2,
    );

    return base.copyWith(
      promptText: prompt,
      explanation:
          '${base.operand1} - ${base.operand2} = ${base.correctAnswer}',
    );
  }

  Question _generateSubtractionMissingNumber(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateSubtraction(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final result = base.correctAnswer;
    final missingLeft = _random.nextBool();

    final prompt = missingLeft
        ? '? - ${base.operand2} = $result'
        : '${base.operand1} - ? = $result';
    final correctMissing = missingLeft ? base.operand1 : base.operand2;

    return base.copyWith(
      promptText: prompt,
      correctAnswer: correctMissing,
      wrongAnswers: _generateWrongAnswers(correctMissing, 3),
      explanation: '${base.operand1} - ${base.operand2} = $result',
    );
  }

  Question _generateGrade1SubtractionNumberSenseQuestion(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    final variantRoll = _random.nextDouble();
    final usesBeforePrompt = difficultyStep <= 3 || variantRoll < 0.40;

    if (usesBeforePrompt) {
      final target = _randomInRange(
        DifficultyNumberRange(max(1, range.min + 1), max(1, range.max)),
      );
      final answer = target - 1;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.subtraction,
        difficulty: difficulty,
        operand1: target,
        operand2: 1,
        correctAnswer: answer,
        wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
        promptText: 'Vilket tal kommer före $target?',
        explanation: 'Talet före $target är $answer.',
      );
    }

    if (variantRoll < 0.62) {
      return _generateSortOrderMcQuestion(
        range: range,
        difficulty: difficulty,
        operationType: OperationType.subtraction,
      );
    }

    if (variantRoll < 0.82) {
      final startFloor = min(range.max, max(range.min + 3, 3));
      final start = _randomInRange(
        DifficultyNumberRange(startFloor, max(startFloor, range.max)),
      );
      final answer = start - 2;
      final end = start - 3;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.subtraction,
        difficulty: difficulty,
        operand1: start,
        operand2: end,
        correctAnswer: answer,
        wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
        promptText:
            'Vilket tal saknas i ordningen: $start, ${start - 1}, __, $end',
        explanation:
            'Talföljden minskar med 1: $start, ${start - 1}, $answer, $end.',
      );
    }

    final left = _randomInRange(range);
    int right = _randomInRange(range);
    for (var attempt = 0; attempt < 40 && right == left; attempt++) {
      right = _randomInRange(range);
    }

    final answer = min(left, right);

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.subtraction,
      difficulty: difficulty,
      operand1: left,
      operand2: right,
      correctAnswer: answer,
      wrongAnswers: _generateGrade1NumberSenseWrongAnswers(answer, range),
      promptText: 'Vilket är minst: $left eller $right?',
      explanation: '$answer är mindre än ${answer == left ? right : left}.',
    );
  }

  List<int> _generateGrade1NumberSenseWrongAnswers(
    int correctAnswer,
    DifficultyNumberRange range,
  ) {
    final wrongAnswers = <int>{};
    const neighborOffsets = <int>[-1, 1, -2, 2, -3, 3];

    for (final offset in neighborOffsets) {
      final candidate = correctAnswer + offset;
      if (candidate < range.min || candidate > range.max) {
        continue;
      }
      if (candidate == correctAnswer) {
        continue;
      }
      wrongAnswers.add(candidate);
      if (wrongAnswers.length == 3) {
        return wrongAnswers.toList(growable: false);
      }
    }

    for (var attempt = 0; attempt < 60 && wrongAnswers.length < 3; attempt++) {
      final candidate = _randomInRange(range);
      if (candidate == correctAnswer) {
        continue;
      }
      wrongAnswers.add(candidate);
    }

    return wrongAnswers.toList(growable: false);
  }

  // endregion

  // region Word Problem Templates

  // --- Word problem templates (Åk 1–3, 1-step) ---
  // We keep Swedish prompts short and avoid tricky pluralization.

  String _pickAdditionPrompt({required int a, required int b}) {
    final templates = <String Function(int, int)>[
      (x, y) => 'Du har $x kulor och får $y fler. Hur många kulor har du nu?',
      (x, y) =>
          'På bordet ligger $x pennor. Du lägger dit $y till. Hur många pennor blir det?',
      (x, y) =>
          'Lisa har $x klossar och får $y till. Hur många klossar har hon nu?',
      (x, y) =>
          'I en burk finns $x knappar. Du lägger i $y till. Hur många knappar finns nu?',
      (x, y) => 'Du har $x kort. Du får $y kort till. Hur många kort har du?',
      (x, y) =>
          'I en låda ligger $x bollar. Du lägger i $y bollar till. Hur många bollar finns?',
      (x, y) =>
          'Det är $x barn i parken. $y barn kommer. Hur många barn är där nu?',
      (x, y) =>
          'Du plockar $x stenar och plockar $y till. Hur många stenar har du?',
    ];

    final pick = templates[_random.nextInt(templates.length)];
    return pick(a, b);
  }

  String _pickSubtractionPrompt({required int a, required int b}) {
    final templates = <String Function(int, int)>[
      (x, y) => 'Du har $x ballonger. $y flyger iväg. Hur många är kvar?',
      (x, y) => 'Det finns $x fiskar. $y simmar bort. Hur många är kvar?',
      (x, y) =>
          'Du har $x godisbitar. Du äter $y. Hur många godisbitar är kvar?',
      (x, y) =>
          'I en skål finns $x frukter. Du tar $y. Hur många frukter är kvar?',
      (x, y) =>
          'På en hylla står $x böcker. Du tar bort $y. Hur många böcker står kvar?',
      (x, y) => 'Du har $x mynt. Du ger bort $y. Hur många mynt har du kvar?',
      (x, y) =>
          'Det ligger $x leksaker på golvet. Du plockar upp $y. Hur många ligger kvar?',
      (x, y) =>
          'I en låda finns $x klossar. Du tar ut $y. Hur många klossar är kvar?',
    ];

    final pick = templates[_random.nextInt(templates.length)];
    return pick(a, b);
  }

  String _pickMultiplicationPrompt({required int a, required int b}) {
    final templates = <String Function(int, int)>[
      (x, y) => 'Du har $y påsar med $x kulor i varje. Hur många kulor är det?',
      (x, y) =>
          'Det finns $y rader med $x stolar i varje rad. Hur många stolar?',
      (x, y) =>
          'Du bygger $y torn med $x klossar i varje torn. Hur många klossar?',
      (x, y) =>
          'I en bok finns $y kapitel med $x sidor i varje. Hur många sidor?',
      (x, y) =>
          'Du har $y lådor med $x bollar i varje. Hur många bollar totalt?',
    ];

    final pick = templates[_random.nextInt(templates.length)];
    return pick(a, b);
  }

  String _pickDivisionPrompt({required int a, required int b}) {
    final templates = <String Function(int, int)>[
      (x, y) =>
          'Du har $x godisbitar och delar dem lika på $y barn. Hur många får varje?',
      (x, y) =>
          'Det finns $x kort. De delas i $y lika stora högar. Hur många i varje hög?',
      (x, y) =>
          'Du har $x äpplen och lägger $y äpplen i varje påse. Hur många påsar blir det?',
      (x, y) =>
          'En klass har $x pennor. $y pennor delas ut till varje bord. Hur många bord får pennor?',
    ];

    final pick = templates[_random.nextInt(templates.length)];
    return pick(a, b);
  }

  // endregion

  // region Arithmetic Generators (Multiplication)

  Question _generateMultiplication(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final grade = gradeLevel;
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);

    // Åk 1–3: tabeller först (förutsägbar progression).
    // - Tidigt: liten “andra faktor” (t.ex. upp till 5)
    // - Mitten: upp till 10
    // - Sent: upp till grade-cap (Åk 3 kan nå 12)
    if (grade != null && grade >= 1 && grade <= 3) {
      final safeMin = max(1, range.min);
      final safeMax = max(safeMin, range.max);

      final factorMin = safeMax >= 2 ? max(2, safeMin) : safeMin;

      // Åk 3: håll dig främst till tabeller 2–10 tills högre step.
      final tableMax =
          (grade == 3 && step <= 6) ? min(10, safeMax) : min(12, safeMax);

      final otherMax = step <= 3
          ? min(5, safeMax)
          : step <= 6
              ? min(10, safeMax)
              : safeMax;

      final a = _randomInRange(
        DifficultyNumberRange(factorMin, max(factorMin, tableMax)),
      );
      final b = _randomInRange(
        DifficultyNumberRange(factorMin, max(factorMin, otherMax)),
      );

      final swap = _random.nextBool();
      final operand1 = swap ? b : a;
      final operand2 = swap ? a : b;
      final correctAnswer = operand1 * operand2;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.multiplication,
        difficulty: difficulty,
        operand1: operand1,
        operand2: operand2,
        correctAnswer: correctAnswer,
        wrongAnswers: _generateWrongAnswers(correctAnswer, 3),
        explanation: '$operand1 × $operand2 = $correctAnswer',
      );
    }

    final operand1 = _randomInRange(range);
    final operand2 = _randomInRange(range);
    final correctAnswer = operand1 * operand2;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.multiplication,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(correctAnswer, 3),
      explanation: '$operand1 × $operand2 = $correctAnswer',
    );
  }

  Question _generateMultiplicationCurriculum(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Åk 4–6: börja med tabeller (<=10) mot större tal och skala sedan upp.
    // Steg 1–10: minst en faktor i tabell-området för att hålla progressionen
    // förutsägbar i quiz-formatet.
    DifficultyConfig.clampDifficultyStep(difficultyStep);

    // Avoid 0 to keep questions meaningful.
    final safeMin = max(1, range.min);
    final safeMax = max(safeMin, range.max);

    final smallMax = min(10, safeMax);

    final a = _randomInRange(DifficultyNumberRange(safeMin, safeMax));
    final b = _randomInRange(DifficultyNumberRange(safeMin, smallMax));

    // Randomize which one is the smaller factor for variety.
    final swap = _random.nextBool();
    final operand1 = swap ? b : a;
    final operand2 = swap ? a : b;
    final correctAnswer = operand1 * operand2;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.multiplication,
      difficulty: difficulty,
      operand1: operand1,
      operand2: operand2,
      correctAnswer: correctAnswer,
      wrongAnswers: _generateWrongAnswers(correctAnswer, 3),
      explanation: '$operand1 × $operand2 = $correctAnswer',
    );
  }

  Question _generateMultiplicationWordProblem(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    // Avoid 0 in story problems.
    final safeMin = max(1, range.min);
    final safeMax = max(safeMin, range.max);

    final base = _generateMultiplication(
      DifficultyNumberRange(safeMin, safeMax),
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final prompt = _pickMultiplicationPrompt(
      a: base.operand1,
      b: base.operand2,
    );

    return base.copyWith(
      promptText: prompt,
      explanation:
          '${base.operand1} × ${base.operand2} = ${base.correctAnswer}',
    );
  }

  Question _generateMultiplicationMissingNumber(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateMultiplication(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final product = base.correctAnswer;
    final missingLeft = _random.nextBool();

    final prompt = missingLeft
        ? '? × ${base.operand2} = $product'
        : '${base.operand1} × ? = $product';
    final correctMissing = missingLeft ? base.operand1 : base.operand2;

    return base.copyWith(
      promptText: prompt,
      correctAnswer: correctMissing,
      wrongAnswers: _generateWrongAnswers(correctMissing, 3),
      explanation: '${base.operand1} × ${base.operand2} = $product',
    );
  }

  // endregion

  // region Arithmetic Generators (Division)

  Question _generateDivision(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    // Generate division that results in whole numbers
    // Avoid division by zero and keep questions meaningful by avoiding quotient=0.
    final grade = gradeLevel;
    final step = DifficultyConfig.clampDifficultyStep(difficultyStep);
    final safeMin = max(1, range.min);
    final safeMax = max(safeMin, range.max);

    // Åk 1–3: håll divisionen i tabell-området och skala gradvis.
    if (grade != null && grade >= 1 && grade <= 3) {
      final divisorMin = safeMax >= 2 ? max(2, safeMin) : safeMin;
      final divisorMax =
          (grade == 3 && step <= 6) ? min(10, safeMax) : min(12, safeMax);

      final quotientMax = step <= 3
          ? min(5, safeMax)
          : step <= 6
              ? min(10, safeMax)
              : safeMax;

      final divisor = _randomInRange(
        DifficultyNumberRange(divisorMin, max(divisorMin, divisorMax)),
      );
      final quotient =
          _randomInRange(DifficultyNumberRange(1, max(1, quotientMax)));
      final dividend = divisor * quotient;

      return Question(
        id: _uuid.v4(),
        operationType: OperationType.division,
        difficulty: difficulty,
        operand1: dividend,
        operand2: divisor,
        correctAnswer: quotient,
        wrongAnswers: _generateWrongAnswers(quotient, 3),
        explanation: '$dividend ÷ $divisor = $quotient',
      );
    }

    final divisor = _randomInRange(DifficultyNumberRange(safeMin, safeMax));
    final quotient = _randomInRange(DifficultyNumberRange(safeMin, safeMax));
    final dividend = divisor * quotient;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.division,
      difficulty: difficulty,
      operand1: dividend,
      operand2: divisor,
      correctAnswer: quotient,
      wrongAnswers: _generateWrongAnswers(quotient, 3),
      explanation: '$dividend ÷ $divisor = $quotient',
    );
  }

  Question _generateDivisionCurriculum(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int difficultyStep,
  }) {
    // Åk 4–6 (quiz-format): håll divisionen i heltal (utan rest) men skala upp.
    // Steg 1–10: divisor hålls i tabell-området (<=10) för trygg progression.
    DifficultyConfig.clampDifficultyStep(difficultyStep);

    final safeMin = max(1, range.min);
    final safeMax = max(safeMin, range.max);

    final smallMax = min(10, safeMax);

    final divisor = _randomInRange(DifficultyNumberRange(safeMin, smallMax));
    final quotient = _randomInRange(DifficultyNumberRange(safeMin, safeMax));
    final dividend = divisor * quotient;

    return Question(
      id: _uuid.v4(),
      operationType: OperationType.division,
      difficulty: difficulty,
      operand1: dividend,
      operand2: divisor,
      correctAnswer: quotient,
      wrongAnswers: _generateWrongAnswers(quotient, 3),
      explanation: '$dividend ÷ $divisor = $quotient',
    );
  }

  Question _generateDivisionWordProblem(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateDivision(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final prompt = _pickDivisionPrompt(
      a: base.operand1,
      b: base.operand2,
    );

    return base.copyWith(
      promptText: prompt,
      explanation:
          '${base.operand1} ÷ ${base.operand2} = ${base.correctAnswer}',
    );
  }

  Question _generateDivisionMissingNumber(
    DifficultyNumberRange range,
    DifficultyLevel difficulty, {
    required int? gradeLevel,
    required int difficultyStep,
  }) {
    final base = _generateDivision(
      range,
      difficulty,
      gradeLevel: gradeLevel,
      difficultyStep: difficultyStep,
    );

    final quotient = base.correctAnswer;
    final missingLeft = _random.nextBool();

    final prompt = missingLeft
        ? '? ÷ ${base.operand2} = $quotient'
        : '${base.operand1} ÷ ? = $quotient';
    final correctMissing = missingLeft ? base.operand1 : base.operand2;

    return base.copyWith(
      promptText: prompt,
      correctAnswer: correctMissing,
      wrongAnswers: _generateWrongAnswers(correctMissing, 3),
      explanation: '${base.operand1} ÷ ${base.operand2} = $quotient',
    );
  }

  // endregion

  // region Wrong Answer Generation

  List<int> _generateWrongAnswers(
    int correctAnswer,
    int count, {
    bool allowNegative = false,
  }) {
    final wrongAnswers = <int>{};
    final spread = max(10, correctAnswer.abs() ~/ 2);

    while (wrongAnswers.length < count) {
      var wrongAnswer = correctAnswer + _random.nextInt(spread * 2) - spread;

      // For younger grades we keep options non-negative.
      if (!allowNegative && wrongAnswer < 0) wrongAnswer = -wrongAnswer;
      if (wrongAnswer == correctAnswer) continue;

      wrongAnswers.add(wrongAnswer);
    }

    return wrongAnswers.toList();
  }

  /// M4a: Tid (klockan) för Åk 1–3
  /// Åk 1: hel/halv timme
  /// Åk 2: + kvart
  /// Åk 3: alla minuter + tidsintervall
  Question _generateM4TimeQuestion(
    DifficultyLevel difficulty, {
    required int gradeLevel,
    required int difficultyStep,
  }) {
    final isGrade1 = gradeLevel == 1;
    final isGrade2 = gradeLevel == 2;
    final isGrade3 = gradeLevel == 3;

    // Åk 1: Endast hel och halv timme
    if (isGrade1) {
      final isHalfHour = _random.nextBool();
      final hour = 1 + _random.nextInt(12); // 1-12
      final minute = isHalfHour ? 30 : 0;

      final timeStr = '$hour:${minute.toString().padLeft(2, '0')}';

      if (minute == 0) {
        // Hel timme: fråga vilken timme
        final prompt = 'Klockan visar $timeStr.\n\nVilken timme är det?';
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: hour,
          wrongAnswers: _generateWrongAnswers(hour, 3)
              .map((w) => w.clamp(1, 12))
              .toSet()
              .toList(),
          promptText: prompt,
          explanation: 'Klockan $timeStr betyder att timmen är $hour.',
        );
      } else {
        // Halv timme: fråga minuter efter hel timme
        final prompt =
            'Klockan visar $timeStr.\n\nHur många minuter efter $hour?';
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: 30,
          wrongAnswers: [15, 45, 0].where((w) => w != 30).take(3).toList(),
          promptText: prompt,
          explanation:
              'Klockan $timeStr betyder att det är 30 minuter efter $hour.',
        );
      }
    }

    // Åk 2: Hel, halv och kvart
    if (isGrade2) {
      final hour = 1 + _random.nextInt(12);
      final minuteOptions = [0, 15, 30, 45];
      final minute = minuteOptions[_random.nextInt(minuteOptions.length)];

      final timeStr = '$hour:${minute.toString().padLeft(2, '0')}';

      if (minute == 0) {
        final prompt = 'Klockan visar $timeStr.\n\nVilken timme är det?';
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: hour,
          wrongAnswers: _generateWrongAnswers(hour, 3)
              .map((w) => w.clamp(1, 12))
              .toSet()
              .toList(),
          promptText: prompt,
          explanation: 'Klockan $timeStr betyder att timmen är $hour.',
        );
      } else {
        final prompt =
            'Klockan visar $timeStr.\n\nHur många minuter efter $hour?';
        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: minute,
          wrongAnswers:
              minuteOptions.where((w) => w != minute).take(3).toList(),
          promptText: prompt,
          explanation:
              'Klockan $timeStr betyder att det är $minute minuter efter $hour.',
        );
      }
    }

    // Åk 3: Alla minuter (5-minutersintervall) + tidsintervall
    if (isGrade3) {
      final useInterval = difficultyStep >= 5 && _random.nextBool();

      if (useInterval) {
        // Tidsintervall: "Klockan var X:YY och blev Z:WW. Hur många minuter?"
        final startHour = 8 + _random.nextInt(4); // 8-11
        final startMinute = _random.nextInt(12) * 5; // 0, 5, 10, ..., 55

        final durationMinutes = 10 + _random.nextInt(90); // 10-99 minuter
        final totalStartMinutes = startHour * 60 + startMinute;
        final totalEndMinutes = totalStartMinutes + durationMinutes;

        final endHour = (totalEndMinutes ~/ 60) % 24;
        final endMinute = totalEndMinutes % 60;

        final startTimeStr =
            '$startHour:${startMinute.toString().padLeft(2, '0')}';
        final endTimeStr = '$endHour:${endMinute.toString().padLeft(2, '0')}';

        final prompt =
            'Klockan var $startTimeStr.\nSen blev klockan $endTimeStr.\n\nHur många minuter gick?';

        return Question(
          id: _uuid.v4(),
          operationType: OperationType.mixed,
          difficulty: difficulty,
          operand1: 0,
          operand2: 0,
          correctAnswer: durationMinutes,
          wrongAnswers: _generateWrongAnswers(durationMinutes, 3),
          promptText: prompt,
          explanation:
              'Från $startTimeStr till $endTimeStr är det $durationMinutes minuter.',
        );
      } else {
        // Enkel tid med minuter
        final hour = 6 + _random.nextInt(10); // 6-15
        final minute = _random.nextInt(12) * 5; // 0, 5, 10, ..., 55

        final timeStr = '$hour:${minute.toString().padLeft(2, '0')}';

        if (minute == 0) {
          final prompt = 'Klockan visar $timeStr.\n\nVilken timme är det?';
          return Question(
            id: _uuid.v4(),
            operationType: OperationType.mixed,
            difficulty: difficulty,
            operand1: 0,
            operand2: 0,
            correctAnswer: hour,
            wrongAnswers: _generateWrongAnswers(hour, 3)
                .map((w) => w.clamp(1, 23))
                .toSet()
                .toList(),
            promptText: prompt,
            explanation: 'Klockan $timeStr betyder att timmen är $hour.',
          );
        } else {
          final prompt =
              'Klockan visar $timeStr.\n\nHur många minuter efter $hour?';
          return Question(
            id: _uuid.v4(),
            operationType: OperationType.mixed,
            difficulty: difficulty,
            operand1: 0,
            operand2: 0,
            correctAnswer: minute,
            wrongAnswers: _generateWrongAnswers(minute, 3)
                .map((w) => w.clamp(0, 55))
                .toSet()
                .toList(),
            promptText: prompt,
            explanation:
                'Klockan $timeStr betyder att det är $minute minuter efter $hour.',
          );
        }
      }
    }

    // Fallback (bör inte hända)
    return _generateM4TimeQuestion(
      difficulty,
      gradeLevel: 1,
      difficultyStep: difficultyStep,
    );
  }

  // endregion
}
