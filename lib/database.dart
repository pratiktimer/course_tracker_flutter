import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'models.dart';
part 'database.g.dart';

/// Drift tables (DB entities)
class CourseEntity extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get thumbnailPath => text().nullable()(); // new column
  @override
  Set<Column> get primaryKey => {id};
}

class VideoEntity extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get path => text()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  TextColumn get thumbnailPath => text().nullable()(); // new column
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CourseEntity, VideoEntity])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(
    NativeDatabase(File('${Directory.current.path}/course_db.sqlite')),
  );

  /// Increment schemaVersion whenever you change table definitions
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Safely add thumbnailPath columns if not already present
        try {
          await m.addColumn(videoEntity, videoEntity.thumbnailPath);
        } catch (_) {
          print('video_entity.thumbnailPath already exists');
        }

        try {
          await m.addColumn(courseEntity, courseEntity.thumbnailPath);
        } catch (_) {
          print('course_entity.thumbnailPath already exists');
        }
      }
    },
  );

  /// Insert course and videos
  Future<void> insertCourseAndVideos(CourseModel course) async {
    await into(courseEntity).insert(
      CourseEntityCompanion(
        id: Value(course.id),
        name: Value(course.name),
        thumbnailPath: Value(course.thumbnailPath),
      ),
      mode: InsertMode.insertOrReplace,
    );

    for (var v in course.videos) {
      await into(videoEntity).insert(
        VideoEntityCompanion(
          id: Value(v.id),
          courseId: Value(course.id),
          path: Value(v.path),
          isComplete: Value(v.isComplete),
          thumbnailPath: Value(v.thumbnailPath),
        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  }

  /// Fetch all courses with videos
  Future<List<CourseModel>> getAllCoursesWithVideos() async {
    final coursesList = await select(courseEntity).get();
    List<CourseModel> result = [];

    // Natural sort function
    int naturalCompare(String a, String b) {
      final regex = RegExp(r'(\d+)|(\D+)');
      final aParts = regex.allMatches(a).map((m) => m[0]!).toList();
      final bParts = regex.allMatches(b).map((m) => m[0]!).toList();

      final len = aParts.length < bParts.length ? aParts.length : bParts.length;

      for (var i = 0; i < len; i++) {
        final aPart = aParts[i];
        final bPart = bParts[i];

        final aNum = int.tryParse(aPart);
        final bNum = int.tryParse(bPart);

        if (aNum != null && bNum != null) {
          final cmp = aNum.compareTo(bNum);
          if (cmp != 0) return cmp;
        } else {
          final cmp = aPart.toLowerCase().compareTo(bPart.toLowerCase());
          if (cmp != 0) return cmp;
        }
      }

      return aParts.length.compareTo(bParts.length);
    }

    for (var c in coursesList) {
      final videosList = await (select(videoEntity)
        ..where((tbl) => tbl.courseId.equals(c.id)))
          .get();

      // Sort videos naturally by filename using Uri
      videosList.sort((a, b) => naturalCompare(
        Uri.file(a.path).pathSegments.last,
        Uri.file(b.path).pathSegments.last,
      ));

      result.add(CourseModel(
        id: c.id,
        name: c.name,
        thumbnailPath: c.thumbnailPath,
        videos: videosList.map((v) => VideoModel(
          id: v.id,
          path: v.path,
          isComplete: v.isComplete,
          thumbnailPath: v.thumbnailPath,
        )).toList(),
      ));
    }

    // Sort courses naturally by name
    result.sort((a, b) => naturalCompare(a.name, b.name));

    return result;
  }


  /// Update video completion
  Future<void> updateVideoStatus(String videoId, bool isComplete) async {
    await (update(videoEntity)
      ..where((tbl) => tbl.id.equals(videoId)))
        .write(VideoEntityCompanion(isComplete: Value(isComplete)));
  }

  /// Update video thumbnail
  Future<void> updateVideoThumbnail(String videoId, String? thumb) async {
    await (update(videoEntity)
      ..where((tbl) => tbl.id.equals(videoId)))
        .write(VideoEntityCompanion(thumbnailPath: Value(thumb)));
  }
  Future<void> updateCourseThumbnail(String courseId, String? thumb) async {
    await (update(courseEntity)..where((tbl) => tbl.id.equals(courseId))).write(
      CourseEntityCompanion(thumbnailPath: Value(thumb)),
    );
  }

  /// Delete all courses and videos
  Future<void> deleteAllCoursesAndVideos() async {
    await batch((batch) {
      batch.deleteAll(videoEntity);
      batch.deleteAll(courseEntity);
    });
  }
}
