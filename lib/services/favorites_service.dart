import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorite_nurseries';

  // Obtenir tous les favoris
  static Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      return [];
    }
  }

  // Vérifier si une garderie est favorite
  static Future<bool> isFavorite(String nurseryId) async {
    final favorites = await getFavorites();
    return favorites.contains(nurseryId);
  }

  // Ajouter aux favoris
  static Future<bool> addFavorite(String nurseryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      if (!favorites.contains(nurseryId)) {
        favorites.add(nurseryId);
        await prefs.setString(_favoritesKey, json.encode(favorites));
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  // Retirer des favoris
  static Future<bool> removeFavorite(String nurseryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      if (favorites.contains(nurseryId)) {
        favorites.remove(nurseryId);
        await prefs.setString(_favoritesKey, json.encode(favorites));
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors du retrait des favoris: $e');
      return false;
    }
  }

  // Basculer le statut favori
  static Future<bool> toggleFavorite(String nurseryId) async {
    final isFav = await isFavorite(nurseryId);
    if (isFav) {
      return await removeFavorite(nurseryId);
    } else {
      return await addFavorite(nurseryId);
    }
  }
}
