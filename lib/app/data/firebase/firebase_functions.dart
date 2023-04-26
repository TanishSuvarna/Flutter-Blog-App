
import 'dart:io';

import 'package:blog_app/app/data/const.dart';
import 'package:blog_app/app/data/global_widgets/indicator.dart';
import 'package:blog_app/app/models/blog_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:get/get.dart';
import '../../modules/home/controllers/home_controller.dart';

class FirebaseFunctions  {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  final _documentLimit = 5;

  
  @override
  var isLoading = false.obs;

  Future<void> createUserCredential(String name, String email) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .set({
        "uid": user!.uid,
        "name": name,
        "email": email
      }).then((value) {
        Indicator.closeLoading();
        
      });
    } catch (e) {
      showAlert(e.toString());
    }
  }

  Future<void> uploadBlog( String title, String description, File image) async {
    try {
      String id = generateId();
      DateTime time = DateTime.now();

      String imageUrl = await uploadImage(image);

      Map<String, dynamic> blogDetails = {
        'id': id,
        'title': title,
        'description': description,
        'img': imageUrl,
        'time': time,
        'name' :user!.displayName ?? "Unknown"
      };

      await _firebaseFirestore
          .collection('blogs')
          .doc(id)
          .set(blogDetails)
          .then((value) {
        saveDataToMyBlogs(id);
      });
      BlogsModel newBlog = BlogsModel(description: description, title: title, id: id, image: imageUrl , name : user!.displayName ?? "Null");
      showAlert(newBlog.title);
      HomeController.to.blogsController.add([...HomeController.to.blogsController.value , newBlog]);


    } catch (e) {
      showAlert("$e");
    }
  }

  Future<String> uploadImage(File file) async {
    try {
      String imageName = generateId();

      var refrence = _storage.ref().child("/images").child("/$imageName.jpg");

      var uploadTask = await refrence.putFile(file);

      String url = await uploadTask.ref.getDownloadURL();

      return url;
    } catch (e) {
      showAlert("$e");
      return "";
    }
  }

  Future<List<BlogsModel>> getBlogs() async {
    if (_hasMoreData) {
      if (!isLoading.value) {
        try {
          if (_lastDocument == null) {
            return await _firebaseFirestore
                .collection('blogs')
                .orderBy('time')
                .limit(_documentLimit)
                .get()
                .then((value) {
              _lastDocument = value.docs.last;

              if (value.docs.length < _documentLimit) {
                _hasMoreData = false;
              }

              Indicator.closeLoading();

              return value.docs
                  .map((e) => BlogsModel.fromJson(e.data()))
                  .toList();
            });
          } else {
            isLoading.value = true;

            return await _firebaseFirestore
                .collection("blogs")
                .orderBy('time')
                .startAfterDocument(_lastDocument!)
                .limit(_documentLimit)
                .get()
                .then((value) {
              _lastDocument = value.docs.last;

              if (value.docs.length < _documentLimit) {
                _hasMoreData = false;
              }

              isLoading.value = false;

              return value.docs
                  .map((e) => BlogsModel.fromJson(e.data()))
                  .toList();
            });
          }
        } catch (e) {
          showAlert("$e");
          print(e);
          return [];
        }
      } else {
        return [];
      }
    } else {
      print("No More Data");
      return [];
    }
  }

  Future<void> saveDataToMyBlogs(String id) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection('myblos')
          .doc(id)
          .set({
        'id': id,
      });
    } catch (e) {
      showAlert("$e");
    }
  }

  Future<List> getMyBlogs() async {
    try {
      var snapshot = await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection("myblos")
          .get();

      return snapshot.docs.map((e) => e.data()['id']).toList();
    } catch (e) {
      showAlert("$e");
      return [];
    }
  }

  Future<BlogsModel> getBlogsById(String id) async {
    try {
      var documentSnapshot =
          await _firebaseFirestore.collection('blogs').doc(id).get();

      return BlogsModel.fromJson(documentSnapshot.data()!);
    } catch (e) {
      showAlert("$e");
      return BlogsModel(description: "", title: "", id: "", image: "" ,name:"");
    }
  }

  Future<void> deleteBlog(String id) async {
    List<BlogsModel> updatedList = HomeController.to.blogsController.value;
    await Future.wait([
      deleteMyBlog(id),
      deletePublicBlog(id),
    ]).then((value) => {
       updatedList.removeWhere((element) => element.id == id), 
       HomeController.to.blogsController.add([...updatedList])
       });
  }

  Future<void> deletePublicBlog(String id) async {
    try {
      await _firebaseFirestore.collection('blogs').doc(id).delete();
    } catch (e) {
      showAlert("$e");
    }
  }

  Future<void> deleteMyBlog(String id) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection('myblos')
          .doc(id)
          .delete();
    } catch (e) {
      showAlert("$e");
    }
  }

  Future<void> editBlog(String id, Map<String, dynamic> map) async {
    try {
      await _firebaseFirestore.collection('blogs').doc(id).update(map);
    } catch (e) {
      showAlert("$e");
    }
  }

  Future<void> addToFavourite(String id) async {
    try {
      await _firebaseFirestore
          .collection("users")
          .doc(user!.uid)
          .collection('favourite')
          .doc(id)
          .set({
        'id': id,
      });
    } catch (e) {
      showAlert("$e");
    }
  }
  @override
  Future<List> getFavouriteList() async {
    try {
      var querySnapshot = await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection('favourite')
          .get();

      return querySnapshot.docs.map((e) => e.data()['id']).toList();
    } catch (e) {
      showAlert("$e");
      return [];
    }
  }

  Future<void> deleteFromFavorite(String id) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(user!.uid)
          .collection('favourite')
          .doc(id)
          .delete();
    } catch (e) {
      showAlert("$e");
    }
  }
}
