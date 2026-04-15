abstract class Plurals {
  static String classNameToCollectionName(String className) {
    final name = camelToSnake(className);
    final nameParts = name.split('_');

    late final List<String> namePrefix;
    late String nameSuffix;

    if (nameParts.length > 1) {
      namePrefix = nameParts.sublist(0, nameParts.length - 1);
      nameSuffix = nameParts.last;
    } else {
      namePrefix = [];
      nameSuffix = name;
    }

    return [...namePrefix, pluralize(nameSuffix)].join('_');
  }

  static String camelToSnake(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        )
        .toLowerCase();
  }

  static String snakeToCamel(String input) {
    if (!input.contains(RegExp(r'(_|-)+'))) {
      return input;
    }
    return input.toLowerCase().replaceAllMapped(
      RegExp(r'(_|-)+([a-z])'),
      (Match m) => m[2]!.toUpperCase(),
    );
  }

  /// Pluralize a word.
  static String pluralize(String word) => _replaceWord(
    _irregularSingles,
    _irregularPlurals,
    _pluralRules,
    word,
  );

  /// Singularize a word.
  static String singularize(String word) => _replaceWord(
    _irregularPlurals,
    _irregularSingles,
    _singularRules,
    word,
  );

  /// Replace a word with the updated word.
  ///
  /// [replaceMap]  map of words to be replaced
  /// [keepMap]     map of words to keep intact
  /// [rules]       List of rules to use for transformation
  /// [word]        a word to update
  ///
  /// Returns a function that accepts a word and returns the updated word
  static String _replaceWord(
    Map<String, String> replaceMap,
    Map<String, String> keepMap,
    Map<RegExp, String> rules,
    String word,
  ) {
    // Getting a token from a word without regard to case.
    final token = word.toLowerCase();

    // Check against the keep object map.
    if (keepMap.containsKey(token)) {
      return token;
    }

    // Check against the replacement map for a direct word replacement.
    if (replaceMap.containsKey(token)) {
      return replaceMap[token]!;
    }

    // Run all the rules against the word.
    return _applyRules(token, word, rules);
  }

  /// Applying word transformation according to a list of rules.
  static String _applyRules(String token, String word, Map<RegExp, String> rules) {
    // Empty string or doesn't need fixing.
    if (token.isEmpty || _uncountables.contains(token)) {
      return word;
    }

    // Iterate over the sanitization rules and use the first one to match.
    for (var i = rules.length - 1; i >= 0; i--) {
      final rule = rules.entries.elementAt(i);

      final regexp = rule.key;
      if (regexp.hasMatch(word)) {
        return _replace(word, rule);
      }
    }

    return word;
  }

  // Replace a word using a rule.
  static String _replace(String word, MapEntry<RegExp, String> rule) {
    final regex = rule.key;
    //print('regex: $regex');

    // Use the key from the rule as a RegExp to match in the word.
    // The value from the rule is used as a string to replace the match.
    return word.replaceFirstMapped(regex, (match) {
      // Interpolate the replacement string using arguments from the match.

      final groups = match.groups([match.groupCount]);

      final args = groups.map((e) => e!).toList();
      final String result = _interpolate(rule.value, args);

      return result;
    });
  }

  /// Interpolate a regexp string.
  static String _interpolate(String str, List<String> args) {
    final RegExp exp = RegExp(r'\$(\d{1,2})');
    return str.replaceAllMapped(exp, (match) {
      final matchedText = match.group(1);
      final int index = int.parse(matchedText!);
      return args.length > index ? args[index] : '';
    });
  }

  // --- Tables

  static final _irregularPlurals = _irregularRulesData.map((single, plural) => MapEntry(plural, single));
  static final _irregularSingles = _irregularRulesData;

  static final Map<RegExp, String> _pluralRules = {
    ..._pluralRulesData,

    // uncountables
    for (final rule in _uncountableRules) rule: r'$0',
  };

  static final Map<RegExp, String> _singularRules = {
    ..._singularRulesData,

    // uncountables
    for (final rule in _uncountableRules) rule: r'$0',
  };

  static final _uncountables = <String>{
    for (final rule in _uncountableWords) rule,
  };

  // ---

  static final Map<RegExp, String> _singularRulesData = {
    Rule(r's$'): '',
    Rule(r'(ss)$'): r'$0',
    Rule(r'(wi|kni|(?:after|half|high|low|mid|non|night|[^\w]|^)li)ves$'): r'$0fe',
    Rule(r'(ar|(?:wo|[ae])l|[eo][ao])ves$'): r'$0f',
    Rule(r'ies$'): 'y',
    Rule(r'([b|r|c]ook|room|smooth)ies$'): r'$0ie',
    Rule(r'\b([pl]|zomb|(?:neck|cross)?t|coll|faer|food|gen|goon|group|lass|talk|goal|cut)ies$'): r'$0ie',
    Rule(r'\b(mon|smil)ies$'): r'$0ey',
    Rule(r'(o)es$'): r'$0',
    Rule(r'(shoe)s$'): r'$0',
    Rule(r'\b((?:tit)?m|l)ice$'): r'$0ouse',
    Rule(r'(seraph|cherub)im$'): r'$0',
    Rule(r'(x|ch|ss|sh|zz|tto|go|cho|alias|bias|trellis|[^aou]us|t[lm]as|gas|(?:her|at|gr)o|[aeiou]ris)(?:es)?$'):
        r'$0',
    Rule(r'(analy|ba|diagno|parenthe|progno|synop|the|ellip|empha|neuro|oa|paraly|cri|ne)(?:sis|ses)$'): r'$0sis',
    Rule(r'([dti])a$'): r'$0um',
    Rule(r'(movie|twelve|abuse|e[mn]u)s$'): r'$0',
    Rule(r'(ax|test)(?:is|es)$'): r'$0is',
    Rule(r'(alumn|syllab|vir|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)(?:us|i)$'): r'$0us',
    Rule(r'(agend|addend|millenni|dat|extrem|bacteri|desiderat|strat|candelabr|errat|ov|symposi|curricul|quor)a$'):
        r'$0um',
    Rule(r'(apheli|hyperbat|periheli|asyndet|noumen|phenomen|criteri|organ|prolegomen|hedr|automat)a$'): r'$0on',
    Rule(r'(buz|blit|walt)zes$'): r'$0z',
    Rule(r'(alumn|alg|larv|vertebr)ae$'): r'$0a',
    Rule(r'(cod|mur|sil|vert|ind)ices$'): r'$0ex',
    Rule(r'(matr|append)ices$'): r'$0ix',
    Rule(r'(person|people)$'): r'person',
    Rule(r'(child)ren$'): r'$0',
    Rule(r'(eau)x?$'): r'$0',
    Rule(r'men$'): 'man',
  };

  static final Map<RegExp, String> _pluralRulesData = {
    Rule(r's?$'): 's',
    Rule('[^\u0000-\u007F]\$'): r'$0',
    Rule(r'([^aeiou]ese)$'): r'$0',
    Rule(r'(ax|test)is$'): r'$0es',
    Rule(r'(alias|bias|[^aou]us|t[lm]as|gas|ris|trellis|virus)$'): r'$0es',
    Rule(r'(e[mn]u)s?$'): r'$0s',
    Rule(r'([^lb]ias|[aeiou]las|[ejzr]as|[iu]am)$'): r'$0',
    Rule(r'(alumn|syllab|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)(?:us|i)$'): r'$0i',
    Rule(r'(alumn|alg|larv|vertebr)(?:a|ae)$'): r'$0ae',
    Rule(r'(seraph|cherub)(?:im)?$'): r'$0im',
    Rule(r'(buffal|volcan|ech|embarg|mosquit|torped|vet|her|at|gr)o$'): r'$0oes',
    Rule(r'([dti]|extrem|candelabr|ov|curricul|quor)(?:a|um)$'): r'$0a',
    Rule(r'(apheli|hyperbat|periheli|asyndet|noumen|phenomen|criteri|organ|prolegomen|hedr|automat)(?:a|on)$'): r'$0a',
    Rule(r'sis$'): 'ses',
    Rule(r'((kni|wi|li)fe)$'): r'$0ves',
    Rule(r'(ar|l|ea|eo|oa|hoo)f$'): r'$0ves',
    Rule(r'([^aeiouy]|qu)y$'): r'$0ies',
    Rule(r'([^ch][ieo][ln])ey$'): r'$0ies',
    Rule(r'(x|ch|ss|sh|zz)$'): r'$0es',
    Rule(r'(buz|blit|walt)z$'): r'$0zes',
    Rule(r'(matr|cod|mur|sil|vert|ind|append)(?:ix|ex)$'): r'$0ices',
    Rule(r'\b((?:tit)?m|l)(?:ice|ouse)$'): r'$0ice',
    Rule(r'(p)erson$'): r'$0eople',
    Rule(r'(child)(?:ren)?$'): r'$0ren',
    Rule(r'eaux$'): r'$0',
    Rule(r'm[ae]n$'): 'men',
    Rule(r'^thou$'): 'you',
  };

  /// Irregular rules.
  /// Single -> Plural
  static const Map<String, String> _irregularRulesData = {
    // Pronouns.
    'i': 'we',
    'me': 'us',
    'he': 'they',
    'she': 'they',
    'them': 'them',
    'myself': 'ourselves',
    'yourself': 'yourselves',
    'itself': 'themselves',
    'herself': 'themselves',
    'himself': 'themselves',
    'themself': 'themselves',
    'is': 'are',
    'was': 'were',
    'has': 'have',
    'this': 'these',
    'that': 'those',
    // Words ending in with a consonant and `o`.
    'echo': 'echoes',
    'dingo': 'dingoes',
    'volcano': 'volcanoes',
    'tornado': 'tornadoes',
    'torpedo': 'torpedoes',
    // Ends with `us`.
    'genus': 'genera',
    'viscus': 'viscera',
    // Ends with `ma`.
    'stigma': 'stigmata',
    'stoma': 'stomata',
    'dogma': 'dogmata',
    'lemma': 'lemmata',
    'schema': 'schemata',
    'anathema': 'anathemata',
    // Other irregular rules.
    'ox': 'oxen',
    'database': 'databases',
    'die': 'dice',
    'yes': 'yeses',
    'foot': 'feet',
    'fuse': 'fuses',
    'eave': 'eaves',
    'goose': 'geese',
    'tooth': 'teeth',
    'quiz': 'quizzes',
    'human': 'humans',
    'proof': 'proofs',
    'cache': 'caches',
    'carve': 'carves',
    'valve': 'valves',
    'looey': 'looies',
    'thief': 'thieves',
    'groove': 'grooves',
    'pickaxe': 'pickaxes',
    'passerby': 'passersby',
    'person': 'people',
  };

  // Uncountable rules
  static final List<String> _uncountableWords = [
    'adulthood',
    'advice',
    'agenda',
    'aid',
    'aircraft',
    'alcohol',
    'ammo',
    'analytics',
    'anime',
    'athletics',
    'audio',
    'bison',
    'blood',
    'bream',
    'butter',
    'carp',
    'cash',
    'chassis',
    'chess',
    'clothing',
    'cod',
    'commerce',
    'cooperation',
    'corn',
    'corps',
    'debris',
    'diabetes',
    'digestion',
    'elk',
    'energy',
    'equipment',
    'excretion',
    'expertise',
    'firmware',
    'flounder',
    'fun',
    'gallows',
    'garbage',
    'graffiti',
    'grass',
    'hair',
    'hardware',
    'headquarters',
    'health',
    'herpes',
    'highjinks',
    'homework',
    'housework',
    'information',
    'jeans',
    'justice',
    'kudos',
    'labour',
    'literature',
    'luggage',
    'machinery',
    'mackerel',
    'mail',
    'means',
    'mews',
    'milk',
    'moose',
    'music',
    'mud',
    'manga',
    'news',
    'offspring',
    'only',
    'personnel',
    'pike',
    'plankton',
    'pliers',
    'police',
    'pollution',
    'premises',
    'rain',
    'research',
    'rice',
    'salmon',
    'scissors',
    'semen',
    'series',
    'sewage',
    'shambles',
    'shrimp',
    'software',
    'someone',
    'species',
    'sperm',
    'staff',
    'swine',
    'tennis',
    'training',
    'traffic',
    'transportation',
    'trout',
    'tuna',
    'water',
    'waters',
    'wealth',
    'welfare',
    'which',
    'whiting',
    'who',
    'wildebeest',
    'wildlife',
    'you',
  ];

  static final List<RegExp> _uncountableRules = [
    Rule(r'pok[eé]mon$'),
    Rule(r'[^aeiou]ese$'),
    Rule(r'deer$'),
    Rule(r'fish$'),
    Rule(r'measles$'),
    Rule(r'o[iu]s$'),
    Rule(r'pox$'),
    Rule(r'sheep$'),
  ];
}

extension type const Rule._(RegExp exp) implements RegExp {
  Rule(String rule) : this._(RegExp(rule, caseSensitive: false));
}
