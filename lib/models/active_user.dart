import 'user.dart'; // Ensure you import the User class

class ActiveUser extends User {
  // Private static instance
  //role 1 admin
  static ActiveUser? _instance;

  // Additional properties of ActiveUser
  String? url; // Make url nullable

  // Private constructor
  ActiveUser._({
    required int id,
    required int role,
    required String name,
    required String surname,
    this.url, // Allow url to be null
  }) : super(id: id, role: role, name: name, surname: surname);

  // Method to initialize the ActiveUser instance
  static void initialize({
    required int id,
    required int role,
    required String name,
    required String surname,
    String? url, // Allow url to be null
  }) {
    _instance = ActiveUser._(
      id: id,
      role: role,
      name: name,
      surname: surname,
      url: url,
    );
  }

  // Static method to get the ActiveUser instance
  static ActiveUser get instance {
    if (_instance == null) {
      throw Exception('ActiveUser instance is not initialized yet');
    }
    return _instance!;
  }

  // Static method to check if the ActiveUser is initialized
  static bool get isInitialized => _instance != null;

  // Optional: Reset the instance
  static void reset() {
    _instance = null;
  }

  // Method to update user properties
  void update({
    int? id,
    int? role,
    String? name,
    String? surname,
    String? url, // Allow url to be null
  }) {
    if (id != null) this.id = id;
    if (role != null) this.role = role;
    if (name != null) this.name = name;
    if (surname != null) this.surname = surname;
    if (url != null) this.url = url; // Update url only if it's not null
  }
}
