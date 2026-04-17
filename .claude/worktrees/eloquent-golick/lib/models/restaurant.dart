class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final List<String> tags;
  final List<MenuCategory> menu;
  final String address;
  final double distance;
  final String city;
  final String district; // ilçe (e.g. Kadıköy, Beşiktaş)
  final double latitude;
  final double longitude;
  final List<String> badges;
  final List<Review> reviews;

  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    required this.tags,
    required this.menu,
    required this.address,
    required this.distance,
    this.city = 'İstanbul',
    this.district = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.badges = const [],
    this.reviews = const [],
  });

  int get deliveryTime => deliveryTimeMin;
  String get deliveryTimeLabel => "$deliveryTimeMin-$deliveryTimeMax dk";

  Restaurant copyWith({
    List<Review>? reviews,
    double? rating,
    int? reviewCount,
    String? district,
  }) => Restaurant(
    id: id, name: name, imageUrl: imageUrl, cuisine: cuisine,
    rating: rating ?? this.rating, reviewCount: reviewCount ?? this.reviewCount,
    deliveryTimeMin: deliveryTimeMin, deliveryTimeMax: deliveryTimeMax,
    deliveryFee: deliveryFee, minOrder: minOrder, isOpen: isOpen,
    tags: tags, menu: menu, address: address, distance: distance,
    city: city, district: district ?? this.district,
    latitude: latitude, longitude: longitude,
    badges: badges, reviews: reviews ?? this.reviews,
  );
}

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? orderId;

  const Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
  });
}

class MenuCategory {
  final String id;
  final String name;
  final List<MenuItem> items;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.items,
  });
}

class MenuOption {
  final String id;
  final String name;
  final double price;
  final bool isRemovable;

  const MenuOption({
    required this.id,
    required this.name,
    this.price = 0,
    this.isRemovable = false,
  });
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isPopular;
  final bool isVegetarian;
  final bool isSpicy;
  final List<String> allergens;
  final List<MenuOption> options;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = '',
    this.isPopular = false,
    this.isVegetarian = false,
    this.isSpicy = false,
    this.allergens = const [],
    this.options = const [],
  });
}

class CartItem {
  final MenuItem item;
  final Restaurant restaurant;
  int quantity;
  String? note;
  List<MenuOption> selectedOptions;
  List<MenuOption> removedIngredients;
  List<MenuOption> sideItems;

  CartItem({
    required this.item,
    required this.restaurant,
    this.quantity = 1,
    this.note,
    this.selectedOptions = const [],
    this.removedIngredients = const [],
    this.sideItems = const [],
  });

  double get totalPrice => (item.price + selectedOptions.fold(0.0, (s, o) => s + o.price) + sideItems.fold(0.0, (s, o) => s + o.price)) * quantity;
  double get optionsPrice => (selectedOptions.fold(0.0, (s, o) => s + o.price) + sideItems.fold(0.0, (s, o) => s + o.price)) * quantity;
}
