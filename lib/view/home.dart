import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_list_app/model/todolist.dart';
import 'package:firebase_todo_list_app/view/delete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const new({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  TextEditingController todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text('Todo Lists'),
        actions: [
          IconButton(
            onPressed: () => Get.to(Delete()), 
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              insertAction();
            }, 
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
                .instance.collection('todolist')
                .orderBy('createdate', descending: false)
                .snapshots(), 
        builder: (context, snapshot) {
          if(! snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: documents.map((e) => buildItemWidget(e)).toList()
              ),
          );
        },
      ),
    );
  }

  Widget buildItemWidget(DocumentSnapshot doc){
    final todolist = Todolist(
      todo: doc['todo'], 
      createdate: doc['createdate'], 
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: BehindMotion(), 
        children: [
          SlidableAction(
            onPressed: (context) async{
              // deletelist에 추가
              await FirebaseFirestore.instance.collection('deletelist').add(
                {
                  'todo' : todolist.todo,
                  'createdate' : (todolist.createdate).substring(0,10)
                }
              );
              // todolist에서 삭제
              FirebaseFirestore.instance
                    .collection('todolist')
                    .doc(doc.id)
                    .delete();
            },
            backgroundColor: Colors.red,
            icon: Icons.delete_forever,
            label: '삭제',
          )
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Card(
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.fromLTRB(10.0,15,10,10),
              child: Row(
                children: [
                  Icon(Icons.calendar_month),
                  Text(
                    '    ${todolist.todo} / ${(todolist.createdate).substring(0,10)}'
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // Functions
  Future<void> insertAction() async{
    Get.defaultDialog(
      title: 'Todo List',
      content: TextField(
        controller: todoController,
        decoration: InputDecoration(
          labelText: '추가할 내용',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FirebaseFirestore.instance.collection('todolist').add(
              {
                'todo':todoController.text,
                'createdate': DateTime.now().toString().substring(0,19),
              }
            );
            Get.back();
          }, 
          child: Text('추가하기'),
        ),
      ],
    );
  }
  
  
  Future<void> deleteInsertAction() async{
    await FirebaseFirestore.instance.collection('deletelist').add(
      {
        'todo':todoController.text,
        'createdate': DateTime.now().toString().substring(0,19),
      }
    );
    Get.back();
  }

  
}