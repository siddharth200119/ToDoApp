import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/category.dart';

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier(this.supabase) : super([]);

  final SupabaseClient supabase;

  Future<List<Category>?> fetchCategories() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    final String uid = user.id;
    try {
      final response =
          await supabase.from('categories').select('*').eq('user_id', uid);

      final List<dynamic>? categories = response as List<dynamic>?;
      if (categories == null || categories.isEmpty) {
        return [];
      }

      final List<Category> res = categories
          .map(
            (category) => Category(
              id: category["id"],
              name: category["name"],
              color: Color(category["color"]),
              isFav: category["isFav"],
            ),
          )
          .toList();
      state = res.reversed.toList();
      return res.reversed.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCategory(String name, Color color, bool isFav) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final String uid = user.id;
    try {
      final response = await supabase
          .from('categories')
          .insert({
            'user_id': uid,
            'name': name,
            'color': color.value,
            'isFav': isFav,
          })
          .select()
          .single();

      final Category newCategory = Category(
        id: response['id'],
        name: response['name'],
        color: Color(response['color']),
        isFav: response['isFav'],
      );

      state = [newCategory, ...state];
    } catch (e) {}
  }

  Future<void> editCategory(
      int id, String name, Color color, bool isFav) async {
    try {
      await supabase.from('categories').update(
          {'name': name, 'color': color.value, 'isFav': isFav}).eq('id', id);

      state = state.map((category) {
        if (category.id == id) {
          return Category(id: id, name: name, color: color, isFav: isFav);
        }
        return category;
      }).toList();
    } catch (e) {}
  }

  Future<void> deleteCategory(int id) async {
    try {
      await supabase.from('categories').delete().eq('id', id);
      state = state.where((category) => category.id != id).toList();
    } catch (e) {}
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  final supabase = Supabase.instance.client;
  return CategoriesNotifier(supabase);
});
