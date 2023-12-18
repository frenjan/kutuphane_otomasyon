import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kutuphane_otomasyon/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService firestoreService= FirestoreService();

  final TextEditingController textController =TextEditingController();

  void openNoteBox({String? docID}){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Kitap Ekle"),
      content: TextField(
        decoration: const InputDecoration(hintText: "Kitap Adı"),
        controller: textController,
      ),
      actions: [
        ElevatedButton(onPressed: (){
          if (docID==null){
            firestoreService.addNote(textController.text);
          }
          else {
            firestoreService.updateNote(docID, textController.text);
          }

          textController.clear();

          Navigator.pop(context);
        }, 
        child: const Text("Add"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eren Can Çelik Kütüphane Yönetimi"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context , snapshot){
          if (snapshot.hasData){
            List notesList=snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context,index){
                DocumentSnapshot document=notesList[index];
                String docID=document.id;

                Map<String,dynamic> data=document.data() as Map<String,dynamic>;
                String noteText = data["note"];

                return ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    IconButton(
                    onPressed: () => openNoteBox(docID: docID),
                    icon: const Icon(Icons.settings),
                    ),
                    IconButton(
                    onPressed: () => firestoreService.deleteNote(docID),
                    icon: const Icon(Icons.delete),
                    )
                  ],),
                  title: Text(noteText),
                );
              }
              );
          }
          else {
            return const Text("Henüz Kitap Eklenmedi");
          }

        }, 
        ),
    );
  }
}
