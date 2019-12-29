
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;

Map<String, IconData> iconMapping = {
  'buy': Icons.add_shopping_cart,
  'download': Icons.file_download,

  'email': Icons.email,
  'school': Icons.school,
  'location': Icons.location_on,
  'phone': Icons.phone,

  'landscape': Icons.landscape,
  'portraits': Icons.portrait,
  'nature': Icons.nature_people,
  'misc': Icons.more_horiz,
  'events': Icons.event,
  'travel': Icons.card_travel,
};

class PictureManager {
  String url, token;
  Map<String, Map<String, List<Picture>>> menu;

  PictureManager({
    this.url,
    this.token,
    this.menu
  });

  factory PictureManager.fromJson({Map<String, dynamic> json, String url, String token}) {
    Map<String, Map<String, List<Picture>>> tmpMenu = Map<String, Map<String, List<Picture>>>();
    for(var category in json['categories']) {
      String categoryName = category['category'];
      String iconName = category['icon'];


      Map<String, List<Picture>> subTmp = Map<String, List<Picture>>();

      subTmp['icon'] = [Picture(name: iconName, time: DateTime.now())];

      if(category['subcategories'].length != 0) {
        List<dynamic> subcategories = category['subcategories'];
        subcategories.forEach((subcategory) {
          String subcategoryName = subcategory['name'];
          List<dynamic> images = subcategory['images'];
          List<Picture> pictures = [];
          images.forEach((image) {
            print(image);
            pictures.add(Picture.fromJson(image, '$categoryName/$subcategoryName'));
          });
          pictures.sort((a,b) => b.time.compareTo(a.time));
          subTmp[subcategoryName] = pictures;
          subTmp['icon'].addAll(pictures);
        });
      } else {
        List<dynamic> images = category['images'];
        images.forEach((image) {
          //print(image);
          subTmp['icon'].add(Picture.fromJson(image, '$categoryName'));
        });
        subTmp['icon'].sort((a,b) => b.time.compareTo(a.time));
      }

      tmpMenu[categoryName] = subTmp;
    }
    return PictureManager(
      url: url,
      token: token,
      menu: tmpMenu,
    );
  }

  static Future<PictureManager> fromFirestore({String url, String token}) async {
    Map<String, Map<String, List<Picture>>> tmpMenu = Map<String, Map<String, List<Picture>>>();

    fs.Firestore store = firestore();
    var categories = await store.collection("photos").orderBy('category').get().catchError((error) => print(error));

    for(var cat in categories.docs) {
      var category = cat.data();

      String categoryName = category['category'];
      String iconName = category['icon'];
      var subcategories = category['subcategories'];

      Map<String, List<Picture>> subTmp = Map<String, List<Picture>>();
      subTmp['icon'] = [Picture(name: iconName, time: DateTime.now())];

      if(subcategories.length != 0) {
        subcategories.sort();
        for(var sc in subcategories) {
          var subcat = await cat.ref.collection(sc).get().catchError((error) => print(error));
          var images = subcat.docs;

          String subcategoryName = sc;
          List<Picture> pictures = [];

          images.forEach((image) {
            try{
              print(image.data());
              if(image.data()['name'] != 'null') {
                pictures.add(Picture.fromJson(image.data(), '$categoryName/$subcategoryName'));
              }
            } catch(e) {
              print(e);
            }
          });

          pictures.sort((a,b) => b.time.compareTo(a.time));
          subTmp[subcategoryName] = pictures;
          subTmp['icon'].addAll(pictures);
        }
      } else {
        var snapshot = await cat.ref.collection('images').get().catchError((error) => print(error));
        var images = snapshot.docs;

        images.forEach((image) {
          try{
            print(image.data());
            if(image.data()['name'] != 'null') {
              subTmp['icon'].add(Picture.fromJson(image.data(), '$categoryName'));
            }
          } catch(e) {
            print(e);
          }
        });
        subTmp['icon'].sort((a,b) => b.time.compareTo(a.time));
      }

      tmpMenu[categoryName] = subTmp;
    }

    return PictureManager(
      url: url,
      token: token,
      menu: tmpMenu,
    );
  }

  static Future<PictureManager> fromUrl({String jsonUrl, String url, String token}) async {
    final response = await http.get(jsonUrl);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return PictureManager.fromJson(
        json: json.decode(response.body),
        url: url,
        token: token,
      );
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  List<String> getCategories() => menu.keys.toList();
  String getCategory(int index) => menu.keys.toList()[index];

  List<String> getSubcategories(String category) => menu[category].keys.toList();
  List<String> getSubcategoriesFrom(int index) => menu[menu.keys.toList()[index]].keys.toList();

  List<Picture> getPictures(String category, String subcategory) => menu[category][subcategory];
  List<Picture> getPicturesFrom(int category, int subcategory)
    => menu[menu.keys.toList()[category]][menu[menu.keys.toList()[category]].keys.toList()[subcategory]];

  List<Picture> getAllPicturesAt(String category) {
    List<Picture> tmp = [];
    for(var i = 1; i < getPictures(category, 'icon').length; i++) {
      tmp.add(getPictures(category, 'icon')[i]);
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp;
  }
  List<String> getAllUrlsAt(String category) {
    List<Picture> tmp = [];
    for(var i = 1; i < getPictures(category, 'icon').length; i++) {
      tmp.add(getPictures(category, 'icon')[i]);
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp.map((pic) => '$url${pic.path.replaceAll('/', '%2F')}%2F${pic.name.replaceAll(' ', '%20')}?alt=media&token=$token').toList();
  }
  List<Picture> getAllPicturesFrom(int index) {
    List<Picture> tmp = [];
    for(var i = 1; i < getPictures(getCategory(index), 'icon').length; i++) {
      tmp.add(getPictures(getCategory(index), 'icon')[i]);
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));

    return tmp;
  }
  List<String> getAllUrlsFrom(int index) {
    List<Picture> tmp = [];
    for(var i = 1; i < getPictures(getCategory(index), 'icon').length; i++) {
      tmp.add(getPictures(getCategory(index), 'icon')[i]);
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp.map((pic) => '$url${pic.path.replaceAll('/', '%2F')}%2F${pic.name.replaceAll(' ', '%20')}?alt=media&token=$token').toList();
  }
  List<Picture> getAllPictures() {
    List<Picture> tmp = [];
    for(var h = 0; h < menu.keys.toList().length; h++) {
      for(var i = 1; i < getPictures(getCategory(h), 'icon').length; i++) {
        tmp.add(getPictures(getCategory(h), 'icon')[i]);
      }
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp;
  }
}

class Picture {
  final String name, path, description, buy, download, title;
  final num width, height;
  final DateTime time;

  Picture({
    this.path,
    this.name,
    this.title,
    this.width,
    this.height,
    this.description,
    this.buy,
    this.download,
    this.time,
  });

  factory Picture.fromJson(Map<String, dynamic> json, String path) => Picture(
    name: json['name'],
    title: json['title'],
    width: json['w'],
    height: json['h'],
    description: json['desc'],
    buy: json['buy'],
    download: json['dl'],
    time: json['time'] != '' ? DateTime.parse(json['time']) : DateTime.utc(1989, 11, 9),
    path: path,
  );
}
