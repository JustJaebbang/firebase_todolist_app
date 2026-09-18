import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_list_app/model/deletelist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Delete extends StatefulWidget {
  const new({super.key});

  @override
  State<Delete> createState() => _DeleteState();
}

class _DeleteState extends State<Delete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text('Delete Lists'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
                .instance.collection('deletelist')
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
    final deletelist = Deletelist(
      todo: doc['todo'], 
      createdate: doc['createdate'], 
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: BehindMotion(), 
        children: [
          SlidableAction(
            onPressed: (context) async{
              // todolist에 추가
              await FirebaseFirestore.instance.collection('todolist').add(
                {
                  'todo' : deletelist.todo,
                  'createdate' : (deletelist.createdate).substring(0,10)
                }
              );
              // deletelist에서 삭제
              FirebaseFirestore.instance
                    .collection('deletelist')
                    .doc(doc.id)
                    .delete();
            },
            backgroundColor: Colors.blue,
            icon: Icons.reset_tv_rounded,
            label: '복구',
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
                    '    ${deletelist.todo} / ${(deletelist.createdate).substring(0,10)}'
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}