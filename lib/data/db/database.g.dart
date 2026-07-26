// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlotsTable extends Plots with TableInfo<$PlotsTable, Plot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortIntroMeta = const VerificationMeta(
    'shortIntro',
  );
  @override
  late final GeneratedColumn<String> shortIntro = GeneratedColumn<String>(
    'short_intro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashtagsMeta = const VerificationMeta(
    'hashtags',
  );
  @override
  late final GeneratedColumn<String> hashtags = GeneratedColumn<String>(
    'hashtags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlotVisibility, int> visibility =
      GeneratedColumn<int>(
        'visibility',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<PlotVisibility>($PlotsTable.$convertervisibility);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    coverImagePath,
    shortIntro,
    hashtags,
    visibility,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('short_intro')) {
      context.handle(
        _shortIntroMeta,
        shortIntro.isAcceptableOrUnknown(data['short_intro']!, _shortIntroMeta),
      );
    }
    if (data.containsKey('hashtags')) {
      context.handle(
        _hashtagsMeta,
        hashtags.isAcceptableOrUnknown(data['hashtags']!, _hashtagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
      shortIntro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_intro'],
      ),
      hashtags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hashtags'],
      )!,
      visibility: $PlotsTable.$convertervisibility.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}visibility'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlotsTable createAlias(String alias) {
    return $PlotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlotVisibility, int, int> $convertervisibility =
      const EnumIndexConverter<PlotVisibility>(PlotVisibility.values);
}

class Plot extends DataClass implements Insertable<Plot> {
  final int id;
  final String title;
  final String description;
  final String? coverImagePath;
  final String? shortIntro;
  final String hashtags;
  final PlotVisibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Plot({
    required this.id,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.shortIntro,
    required this.hashtags,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    if (!nullToAbsent || shortIntro != null) {
      map['short_intro'] = Variable<String>(shortIntro);
    }
    map['hashtags'] = Variable<String>(hashtags);
    {
      map['visibility'] = Variable<int>(
        $PlotsTable.$convertervisibility.toSql(visibility),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlotsCompanion toCompanion(bool nullToAbsent) {
    return PlotsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      shortIntro: shortIntro == null && nullToAbsent
          ? const Value.absent()
          : Value(shortIntro),
      hashtags: Value(hashtags),
      visibility: Value(visibility),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Plot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plot(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      shortIntro: serializer.fromJson<String?>(json['shortIntro']),
      hashtags: serializer.fromJson<String>(json['hashtags']),
      visibility: $PlotsTable.$convertervisibility.fromJson(
        serializer.fromJson<int>(json['visibility']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'shortIntro': serializer.toJson<String?>(shortIntro),
      'hashtags': serializer.toJson<String>(hashtags),
      'visibility': serializer.toJson<int>(
        $PlotsTable.$convertervisibility.toJson(visibility),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Plot copyWith({
    int? id,
    String? title,
    String? description,
    Value<String?> coverImagePath = const Value.absent(),
    Value<String?> shortIntro = const Value.absent(),
    String? hashtags,
    PlotVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Plot(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
    shortIntro: shortIntro.present ? shortIntro.value : this.shortIntro,
    hashtags: hashtags ?? this.hashtags,
    visibility: visibility ?? this.visibility,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Plot copyWithCompanion(PlotsCompanion data) {
    return Plot(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      shortIntro: data.shortIntro.present
          ? data.shortIntro.value
          : this.shortIntro,
      hashtags: data.hashtags.present ? data.hashtags.value : this.hashtags,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plot(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('shortIntro: $shortIntro, ')
          ..write('hashtags: $hashtags, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    coverImagePath,
    shortIntro,
    hashtags,
    visibility,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plot &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.coverImagePath == this.coverImagePath &&
          other.shortIntro == this.shortIntro &&
          other.hashtags == this.hashtags &&
          other.visibility == this.visibility &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlotsCompanion extends UpdateCompanion<Plot> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> coverImagePath;
  final Value<String?> shortIntro;
  final Value<String> hashtags;
  final Value<PlotVisibility> visibility;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlotsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.shortIntro = const Value.absent(),
    this.hashtags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlotsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String description,
    this.coverImagePath = const Value.absent(),
    this.shortIntro = const Value.absent(),
    this.hashtags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       description = Value(description);
  static Insertable<Plot> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverImagePath,
    Expression<String>? shortIntro,
    Expression<String>? hashtags,
    Expression<int>? visibility,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (shortIntro != null) 'short_intro': shortIntro,
      if (hashtags != null) 'hashtags': hashtags,
      if (visibility != null) 'visibility': visibility,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlotsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? coverImagePath,
    Value<String?>? shortIntro,
    Value<String>? hashtags,
    Value<PlotVisibility>? visibility,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PlotsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      shortIntro: shortIntro ?? this.shortIntro,
      hashtags: hashtags ?? this.hashtags,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (shortIntro.present) {
      map['short_intro'] = Variable<String>(shortIntro.value);
    }
    if (hashtags.present) {
      map['hashtags'] = Variable<String>(hashtags.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<int>(
        $PlotsTable.$convertervisibility.toSql(visibility.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlotsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('shortIntro: $shortIntro, ')
          ..write('hashtags: $hashtags, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, Character> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<int> plotId = GeneratedColumn<int>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRepresentativeMeta = const VerificationMeta(
    'isRepresentative',
  );
  @override
  late final GeneratedColumn<bool> isRepresentative = GeneratedColumn<bool>(
    'is_representative',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_representative" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aboutTextMeta = const VerificationMeta(
    'aboutText',
  );
  @override
  late final GeneratedColumn<String> aboutText = GeneratedColumn<String>(
    'about_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plotId,
    name,
    description,
    imagePath,
    isRepresentative,
    sortOrder,
    aboutText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Character> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_representative')) {
      context.handle(
        _isRepresentativeMeta,
        isRepresentative.isAcceptableOrUnknown(
          data['is_representative']!,
          _isRepresentativeMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('about_text')) {
      context.handle(
        _aboutTextMeta,
        aboutText.isAcceptableOrUnknown(data['about_text']!, _aboutTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Character map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Character(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plot_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      isRepresentative: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_representative'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      aboutText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}about_text'],
      )!,
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class Character extends DataClass implements Insertable<Character> {
  final int id;
  final int plotId;
  final String name;
  final String description;
  final String? imagePath;
  final bool isRepresentative;
  final int sortOrder;

  /// 플롯 편집 > 소개 탭에서 캐릭터별로 작성하는 상세 페이지용 소개 마크다운.
  /// AI에게는 전달되지 않고 상세 페이지 표시 전용이다(AI용 페르소나는 [description]).
  final String aboutText;
  const Character({
    required this.id,
    required this.plotId,
    required this.name,
    required this.description,
    this.imagePath,
    required this.isRepresentative,
    required this.sortOrder,
    required this.aboutText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plot_id'] = Variable<int>(plotId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_representative'] = Variable<bool>(isRepresentative);
    map['sort_order'] = Variable<int>(sortOrder);
    map['about_text'] = Variable<String>(aboutText);
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      plotId: Value(plotId),
      name: Value(name),
      description: Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isRepresentative: Value(isRepresentative),
      sortOrder: Value(sortOrder),
      aboutText: Value(aboutText),
    );
  }

  factory Character.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Character(
      id: serializer.fromJson<int>(json['id']),
      plotId: serializer.fromJson<int>(json['plotId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isRepresentative: serializer.fromJson<bool>(json['isRepresentative']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      aboutText: serializer.fromJson<String>(json['aboutText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plotId': serializer.toJson<int>(plotId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isRepresentative': serializer.toJson<bool>(isRepresentative),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'aboutText': serializer.toJson<String>(aboutText),
    };
  }

  Character copyWith({
    int? id,
    int? plotId,
    String? name,
    String? description,
    Value<String?> imagePath = const Value.absent(),
    bool? isRepresentative,
    int? sortOrder,
    String? aboutText,
  }) => Character(
    id: id ?? this.id,
    plotId: plotId ?? this.plotId,
    name: name ?? this.name,
    description: description ?? this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    isRepresentative: isRepresentative ?? this.isRepresentative,
    sortOrder: sortOrder ?? this.sortOrder,
    aboutText: aboutText ?? this.aboutText,
  );
  Character copyWithCompanion(CharactersCompanion data) {
    return Character(
      id: data.id.present ? data.id.value : this.id,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isRepresentative: data.isRepresentative.present
          ? data.isRepresentative.value
          : this.isRepresentative,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      aboutText: data.aboutText.present ? data.aboutText.value : this.aboutText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Character(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isRepresentative: $isRepresentative, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('aboutText: $aboutText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plotId,
    name,
    description,
    imagePath,
    isRepresentative,
    sortOrder,
    aboutText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Character &&
          other.id == this.id &&
          other.plotId == this.plotId &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.isRepresentative == this.isRepresentative &&
          other.sortOrder == this.sortOrder &&
          other.aboutText == this.aboutText);
}

class CharactersCompanion extends UpdateCompanion<Character> {
  final Value<int> id;
  final Value<int> plotId;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> imagePath;
  final Value<bool> isRepresentative;
  final Value<int> sortOrder;
  final Value<String> aboutText;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.plotId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isRepresentative = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.aboutText = const Value.absent(),
  });
  CharactersCompanion.insert({
    this.id = const Value.absent(),
    required int plotId,
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isRepresentative = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.aboutText = const Value.absent(),
  }) : plotId = Value(plotId),
       name = Value(name);
  static Insertable<Character> custom({
    Expression<int>? id,
    Expression<int>? plotId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<bool>? isRepresentative,
    Expression<int>? sortOrder,
    Expression<String>? aboutText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plotId != null) 'plot_id': plotId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (isRepresentative != null) 'is_representative': isRepresentative,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (aboutText != null) 'about_text': aboutText,
    });
  }

  CharactersCompanion copyWith({
    Value<int>? id,
    Value<int>? plotId,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? imagePath,
    Value<bool>? isRepresentative,
    Value<int>? sortOrder,
    Value<String>? aboutText,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isRepresentative: isRepresentative ?? this.isRepresentative,
      sortOrder: sortOrder ?? this.sortOrder,
      aboutText: aboutText ?? this.aboutText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<int>(plotId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isRepresentative.present) {
      map['is_representative'] = Variable<bool>(isRepresentative.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (aboutText.present) {
      map['about_text'] = Variable<String>(aboutText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isRepresentative: $isRepresentative, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('aboutText: $aboutText')
          ..write(')'))
        .toString();
  }
}

class $IntroVersionsTable extends IntroVersions
    with TableInfo<$IntroVersionsTable, IntroVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntroVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<int> plotId = GeneratedColumn<int>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, plotId, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intro_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntroVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntroVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntroVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plot_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IntroVersionsTable createAlias(String alias) {
    return $IntroVersionsTable(attachedDatabase, alias);
  }
}

class IntroVersion extends DataClass implements Insertable<IntroVersion> {
  final int id;
  final int plotId;
  final int sortOrder;
  final DateTime createdAt;
  const IntroVersion({
    required this.id,
    required this.plotId,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plot_id'] = Variable<int>(plotId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IntroVersionsCompanion toCompanion(bool nullToAbsent) {
    return IntroVersionsCompanion(
      id: Value(id),
      plotId: Value(plotId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory IntroVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntroVersion(
      id: serializer.fromJson<int>(json['id']),
      plotId: serializer.fromJson<int>(json['plotId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plotId': serializer.toJson<int>(plotId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IntroVersion copyWith({
    int? id,
    int? plotId,
    int? sortOrder,
    DateTime? createdAt,
  }) => IntroVersion(
    id: id ?? this.id,
    plotId: plotId ?? this.plotId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  IntroVersion copyWithCompanion(IntroVersionsCompanion data) {
    return IntroVersion(
      id: data.id.present ? data.id.value : this.id,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntroVersion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plotId, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntroVersion &&
          other.id == this.id &&
          other.plotId == this.plotId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class IntroVersionsCompanion extends UpdateCompanion<IntroVersion> {
  final Value<int> id;
  final Value<int> plotId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const IntroVersionsCompanion({
    this.id = const Value.absent(),
    this.plotId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IntroVersionsCompanion.insert({
    this.id = const Value.absent(),
    required int plotId,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : plotId = Value(plotId);
  static Insertable<IntroVersion> custom({
    Expression<int>? id,
    Expression<int>? plotId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plotId != null) 'plot_id': plotId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IntroVersionsCompanion copyWith({
    Value<int>? id,
    Value<int>? plotId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return IntroVersionsCompanion(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<int>(plotId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntroVersionsCompanion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $IntroEntriesTable extends IntroEntries
    with TableInfo<$IntroEntriesTable, IntroEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntroEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<int> plotId = GeneratedColumn<int>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _introVersionIdMeta = const VerificationMeta(
    'introVersionId',
  );
  @override
  late final GeneratedColumn<int> introVersionId = GeneratedColumn<int>(
    'intro_version_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intro_versions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IntroEntryType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<IntroEntryType>($IntroEntriesTable.$convertertype);
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plotId,
    introVersionId,
    characterId,
    type,
    content,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intro_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntroEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('intro_version_id')) {
      context.handle(
        _introVersionIdMeta,
        introVersionId.isAcceptableOrUnknown(
          data['intro_version_id']!,
          _introVersionIdMeta,
        ),
      );
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntroEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntroEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plot_id'],
      )!,
      introVersionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intro_version_id'],
      ),
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      ),
      type: $IntroEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $IntroEntriesTable createAlias(String alias) {
    return $IntroEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IntroEntryType, int, int> $convertertype =
      const EnumIndexConverter<IntroEntryType>(IntroEntryType.values);
}

class IntroEntry extends DataClass implements Insertable<IntroEntry> {
  final int id;
  final int plotId;
  final int? introVersionId;
  final int? characterId;
  final IntroEntryType type;
  final String content;
  final int sortOrder;
  const IntroEntry({
    required this.id,
    required this.plotId,
    this.introVersionId,
    this.characterId,
    required this.type,
    required this.content,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plot_id'] = Variable<int>(plotId);
    if (!nullToAbsent || introVersionId != null) {
      map['intro_version_id'] = Variable<int>(introVersionId);
    }
    if (!nullToAbsent || characterId != null) {
      map['character_id'] = Variable<int>(characterId);
    }
    {
      map['type'] = Variable<int>(
        $IntroEntriesTable.$convertertype.toSql(type),
      );
    }
    map['content'] = Variable<String>(content);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  IntroEntriesCompanion toCompanion(bool nullToAbsent) {
    return IntroEntriesCompanion(
      id: Value(id),
      plotId: Value(plotId),
      introVersionId: introVersionId == null && nullToAbsent
          ? const Value.absent()
          : Value(introVersionId),
      characterId: characterId == null && nullToAbsent
          ? const Value.absent()
          : Value(characterId),
      type: Value(type),
      content: Value(content),
      sortOrder: Value(sortOrder),
    );
  }

  factory IntroEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntroEntry(
      id: serializer.fromJson<int>(json['id']),
      plotId: serializer.fromJson<int>(json['plotId']),
      introVersionId: serializer.fromJson<int?>(json['introVersionId']),
      characterId: serializer.fromJson<int?>(json['characterId']),
      type: $IntroEntriesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      content: serializer.fromJson<String>(json['content']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plotId': serializer.toJson<int>(plotId),
      'introVersionId': serializer.toJson<int?>(introVersionId),
      'characterId': serializer.toJson<int?>(characterId),
      'type': serializer.toJson<int>(
        $IntroEntriesTable.$convertertype.toJson(type),
      ),
      'content': serializer.toJson<String>(content),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  IntroEntry copyWith({
    int? id,
    int? plotId,
    Value<int?> introVersionId = const Value.absent(),
    Value<int?> characterId = const Value.absent(),
    IntroEntryType? type,
    String? content,
    int? sortOrder,
  }) => IntroEntry(
    id: id ?? this.id,
    plotId: plotId ?? this.plotId,
    introVersionId: introVersionId.present
        ? introVersionId.value
        : this.introVersionId,
    characterId: characterId.present ? characterId.value : this.characterId,
    type: type ?? this.type,
    content: content ?? this.content,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  IntroEntry copyWithCompanion(IntroEntriesCompanion data) {
    return IntroEntry(
      id: data.id.present ? data.id.value : this.id,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      introVersionId: data.introVersionId.present
          ? data.introVersionId.value
          : this.introVersionId,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntroEntry(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('introVersionId: $introVersionId, ')
          ..write('characterId: $characterId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plotId,
    introVersionId,
    characterId,
    type,
    content,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntroEntry &&
          other.id == this.id &&
          other.plotId == this.plotId &&
          other.introVersionId == this.introVersionId &&
          other.characterId == this.characterId &&
          other.type == this.type &&
          other.content == this.content &&
          other.sortOrder == this.sortOrder);
}

class IntroEntriesCompanion extends UpdateCompanion<IntroEntry> {
  final Value<int> id;
  final Value<int> plotId;
  final Value<int?> introVersionId;
  final Value<int?> characterId;
  final Value<IntroEntryType> type;
  final Value<String> content;
  final Value<int> sortOrder;
  const IntroEntriesCompanion({
    this.id = const Value.absent(),
    this.plotId = const Value.absent(),
    this.introVersionId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  IntroEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int plotId,
    this.introVersionId = const Value.absent(),
    this.characterId = const Value.absent(),
    required IntroEntryType type,
    required String content,
    this.sortOrder = const Value.absent(),
  }) : plotId = Value(plotId),
       type = Value(type),
       content = Value(content);
  static Insertable<IntroEntry> custom({
    Expression<int>? id,
    Expression<int>? plotId,
    Expression<int>? introVersionId,
    Expression<int>? characterId,
    Expression<int>? type,
    Expression<String>? content,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plotId != null) 'plot_id': plotId,
      if (introVersionId != null) 'intro_version_id': introVersionId,
      if (characterId != null) 'character_id': characterId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  IntroEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? plotId,
    Value<int?>? introVersionId,
    Value<int?>? characterId,
    Value<IntroEntryType>? type,
    Value<String>? content,
    Value<int>? sortOrder,
  }) {
    return IntroEntriesCompanion(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      introVersionId: introVersionId ?? this.introVersionId,
      characterId: characterId ?? this.characterId,
      type: type ?? this.type,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<int>(plotId.value);
    }
    if (introVersionId.present) {
      map['intro_version_id'] = Variable<int>(introVersionId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $IntroEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntroEntriesCompanion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('introVersionId: $introVersionId, ')
          ..write('characterId: $characterId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ConversationProfilesTable extends ConversationProfiles
    with TableInfo<$ConversationProfilesTable, ConversationProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    imagePath,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $ConversationProfilesTable createAlias(String alias) {
    return $ConversationProfilesTable(attachedDatabase, alias);
  }
}

class ConversationProfile extends DataClass
    implements Insertable<ConversationProfile> {
  final int id;
  final String name;
  final String description;
  final String? imagePath;
  final bool isDefault;
  const ConversationProfile({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  ConversationProfilesCompanion toCompanion(bool nullToAbsent) {
    return ConversationProfilesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isDefault: Value(isDefault),
    );
  }

  factory ConversationProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  ConversationProfile copyWith({
    int? id,
    String? name,
    String? description,
    Value<String?> imagePath = const Value.absent(),
    bool? isDefault,
  }) => ConversationProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    isDefault: isDefault ?? this.isDefault,
  );
  ConversationProfile copyWithCompanion(ConversationProfilesCompanion data) {
    return ConversationProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, imagePath, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.isDefault == this.isDefault);
}

class ConversationProfilesCompanion
    extends UpdateCompanion<ConversationProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> imagePath;
  final Value<bool> isDefault;
  const ConversationProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  ConversationProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isDefault = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ConversationProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  ConversationProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? imagePath,
    Value<bool>? isDefault,
  }) {
    return ConversationProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

class $AiPresetsTable extends AiPresets
    with TableInfo<$AiPresetsTable, AiPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiKeyRefMeta = const VerificationMeta(
    'apiKeyRef',
  );
  @override
  late final GeneratedColumn<String> apiKeyRef = GeneratedColumn<String>(
    'api_key_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _topKMeta = const VerificationMeta('topK');
  @override
  late final GeneratedColumn<int> topK = GeneratedColumn<int>(
    'top_k',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxTokensMeta = const VerificationMeta(
    'maxTokens',
  );
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
    'max_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextLengthMeta = const VerificationMeta(
    'contextLength',
  );
  @override
  late final GeneratedColumn<int> contextLength = GeneratedColumn<int>(
    'context_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionalSystemPromptMeta =
      const VerificationMeta('additionalSystemPrompt');
  @override
  late final GeneratedColumn<String> additionalSystemPrompt =
      GeneratedColumn<String>(
        'additional_system_prompt',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    baseUrl,
    modelName,
    apiKeyRef,
    temperature,
    isDefault,
    createdAt,
    updatedAt,
    topK,
    maxTokens,
    contextLength,
    additionalSystemPrompt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('api_key_ref')) {
      context.handle(
        _apiKeyRefMeta,
        apiKeyRef.isAcceptableOrUnknown(data['api_key_ref']!, _apiKeyRefMeta),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('top_k')) {
      context.handle(
        _topKMeta,
        topK.isAcceptableOrUnknown(data['top_k']!, _topKMeta),
      );
    }
    if (data.containsKey('max_tokens')) {
      context.handle(
        _maxTokensMeta,
        maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta),
      );
    }
    if (data.containsKey('context_length')) {
      context.handle(
        _contextLengthMeta,
        contextLength.isAcceptableOrUnknown(
          data['context_length']!,
          _contextLengthMeta,
        ),
      );
    }
    if (data.containsKey('additional_system_prompt')) {
      context.handle(
        _additionalSystemPromptMeta,
        additionalSystemPrompt.isAcceptableOrUnknown(
          data['additional_system_prompt']!,
          _additionalSystemPromptMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      apiKeyRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key_ref'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      topK: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}top_k'],
      ),
      maxTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_tokens'],
      ),
      contextLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}context_length'],
      ),
      additionalSystemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_system_prompt'],
      )!,
    );
  }

  @override
  $AiPresetsTable createAlias(String alias) {
    return $AiPresetsTable(attachedDatabase, alias);
  }
}

class AiPreset extends DataClass implements Insertable<AiPreset> {
  final int id;
  final String name;
  final String description;
  final String baseUrl;
  final String modelName;
  final String? apiKeyRef;
  final double temperature;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 아래 4개는 전부 선택 사항이다(null/빈 문자열이면 요청에 포함하지 않거나 기본 동작).
  final int? topK;
  final int? maxTokens;

  /// 매 요청마다 히스토리에 포함할 최근 메시지 개수 상한. null이면 전체를 보낸다.
  final int? contextLength;

  /// 시스템 프롬프트 뒤에 그대로 덧붙이는 사용자 정의 지침. 기본값은 빈 문자열.
  final String additionalSystemPrompt;
  const AiPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.baseUrl,
    required this.modelName,
    this.apiKeyRef,
    required this.temperature,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.topK,
    this.maxTokens,
    this.contextLength,
    required this.additionalSystemPrompt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['base_url'] = Variable<String>(baseUrl);
    map['model_name'] = Variable<String>(modelName);
    if (!nullToAbsent || apiKeyRef != null) {
      map['api_key_ref'] = Variable<String>(apiKeyRef);
    }
    map['temperature'] = Variable<double>(temperature);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || topK != null) {
      map['top_k'] = Variable<int>(topK);
    }
    if (!nullToAbsent || maxTokens != null) {
      map['max_tokens'] = Variable<int>(maxTokens);
    }
    if (!nullToAbsent || contextLength != null) {
      map['context_length'] = Variable<int>(contextLength);
    }
    map['additional_system_prompt'] = Variable<String>(additionalSystemPrompt);
    return map;
  }

  AiPresetsCompanion toCompanion(bool nullToAbsent) {
    return AiPresetsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      baseUrl: Value(baseUrl),
      modelName: Value(modelName),
      apiKeyRef: apiKeyRef == null && nullToAbsent
          ? const Value.absent()
          : Value(apiKeyRef),
      temperature: Value(temperature),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      topK: topK == null && nullToAbsent ? const Value.absent() : Value(topK),
      maxTokens: maxTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(maxTokens),
      contextLength: contextLength == null && nullToAbsent
          ? const Value.absent()
          : Value(contextLength),
      additionalSystemPrompt: Value(additionalSystemPrompt),
    );
  }

  factory AiPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      modelName: serializer.fromJson<String>(json['modelName']),
      apiKeyRef: serializer.fromJson<String?>(json['apiKeyRef']),
      temperature: serializer.fromJson<double>(json['temperature']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      topK: serializer.fromJson<int?>(json['topK']),
      maxTokens: serializer.fromJson<int?>(json['maxTokens']),
      contextLength: serializer.fromJson<int?>(json['contextLength']),
      additionalSystemPrompt: serializer.fromJson<String>(
        json['additionalSystemPrompt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'modelName': serializer.toJson<String>(modelName),
      'apiKeyRef': serializer.toJson<String?>(apiKeyRef),
      'temperature': serializer.toJson<double>(temperature),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'topK': serializer.toJson<int?>(topK),
      'maxTokens': serializer.toJson<int?>(maxTokens),
      'contextLength': serializer.toJson<int?>(contextLength),
      'additionalSystemPrompt': serializer.toJson<String>(
        additionalSystemPrompt,
      ),
    };
  }

  AiPreset copyWith({
    int? id,
    String? name,
    String? description,
    String? baseUrl,
    String? modelName,
    Value<String?> apiKeyRef = const Value.absent(),
    double? temperature,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> topK = const Value.absent(),
    Value<int?> maxTokens = const Value.absent(),
    Value<int?> contextLength = const Value.absent(),
    String? additionalSystemPrompt,
  }) => AiPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    baseUrl: baseUrl ?? this.baseUrl,
    modelName: modelName ?? this.modelName,
    apiKeyRef: apiKeyRef.present ? apiKeyRef.value : this.apiKeyRef,
    temperature: temperature ?? this.temperature,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    topK: topK.present ? topK.value : this.topK,
    maxTokens: maxTokens.present ? maxTokens.value : this.maxTokens,
    contextLength: contextLength.present
        ? contextLength.value
        : this.contextLength,
    additionalSystemPrompt:
        additionalSystemPrompt ?? this.additionalSystemPrompt,
  );
  AiPreset copyWithCompanion(AiPresetsCompanion data) {
    return AiPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      apiKeyRef: data.apiKeyRef.present ? data.apiKeyRef.value : this.apiKeyRef,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      topK: data.topK.present ? data.topK.value : this.topK,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      contextLength: data.contextLength.present
          ? data.contextLength.value
          : this.contextLength,
      additionalSystemPrompt: data.additionalSystemPrompt.present
          ? data.additionalSystemPrompt.value
          : this.additionalSystemPrompt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelName: $modelName, ')
          ..write('apiKeyRef: $apiKeyRef, ')
          ..write('temperature: $temperature, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('topK: $topK, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextLength: $contextLength, ')
          ..write('additionalSystemPrompt: $additionalSystemPrompt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    baseUrl,
    modelName,
    apiKeyRef,
    temperature,
    isDefault,
    createdAt,
    updatedAt,
    topK,
    maxTokens,
    contextLength,
    additionalSystemPrompt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.baseUrl == this.baseUrl &&
          other.modelName == this.modelName &&
          other.apiKeyRef == this.apiKeyRef &&
          other.temperature == this.temperature &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.topK == this.topK &&
          other.maxTokens == this.maxTokens &&
          other.contextLength == this.contextLength &&
          other.additionalSystemPrompt == this.additionalSystemPrompt);
}

class AiPresetsCompanion extends UpdateCompanion<AiPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> baseUrl;
  final Value<String> modelName;
  final Value<String?> apiKeyRef;
  final Value<double> temperature;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> topK;
  final Value<int?> maxTokens;
  final Value<int?> contextLength;
  final Value<String> additionalSystemPrompt;
  const AiPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.modelName = const Value.absent(),
    this.apiKeyRef = const Value.absent(),
    this.temperature = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.topK = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextLength = const Value.absent(),
    this.additionalSystemPrompt = const Value.absent(),
  });
  AiPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required String baseUrl,
    required String modelName,
    this.apiKeyRef = const Value.absent(),
    this.temperature = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.topK = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextLength = const Value.absent(),
    this.additionalSystemPrompt = const Value.absent(),
  }) : name = Value(name),
       baseUrl = Value(baseUrl),
       modelName = Value(modelName);
  static Insertable<AiPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? baseUrl,
    Expression<String>? modelName,
    Expression<String>? apiKeyRef,
    Expression<double>? temperature,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? topK,
    Expression<int>? maxTokens,
    Expression<int>? contextLength,
    Expression<String>? additionalSystemPrompt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (baseUrl != null) 'base_url': baseUrl,
      if (modelName != null) 'model_name': modelName,
      if (apiKeyRef != null) 'api_key_ref': apiKeyRef,
      if (temperature != null) 'temperature': temperature,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (topK != null) 'top_k': topK,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (contextLength != null) 'context_length': contextLength,
      if (additionalSystemPrompt != null)
        'additional_system_prompt': additionalSystemPrompt,
    });
  }

  AiPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? baseUrl,
    Value<String>? modelName,
    Value<String?>? apiKeyRef,
    Value<double>? temperature,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? topK,
    Value<int?>? maxTokens,
    Value<int?>? contextLength,
    Value<String>? additionalSystemPrompt,
  }) {
    return AiPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      apiKeyRef: apiKeyRef ?? this.apiKeyRef,
      temperature: temperature ?? this.temperature,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      topK: topK ?? this.topK,
      maxTokens: maxTokens ?? this.maxTokens,
      contextLength: contextLength ?? this.contextLength,
      additionalSystemPrompt:
          additionalSystemPrompt ?? this.additionalSystemPrompt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (apiKeyRef.present) {
      map['api_key_ref'] = Variable<String>(apiKeyRef.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (topK.present) {
      map['top_k'] = Variable<int>(topK.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (contextLength.present) {
      map['context_length'] = Variable<int>(contextLength.value);
    }
    if (additionalSystemPrompt.present) {
      map['additional_system_prompt'] = Variable<String>(
        additionalSystemPrompt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelName: $modelName, ')
          ..write('apiKeyRef: $apiKeyRef, ')
          ..write('temperature: $temperature, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('topK: $topK, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextLength: $contextLength, ')
          ..write('additionalSystemPrompt: $additionalSystemPrompt')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<int> plotId = GeneratedColumn<int>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _conversationProfileIdMeta =
      const VerificationMeta('conversationProfileId');
  @override
  late final GeneratedColumn<int> conversationProfileId = GeneratedColumn<int>(
    'conversation_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversation_profiles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<int> presetId = GeneratedColumn<int>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_presets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plotId,
    conversationProfileId,
    presetId,
    pinned,
    locked,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('conversation_profile_id')) {
      context.handle(
        _conversationProfileIdMeta,
        conversationProfileId.isAcceptableOrUnknown(
          data['conversation_profile_id']!,
          _conversationProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plot_id'],
      )!,
      conversationProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_profile_id'],
      ),
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preset_id'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final int id;
  final int plotId;
  final int? conversationProfileId;
  final int? presetId;
  final bool pinned;
  final bool locked;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// null이면 현재 진행 중인 활성 대화. 값이 있으면 '새로하기'로 저장되어 '이어하기'
  /// 목록에만 노출되는 보관된 대화이며, 값은 저장된 시각이다.
  final DateTime? archivedAt;
  const ChatSession({
    required this.id,
    required this.plotId,
    this.conversationProfileId,
    this.presetId,
    required this.pinned,
    required this.locked,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plot_id'] = Variable<int>(plotId);
    if (!nullToAbsent || conversationProfileId != null) {
      map['conversation_profile_id'] = Variable<int>(conversationProfileId);
    }
    if (!nullToAbsent || presetId != null) {
      map['preset_id'] = Variable<int>(presetId);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['locked'] = Variable<bool>(locked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      plotId: Value(plotId),
      conversationProfileId: conversationProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationProfileId),
      presetId: presetId == null && nullToAbsent
          ? const Value.absent()
          : Value(presetId),
      pinned: Value(pinned),
      locked: Value(locked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<int>(json['id']),
      plotId: serializer.fromJson<int>(json['plotId']),
      conversationProfileId: serializer.fromJson<int?>(
        json['conversationProfileId'],
      ),
      presetId: serializer.fromJson<int?>(json['presetId']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      locked: serializer.fromJson<bool>(json['locked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plotId': serializer.toJson<int>(plotId),
      'conversationProfileId': serializer.toJson<int?>(conversationProfileId),
      'presetId': serializer.toJson<int?>(presetId),
      'pinned': serializer.toJson<bool>(pinned),
      'locked': serializer.toJson<bool>(locked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ChatSession copyWith({
    int? id,
    int? plotId,
    Value<int?> conversationProfileId = const Value.absent(),
    Value<int?> presetId = const Value.absent(),
    bool? pinned,
    bool? locked,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ChatSession(
    id: id ?? this.id,
    plotId: plotId ?? this.plotId,
    conversationProfileId: conversationProfileId.present
        ? conversationProfileId.value
        : this.conversationProfileId,
    presetId: presetId.present ? presetId.value : this.presetId,
    pinned: pinned ?? this.pinned,
    locked: locked ?? this.locked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      conversationProfileId: data.conversationProfileId.present
          ? data.conversationProfileId.value
          : this.conversationProfileId,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      locked: data.locked.present ? data.locked.value : this.locked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('conversationProfileId: $conversationProfileId, ')
          ..write('presetId: $presetId, ')
          ..write('pinned: $pinned, ')
          ..write('locked: $locked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plotId,
    conversationProfileId,
    presetId,
    pinned,
    locked,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.plotId == this.plotId &&
          other.conversationProfileId == this.conversationProfileId &&
          other.presetId == this.presetId &&
          other.pinned == this.pinned &&
          other.locked == this.locked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<int> id;
  final Value<int> plotId;
  final Value<int?> conversationProfileId;
  final Value<int?> presetId;
  final Value<bool> pinned;
  final Value<bool> locked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.plotId = const Value.absent(),
    this.conversationProfileId = const Value.absent(),
    this.presetId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.locked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int plotId,
    this.conversationProfileId = const Value.absent(),
    this.presetId = const Value.absent(),
    this.pinned = const Value.absent(),
    this.locked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : plotId = Value(plotId);
  static Insertable<ChatSession> custom({
    Expression<int>? id,
    Expression<int>? plotId,
    Expression<int>? conversationProfileId,
    Expression<int>? presetId,
    Expression<bool>? pinned,
    Expression<bool>? locked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plotId != null) 'plot_id': plotId,
      if (conversationProfileId != null)
        'conversation_profile_id': conversationProfileId,
      if (presetId != null) 'preset_id': presetId,
      if (pinned != null) 'pinned': pinned,
      if (locked != null) 'locked': locked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? plotId,
    Value<int?>? conversationProfileId,
    Value<int?>? presetId,
    Value<bool>? pinned,
    Value<bool>? locked,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      conversationProfileId:
          conversationProfileId ?? this.conversationProfileId,
      presetId: presetId ?? this.presetId,
      pinned: pinned ?? this.pinned,
      locked: locked ?? this.locked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<int>(plotId.value);
    }
    if (conversationProfileId.present) {
      map['conversation_profile_id'] = Variable<int>(
        conversationProfileId.value,
      );
    }
    if (presetId.present) {
      map['preset_id'] = Variable<int>(presetId.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('conversationProfileId: $conversationProfileId, ')
          ..write('presetId: $presetId, ')
          ..write('pinned: $pinned, ')
          ..write('locked: $locked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatTurnsTable extends ChatTurns
    with TableInfo<$ChatTurnsTable, ChatTurn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatTurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activeVersionIndexMeta =
      const VerificationMeta('activeVersionIndex');
  @override
  late final GeneratedColumn<int> activeVersionIndex = GeneratedColumn<int>(
    'active_version_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    activeVersionIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatTurn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('active_version_index')) {
      context.handle(
        _activeVersionIndexMeta,
        activeVersionIndex.isAcceptableOrUnknown(
          data['active_version_index']!,
          _activeVersionIndexMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatTurn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatTurn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      activeVersionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_version_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatTurnsTable createAlias(String alias) {
    return $ChatTurnsTable(attachedDatabase, alias);
  }
}

class ChatTurn extends DataClass implements Insertable<ChatTurn> {
  final int id;
  final int sessionId;

  /// 지금 화면에 보여줄 버전 번호(0부터 시작). '<, >'로 넘길 때 이 값만 바뀐다.
  final int activeVersionIndex;
  final DateTime createdAt;
  const ChatTurn({
    required this.id,
    required this.sessionId,
    required this.activeVersionIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['active_version_index'] = Variable<int>(activeVersionIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatTurnsCompanion toCompanion(bool nullToAbsent) {
    return ChatTurnsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      activeVersionIndex: Value(activeVersionIndex),
      createdAt: Value(createdAt),
    );
  }

  factory ChatTurn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatTurn(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      activeVersionIndex: serializer.fromJson<int>(json['activeVersionIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'activeVersionIndex': serializer.toJson<int>(activeVersionIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatTurn copyWith({
    int? id,
    int? sessionId,
    int? activeVersionIndex,
    DateTime? createdAt,
  }) => ChatTurn(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    activeVersionIndex: activeVersionIndex ?? this.activeVersionIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatTurn copyWithCompanion(ChatTurnsCompanion data) {
    return ChatTurn(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      activeVersionIndex: data.activeVersionIndex.present
          ? data.activeVersionIndex.value
          : this.activeVersionIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatTurn(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('activeVersionIndex: $activeVersionIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, activeVersionIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatTurn &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.activeVersionIndex == this.activeVersionIndex &&
          other.createdAt == this.createdAt);
}

class ChatTurnsCompanion extends UpdateCompanion<ChatTurn> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> activeVersionIndex;
  final Value<DateTime> createdAt;
  const ChatTurnsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.activeVersionIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatTurnsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.activeVersionIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionId = Value(sessionId);
  static Insertable<ChatTurn> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? activeVersionIndex,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (activeVersionIndex != null)
        'active_version_index': activeVersionIndex,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatTurnsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? activeVersionIndex,
    Value<DateTime>? createdAt,
  }) {
    return ChatTurnsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      activeVersionIndex: activeVersionIndex ?? this.activeVersionIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (activeVersionIndex.present) {
      map['active_version_index'] = Variable<int>(activeVersionIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatTurnsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('activeVersionIndex: $activeVersionIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageSender, int> senderType =
      GeneratedColumn<int>(
        'sender_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MessageSender>($ChatMessagesTable.$convertersenderType);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES characters (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _speakerNameOverrideMeta =
      const VerificationMeta('speakerNameOverride');
  @override
  late final GeneratedColumn<String> speakerNameOverride =
      GeneratedColumn<String>(
        'speaker_name_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _turnIdMeta = const VerificationMeta('turnId');
  @override
  late final GeneratedColumn<int> turnId = GeneratedColumn<int>(
    'turn_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_turns (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _versionIndexMeta = const VerificationMeta(
    'versionIndex',
  );
  @override
  late final GeneratedColumn<int> versionIndex = GeneratedColumn<int>(
    'version_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _turnSortOrderMeta = const VerificationMeta(
    'turnSortOrder',
  );
  @override
  late final GeneratedColumn<int> turnSortOrder = GeneratedColumn<int>(
    'turn_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    senderType,
    characterId,
    content,
    createdAt,
    speakerNameOverride,
    turnId,
    versionIndex,
    turnSortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('speaker_name_override')) {
      context.handle(
        _speakerNameOverrideMeta,
        speakerNameOverride.isAcceptableOrUnknown(
          data['speaker_name_override']!,
          _speakerNameOverrideMeta,
        ),
      );
    }
    if (data.containsKey('turn_id')) {
      context.handle(
        _turnIdMeta,
        turnId.isAcceptableOrUnknown(data['turn_id']!, _turnIdMeta),
      );
    }
    if (data.containsKey('version_index')) {
      context.handle(
        _versionIndexMeta,
        versionIndex.isAcceptableOrUnknown(
          data['version_index']!,
          _versionIndexMeta,
        ),
      );
    }
    if (data.containsKey('turn_sort_order')) {
      context.handle(
        _turnSortOrderMeta,
        turnSortOrder.isAcceptableOrUnknown(
          data['turn_sort_order']!,
          _turnSortOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      senderType: $ChatMessagesTable.$convertersenderType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sender_type'],
        )!,
      ),
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      speakerNameOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker_name_override'],
      ),
      turnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_id'],
      ),
      versionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_index'],
      )!,
      turnSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_sort_order'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageSender, int, int> $convertersenderType =
      const EnumIndexConverter<MessageSender>(MessageSender.values);
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final int sessionId;
  final MessageSender senderType;
  final int? characterId;
  final String content;
  final DateTime createdAt;

  /// AI가 등장시켰지만 등록된 캐릭터와 매칭되지 않은 발화자의 원문 이름.
  /// characterId가 null일 때 표시용으로만 쓴다(예: 즉석에서 등장한 새 인물).
  final String? speakerNameOverride;

  /// null이면 유저가 직접 입력한 메시지. 값이 있으면 AI 응답(또는 인트로)의 한 말풍선이며,
  /// 같은 turnId 안에서 versionIndex로 재시도/AI 수정 버전을, turnSortOrder로 한 버전
  /// 안에서의 말풍선 순서를 구분한다.
  final int? turnId;
  final int versionIndex;
  final int turnSortOrder;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderType,
    this.characterId,
    required this.content,
    required this.createdAt,
    this.speakerNameOverride,
    this.turnId,
    required this.versionIndex,
    required this.turnSortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    {
      map['sender_type'] = Variable<int>(
        $ChatMessagesTable.$convertersenderType.toSql(senderType),
      );
    }
    if (!nullToAbsent || characterId != null) {
      map['character_id'] = Variable<int>(characterId);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || speakerNameOverride != null) {
      map['speaker_name_override'] = Variable<String>(speakerNameOverride);
    }
    if (!nullToAbsent || turnId != null) {
      map['turn_id'] = Variable<int>(turnId);
    }
    map['version_index'] = Variable<int>(versionIndex);
    map['turn_sort_order'] = Variable<int>(turnSortOrder);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      senderType: Value(senderType),
      characterId: characterId == null && nullToAbsent
          ? const Value.absent()
          : Value(characterId),
      content: Value(content),
      createdAt: Value(createdAt),
      speakerNameOverride: speakerNameOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerNameOverride),
      turnId: turnId == null && nullToAbsent
          ? const Value.absent()
          : Value(turnId),
      versionIndex: Value(versionIndex),
      turnSortOrder: Value(turnSortOrder),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      senderType: $ChatMessagesTable.$convertersenderType.fromJson(
        serializer.fromJson<int>(json['senderType']),
      ),
      characterId: serializer.fromJson<int?>(json['characterId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      speakerNameOverride: serializer.fromJson<String?>(
        json['speakerNameOverride'],
      ),
      turnId: serializer.fromJson<int?>(json['turnId']),
      versionIndex: serializer.fromJson<int>(json['versionIndex']),
      turnSortOrder: serializer.fromJson<int>(json['turnSortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'senderType': serializer.toJson<int>(
        $ChatMessagesTable.$convertersenderType.toJson(senderType),
      ),
      'characterId': serializer.toJson<int?>(characterId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'speakerNameOverride': serializer.toJson<String?>(speakerNameOverride),
      'turnId': serializer.toJson<int?>(turnId),
      'versionIndex': serializer.toJson<int>(versionIndex),
      'turnSortOrder': serializer.toJson<int>(turnSortOrder),
    };
  }

  ChatMessage copyWith({
    int? id,
    int? sessionId,
    MessageSender? senderType,
    Value<int?> characterId = const Value.absent(),
    String? content,
    DateTime? createdAt,
    Value<String?> speakerNameOverride = const Value.absent(),
    Value<int?> turnId = const Value.absent(),
    int? versionIndex,
    int? turnSortOrder,
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    senderType: senderType ?? this.senderType,
    characterId: characterId.present ? characterId.value : this.characterId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    speakerNameOverride: speakerNameOverride.present
        ? speakerNameOverride.value
        : this.speakerNameOverride,
    turnId: turnId.present ? turnId.value : this.turnId,
    versionIndex: versionIndex ?? this.versionIndex,
    turnSortOrder: turnSortOrder ?? this.turnSortOrder,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      senderType: data.senderType.present
          ? data.senderType.value
          : this.senderType,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      speakerNameOverride: data.speakerNameOverride.present
          ? data.speakerNameOverride.value
          : this.speakerNameOverride,
      turnId: data.turnId.present ? data.turnId.value : this.turnId,
      versionIndex: data.versionIndex.present
          ? data.versionIndex.value
          : this.versionIndex,
      turnSortOrder: data.turnSortOrder.present
          ? data.turnSortOrder.value
          : this.turnSortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('senderType: $senderType, ')
          ..write('characterId: $characterId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('speakerNameOverride: $speakerNameOverride, ')
          ..write('turnId: $turnId, ')
          ..write('versionIndex: $versionIndex, ')
          ..write('turnSortOrder: $turnSortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    senderType,
    characterId,
    content,
    createdAt,
    speakerNameOverride,
    turnId,
    versionIndex,
    turnSortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.senderType == this.senderType &&
          other.characterId == this.characterId &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.speakerNameOverride == this.speakerNameOverride &&
          other.turnId == this.turnId &&
          other.versionIndex == this.versionIndex &&
          other.turnSortOrder == this.turnSortOrder);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<MessageSender> senderType;
  final Value<int?> characterId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> speakerNameOverride;
  final Value<int?> turnId;
  final Value<int> versionIndex;
  final Value<int> turnSortOrder;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.senderType = const Value.absent(),
    this.characterId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.speakerNameOverride = const Value.absent(),
    this.turnId = const Value.absent(),
    this.versionIndex = const Value.absent(),
    this.turnSortOrder = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required MessageSender senderType,
    this.characterId = const Value.absent(),
    required String content,
    this.createdAt = const Value.absent(),
    this.speakerNameOverride = const Value.absent(),
    this.turnId = const Value.absent(),
    this.versionIndex = const Value.absent(),
    this.turnSortOrder = const Value.absent(),
  }) : sessionId = Value(sessionId),
       senderType = Value(senderType),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? senderType,
    Expression<int>? characterId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? speakerNameOverride,
    Expression<int>? turnId,
    Expression<int>? versionIndex,
    Expression<int>? turnSortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (senderType != null) 'sender_type': senderType,
      if (characterId != null) 'character_id': characterId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (speakerNameOverride != null)
        'speaker_name_override': speakerNameOverride,
      if (turnId != null) 'turn_id': turnId,
      if (versionIndex != null) 'version_index': versionIndex,
      if (turnSortOrder != null) 'turn_sort_order': turnSortOrder,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<MessageSender>? senderType,
    Value<int?>? characterId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<String?>? speakerNameOverride,
    Value<int?>? turnId,
    Value<int>? versionIndex,
    Value<int>? turnSortOrder,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      senderType: senderType ?? this.senderType,
      characterId: characterId ?? this.characterId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      speakerNameOverride: speakerNameOverride ?? this.speakerNameOverride,
      turnId: turnId ?? this.turnId,
      versionIndex: versionIndex ?? this.versionIndex,
      turnSortOrder: turnSortOrder ?? this.turnSortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (senderType.present) {
      map['sender_type'] = Variable<int>(
        $ChatMessagesTable.$convertersenderType.toSql(senderType.value),
      );
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (speakerNameOverride.present) {
      map['speaker_name_override'] = Variable<String>(
        speakerNameOverride.value,
      );
    }
    if (turnId.present) {
      map['turn_id'] = Variable<int>(turnId.value);
    }
    if (versionIndex.present) {
      map['version_index'] = Variable<int>(versionIndex.value);
    }
    if (turnSortOrder.present) {
      map['turn_sort_order'] = Variable<int>(turnSortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('senderType: $senderType, ')
          ..write('characterId: $characterId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('speakerNameOverride: $speakerNameOverride, ')
          ..write('turnId: $turnId, ')
          ..write('versionIndex: $versionIndex, ')
          ..write('turnSortOrder: $turnSortOrder')
          ..write(')'))
        .toString();
  }
}

class $TokenUsageLogsTable extends TokenUsageLogs
    with TableInfo<$TokenUsageLogsTable, TokenUsageLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenUsageLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _presetNameMeta = const VerificationMeta(
    'presetName',
  );
  @override
  late final GeneratedColumn<String> presetName = GeneratedColumn<String>(
    'preset_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptTokensMeta = const VerificationMeta(
    'promptTokens',
  );
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
    'prompt_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completionTokensMeta = const VerificationMeta(
    'completionTokens',
  );
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
    'completion_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costUsdMeta = const VerificationMeta(
    'costUsd',
  );
  @override
  late final GeneratedColumn<double> costUsd = GeneratedColumn<double>(
    'cost_usd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    presetName,
    baseUrl,
    modelName,
    promptTokens,
    completionTokens,
    costUsd,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_usage_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TokenUsageLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preset_name')) {
      context.handle(
        _presetNameMeta,
        presetName.isAcceptableOrUnknown(data['preset_name']!, _presetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_presetNameMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
        _promptTokensMeta,
        promptTokens.isAcceptableOrUnknown(
          data['prompt_tokens']!,
          _promptTokensMeta,
        ),
      );
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
        _completionTokensMeta,
        completionTokens.isAcceptableOrUnknown(
          data['completion_tokens']!,
          _completionTokensMeta,
        ),
      );
    }
    if (data.containsKey('cost_usd')) {
      context.handle(
        _costUsdMeta,
        costUsd.isAcceptableOrUnknown(data['cost_usd']!, _costUsdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenUsageLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenUsageLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      presetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_name'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      promptTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_tokens'],
      )!,
      completionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_tokens'],
      )!,
      costUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_usd'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TokenUsageLogsTable createAlias(String alias) {
    return $TokenUsageLogsTable(attachedDatabase, alias);
  }
}

class TokenUsageLog extends DataClass implements Insertable<TokenUsageLog> {
  final int id;
  final String presetName;
  final String baseUrl;
  final String modelName;
  final int promptTokens;
  final int completionTokens;

  /// 엔드포인트가 가격을 알려줄 때만(예: OpenRouter) 값이 있다. USD 기준.
  final double? costUsd;
  final DateTime createdAt;
  const TokenUsageLog({
    required this.id,
    required this.presetName,
    required this.baseUrl,
    required this.modelName,
    required this.promptTokens,
    required this.completionTokens,
    this.costUsd,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['preset_name'] = Variable<String>(presetName);
    map['base_url'] = Variable<String>(baseUrl);
    map['model_name'] = Variable<String>(modelName);
    map['prompt_tokens'] = Variable<int>(promptTokens);
    map['completion_tokens'] = Variable<int>(completionTokens);
    if (!nullToAbsent || costUsd != null) {
      map['cost_usd'] = Variable<double>(costUsd);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TokenUsageLogsCompanion toCompanion(bool nullToAbsent) {
    return TokenUsageLogsCompanion(
      id: Value(id),
      presetName: Value(presetName),
      baseUrl: Value(baseUrl),
      modelName: Value(modelName),
      promptTokens: Value(promptTokens),
      completionTokens: Value(completionTokens),
      costUsd: costUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(costUsd),
      createdAt: Value(createdAt),
    );
  }

  factory TokenUsageLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenUsageLog(
      id: serializer.fromJson<int>(json['id']),
      presetName: serializer.fromJson<String>(json['presetName']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      modelName: serializer.fromJson<String>(json['modelName']),
      promptTokens: serializer.fromJson<int>(json['promptTokens']),
      completionTokens: serializer.fromJson<int>(json['completionTokens']),
      costUsd: serializer.fromJson<double?>(json['costUsd']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'presetName': serializer.toJson<String>(presetName),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'modelName': serializer.toJson<String>(modelName),
      'promptTokens': serializer.toJson<int>(promptTokens),
      'completionTokens': serializer.toJson<int>(completionTokens),
      'costUsd': serializer.toJson<double?>(costUsd),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TokenUsageLog copyWith({
    int? id,
    String? presetName,
    String? baseUrl,
    String? modelName,
    int? promptTokens,
    int? completionTokens,
    Value<double?> costUsd = const Value.absent(),
    DateTime? createdAt,
  }) => TokenUsageLog(
    id: id ?? this.id,
    presetName: presetName ?? this.presetName,
    baseUrl: baseUrl ?? this.baseUrl,
    modelName: modelName ?? this.modelName,
    promptTokens: promptTokens ?? this.promptTokens,
    completionTokens: completionTokens ?? this.completionTokens,
    costUsd: costUsd.present ? costUsd.value : this.costUsd,
    createdAt: createdAt ?? this.createdAt,
  );
  TokenUsageLog copyWithCompanion(TokenUsageLogsCompanion data) {
    return TokenUsageLog(
      id: data.id.present ? data.id.value : this.id,
      presetName: data.presetName.present
          ? data.presetName.value
          : this.presetName,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
      costUsd: data.costUsd.present ? data.costUsd.value : this.costUsd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenUsageLog(')
          ..write('id: $id, ')
          ..write('presetName: $presetName, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelName: $modelName, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    presetName,
    baseUrl,
    modelName,
    promptTokens,
    completionTokens,
    costUsd,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenUsageLog &&
          other.id == this.id &&
          other.presetName == this.presetName &&
          other.baseUrl == this.baseUrl &&
          other.modelName == this.modelName &&
          other.promptTokens == this.promptTokens &&
          other.completionTokens == this.completionTokens &&
          other.costUsd == this.costUsd &&
          other.createdAt == this.createdAt);
}

class TokenUsageLogsCompanion extends UpdateCompanion<TokenUsageLog> {
  final Value<int> id;
  final Value<String> presetName;
  final Value<String> baseUrl;
  final Value<String> modelName;
  final Value<int> promptTokens;
  final Value<int> completionTokens;
  final Value<double?> costUsd;
  final Value<DateTime> createdAt;
  const TokenUsageLogsCompanion({
    this.id = const Value.absent(),
    this.presetName = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.modelName = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.costUsd = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TokenUsageLogsCompanion.insert({
    this.id = const Value.absent(),
    required String presetName,
    required String baseUrl,
    required String modelName,
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.costUsd = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : presetName = Value(presetName),
       baseUrl = Value(baseUrl),
       modelName = Value(modelName);
  static Insertable<TokenUsageLog> custom({
    Expression<int>? id,
    Expression<String>? presetName,
    Expression<String>? baseUrl,
    Expression<String>? modelName,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
    Expression<double>? costUsd,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetName != null) 'preset_name': presetName,
      if (baseUrl != null) 'base_url': baseUrl,
      if (modelName != null) 'model_name': modelName,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (costUsd != null) 'cost_usd': costUsd,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TokenUsageLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? presetName,
    Value<String>? baseUrl,
    Value<String>? modelName,
    Value<int>? promptTokens,
    Value<int>? completionTokens,
    Value<double?>? costUsd,
    Value<DateTime>? createdAt,
  }) {
    return TokenUsageLogsCompanion(
      id: id ?? this.id,
      presetName: presetName ?? this.presetName,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      costUsd: costUsd ?? this.costUsd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (presetName.present) {
      map['preset_name'] = Variable<String>(presetName.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (costUsd.present) {
      map['cost_usd'] = Variable<double>(costUsd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenUsageLogsCompanion(')
          ..write('id: $id, ')
          ..write('presetName: $presetName, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelName: $modelName, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LorebooksTable extends Lorebooks
    with TableInfo<$LorebooksTable, Lorebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LorebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortIntroMeta = const VerificationMeta(
    'shortIntro',
  );
  @override
  late final GeneratedColumn<String> shortIntro = GeneratedColumn<String>(
    'short_intro',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    shortIntro,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lorebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lorebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('short_intro')) {
      context.handle(
        _shortIntroMeta,
        shortIntro.isAcceptableOrUnknown(data['short_intro']!, _shortIntroMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lorebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lorebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      shortIntro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_intro'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LorebooksTable createAlias(String alias) {
    return $LorebooksTable(attachedDatabase, alias);
  }
}

class Lorebook extends DataClass implements Insertable<Lorebook> {
  final int id;
  final String title;
  final String shortIntro;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Lorebook({
    required this.id,
    required this.title,
    required this.shortIntro,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['short_intro'] = Variable<String>(shortIntro);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LorebooksCompanion toCompanion(bool nullToAbsent) {
    return LorebooksCompanion(
      id: Value(id),
      title: Value(title),
      shortIntro: Value(shortIntro),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Lorebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lorebook(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      shortIntro: serializer.fromJson<String>(json['shortIntro']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'shortIntro': serializer.toJson<String>(shortIntro),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Lorebook copyWith({
    int? id,
    String? title,
    String? shortIntro,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Lorebook(
    id: id ?? this.id,
    title: title ?? this.title,
    shortIntro: shortIntro ?? this.shortIntro,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Lorebook copyWithCompanion(LorebooksCompanion data) {
    return Lorebook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      shortIntro: data.shortIntro.present
          ? data.shortIntro.value
          : this.shortIntro,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lorebook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('shortIntro: $shortIntro, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, shortIntro, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lorebook &&
          other.id == this.id &&
          other.title == this.title &&
          other.shortIntro == this.shortIntro &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LorebooksCompanion extends UpdateCompanion<Lorebook> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> shortIntro;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LorebooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.shortIntro = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LorebooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.shortIntro = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Lorebook> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? shortIntro,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (shortIntro != null) 'short_intro': shortIntro,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LorebooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? shortIntro,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LorebooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      shortIntro: shortIntro ?? this.shortIntro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (shortIntro.present) {
      map['short_intro'] = Variable<String>(shortIntro.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LorebooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('shortIntro: $shortIntro, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LorebookEntriesTable extends LorebookEntries
    with TableInfo<$LorebookEntriesTable, LorebookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LorebookEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lorebookIdMeta = const VerificationMeta(
    'lorebookId',
  );
  @override
  late final GeneratedColumn<int> lorebookId = GeneratedColumn<int>(
    'lorebook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lorebooks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lorebookId,
    title,
    keywords,
    content,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lorebook_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LorebookEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lorebook_id')) {
      context.handle(
        _lorebookIdMeta,
        lorebookId.isAcceptableOrUnknown(data['lorebook_id']!, _lorebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lorebookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LorebookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LorebookEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lorebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lorebook_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LorebookEntriesTable createAlias(String alias) {
    return $LorebookEntriesTable(attachedDatabase, alias);
  }
}

class LorebookEntry extends DataClass implements Insertable<LorebookEntry> {
  final int id;
  final int lorebookId;
  final String title;
  final String keywords;
  final String content;
  final int sortOrder;
  const LorebookEntry({
    required this.id,
    required this.lorebookId,
    required this.title,
    required this.keywords,
    required this.content,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lorebook_id'] = Variable<int>(lorebookId);
    map['title'] = Variable<String>(title);
    map['keywords'] = Variable<String>(keywords);
    map['content'] = Variable<String>(content);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LorebookEntriesCompanion toCompanion(bool nullToAbsent) {
    return LorebookEntriesCompanion(
      id: Value(id),
      lorebookId: Value(lorebookId),
      title: Value(title),
      keywords: Value(keywords),
      content: Value(content),
      sortOrder: Value(sortOrder),
    );
  }

  factory LorebookEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LorebookEntry(
      id: serializer.fromJson<int>(json['id']),
      lorebookId: serializer.fromJson<int>(json['lorebookId']),
      title: serializer.fromJson<String>(json['title']),
      keywords: serializer.fromJson<String>(json['keywords']),
      content: serializer.fromJson<String>(json['content']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lorebookId': serializer.toJson<int>(lorebookId),
      'title': serializer.toJson<String>(title),
      'keywords': serializer.toJson<String>(keywords),
      'content': serializer.toJson<String>(content),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LorebookEntry copyWith({
    int? id,
    int? lorebookId,
    String? title,
    String? keywords,
    String? content,
    int? sortOrder,
  }) => LorebookEntry(
    id: id ?? this.id,
    lorebookId: lorebookId ?? this.lorebookId,
    title: title ?? this.title,
    keywords: keywords ?? this.keywords,
    content: content ?? this.content,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LorebookEntry copyWithCompanion(LorebookEntriesCompanion data) {
    return LorebookEntry(
      id: data.id.present ? data.id.value : this.id,
      lorebookId: data.lorebookId.present
          ? data.lorebookId.value
          : this.lorebookId,
      title: data.title.present ? data.title.value : this.title,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      content: data.content.present ? data.content.value : this.content,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LorebookEntry(')
          ..write('id: $id, ')
          ..write('lorebookId: $lorebookId, ')
          ..write('title: $title, ')
          ..write('keywords: $keywords, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lorebookId, title, keywords, content, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LorebookEntry &&
          other.id == this.id &&
          other.lorebookId == this.lorebookId &&
          other.title == this.title &&
          other.keywords == this.keywords &&
          other.content == this.content &&
          other.sortOrder == this.sortOrder);
}

class LorebookEntriesCompanion extends UpdateCompanion<LorebookEntry> {
  final Value<int> id;
  final Value<int> lorebookId;
  final Value<String> title;
  final Value<String> keywords;
  final Value<String> content;
  final Value<int> sortOrder;
  const LorebookEntriesCompanion({
    this.id = const Value.absent(),
    this.lorebookId = const Value.absent(),
    this.title = const Value.absent(),
    this.keywords = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  LorebookEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int lorebookId,
    this.title = const Value.absent(),
    this.keywords = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : lorebookId = Value(lorebookId);
  static Insertable<LorebookEntry> custom({
    Expression<int>? id,
    Expression<int>? lorebookId,
    Expression<String>? title,
    Expression<String>? keywords,
    Expression<String>? content,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lorebookId != null) 'lorebook_id': lorebookId,
      if (title != null) 'title': title,
      if (keywords != null) 'keywords': keywords,
      if (content != null) 'content': content,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  LorebookEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? lorebookId,
    Value<String>? title,
    Value<String>? keywords,
    Value<String>? content,
    Value<int>? sortOrder,
  }) {
    return LorebookEntriesCompanion(
      id: id ?? this.id,
      lorebookId: lorebookId ?? this.lorebookId,
      title: title ?? this.title,
      keywords: keywords ?? this.keywords,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lorebookId.present) {
      map['lorebook_id'] = Variable<int>(lorebookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LorebookEntriesCompanion(')
          ..write('id: $id, ')
          ..write('lorebookId: $lorebookId, ')
          ..write('title: $title, ')
          ..write('keywords: $keywords, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LorebookPlotLinksTable extends LorebookPlotLinks
    with TableInfo<$LorebookPlotLinksTable, LorebookPlotLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LorebookPlotLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lorebookIdMeta = const VerificationMeta(
    'lorebookId',
  );
  @override
  late final GeneratedColumn<int> lorebookId = GeneratedColumn<int>(
    'lorebook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lorebooks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<int> plotId = GeneratedColumn<int>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plots (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, lorebookId, plotId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lorebook_plot_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<LorebookPlotLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lorebook_id')) {
      context.handle(
        _lorebookIdMeta,
        lorebookId.isAcceptableOrUnknown(data['lorebook_id']!, _lorebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lorebookIdMeta);
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LorebookPlotLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LorebookPlotLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lorebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lorebook_id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plot_id'],
      )!,
    );
  }

  @override
  $LorebookPlotLinksTable createAlias(String alias) {
    return $LorebookPlotLinksTable(attachedDatabase, alias);
  }
}

class LorebookPlotLink extends DataClass
    implements Insertable<LorebookPlotLink> {
  final int id;
  final int lorebookId;
  final int plotId;
  const LorebookPlotLink({
    required this.id,
    required this.lorebookId,
    required this.plotId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lorebook_id'] = Variable<int>(lorebookId);
    map['plot_id'] = Variable<int>(plotId);
    return map;
  }

  LorebookPlotLinksCompanion toCompanion(bool nullToAbsent) {
    return LorebookPlotLinksCompanion(
      id: Value(id),
      lorebookId: Value(lorebookId),
      plotId: Value(plotId),
    );
  }

  factory LorebookPlotLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LorebookPlotLink(
      id: serializer.fromJson<int>(json['id']),
      lorebookId: serializer.fromJson<int>(json['lorebookId']),
      plotId: serializer.fromJson<int>(json['plotId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lorebookId': serializer.toJson<int>(lorebookId),
      'plotId': serializer.toJson<int>(plotId),
    };
  }

  LorebookPlotLink copyWith({int? id, int? lorebookId, int? plotId}) =>
      LorebookPlotLink(
        id: id ?? this.id,
        lorebookId: lorebookId ?? this.lorebookId,
        plotId: plotId ?? this.plotId,
      );
  LorebookPlotLink copyWithCompanion(LorebookPlotLinksCompanion data) {
    return LorebookPlotLink(
      id: data.id.present ? data.id.value : this.id,
      lorebookId: data.lorebookId.present
          ? data.lorebookId.value
          : this.lorebookId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LorebookPlotLink(')
          ..write('id: $id, ')
          ..write('lorebookId: $lorebookId, ')
          ..write('plotId: $plotId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lorebookId, plotId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LorebookPlotLink &&
          other.id == this.id &&
          other.lorebookId == this.lorebookId &&
          other.plotId == this.plotId);
}

class LorebookPlotLinksCompanion extends UpdateCompanion<LorebookPlotLink> {
  final Value<int> id;
  final Value<int> lorebookId;
  final Value<int> plotId;
  const LorebookPlotLinksCompanion({
    this.id = const Value.absent(),
    this.lorebookId = const Value.absent(),
    this.plotId = const Value.absent(),
  });
  LorebookPlotLinksCompanion.insert({
    this.id = const Value.absent(),
    required int lorebookId,
    required int plotId,
  }) : lorebookId = Value(lorebookId),
       plotId = Value(plotId);
  static Insertable<LorebookPlotLink> custom({
    Expression<int>? id,
    Expression<int>? lorebookId,
    Expression<int>? plotId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lorebookId != null) 'lorebook_id': lorebookId,
      if (plotId != null) 'plot_id': plotId,
    });
  }

  LorebookPlotLinksCompanion copyWith({
    Value<int>? id,
    Value<int>? lorebookId,
    Value<int>? plotId,
  }) {
    return LorebookPlotLinksCompanion(
      id: id ?? this.id,
      lorebookId: lorebookId ?? this.lorebookId,
      plotId: plotId ?? this.plotId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lorebookId.present) {
      map['lorebook_id'] = Variable<int>(lorebookId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<int>(plotId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LorebookPlotLinksCompanion(')
          ..write('id: $id, ')
          ..write('lorebookId: $lorebookId, ')
          ..write('plotId: $plotId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlotsTable plots = $PlotsTable(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final $IntroVersionsTable introVersions = $IntroVersionsTable(this);
  late final $IntroEntriesTable introEntries = $IntroEntriesTable(this);
  late final $ConversationProfilesTable conversationProfiles =
      $ConversationProfilesTable(this);
  late final $AiPresetsTable aiPresets = $AiPresetsTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatTurnsTable chatTurns = $ChatTurnsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $TokenUsageLogsTable tokenUsageLogs = $TokenUsageLogsTable(this);
  late final $LorebooksTable lorebooks = $LorebooksTable(this);
  late final $LorebookEntriesTable lorebookEntries = $LorebookEntriesTable(
    this,
  );
  late final $LorebookPlotLinksTable lorebookPlotLinks =
      $LorebookPlotLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    plots,
    characters,
    introVersions,
    introEntries,
    conversationProfiles,
    aiPresets,
    chatSessions,
    chatTurns,
    chatMessages,
    tokenUsageLogs,
    lorebooks,
    lorebookEntries,
    lorebookPlotLinks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('characters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intro_versions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intro_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'intro_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intro_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intro_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversation_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ai_presets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_turns', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'characters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_messages', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_turns',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lorebooks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lorebook_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lorebooks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lorebook_plot_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lorebook_plot_links', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlotsTableCreateCompanionBuilder =
    PlotsCompanion Function({
      Value<int> id,
      required String title,
      required String description,
      Value<String?> coverImagePath,
      Value<String?> shortIntro,
      Value<String> hashtags,
      Value<PlotVisibility> visibility,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$PlotsTableUpdateCompanionBuilder =
    PlotsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<String?> coverImagePath,
      Value<String?> shortIntro,
      Value<String> hashtags,
      Value<PlotVisibility> visibility,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PlotsTableReferences
    extends BaseReferences<_$AppDatabase, $PlotsTable, Plot> {
  $$PlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CharactersTable, List<Character>>
  _charactersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.characters,
    aliasName: 'plots__id__characters__plot_id',
  );

  $$CharactersTableProcessedTableManager get charactersRefs {
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_charactersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntroVersionsTable, List<IntroVersion>>
  _introVersionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.introVersions,
    aliasName: 'plots__id__intro_versions__plot_id',
  );

  $$IntroVersionsTableProcessedTableManager get introVersionsRefs {
    final manager = $$IntroVersionsTableTableManager(
      $_db,
      $_db.introVersions,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_introVersionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntroEntriesTable, List<IntroEntry>>
  _introEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.introEntries,
    aliasName: 'plots__id__intro_entries__plot_id',
  );

  $$IntroEntriesTableProcessedTableManager get introEntriesRefs {
    final manager = $$IntroEntriesTableTableManager(
      $_db,
      $_db.introEntries,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_introEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName: 'plots__id__chat_sessions__plot_id',
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LorebookPlotLinksTable, List<LorebookPlotLink>>
  _lorebookPlotLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lorebookPlotLinks,
        aliasName: 'plots__id__lorebook_plot_links__plot_id',
      );

  $$LorebookPlotLinksTableProcessedTableManager get lorebookPlotLinksRefs {
    final manager = $$LorebookPlotLinksTableTableManager(
      $_db,
      $_db.lorebookPlotLinks,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lorebookPlotLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlotsTableFilterComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashtags => $composableBuilder(
    column: $table.hashtags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlotVisibility, PlotVisibility, int>
  get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> charactersRefs(
    Expression<bool> Function($$CharactersTableFilterComposer f) f,
  ) {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> introVersionsRefs(
    Expression<bool> Function($$IntroVersionsTableFilterComposer f) f,
  ) {
    final $$IntroVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introVersions,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroVersionsTableFilterComposer(
            $db: $db,
            $table: $db.introVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> introEntriesRefs(
    Expression<bool> Function($$IntroEntriesTableFilterComposer f) f,
  ) {
    final $$IntroEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableFilterComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lorebookPlotLinksRefs(
    Expression<bool> Function($$LorebookPlotLinksTableFilterComposer f) f,
  ) {
    final $$LorebookPlotLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lorebookPlotLinks,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebookPlotLinksTableFilterComposer(
            $db: $db,
            $table: $db.lorebookPlotLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashtags => $composableBuilder(
    column: $table.hashtags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashtags =>
      $composableBuilder(column: $table.hashtags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlotVisibility, int> get visibility =>
      $composableBuilder(
        column: $table.visibility,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> charactersRefs<T extends Object>(
    Expression<T> Function($$CharactersTableAnnotationComposer a) f,
  ) {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> introVersionsRefs<T extends Object>(
    Expression<T> Function($$IntroVersionsTableAnnotationComposer a) f,
  ) {
    final $$IntroVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introVersions,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.introVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> introEntriesRefs<T extends Object>(
    Expression<T> Function($$IntroEntriesTableAnnotationComposer a) f,
  ) {
    final $$IntroEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lorebookPlotLinksRefs<T extends Object>(
    Expression<T> Function($$LorebookPlotLinksTableAnnotationComposer a) f,
  ) {
    final $$LorebookPlotLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lorebookPlotLinks,
          getReferencedColumn: (t) => t.plotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LorebookPlotLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.lorebookPlotLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotsTable,
          Plot,
          $$PlotsTableFilterComposer,
          $$PlotsTableOrderingComposer,
          $$PlotsTableAnnotationComposer,
          $$PlotsTableCreateCompanionBuilder,
          $$PlotsTableUpdateCompanionBuilder,
          (Plot, $$PlotsTableReferences),
          Plot,
          PrefetchHooks Function({
            bool charactersRefs,
            bool introVersionsRefs,
            bool introEntriesRefs,
            bool chatSessionsRefs,
            bool lorebookPlotLinksRefs,
          })
        > {
  $$PlotsTableTableManager(_$AppDatabase db, $PlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<String?> shortIntro = const Value.absent(),
                Value<String> hashtags = const Value.absent(),
                Value<PlotVisibility> visibility = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlotsCompanion(
                id: id,
                title: title,
                description: description,
                coverImagePath: coverImagePath,
                shortIntro: shortIntro,
                hashtags: hashtags,
                visibility: visibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String description,
                Value<String?> coverImagePath = const Value.absent(),
                Value<String?> shortIntro = const Value.absent(),
                Value<String> hashtags = const Value.absent(),
                Value<PlotVisibility> visibility = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlotsCompanion.insert(
                id: id,
                title: title,
                description: description,
                coverImagePath: coverImagePath,
                shortIntro: shortIntro,
                hashtags: hashtags,
                visibility: visibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlotsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                charactersRefs = false,
                introVersionsRefs = false,
                introEntriesRefs = false,
                chatSessionsRefs = false,
                lorebookPlotLinksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (charactersRefs) db.characters,
                    if (introVersionsRefs) db.introVersions,
                    if (introEntriesRefs) db.introEntries,
                    if (chatSessionsRefs) db.chatSessions,
                    if (lorebookPlotLinksRefs) db.lorebookPlotLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (charactersRefs)
                        await $_getPrefetchedData<Plot, $PlotsTable, Character>(
                          currentTable: table,
                          referencedTable: $$PlotsTableReferences
                              ._charactersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).charactersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (introVersionsRefs)
                        await $_getPrefetchedData<
                          Plot,
                          $PlotsTable,
                          IntroVersion
                        >(
                          currentTable: table,
                          referencedTable: $$PlotsTableReferences
                              ._introVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).introVersionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (introEntriesRefs)
                        await $_getPrefetchedData<
                          Plot,
                          $PlotsTable,
                          IntroEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PlotsTableReferences
                              ._introEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).introEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatSessionsRefs)
                        await $_getPrefetchedData<
                          Plot,
                          $PlotsTable,
                          ChatSession
                        >(
                          currentTable: table,
                          referencedTable: $$PlotsTableReferences
                              ._chatSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lorebookPlotLinksRefs)
                        await $_getPrefetchedData<
                          Plot,
                          $PlotsTable,
                          LorebookPlotLink
                        >(
                          currentTable: table,
                          referencedTable: $$PlotsTableReferences
                              ._lorebookPlotLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).lorebookPlotLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotsTable,
      Plot,
      $$PlotsTableFilterComposer,
      $$PlotsTableOrderingComposer,
      $$PlotsTableAnnotationComposer,
      $$PlotsTableCreateCompanionBuilder,
      $$PlotsTableUpdateCompanionBuilder,
      (Plot, $$PlotsTableReferences),
      Plot,
      PrefetchHooks Function({
        bool charactersRefs,
        bool introVersionsRefs,
        bool introEntriesRefs,
        bool chatSessionsRefs,
        bool lorebookPlotLinksRefs,
      })
    >;
typedef $$CharactersTableCreateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      required int plotId,
      required String name,
      Value<String> description,
      Value<String?> imagePath,
      Value<bool> isRepresentative,
      Value<int> sortOrder,
      Value<String> aboutText,
    });
typedef $$CharactersTableUpdateCompanionBuilder =
    CharactersCompanion Function({
      Value<int> id,
      Value<int> plotId,
      Value<String> name,
      Value<String> description,
      Value<String?> imagePath,
      Value<bool> isRepresentative,
      Value<int> sortOrder,
      Value<String> aboutText,
    });

final class $$CharactersTableReferences
    extends BaseReferences<_$AppDatabase, $CharactersTable, Character> {
  $$CharactersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlotsTable _plotIdTable(_$AppDatabase db) =>
      db.plots.createAlias('characters__plot_id__plots__id');

  $$PlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<int>('plot_id')!;

    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IntroEntriesTable, List<IntroEntry>>
  _introEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.introEntries,
    aliasName: 'characters__id__intro_entries__character_id',
  );

  $$IntroEntriesTableProcessedTableManager get introEntriesRefs {
    final manager = $$IntroEntriesTableTableManager(
      $_db,
      $_db.introEntries,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_introEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'characters__id__chat_messages__character_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.characterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CharactersTableFilterComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRepresentative => $composableBuilder(
    column: $table.isRepresentative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aboutText => $composableBuilder(
    column: $table.aboutText,
    builder: (column) => ColumnFilters(column),
  );

  $$PlotsTableFilterComposer get plotId {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> introEntriesRefs(
    Expression<bool> Function($$IntroEntriesTableFilterComposer f) f,
  ) {
    final $$IntroEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableFilterComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRepresentative => $composableBuilder(
    column: $table.isRepresentative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aboutText => $composableBuilder(
    column: $table.aboutText,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlotsTableOrderingComposer get plotId {
    final $$PlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableOrderingComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isRepresentative => $composableBuilder(
    column: $table.isRepresentative,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get aboutText =>
      $composableBuilder(column: $table.aboutText, builder: (column) => column);

  $$PlotsTableAnnotationComposer get plotId {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> introEntriesRefs<T extends Object>(
    Expression<T> Function($$IntroEntriesTableAnnotationComposer a) f,
  ) {
    final $$IntroEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.characterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharactersTable,
          Character,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (Character, $$CharactersTableReferences),
          Character,
          PrefetchHooks Function({
            bool plotId,
            bool introEntriesRefs,
            bool chatMessagesRefs,
          })
        > {
  $$CharactersTableTableManager(_$AppDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plotId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isRepresentative = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> aboutText = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                plotId: plotId,
                name: name,
                description: description,
                imagePath: imagePath,
                isRepresentative: isRepresentative,
                sortOrder: sortOrder,
                aboutText: aboutText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plotId,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isRepresentative = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> aboutText = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                plotId: plotId,
                name: name,
                description: description,
                imagePath: imagePath,
                isRepresentative: isRepresentative,
                sortOrder: sortOrder,
                aboutText: aboutText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CharactersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                plotId = false,
                introEntriesRefs = false,
                chatMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (introEntriesRefs) db.introEntries,
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (plotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plotId,
                                    referencedTable: $$CharactersTableReferences
                                        ._plotIdTable(db),
                                    referencedColumn:
                                        $$CharactersTableReferences
                                            ._plotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (introEntriesRefs)
                        await $_getPrefetchedData<
                          Character,
                          $CharactersTable,
                          IntroEntry
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._introEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).introEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          Character,
                          $CharactersTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$CharactersTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CharactersTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.characterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharactersTable,
      Character,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (Character, $$CharactersTableReferences),
      Character,
      PrefetchHooks Function({
        bool plotId,
        bool introEntriesRefs,
        bool chatMessagesRefs,
      })
    >;
typedef $$IntroVersionsTableCreateCompanionBuilder =
    IntroVersionsCompanion Function({
      Value<int> id,
      required int plotId,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });
typedef $$IntroVersionsTableUpdateCompanionBuilder =
    IntroVersionsCompanion Function({
      Value<int> id,
      Value<int> plotId,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$IntroVersionsTableReferences
    extends BaseReferences<_$AppDatabase, $IntroVersionsTable, IntroVersion> {
  $$IntroVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlotsTable _plotIdTable(_$AppDatabase db) =>
      db.plots.createAlias('intro_versions__plot_id__plots__id');

  $$PlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<int>('plot_id')!;

    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IntroEntriesTable, List<IntroEntry>>
  _introEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.introEntries,
    aliasName: 'intro_versions__id__intro_entries__intro_version_id',
  );

  $$IntroEntriesTableProcessedTableManager get introEntriesRefs {
    final manager = $$IntroEntriesTableTableManager(
      $_db,
      $_db.introEntries,
    ).filter((f) => f.introVersionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_introEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IntroVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $IntroVersionsTable> {
  $$IntroVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlotsTableFilterComposer get plotId {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> introEntriesRefs(
    Expression<bool> Function($$IntroEntriesTableFilterComposer f) f,
  ) {
    final $$IntroEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.introVersionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableFilterComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntroVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntroVersionsTable> {
  $$IntroVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlotsTableOrderingComposer get plotId {
    final $$PlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableOrderingComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntroVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntroVersionsTable> {
  $$IntroVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PlotsTableAnnotationComposer get plotId {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> introEntriesRefs<T extends Object>(
    Expression<T> Function($$IntroEntriesTableAnnotationComposer a) f,
  ) {
    final $$IntroEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.introEntries,
      getReferencedColumn: (t) => t.introVersionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.introEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntroVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntroVersionsTable,
          IntroVersion,
          $$IntroVersionsTableFilterComposer,
          $$IntroVersionsTableOrderingComposer,
          $$IntroVersionsTableAnnotationComposer,
          $$IntroVersionsTableCreateCompanionBuilder,
          $$IntroVersionsTableUpdateCompanionBuilder,
          (IntroVersion, $$IntroVersionsTableReferences),
          IntroVersion,
          PrefetchHooks Function({bool plotId, bool introEntriesRefs})
        > {
  $$IntroVersionsTableTableManager(_$AppDatabase db, $IntroVersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntroVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntroVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntroVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plotId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IntroVersionsCompanion(
                id: id,
                plotId: plotId,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plotId,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IntroVersionsCompanion.insert(
                id: id,
                plotId: plotId,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntroVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plotId = false, introEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (introEntriesRefs) db.introEntries],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (plotId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plotId,
                                referencedTable: $$IntroVersionsTableReferences
                                    ._plotIdTable(db),
                                referencedColumn: $$IntroVersionsTableReferences
                                    ._plotIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (introEntriesRefs)
                    await $_getPrefetchedData<
                      IntroVersion,
                      $IntroVersionsTable,
                      IntroEntry
                    >(
                      currentTable: table,
                      referencedTable: $$IntroVersionsTableReferences
                          ._introEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IntroVersionsTableReferences(
                            db,
                            table,
                            p0,
                          ).introEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.introVersionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IntroVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntroVersionsTable,
      IntroVersion,
      $$IntroVersionsTableFilterComposer,
      $$IntroVersionsTableOrderingComposer,
      $$IntroVersionsTableAnnotationComposer,
      $$IntroVersionsTableCreateCompanionBuilder,
      $$IntroVersionsTableUpdateCompanionBuilder,
      (IntroVersion, $$IntroVersionsTableReferences),
      IntroVersion,
      PrefetchHooks Function({bool plotId, bool introEntriesRefs})
    >;
typedef $$IntroEntriesTableCreateCompanionBuilder =
    IntroEntriesCompanion Function({
      Value<int> id,
      required int plotId,
      Value<int?> introVersionId,
      Value<int?> characterId,
      required IntroEntryType type,
      required String content,
      Value<int> sortOrder,
    });
typedef $$IntroEntriesTableUpdateCompanionBuilder =
    IntroEntriesCompanion Function({
      Value<int> id,
      Value<int> plotId,
      Value<int?> introVersionId,
      Value<int?> characterId,
      Value<IntroEntryType> type,
      Value<String> content,
      Value<int> sortOrder,
    });

final class $$IntroEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $IntroEntriesTable, IntroEntry> {
  $$IntroEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlotsTable _plotIdTable(_$AppDatabase db) =>
      db.plots.createAlias('intro_entries__plot_id__plots__id');

  $$PlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<int>('plot_id')!;

    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IntroVersionsTable _introVersionIdTable(_$AppDatabase db) => db
      .introVersions
      .createAlias('intro_entries__intro_version_id__intro_versions__id');

  $$IntroVersionsTableProcessedTableManager? get introVersionId {
    final $_column = $_itemColumn<int>('intro_version_id');
    if ($_column == null) return null;
    final manager = $$IntroVersionsTableTableManager(
      $_db,
      $_db.introVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_introVersionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias('intro_entries__character_id__characters__id');

  $$CharactersTableProcessedTableManager? get characterId {
    final $_column = $_itemColumn<int>('character_id');
    if ($_column == null) return null;
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntroEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $IntroEntriesTable> {
  $$IntroEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IntroEntryType, IntroEntryType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PlotsTableFilterComposer get plotId {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntroVersionsTableFilterComposer get introVersionId {
    final $$IntroVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.introVersionId,
      referencedTable: $db.introVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroVersionsTableFilterComposer(
            $db: $db,
            $table: $db.introVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntroEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IntroEntriesTable> {
  $$IntroEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlotsTableOrderingComposer get plotId {
    final $$PlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableOrderingComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntroVersionsTableOrderingComposer get introVersionId {
    final $$IntroVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.introVersionId,
      referencedTable: $db.introVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.introVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntroEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntroEntriesTable> {
  $$IntroEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IntroEntryType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PlotsTableAnnotationComposer get plotId {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IntroVersionsTableAnnotationComposer get introVersionId {
    final $$IntroVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.introVersionId,
      referencedTable: $db.introVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntroVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.introVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntroEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntroEntriesTable,
          IntroEntry,
          $$IntroEntriesTableFilterComposer,
          $$IntroEntriesTableOrderingComposer,
          $$IntroEntriesTableAnnotationComposer,
          $$IntroEntriesTableCreateCompanionBuilder,
          $$IntroEntriesTableUpdateCompanionBuilder,
          (IntroEntry, $$IntroEntriesTableReferences),
          IntroEntry,
          PrefetchHooks Function({
            bool plotId,
            bool introVersionId,
            bool characterId,
          })
        > {
  $$IntroEntriesTableTableManager(_$AppDatabase db, $IntroEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntroEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntroEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntroEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plotId = const Value.absent(),
                Value<int?> introVersionId = const Value.absent(),
                Value<int?> characterId = const Value.absent(),
                Value<IntroEntryType> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => IntroEntriesCompanion(
                id: id,
                plotId: plotId,
                introVersionId: introVersionId,
                characterId: characterId,
                type: type,
                content: content,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plotId,
                Value<int?> introVersionId = const Value.absent(),
                Value<int?> characterId = const Value.absent(),
                required IntroEntryType type,
                required String content,
                Value<int> sortOrder = const Value.absent(),
              }) => IntroEntriesCompanion.insert(
                id: id,
                plotId: plotId,
                introVersionId: introVersionId,
                characterId: characterId,
                type: type,
                content: content,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntroEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({plotId = false, introVersionId = false, characterId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (plotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plotId,
                                    referencedTable:
                                        $$IntroEntriesTableReferences
                                            ._plotIdTable(db),
                                    referencedColumn:
                                        $$IntroEntriesTableReferences
                                            ._plotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (introVersionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.introVersionId,
                                    referencedTable:
                                        $$IntroEntriesTableReferences
                                            ._introVersionIdTable(db),
                                    referencedColumn:
                                        $$IntroEntriesTableReferences
                                            ._introVersionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (characterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.characterId,
                                    referencedTable:
                                        $$IntroEntriesTableReferences
                                            ._characterIdTable(db),
                                    referencedColumn:
                                        $$IntroEntriesTableReferences
                                            ._characterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$IntroEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntroEntriesTable,
      IntroEntry,
      $$IntroEntriesTableFilterComposer,
      $$IntroEntriesTableOrderingComposer,
      $$IntroEntriesTableAnnotationComposer,
      $$IntroEntriesTableCreateCompanionBuilder,
      $$IntroEntriesTableUpdateCompanionBuilder,
      (IntroEntry, $$IntroEntriesTableReferences),
      IntroEntry,
      PrefetchHooks Function({
        bool plotId,
        bool introVersionId,
        bool characterId,
      })
    >;
typedef $$ConversationProfilesTableCreateCompanionBuilder =
    ConversationProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> description,
      Value<String?> imagePath,
      Value<bool> isDefault,
    });
typedef $$ConversationProfilesTableUpdateCompanionBuilder =
    ConversationProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String?> imagePath,
      Value<bool> isDefault,
    });

final class $$ConversationProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConversationProfilesTable,
          ConversationProfile
        > {
  $$ConversationProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName:
        'conversation_profiles__id__chat_sessions__conversation_profile_id',
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager($_db, $_db.chatSessions)
        .filter(
          (f) => f.conversationProfileId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationProfilesTable> {
  $$ConversationProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.conversationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationProfilesTable> {
  $$ConversationProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationProfilesTable> {
  $$ConversationProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.conversationProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationProfilesTable,
          ConversationProfile,
          $$ConversationProfilesTableFilterComposer,
          $$ConversationProfilesTableOrderingComposer,
          $$ConversationProfilesTableAnnotationComposer,
          $$ConversationProfilesTableCreateCompanionBuilder,
          $$ConversationProfilesTableUpdateCompanionBuilder,
          (ConversationProfile, $$ConversationProfilesTableReferences),
          ConversationProfile,
          PrefetchHooks Function({bool chatSessionsRefs})
        > {
  $$ConversationProfilesTableTableManager(
    _$AppDatabase db,
    $ConversationProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConversationProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => ConversationProfilesCompanion(
                id: id,
                name: name,
                description: description,
                imagePath: imagePath,
                isDefault: isDefault,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => ConversationProfilesCompanion.insert(
                id: id,
                name: name,
                description: description,
                imagePath: imagePath,
                isDefault: isDefault,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatSessionsRefs) db.chatSessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatSessionsRefs)
                    await $_getPrefetchedData<
                      ConversationProfile,
                      $ConversationProfilesTable,
                      ChatSession
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationProfilesTableReferences
                          ._chatSessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).chatSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationProfileId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConversationProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationProfilesTable,
      ConversationProfile,
      $$ConversationProfilesTableFilterComposer,
      $$ConversationProfilesTableOrderingComposer,
      $$ConversationProfilesTableAnnotationComposer,
      $$ConversationProfilesTableCreateCompanionBuilder,
      $$ConversationProfilesTableUpdateCompanionBuilder,
      (ConversationProfile, $$ConversationProfilesTableReferences),
      ConversationProfile,
      PrefetchHooks Function({bool chatSessionsRefs})
    >;
typedef $$AiPresetsTableCreateCompanionBuilder =
    AiPresetsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> description,
      required String baseUrl,
      required String modelName,
      Value<String?> apiKeyRef,
      Value<double> temperature,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> topK,
      Value<int?> maxTokens,
      Value<int?> contextLength,
      Value<String> additionalSystemPrompt,
    });
typedef $$AiPresetsTableUpdateCompanionBuilder =
    AiPresetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String> baseUrl,
      Value<String> modelName,
      Value<String?> apiKeyRef,
      Value<double> temperature,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> topK,
      Value<int?> maxTokens,
      Value<int?> contextLength,
      Value<String> additionalSystemPrompt,
    });

final class $$AiPresetsTableReferences
    extends BaseReferences<_$AppDatabase, $AiPresetsTable, AiPreset> {
  $$AiPresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatSessionsTable, List<ChatSession>>
  _chatSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatSessions,
    aliasName: 'ai_presets__id__chat_sessions__preset_id',
  );

  $$ChatSessionsTableProcessedTableManager get chatSessionsRefs {
    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AiPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $AiPresetsTable> {
  $$AiPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKeyRef => $composableBuilder(
    column: $table.apiKeyRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topK => $composableBuilder(
    column: $table.topK,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalSystemPrompt => $composableBuilder(
    column: $table.additionalSystemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatSessionsRefs(
    Expression<bool> Function($$ChatSessionsTableFilterComposer f) f,
  ) {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiPresetsTable> {
  $$AiPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKeyRef => $composableBuilder(
    column: $table.apiKeyRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topK => $composableBuilder(
    column: $table.topK,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalSystemPrompt => $composableBuilder(
    column: $table.additionalSystemPrompt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiPresetsTable> {
  $$AiPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get apiKeyRef =>
      $composableBuilder(column: $table.apiKeyRef, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get topK =>
      $composableBuilder(column: $table.topK, builder: (column) => column);

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionalSystemPrompt => $composableBuilder(
    column: $table.additionalSystemPrompt,
    builder: (column) => column,
  );

  Expression<T> chatSessionsRefs<T extends Object>(
    Expression<T> Function($$ChatSessionsTableAnnotationComposer a) f,
  ) {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AiPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiPresetsTable,
          AiPreset,
          $$AiPresetsTableFilterComposer,
          $$AiPresetsTableOrderingComposer,
          $$AiPresetsTableAnnotationComposer,
          $$AiPresetsTableCreateCompanionBuilder,
          $$AiPresetsTableUpdateCompanionBuilder,
          (AiPreset, $$AiPresetsTableReferences),
          AiPreset,
          PrefetchHooks Function({bool chatSessionsRefs})
        > {
  $$AiPresetsTableTableManager(_$AppDatabase db, $AiPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String?> apiKeyRef = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> topK = const Value.absent(),
                Value<int?> maxTokens = const Value.absent(),
                Value<int?> contextLength = const Value.absent(),
                Value<String> additionalSystemPrompt = const Value.absent(),
              }) => AiPresetsCompanion(
                id: id,
                name: name,
                description: description,
                baseUrl: baseUrl,
                modelName: modelName,
                apiKeyRef: apiKeyRef,
                temperature: temperature,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                topK: topK,
                maxTokens: maxTokens,
                contextLength: contextLength,
                additionalSystemPrompt: additionalSystemPrompt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                required String baseUrl,
                required String modelName,
                Value<String?> apiKeyRef = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> topK = const Value.absent(),
                Value<int?> maxTokens = const Value.absent(),
                Value<int?> contextLength = const Value.absent(),
                Value<String> additionalSystemPrompt = const Value.absent(),
              }) => AiPresetsCompanion.insert(
                id: id,
                name: name,
                description: description,
                baseUrl: baseUrl,
                modelName: modelName,
                apiKeyRef: apiKeyRef,
                temperature: temperature,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
                topK: topK,
                maxTokens: maxTokens,
                contextLength: contextLength,
                additionalSystemPrompt: additionalSystemPrompt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AiPresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatSessionsRefs) db.chatSessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatSessionsRefs)
                    await $_getPrefetchedData<
                      AiPreset,
                      $AiPresetsTable,
                      ChatSession
                    >(
                      currentTable: table,
                      referencedTable: $$AiPresetsTableReferences
                          ._chatSessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AiPresetsTableReferences(
                            db,
                            table,
                            p0,
                          ).chatSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.presetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AiPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiPresetsTable,
      AiPreset,
      $$AiPresetsTableFilterComposer,
      $$AiPresetsTableOrderingComposer,
      $$AiPresetsTableAnnotationComposer,
      $$AiPresetsTableCreateCompanionBuilder,
      $$AiPresetsTableUpdateCompanionBuilder,
      (AiPreset, $$AiPresetsTableReferences),
      AiPreset,
      PrefetchHooks Function({bool chatSessionsRefs})
    >;
typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      required int plotId,
      Value<int?> conversationProfileId,
      Value<int?> presetId,
      Value<bool> pinned,
      Value<bool> locked,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<int> id,
      Value<int> plotId,
      Value<int?> conversationProfileId,
      Value<int?> presetId,
      Value<bool> pinned,
      Value<bool> locked,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
    });

final class $$ChatSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession> {
  $$ChatSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlotsTable _plotIdTable(_$AppDatabase db) =>
      db.plots.createAlias('chat_sessions__plot_id__plots__id');

  $$PlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<int>('plot_id')!;

    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConversationProfilesTable _conversationProfileIdTable(
    _$AppDatabase db,
  ) => db.conversationProfiles.createAlias(
    'chat_sessions__conversation_profile_id__conversation_profiles__id',
  );

  $$ConversationProfilesTableProcessedTableManager? get conversationProfileId {
    final $_column = $_itemColumn<int>('conversation_profile_id');
    if ($_column == null) return null;
    final manager = $$ConversationProfilesTableTableManager(
      $_db,
      $_db.conversationProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _conversationProfileIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AiPresetsTable _presetIdTable(_$AppDatabase db) =>
      db.aiPresets.createAlias('chat_sessions__preset_id__ai_presets__id');

  $$AiPresetsTableProcessedTableManager? get presetId {
    final $_column = $_itemColumn<int>('preset_id');
    if ($_column == null) return null;
    final manager = $$AiPresetsTableTableManager(
      $_db,
      $_db.aiPresets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatTurnsTable, List<ChatTurn>>
  _chatTurnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatTurns,
    aliasName: 'chat_sessions__id__chat_turns__session_id',
  );

  $$ChatTurnsTableProcessedTableManager get chatTurnsRefs {
    final manager = $$ChatTurnsTableTableManager(
      $_db,
      $_db.chatTurns,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatTurnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'chat_sessions__id__chat_messages__session_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlotsTableFilterComposer get plotId {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConversationProfilesTableFilterComposer get conversationProfileId {
    final $$ConversationProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationProfileId,
      referencedTable: $db.conversationProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationProfilesTableFilterComposer(
            $db: $db,
            $table: $db.conversationProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AiPresetsTableFilterComposer get presetId {
    final $$AiPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.aiPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiPresetsTableFilterComposer(
            $db: $db,
            $table: $db.aiPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatTurnsRefs(
    Expression<bool> Function($$ChatTurnsTableFilterComposer f) f,
  ) {
    final $$ChatTurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatTurns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatTurnsTableFilterComposer(
            $db: $db,
            $table: $db.chatTurns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlotsTableOrderingComposer get plotId {
    final $$PlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableOrderingComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConversationProfilesTableOrderingComposer get conversationProfileId {
    final $$ConversationProfilesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationProfileId,
          referencedTable: $db.conversationProfiles,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConversationProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.conversationProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AiPresetsTableOrderingComposer get presetId {
    final $$AiPresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.aiPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiPresetsTableOrderingComposer(
            $db: $db,
            $table: $db.aiPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$PlotsTableAnnotationComposer get plotId {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConversationProfilesTableAnnotationComposer get conversationProfileId {
    final $$ConversationProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationProfileId,
          referencedTable: $db.conversationProfiles,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConversationProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.conversationProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AiPresetsTableAnnotationComposer get presetId {
    final $$AiPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.aiPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AiPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.aiPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatTurnsRefs<T extends Object>(
    Expression<T> Function($$ChatTurnsTableAnnotationComposer a) f,
  ) {
    final $$ChatTurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatTurns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatTurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatTurns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (ChatSession, $$ChatSessionsTableReferences),
          ChatSession,
          PrefetchHooks Function({
            bool plotId,
            bool conversationProfileId,
            bool presetId,
            bool chatTurnsRefs,
            bool chatMessagesRefs,
          })
        > {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> plotId = const Value.absent(),
                Value<int?> conversationProfileId = const Value.absent(),
                Value<int?> presetId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                plotId: plotId,
                conversationProfileId: conversationProfileId,
                presetId: presetId,
                pinned: pinned,
                locked: locked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int plotId,
                Value<int?> conversationProfileId = const Value.absent(),
                Value<int?> presetId = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                plotId: plotId,
                conversationProfileId: conversationProfileId,
                presetId: presetId,
                pinned: pinned,
                locked: locked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                plotId = false,
                conversationProfileId = false,
                presetId = false,
                chatTurnsRefs = false,
                chatMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatTurnsRefs) db.chatTurns,
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (plotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plotId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._plotIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._plotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (conversationProfileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.conversationProfileId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._conversationProfileIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._conversationProfileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (presetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.presetId,
                                    referencedTable:
                                        $$ChatSessionsTableReferences
                                            ._presetIdTable(db),
                                    referencedColumn:
                                        $$ChatSessionsTableReferences
                                            ._presetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatTurnsRefs)
                        await $_getPrefetchedData<
                          ChatSession,
                          $ChatSessionsTable,
                          ChatTurn
                        >(
                          currentTable: table,
                          referencedTable: $$ChatSessionsTableReferences
                              ._chatTurnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatTurnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatSession,
                          $ChatSessionsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatSessionsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (ChatSession, $$ChatSessionsTableReferences),
      ChatSession,
      PrefetchHooks Function({
        bool plotId,
        bool conversationProfileId,
        bool presetId,
        bool chatTurnsRefs,
        bool chatMessagesRefs,
      })
    >;
typedef $$ChatTurnsTableCreateCompanionBuilder =
    ChatTurnsCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int> activeVersionIndex,
      Value<DateTime> createdAt,
    });
typedef $$ChatTurnsTableUpdateCompanionBuilder =
    ChatTurnsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> activeVersionIndex,
      Value<DateTime> createdAt,
    });

final class $$ChatTurnsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatTurnsTable, ChatTurn> {
  $$ChatTurnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.chatSessions.createAlias('chat_turns__session_id__chat_sessions__id');

  $$ChatSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'chat_turns__id__chat_messages__turn_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.turnId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatTurnsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeVersionIndex => $composableBuilder(
    column: $table.activeVersionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatTurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeVersionIndex => $composableBuilder(
    column: $table.activeVersionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatTurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatTurnsTable> {
  $$ChatTurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get activeVersionIndex => $composableBuilder(
    column: $table.activeVersionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChatSessionsTableAnnotationComposer get sessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatTurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatTurnsTable,
          ChatTurn,
          $$ChatTurnsTableFilterComposer,
          $$ChatTurnsTableOrderingComposer,
          $$ChatTurnsTableAnnotationComposer,
          $$ChatTurnsTableCreateCompanionBuilder,
          $$ChatTurnsTableUpdateCompanionBuilder,
          (ChatTurn, $$ChatTurnsTableReferences),
          ChatTurn,
          PrefetchHooks Function({bool sessionId, bool chatMessagesRefs})
        > {
  $$ChatTurnsTableTableManager(_$AppDatabase db, $ChatTurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatTurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatTurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatTurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> activeVersionIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatTurnsCompanion(
                id: id,
                sessionId: sessionId,
                activeVersionIndex: activeVersionIndex,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int> activeVersionIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatTurnsCompanion.insert(
                id: id,
                sessionId: sessionId,
                activeVersionIndex: activeVersionIndex,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatTurnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, chatMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable: $$ChatTurnsTableReferences
                                        ._sessionIdTable(db),
                                    referencedColumn: $$ChatTurnsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatTurn,
                          $ChatTurnsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatTurnsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatTurnsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.turnId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatTurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatTurnsTable,
      ChatTurn,
      $$ChatTurnsTableFilterComposer,
      $$ChatTurnsTableOrderingComposer,
      $$ChatTurnsTableAnnotationComposer,
      $$ChatTurnsTableCreateCompanionBuilder,
      $$ChatTurnsTableUpdateCompanionBuilder,
      (ChatTurn, $$ChatTurnsTableReferences),
      ChatTurn,
      PrefetchHooks Function({bool sessionId, bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required int sessionId,
      required MessageSender senderType,
      Value<int?> characterId,
      required String content,
      Value<DateTime> createdAt,
      Value<String?> speakerNameOverride,
      Value<int?> turnId,
      Value<int> versionIndex,
      Value<int> turnSortOrder,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<MessageSender> senderType,
      Value<int?> characterId,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<String?> speakerNameOverride,
      Value<int?> turnId,
      Value<int> versionIndex,
      Value<int> turnSortOrder,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _sessionIdTable(_$AppDatabase db) => db.chatSessions
      .createAlias('chat_messages__session_id__chat_sessions__id');

  $$ChatSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CharactersTable _characterIdTable(_$AppDatabase db) =>
      db.characters.createAlias('chat_messages__character_id__characters__id');

  $$CharactersTableProcessedTableManager? get characterId {
    final $_column = $_itemColumn<int>('character_id');
    if ($_column == null) return null;
    final manager = $$CharactersTableTableManager(
      $_db,
      $_db.characters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_characterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChatTurnsTable _turnIdTable(_$AppDatabase db) =>
      db.chatTurns.createAlias('chat_messages__turn_id__chat_turns__id');

  $$ChatTurnsTableProcessedTableManager? get turnId {
    final $_column = $_itemColumn<int>('turn_id');
    if ($_column == null) return null;
    final manager = $$ChatTurnsTableTableManager(
      $_db,
      $_db.chatTurns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_turnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageSender, MessageSender, int>
  get senderType => $composableBuilder(
    column: $table.senderType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speakerNameOverride => $composableBuilder(
    column: $table.speakerNameOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get turnSortOrder => $composableBuilder(
    column: $table.turnSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableFilterComposer get characterId {
    final $$CharactersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableFilterComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatTurnsTableFilterComposer get turnId {
    final $$ChatTurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.chatTurns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatTurnsTableFilterComposer(
            $db: $db,
            $table: $db.chatTurns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderType => $composableBuilder(
    column: $table.senderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speakerNameOverride => $composableBuilder(
    column: $table.speakerNameOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get turnSortOrder => $composableBuilder(
    column: $table.turnSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableOrderingComposer get characterId {
    final $$CharactersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableOrderingComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatTurnsTableOrderingComposer get turnId {
    final $$ChatTurnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.chatTurns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatTurnsTableOrderingComposer(
            $db: $db,
            $table: $db.chatTurns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageSender, int> get senderType =>
      $composableBuilder(
        column: $table.senderType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get speakerNameOverride => $composableBuilder(
    column: $table.speakerNameOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versionIndex => $composableBuilder(
    column: $table.versionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get turnSortOrder => $composableBuilder(
    column: $table.turnSortOrder,
    builder: (column) => column,
  );

  $$ChatSessionsTableAnnotationComposer get sessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CharactersTableAnnotationComposer get characterId {
    final $$CharactersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.characterId,
      referencedTable: $db.characters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CharactersTableAnnotationComposer(
            $db: $db,
            $table: $db.characters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatTurnsTableAnnotationComposer get turnId {
    final $$ChatTurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.chatTurns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatTurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatTurns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({
            bool sessionId,
            bool characterId,
            bool turnId,
          })
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<MessageSender> senderType = const Value.absent(),
                Value<int?> characterId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> speakerNameOverride = const Value.absent(),
                Value<int?> turnId = const Value.absent(),
                Value<int> versionIndex = const Value.absent(),
                Value<int> turnSortOrder = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                senderType: senderType,
                characterId: characterId,
                content: content,
                createdAt: createdAt,
                speakerNameOverride: speakerNameOverride,
                turnId: turnId,
                versionIndex: versionIndex,
                turnSortOrder: turnSortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required MessageSender senderType,
                Value<int?> characterId = const Value.absent(),
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> speakerNameOverride = const Value.absent(),
                Value<int?> turnId = const Value.absent(),
                Value<int> versionIndex = const Value.absent(),
                Value<int> turnSortOrder = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                senderType: senderType,
                characterId: characterId,
                content: content,
                createdAt: createdAt,
                speakerNameOverride: speakerNameOverride,
                turnId: turnId,
                versionIndex: versionIndex,
                turnSortOrder: turnSortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, characterId = false, turnId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$ChatMessagesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$ChatMessagesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (characterId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.characterId,
                                    referencedTable:
                                        $$ChatMessagesTableReferences
                                            ._characterIdTable(db),
                                    referencedColumn:
                                        $$ChatMessagesTableReferences
                                            ._characterIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (turnId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.turnId,
                                    referencedTable:
                                        $$ChatMessagesTableReferences
                                            ._turnIdTable(db),
                                    referencedColumn:
                                        $$ChatMessagesTableReferences
                                            ._turnIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool sessionId, bool characterId, bool turnId})
    >;
typedef $$TokenUsageLogsTableCreateCompanionBuilder =
    TokenUsageLogsCompanion Function({
      Value<int> id,
      required String presetName,
      required String baseUrl,
      required String modelName,
      Value<int> promptTokens,
      Value<int> completionTokens,
      Value<double?> costUsd,
      Value<DateTime> createdAt,
    });
typedef $$TokenUsageLogsTableUpdateCompanionBuilder =
    TokenUsageLogsCompanion Function({
      Value<int> id,
      Value<String> presetName,
      Value<String> baseUrl,
      Value<String> modelName,
      Value<int> promptTokens,
      Value<int> completionTokens,
      Value<double?> costUsd,
      Value<DateTime> createdAt,
    });

class $$TokenUsageLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TokenUsageLogsTable> {
  $$TokenUsageLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetName => $composableBuilder(
    column: $table.presetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TokenUsageLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TokenUsageLogsTable> {
  $$TokenUsageLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetName => $composableBuilder(
    column: $table.presetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TokenUsageLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokenUsageLogsTable> {
  $$TokenUsageLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get presetName => $composableBuilder(
    column: $table.presetName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costUsd =>
      $composableBuilder(column: $table.costUsd, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TokenUsageLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokenUsageLogsTable,
          TokenUsageLog,
          $$TokenUsageLogsTableFilterComposer,
          $$TokenUsageLogsTableOrderingComposer,
          $$TokenUsageLogsTableAnnotationComposer,
          $$TokenUsageLogsTableCreateCompanionBuilder,
          $$TokenUsageLogsTableUpdateCompanionBuilder,
          (
            TokenUsageLog,
            BaseReferences<_$AppDatabase, $TokenUsageLogsTable, TokenUsageLog>,
          ),
          TokenUsageLog,
          PrefetchHooks Function()
        > {
  $$TokenUsageLogsTableTableManager(
    _$AppDatabase db,
    $TokenUsageLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenUsageLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenUsageLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenUsageLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> presetName = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<int> promptTokens = const Value.absent(),
                Value<int> completionTokens = const Value.absent(),
                Value<double?> costUsd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TokenUsageLogsCompanion(
                id: id,
                presetName: presetName,
                baseUrl: baseUrl,
                modelName: modelName,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                costUsd: costUsd,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String presetName,
                required String baseUrl,
                required String modelName,
                Value<int> promptTokens = const Value.absent(),
                Value<int> completionTokens = const Value.absent(),
                Value<double?> costUsd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TokenUsageLogsCompanion.insert(
                id: id,
                presetName: presetName,
                baseUrl: baseUrl,
                modelName: modelName,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                costUsd: costUsd,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TokenUsageLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokenUsageLogsTable,
      TokenUsageLog,
      $$TokenUsageLogsTableFilterComposer,
      $$TokenUsageLogsTableOrderingComposer,
      $$TokenUsageLogsTableAnnotationComposer,
      $$TokenUsageLogsTableCreateCompanionBuilder,
      $$TokenUsageLogsTableUpdateCompanionBuilder,
      (
        TokenUsageLog,
        BaseReferences<_$AppDatabase, $TokenUsageLogsTable, TokenUsageLog>,
      ),
      TokenUsageLog,
      PrefetchHooks Function()
    >;
typedef $$LorebooksTableCreateCompanionBuilder =
    LorebooksCompanion Function({
      Value<int> id,
      required String title,
      Value<String> shortIntro,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LorebooksTableUpdateCompanionBuilder =
    LorebooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> shortIntro,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$LorebooksTableReferences
    extends BaseReferences<_$AppDatabase, $LorebooksTable, Lorebook> {
  $$LorebooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LorebookEntriesTable, List<LorebookEntry>>
  _lorebookEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lorebookEntries,
    aliasName: 'lorebooks__id__lorebook_entries__lorebook_id',
  );

  $$LorebookEntriesTableProcessedTableManager get lorebookEntriesRefs {
    final manager = $$LorebookEntriesTableTableManager(
      $_db,
      $_db.lorebookEntries,
    ).filter((f) => f.lorebookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lorebookEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LorebookPlotLinksTable, List<LorebookPlotLink>>
  _lorebookPlotLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lorebookPlotLinks,
        aliasName: 'lorebooks__id__lorebook_plot_links__lorebook_id',
      );

  $$LorebookPlotLinksTableProcessedTableManager get lorebookPlotLinksRefs {
    final manager = $$LorebookPlotLinksTableTableManager(
      $_db,
      $_db.lorebookPlotLinks,
    ).filter((f) => f.lorebookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lorebookPlotLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LorebooksTableFilterComposer
    extends Composer<_$AppDatabase, $LorebooksTable> {
  $$LorebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lorebookEntriesRefs(
    Expression<bool> Function($$LorebookEntriesTableFilterComposer f) f,
  ) {
    final $$LorebookEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lorebookEntries,
      getReferencedColumn: (t) => t.lorebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebookEntriesTableFilterComposer(
            $db: $db,
            $table: $db.lorebookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lorebookPlotLinksRefs(
    Expression<bool> Function($$LorebookPlotLinksTableFilterComposer f) f,
  ) {
    final $$LorebookPlotLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lorebookPlotLinks,
      getReferencedColumn: (t) => t.lorebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebookPlotLinksTableFilterComposer(
            $db: $db,
            $table: $db.lorebookPlotLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LorebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $LorebooksTable> {
  $$LorebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LorebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LorebooksTable> {
  $$LorebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get shortIntro => $composableBuilder(
    column: $table.shortIntro,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> lorebookEntriesRefs<T extends Object>(
    Expression<T> Function($$LorebookEntriesTableAnnotationComposer a) f,
  ) {
    final $$LorebookEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lorebookEntries,
      getReferencedColumn: (t) => t.lorebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebookEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.lorebookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lorebookPlotLinksRefs<T extends Object>(
    Expression<T> Function($$LorebookPlotLinksTableAnnotationComposer a) f,
  ) {
    final $$LorebookPlotLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lorebookPlotLinks,
          getReferencedColumn: (t) => t.lorebookId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LorebookPlotLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.lorebookPlotLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LorebooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LorebooksTable,
          Lorebook,
          $$LorebooksTableFilterComposer,
          $$LorebooksTableOrderingComposer,
          $$LorebooksTableAnnotationComposer,
          $$LorebooksTableCreateCompanionBuilder,
          $$LorebooksTableUpdateCompanionBuilder,
          (Lorebook, $$LorebooksTableReferences),
          Lorebook,
          PrefetchHooks Function({
            bool lorebookEntriesRefs,
            bool lorebookPlotLinksRefs,
          })
        > {
  $$LorebooksTableTableManager(_$AppDatabase db, $LorebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LorebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LorebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LorebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> shortIntro = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LorebooksCompanion(
                id: id,
                title: title,
                shortIntro: shortIntro,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> shortIntro = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LorebooksCompanion.insert(
                id: id,
                title: title,
                shortIntro: shortIntro,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LorebooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lorebookEntriesRefs = false, lorebookPlotLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lorebookEntriesRefs) db.lorebookEntries,
                    if (lorebookPlotLinksRefs) db.lorebookPlotLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lorebookEntriesRefs)
                        await $_getPrefetchedData<
                          Lorebook,
                          $LorebooksTable,
                          LorebookEntry
                        >(
                          currentTable: table,
                          referencedTable: $$LorebooksTableReferences
                              ._lorebookEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LorebooksTableReferences(
                                db,
                                table,
                                p0,
                              ).lorebookEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lorebookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lorebookPlotLinksRefs)
                        await $_getPrefetchedData<
                          Lorebook,
                          $LorebooksTable,
                          LorebookPlotLink
                        >(
                          currentTable: table,
                          referencedTable: $$LorebooksTableReferences
                              ._lorebookPlotLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LorebooksTableReferences(
                                db,
                                table,
                                p0,
                              ).lorebookPlotLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lorebookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LorebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LorebooksTable,
      Lorebook,
      $$LorebooksTableFilterComposer,
      $$LorebooksTableOrderingComposer,
      $$LorebooksTableAnnotationComposer,
      $$LorebooksTableCreateCompanionBuilder,
      $$LorebooksTableUpdateCompanionBuilder,
      (Lorebook, $$LorebooksTableReferences),
      Lorebook,
      PrefetchHooks Function({
        bool lorebookEntriesRefs,
        bool lorebookPlotLinksRefs,
      })
    >;
typedef $$LorebookEntriesTableCreateCompanionBuilder =
    LorebookEntriesCompanion Function({
      Value<int> id,
      required int lorebookId,
      Value<String> title,
      Value<String> keywords,
      Value<String> content,
      Value<int> sortOrder,
    });
typedef $$LorebookEntriesTableUpdateCompanionBuilder =
    LorebookEntriesCompanion Function({
      Value<int> id,
      Value<int> lorebookId,
      Value<String> title,
      Value<String> keywords,
      Value<String> content,
      Value<int> sortOrder,
    });

final class $$LorebookEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $LorebookEntriesTable, LorebookEntry> {
  $$LorebookEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LorebooksTable _lorebookIdTable(_$AppDatabase db) =>
      db.lorebooks.createAlias('lorebook_entries__lorebook_id__lorebooks__id');

  $$LorebooksTableProcessedTableManager get lorebookId {
    final $_column = $_itemColumn<int>('lorebook_id')!;

    final manager = $$LorebooksTableTableManager(
      $_db,
      $_db.lorebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lorebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LorebookEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LorebookEntriesTable> {
  $$LorebookEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$LorebooksTableFilterComposer get lorebookId {
    final $$LorebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableFilterComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LorebookEntriesTable> {
  $$LorebookEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$LorebooksTableOrderingComposer get lorebookId {
    final $$LorebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableOrderingComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LorebookEntriesTable> {
  $$LorebookEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$LorebooksTableAnnotationComposer get lorebookId {
    final $$LorebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LorebookEntriesTable,
          LorebookEntry,
          $$LorebookEntriesTableFilterComposer,
          $$LorebookEntriesTableOrderingComposer,
          $$LorebookEntriesTableAnnotationComposer,
          $$LorebookEntriesTableCreateCompanionBuilder,
          $$LorebookEntriesTableUpdateCompanionBuilder,
          (LorebookEntry, $$LorebookEntriesTableReferences),
          LorebookEntry,
          PrefetchHooks Function({bool lorebookId})
        > {
  $$LorebookEntriesTableTableManager(
    _$AppDatabase db,
    $LorebookEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LorebookEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LorebookEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LorebookEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lorebookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LorebookEntriesCompanion(
                id: id,
                lorebookId: lorebookId,
                title: title,
                keywords: keywords,
                content: content,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lorebookId,
                Value<String> title = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LorebookEntriesCompanion.insert(
                id: id,
                lorebookId: lorebookId,
                title: title,
                keywords: keywords,
                content: content,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LorebookEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lorebookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lorebookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lorebookId,
                                referencedTable:
                                    $$LorebookEntriesTableReferences
                                        ._lorebookIdTable(db),
                                referencedColumn:
                                    $$LorebookEntriesTableReferences
                                        ._lorebookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LorebookEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LorebookEntriesTable,
      LorebookEntry,
      $$LorebookEntriesTableFilterComposer,
      $$LorebookEntriesTableOrderingComposer,
      $$LorebookEntriesTableAnnotationComposer,
      $$LorebookEntriesTableCreateCompanionBuilder,
      $$LorebookEntriesTableUpdateCompanionBuilder,
      (LorebookEntry, $$LorebookEntriesTableReferences),
      LorebookEntry,
      PrefetchHooks Function({bool lorebookId})
    >;
typedef $$LorebookPlotLinksTableCreateCompanionBuilder =
    LorebookPlotLinksCompanion Function({
      Value<int> id,
      required int lorebookId,
      required int plotId,
    });
typedef $$LorebookPlotLinksTableUpdateCompanionBuilder =
    LorebookPlotLinksCompanion Function({
      Value<int> id,
      Value<int> lorebookId,
      Value<int> plotId,
    });

final class $$LorebookPlotLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LorebookPlotLinksTable,
          LorebookPlotLink
        > {
  $$LorebookPlotLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LorebooksTable _lorebookIdTable(_$AppDatabase db) => db.lorebooks
      .createAlias('lorebook_plot_links__lorebook_id__lorebooks__id');

  $$LorebooksTableProcessedTableManager get lorebookId {
    final $_column = $_itemColumn<int>('lorebook_id')!;

    final manager = $$LorebooksTableTableManager(
      $_db,
      $_db.lorebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lorebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlotsTable _plotIdTable(_$AppDatabase db) =>
      db.plots.createAlias('lorebook_plot_links__plot_id__plots__id');

  $$PlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<int>('plot_id')!;

    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LorebookPlotLinksTableFilterComposer
    extends Composer<_$AppDatabase, $LorebookPlotLinksTable> {
  $$LorebookPlotLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$LorebooksTableFilterComposer get lorebookId {
    final $$LorebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableFilterComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlotsTableFilterComposer get plotId {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookPlotLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LorebookPlotLinksTable> {
  $$LorebookPlotLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$LorebooksTableOrderingComposer get lorebookId {
    final $$LorebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableOrderingComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlotsTableOrderingComposer get plotId {
    final $$PlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableOrderingComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookPlotLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LorebookPlotLinksTable> {
  $$LorebookPlotLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$LorebooksTableAnnotationComposer get lorebookId {
    final $$LorebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lorebookId,
      referencedTable: $db.lorebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LorebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.lorebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlotsTableAnnotationComposer get plotId {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LorebookPlotLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LorebookPlotLinksTable,
          LorebookPlotLink,
          $$LorebookPlotLinksTableFilterComposer,
          $$LorebookPlotLinksTableOrderingComposer,
          $$LorebookPlotLinksTableAnnotationComposer,
          $$LorebookPlotLinksTableCreateCompanionBuilder,
          $$LorebookPlotLinksTableUpdateCompanionBuilder,
          (LorebookPlotLink, $$LorebookPlotLinksTableReferences),
          LorebookPlotLink,
          PrefetchHooks Function({bool lorebookId, bool plotId})
        > {
  $$LorebookPlotLinksTableTableManager(
    _$AppDatabase db,
    $LorebookPlotLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LorebookPlotLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LorebookPlotLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LorebookPlotLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lorebookId = const Value.absent(),
                Value<int> plotId = const Value.absent(),
              }) => LorebookPlotLinksCompanion(
                id: id,
                lorebookId: lorebookId,
                plotId: plotId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lorebookId,
                required int plotId,
              }) => LorebookPlotLinksCompanion.insert(
                id: id,
                lorebookId: lorebookId,
                plotId: plotId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LorebookPlotLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lorebookId = false, plotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lorebookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lorebookId,
                                referencedTable:
                                    $$LorebookPlotLinksTableReferences
                                        ._lorebookIdTable(db),
                                referencedColumn:
                                    $$LorebookPlotLinksTableReferences
                                        ._lorebookIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (plotId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plotId,
                                referencedTable:
                                    $$LorebookPlotLinksTableReferences
                                        ._plotIdTable(db),
                                referencedColumn:
                                    $$LorebookPlotLinksTableReferences
                                        ._plotIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LorebookPlotLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LorebookPlotLinksTable,
      LorebookPlotLink,
      $$LorebookPlotLinksTableFilterComposer,
      $$LorebookPlotLinksTableOrderingComposer,
      $$LorebookPlotLinksTableAnnotationComposer,
      $$LorebookPlotLinksTableCreateCompanionBuilder,
      $$LorebookPlotLinksTableUpdateCompanionBuilder,
      (LorebookPlotLink, $$LorebookPlotLinksTableReferences),
      LorebookPlotLink,
      PrefetchHooks Function({bool lorebookId, bool plotId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlotsTableTableManager get plots =>
      $$PlotsTableTableManager(_db, _db.plots);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
  $$IntroVersionsTableTableManager get introVersions =>
      $$IntroVersionsTableTableManager(_db, _db.introVersions);
  $$IntroEntriesTableTableManager get introEntries =>
      $$IntroEntriesTableTableManager(_db, _db.introEntries);
  $$ConversationProfilesTableTableManager get conversationProfiles =>
      $$ConversationProfilesTableTableManager(_db, _db.conversationProfiles);
  $$AiPresetsTableTableManager get aiPresets =>
      $$AiPresetsTableTableManager(_db, _db.aiPresets);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatTurnsTableTableManager get chatTurns =>
      $$ChatTurnsTableTableManager(_db, _db.chatTurns);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$TokenUsageLogsTableTableManager get tokenUsageLogs =>
      $$TokenUsageLogsTableTableManager(_db, _db.tokenUsageLogs);
  $$LorebooksTableTableManager get lorebooks =>
      $$LorebooksTableTableManager(_db, _db.lorebooks);
  $$LorebookEntriesTableTableManager get lorebookEntries =>
      $$LorebookEntriesTableTableManager(_db, _db.lorebookEntries);
  $$LorebookPlotLinksTableTableManager get lorebookPlotLinks =>
      $$LorebookPlotLinksTableTableManager(_db, _db.lorebookPlotLinks);
}
