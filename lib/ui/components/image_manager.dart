

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Map<String, IconData> iconMapping = {
  'landscape': Icons.landscape,
  'portraits': Icons.portrait,
  'nature': Icons.nature_people,
  'misc': Icons.more_horiz,
  'email': Icons.email,
  'school': Icons.school,
  'location': Icons.location_on,
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

      subTmp['icon'] = [Picture(title: iconName)];

      if(category['subcategories'].length != 0) {
        List<dynamic> subcategories = category['subcategories'];
        subcategories.forEach((subcategory) {
          String subcategoryName = subcategory['name'];
          List<dynamic> images = subcategory['images'];
          List<Picture> pictures = [];
          images.forEach((image) {
            pictures.add(Picture.fromJson(image, '$categoryName/$subcategoryName'));
          });
          subTmp[subcategoryName] = pictures;
          subTmp['icon'].addAll(pictures);
        });
      } else {
        List<dynamic> images = category['images'];
        images.forEach((image) {
          subTmp['icon'].add(Picture.fromJson(image, '$categoryName'));
        });
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

  List<Picture> getAllPictures(String category) {
    List<Picture> tmp = [];
    menu[category].values.map((s) => tmp.addAll(s));
    return tmp;
  }
  List<Picture> getAllPicturesFrom(int index) {
    List<Picture> tmp = [];
    menu[menu.keys.toList()[index]].values.map((s) => tmp.addAll(s));
    return tmp;
  }
}

class Picture {
  final String title, path, description, buy;
  final int width;
  final double height;

  Picture({
    this.path,
    this.title,
    this.width,
    this.height,
    this.description,
    this.buy,
  });

  factory Picture.fromJson(Map<String, dynamic> json, String path) => Picture(
    title: json['title'],
    width: json['width'],
    height: json['height'],
    description: json['description'],
    buy: json['buy'],
    path: path,
  );
}
