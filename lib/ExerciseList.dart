import  'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ExerciseSelection()
    );
  }
}

class ExerciseSelection extends StatefulWidget {
  const ExerciseSelection({super.key});

  @override
  State<ExerciseSelection> createState() => _ExerciseSelectionState();
}

class _ExerciseSelectionState extends State<ExerciseSelection> {
  String searchQuery = '';
  late List<dynamic> exercises = [];

  @override
  void initState() {
    super.initState();
    fetchData('lats');
  }

  Future<void> fetchData(String searchQuery) async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=${searchQuery}'),
      headers: {
        'x-api-key': '/J+4XMLi0cWNeQ3F70t39Q==oNVAN6eElkdV58Fl',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        exercises = jsonDecode(response.body);
      });
    } else {
// Handle error
      print('Failed to fetch exercises: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Selection'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search Exercise',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  fetchData(searchQuery);
                },
                child: Text('Search'),
              ),
              SizedBox(height: 16.0),
              Text('Exercises'),
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                  child: Text('Invalid Search')// OR CircularProgressIndicator(),
                )
                    : ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListCard(
                      title: Text(exercise['name']),
                      subtitle: Text('${exercise['muscle']}'),
                      onTap: (name, muscle) {
                        // Send exercise information back to previous page
                        Navigator.pop(context, {'name': name, 'muscle': muscle});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListCard extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Function(String name, String muscle) onTap; // Function to handle button tap

  ListCard({
    required this.title,
    required this.subtitle,
    required this.onTap, // Add onTap parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Use GestureDetector instead of ListTile to handle tap
      onTap: () {
        // Pass exercise information back to previous page
        final exerciseName = (title as Text).data!;
        final exerciseMuscle = (subtitle as Text).data!;
        onTap(exerciseName, exerciseMuscle);
      },
      child: Card(
        child: ListTile(
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }
}


