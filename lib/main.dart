import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(home: Mynotes()));
}

class Mynotes extends StatefulWidget {
  const Mynotes({Key? key}) : super(key: key);

  @override
  State<Mynotes> createState() => _MynotesState();
}

class _MynotesState extends State<Mynotes> {
  Database? database;
  List<Map>? _notes;

  @override
  void initState() {
    super.initState();
    creatDatabase();
  }

  Future<void> creatDatabase() async {
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
      print("database created!");
      // When creating the db, create the table
      await db
          .execute('CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
      print("table created!");
    }, onOpen: (database) async {
      // Get the records
      _notes = await database.rawQuery('SELECT * FROM Note');
      print("notes: ${_notes.toString()}");
      print("database opened!");
      setState(() {});
    });
  }

  Future<void> getNotes() async {
    _notes = await database?.rawQuery('SELECT * FROM Note');
    print("notes ${_notes}");
    setState(() {});
  }

  Future<void> updatenote(String note) async {
    // Insert some records in a transaction
    await database?.transaction((txn) async {
      int id1 = await txn.rawInsert('UPDATE  Note(content) VALUES("$note")');

      print('update: $id1');
    });
  }

  Future<void> deleteNote(int id) async {
    // Delete a record
    await database?.rawDelete('DELETE FROM Note WHERE id = $id');
    getNotes();
    @override
    void initState() {
      creatDatabase();
      super.initState();
    }

    @override
    void dispose() {
      database?.close();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my note"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {
                getNotes();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) => Dismissible(
                      background: Container(
                        color: Colors.red,
                      ),
                      onDismissed: (DismissDirection direction) {
                        int id = _notes?[index]['id'];
                        deleteNote(id);

                        setState(() {});
                      },
                      key: ValueKey<Map>(_notes![index]),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Updatscr(
                                      _notes?[index]['id'],
                                      _notes?[index]['content'])));
                        },
                        child: Card(
                          shape: const RoundedRectangleBorder(),
                          child: Text(
                            _notes?[index]['content'],
                            style: const TextStyle(
                                fontSize: 32, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                separatorBuilder: (context, index) => const SizedBox(
                      height: 16,
                    ),
                itemCount: _notes?.length ?? 0),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => secscr()));
          },
          child: Icon(
            Icons.add_circle,
            color: Colors.white,
          )),
    );
  }
}

class secscr extends StatefulWidget {
  const secscr({Key? key}) : super(key: key);

  @override
  State<secscr> createState() => _secscrState();
}

class _secscrState extends State<secscr> {
  var noteController = TextEditingController();

  Database? database;

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  Future<void> createDatabase() async {
    // open the database
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
      print("database created!");
      // When creating the db, create the table
      await db
          .execute('CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
      print("table created!");
    }, onOpen: (database) {
      print("database opened!");
    });
  }

  Future<void> insertToDatabase(String note) async {
    // Insert some records in a transaction
    await database?.transaction((txn) async {
      int id1 =
          await txn.rawInsert('INSERT INTO Note(content) VALUES("$note")');
      print('inserted: $id1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("my note"),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            TextFormField(
              controller: noteController,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              insertToDatabase(noteController.text);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Mynotes()));
            },
            child: const Icon(
              Icons.note_add_outlined,
              color: Colors.white,
            )));
  }
}

class Updatscr extends StatefulWidget {
   Updatscr( this.id,this.content
       ,{Key? key}) : super(key: key);
int id;
String content;
  @override
  State<Updatscr> createState() => _UpdatscrState();
}

class _UpdatscrState extends State<Updatscr> {
  var notecontrolar = TextEditingController();
  Database? database;

  @override
  void initState() {
    super.initState();
    notecontrolar.text=widget.content;
    creatDatabase();
  }

  Future<void> creatDatabase() async {
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
      print("database created!");
      // When creating the db, create the table
      await db
          .execute('CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
      print("table created!");
    }, onOpen: (database) async {
      // Get the records
    });
  }

  Future<void> update()async{
     await database?.rawUpdate(
        'UPDATE Note SET content = ? WHERE id = ?',
        [notecontrolar.text,widget.id]);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("notes"),backgroundColor: Colors.blue,),
      body: Column(
        children: [
          TextFormField(controller: notecontrolar),
          ElevatedButton(
              onPressed: () {
                update();
                Navigator.pop(context);
              },
              child: Text("save"))
        ],
      ),
    );
  }
}
