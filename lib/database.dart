import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'models.dart';
part 'database.g.dart';

/// Drift tables (DB entities)
class CourseEntity extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get thumbnailPath => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class VideoEntity extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get path => text()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CourseEntity, VideoEntity])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase(File('${Directory.current.path}/course_db.sqlite')));

  @override
  int get schemaVersion => 1;

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

        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  }

  /// Fetch all courses with videos
  Future<List<CourseModel>> getAllCoursesWithVideos() async {
    final coursesList = await select(courseEntity).get();
    List<CourseModel> result = [];

    for (var c in coursesList) {
      final videosList = await (select(videoEntity)..where((tbl) => tbl.courseId.equals(c.id))).get();
      result.add(CourseModel(
        id: c.id,
        name: c.name,
        thumbnailPath: c.thumbnailPath,
        videos: videosList.map((v) => VideoModel(id: v.id, path: v.path, isComplete: v.isComplete)).toList(),
      ));
    }
    return result;
  }

  /// Update video completion
  Future<void> updateVideoStatus(String videoId, bool isComplete) async {
    await (update(videoEntity)..where((tbl) => tbl.id.equals(videoId))).write(
      VideoEntityCompanion(isComplete: Value(isComplete)),
    );
  }
  Future<void> deleteAllCoursesAndVideos() async {
    await batch((batch) {
      batch.deleteAll(videoEntity);
      batch.deleteAll(courseEntity);
    });
  }

}
