import 'package:stacked/stacked.dart';

export 'user_service.dart' show User;

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final int age;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'age': age,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class UserService with ReactiveServiceMixin {
  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _selectedAccountId;
  String? get selectedAccountId => _selectedAccountId;

  List<User> _sharedUsers = [];
  List<User> get sharedUsers => _sharedUsers;

  bool get isAuthenticated => _currentUser != null;

  List<User> get allAvailableUsers {
    final users = <User>[];
    if (_currentUser != null) {
      users.add(_currentUser!);
    }
    users.addAll(_sharedUsers);
    return users;
  }

  User? get selectedUser {
    if (_selectedAccountId == null) return _currentUser;
    
    // Try to find in current user
    if (_currentUser?.id == _selectedAccountId) {
      return _currentUser;
    }
    
    // Try to find in shared users
    try {
      return _sharedUsers.firstWhere((user) => user.id == _selectedAccountId);
    } catch (e) {
      return _currentUser; // Fallback to current user
    }
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    // Default to current user if no account is selected
    if (_selectedAccountId == null) {
      _selectedAccountId = user.id;
    }
    notifyListeners();
  }

  void setSharedUsers(List<User> users) {
    _sharedUsers = users;
    notifyListeners();
  }

  void selectAccount(String accountId) {
    // Validate that the account exists
    final allUsers = allAvailableUsers;
    final userExists = allUsers.any((user) => user.id == accountId);
    
    if (userExists) {
      _selectedAccountId = accountId;
      notifyListeners();
    } else {
      // Invalid account ID, fallback to current user
      _selectedAccountId = _currentUser?.id;
      notifyListeners();
    }
  }

  void addSharedUser(User user) {
    if (!_sharedUsers.any((u) => u.id == user.id)) {
      _sharedUsers.add(user);
      notifyListeners();
    }
  }

  void removeSharedUser(String userId) {
    _sharedUsers.removeWhere((user) => user.id == userId);
    
    // If the selected account was removed, switch to current user
    if (_selectedAccountId == userId) {
      _selectedAccountId = _currentUser?.id;
    }
    
    notifyListeners();
  }

  void updateCurrentUser(User updatedUser) {
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  void updateSharedUser(User updatedUser) {
    final index = _sharedUsers.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _sharedUsers[index] = updatedUser;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _selectedAccountId = null;
    _sharedUsers.clear();
    notifyListeners();
  }

  // Helper methods for permissions (to be implemented later)
  bool canViewAccount(String accountId) {
    return allAvailableUsers.any((user) => user.id == accountId);
  }

  bool canEditAccount(String accountId) {
    // For now, assume full access to all accounts
    // TODO: Implement permission levels
    return canViewAccount(accountId);
  }

  bool canManageAccount(String accountId) {
    // For now, only current user can manage their own account
    return _currentUser?.id == accountId;
  }

  // Get display name for account selection
  String getDisplayName(String accountId) {
    if (_currentUser?.id == accountId) {
      return '${_currentUser!.name} (Me)';
    }
    
    final user = _sharedUsers.firstWhere(
      (user) => user.id == accountId,
      orElse: () => User(
        id: accountId,
        name: 'Unknown User',
        phone: '',
        email: '',
        gender: '',
        age: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return user.name;
  }
}