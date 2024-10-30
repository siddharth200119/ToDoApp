import 'package:flutter/material.dart';

class Category {
  Category({
    required this.id,
    required this.name,
    this.color,
    this.isFav = false,
  });

  final int id;
  final String name;
  final Color? color;
  final bool isFav;

  Map<String, dynamic> toMap(){
    return{
      "id": id,
      "name": name,
      "color": color ?? color!.value,
      "isFav": isFav
    };
  }

  static Category? fromMap(Map<String, dynamic> map){
    return Category(
      id: map["id"], 
      name: map["name"],
      color: map["color"] != null ? Color(map["color"]) : null,
      isFav: map["isFav"] == 1
    );
  }
}