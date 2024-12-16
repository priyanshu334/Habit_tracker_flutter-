import 'package:flutter/material.dart';
import 'package:habit_tracker/model/app_settings.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  static bool _initialized = false;

  /// Initialize the Isar database
  static Future<void> initialize() async {
    if (_initialized) return; // Prevent reinitialization
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
    _initialized = true;
  }

  /// Save the first launch date if not already saved
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() async {
        await isar.appSettings.put(settings);
      });
    }
  }

  /// Get the first launch date
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  final List<Habit> currentHabits = [];
  Future<void> addHabit(String habitName) async {
    //creating habit
    final newHabit = Habit()..name = habitName;

    //saving to the database

    await isar.writeTxn(() => isar.habits.put(newHabit));

    readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      await isar.writeTxn(() async {
        if (isCompleted && !habit.completeDays.contains(normalizedToday)) {
          // Add today's date to completedDays
          habit.completeDays.add(normalizedToday);
        } else {
          // Remove today's date from completedDays
          habit.completeDays.removeWhere((data) =>
              data.year == normalizedToday.year &&
              data.month == normalizedToday.month &&
              data.day == normalizedToday.day);
        }

        // Save updated habit to database
        await isar.habits.put(habit);
      });
    }
  }

  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.delete(id);
      });
    }
    readHabits();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();
  }
}
