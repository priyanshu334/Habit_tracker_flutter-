import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tiile.dart';
import 'package:habit_tracker/database/habiit_database.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/utils/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  final TextEditingController textController = TextEditingController();
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: InputDecoration(hintText: "create a new Habit"),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    context.read<HabitDatabase>().addHabit(newHabitName);

                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
      ),
    actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;
                    context.read<HabitDatabase>().updateHabitName(habit.id , newHabitName);

                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
    ));
  }
 void deleteHabitBox(Habit habit){
    showDialog(context: context, builder: (context) => AlertDialog(
   title: Text("Are you sure you want to delete "),
    actions: [
                MaterialButton(
                  onPressed: () {
               
                    context.read<HabitDatabase>().updateHabitName(habit.id , newHabitName);

                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
    ));
 }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(Icons.add),
      ),
      body: _buildHabitsList(),
    );
  }

  Widget _buildHabitsList() {
    final habitDatebase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = HabitDatabase().currentHabits;

    return ListView.builder(
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompletedToday = isHabitCompleted(habit.completeDays);
          return MyHabitTiile(
            isCompleted: isCompletedToday,
            text: habit.name,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context)=>editHabitBox,
          );
        });
  }
}
