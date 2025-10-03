// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CourseEntityTable extends CourseEntity
    with TableInfo<$CourseEntityTable, CourseEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, thumbnailPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseEntityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
    );
  }

  @override
  $CourseEntityTable createAlias(String alias) {
    return $CourseEntityTable(attachedDatabase, alias);
  }
}

class CourseEntityData extends DataClass
    implements Insertable<CourseEntityData> {
  final String id;
  final String name;
  final String? thumbnailPath;
  const CourseEntityData({
    required this.id,
    required this.name,
    this.thumbnailPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  CourseEntityCompanion toCompanion(bool nullToAbsent) {
    return CourseEntityCompanion(
      id: Value(id),
      name: Value(name),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory CourseEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseEntityData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  CourseEntityData copyWith({
    String? id,
    String? name,
    Value<String?> thumbnailPath = const Value.absent(),
  }) => CourseEntityData(
    id: id ?? this.id,
    name: name ?? this.name,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
  );
  CourseEntityData copyWithCompanion(CourseEntityCompanion data) {
    return CourseEntityData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseEntityData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, thumbnailPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseEntityData &&
          other.id == this.id &&
          other.name == this.name &&
          other.thumbnailPath == this.thumbnailPath);
}

class CourseEntityCompanion extends UpdateCompanion<CourseEntityData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> thumbnailPath;
  final Value<int> rowid;
  const CourseEntityCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseEntityCompanion.insert({
    required String id,
    required String name,
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CourseEntityData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseEntityCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? thumbnailPath,
    Value<int>? rowid,
  }) {
    return CourseEntityCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseEntityCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VideoEntityTable extends VideoEntity
    with TableInfo<$VideoEntityTable, VideoEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    path,
    isComplete,
    thumbnailPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoEntityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
    );
  }

  @override
  $VideoEntityTable createAlias(String alias) {
    return $VideoEntityTable(attachedDatabase, alias);
  }
}

class VideoEntityData extends DataClass implements Insertable<VideoEntityData> {
  final String id;
  final String courseId;
  final String path;
  final bool isComplete;
  final String? thumbnailPath;
  const VideoEntityData({
    required this.id,
    required this.courseId,
    required this.path,
    required this.isComplete,
    this.thumbnailPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['path'] = Variable<String>(path);
    map['is_complete'] = Variable<bool>(isComplete);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  VideoEntityCompanion toCompanion(bool nullToAbsent) {
    return VideoEntityCompanion(
      id: Value(id),
      courseId: Value(courseId),
      path: Value(path),
      isComplete: Value(isComplete),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory VideoEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoEntityData(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      path: serializer.fromJson<String>(json['path']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'path': serializer.toJson<String>(path),
      'isComplete': serializer.toJson<bool>(isComplete),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  VideoEntityData copyWith({
    String? id,
    String? courseId,
    String? path,
    bool? isComplete,
    Value<String?> thumbnailPath = const Value.absent(),
  }) => VideoEntityData(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    path: path ?? this.path,
    isComplete: isComplete ?? this.isComplete,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
  );
  VideoEntityData copyWithCompanion(VideoEntityCompanion data) {
    return VideoEntityData(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      path: data.path.present ? data.path.value : this.path,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoEntityData(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('path: $path, ')
          ..write('isComplete: $isComplete, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, courseId, path, isComplete, thumbnailPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoEntityData &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.path == this.path &&
          other.isComplete == this.isComplete &&
          other.thumbnailPath == this.thumbnailPath);
}

class VideoEntityCompanion extends UpdateCompanion<VideoEntityData> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> path;
  final Value<bool> isComplete;
  final Value<String?> thumbnailPath;
  final Value<int> rowid;
  const VideoEntityCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.path = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoEntityCompanion.insert({
    required String id,
    required String courseId,
    required String path,
    this.isComplete = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       path = Value(path);
  static Insertable<VideoEntityData> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? path,
    Expression<bool>? isComplete,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (path != null) 'path': path,
      if (isComplete != null) 'is_complete': isComplete,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoEntityCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? path,
    Value<bool>? isComplete,
    Value<String?>? thumbnailPath,
    Value<int>? rowid,
  }) {
    return VideoEntityCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      path: path ?? this.path,
      isComplete: isComplete ?? this.isComplete,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoEntityCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('path: $path, ')
          ..write('isComplete: $isComplete, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CourseEntityTable courseEntity = $CourseEntityTable(this);
  late final $VideoEntityTable videoEntity = $VideoEntityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courseEntity,
    videoEntity,
  ];
}

typedef $$CourseEntityTableCreateCompanionBuilder =
    CourseEntityCompanion Function({
      required String id,
      required String name,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });
typedef $$CourseEntityTableUpdateCompanionBuilder =
    CourseEntityCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });

class $$CourseEntityTableFilterComposer
    extends Composer<_$AppDatabase, $CourseEntityTable> {
  $$CourseEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CourseEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseEntityTable> {
  $$CourseEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseEntityTable> {
  $$CourseEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );
}

class $$CourseEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseEntityTable,
          CourseEntityData,
          $$CourseEntityTableFilterComposer,
          $$CourseEntityTableOrderingComposer,
          $$CourseEntityTableAnnotationComposer,
          $$CourseEntityTableCreateCompanionBuilder,
          $$CourseEntityTableUpdateCompanionBuilder,
          (
            CourseEntityData,
            BaseReferences<_$AppDatabase, $CourseEntityTable, CourseEntityData>,
          ),
          CourseEntityData,
          PrefetchHooks Function()
        > {
  $$CourseEntityTableTableManager(_$AppDatabase db, $CourseEntityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseEntityCompanion(
                id: id,
                name: name,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseEntityCompanion.insert(
                id: id,
                name: name,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CourseEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseEntityTable,
      CourseEntityData,
      $$CourseEntityTableFilterComposer,
      $$CourseEntityTableOrderingComposer,
      $$CourseEntityTableAnnotationComposer,
      $$CourseEntityTableCreateCompanionBuilder,
      $$CourseEntityTableUpdateCompanionBuilder,
      (
        CourseEntityData,
        BaseReferences<_$AppDatabase, $CourseEntityTable, CourseEntityData>,
      ),
      CourseEntityData,
      PrefetchHooks Function()
    >;
typedef $$VideoEntityTableCreateCompanionBuilder =
    VideoEntityCompanion Function({
      required String id,
      required String courseId,
      required String path,
      Value<bool> isComplete,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });
typedef $$VideoEntityTableUpdateCompanionBuilder =
    VideoEntityCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> path,
      Value<bool> isComplete,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });

class $$VideoEntityTableFilterComposer
    extends Composer<_$AppDatabase, $VideoEntityTable> {
  $$VideoEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideoEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoEntityTable> {
  $$VideoEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoEntityTable> {
  $$VideoEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );
}

class $$VideoEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoEntityTable,
          VideoEntityData,
          $$VideoEntityTableFilterComposer,
          $$VideoEntityTableOrderingComposer,
          $$VideoEntityTableAnnotationComposer,
          $$VideoEntityTableCreateCompanionBuilder,
          $$VideoEntityTableUpdateCompanionBuilder,
          (
            VideoEntityData,
            BaseReferences<_$AppDatabase, $VideoEntityTable, VideoEntityData>,
          ),
          VideoEntityData,
          PrefetchHooks Function()
        > {
  $$VideoEntityTableTableManager(_$AppDatabase db, $VideoEntityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoEntityCompanion(
                id: id,
                courseId: courseId,
                path: path,
                isComplete: isComplete,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String path,
                Value<bool> isComplete = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoEntityCompanion.insert(
                id: id,
                courseId: courseId,
                path: path,
                isComplete: isComplete,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideoEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoEntityTable,
      VideoEntityData,
      $$VideoEntityTableFilterComposer,
      $$VideoEntityTableOrderingComposer,
      $$VideoEntityTableAnnotationComposer,
      $$VideoEntityTableCreateCompanionBuilder,
      $$VideoEntityTableUpdateCompanionBuilder,
      (
        VideoEntityData,
        BaseReferences<_$AppDatabase, $VideoEntityTable, VideoEntityData>,
      ),
      VideoEntityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CourseEntityTableTableManager get courseEntity =>
      $$CourseEntityTableTableManager(_db, _db.courseEntity);
  $$VideoEntityTableTableManager get videoEntity =>
      $$VideoEntityTableTableManager(_db, _db.videoEntity);
}
