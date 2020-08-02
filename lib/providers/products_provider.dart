import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import './product_model.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<ProductModel> _items = [
    // ProductModel(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // ProductModel(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // ProductModel(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // ProductModel(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showOnlyFavorites = false;

  final String authToken;
  final String userId;

  ProductsProvider(
    this.authToken,
    this.userId,
    this._items,
  );

  List<ProductModel> get items {
    // if (_showOnlyFavorites) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }

    return [..._items];
  }

  List<ProductModel> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavorites() {
  //   _showOnlyFavorites = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showOnlyFavorites = false;
  //   notifyListeners();
  // }

  ProductModel findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://my-shop-app-flutter-e052a.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://my-shop-app-flutter-e052a.firebaseio.com/userFavorites/$userId/.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<ProductModel> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(
          ProductModel(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData['prodId'] ?? false,
          ),
        );
        _items = loadedProduct;
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProducts(ProductModel productModel) async {
    final url =
        'https://my-shop-app-flutter-e052a.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          // Convert into map
          {
            'title': productModel.title,
            'description': productModel.description,
            'price': productModel.price,
            'imageUrl': productModel.imageUrl,
            'isFavorite': productModel.isFavorite,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = ProductModel(
        id: json.decode(response.body)['name'], // For decoding from map
        title: productModel.title,
        description: productModel.description,
        imageUrl: productModel.imageUrl,
        price: productModel.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, ProductModel newProduct) async {
    final url =
        'https://my-shop-app-flutter-e052a.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );
      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
      } else {
        print('....');
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://my-shop-app-flutter-e052a.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var exisitingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    print(response.statusCode);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, exisitingProduct);
      notifyListeners();
      throw HttpException('Could not delete');
    }
    exisitingProduct = null;
  }
}
