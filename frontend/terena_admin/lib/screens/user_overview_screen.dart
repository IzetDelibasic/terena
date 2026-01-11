import 'package:flutter/material.dart';
import 'package:terena_admin/layouts/master_screen.dart';

class UserOverviewScreen extends StatefulWidget {
  const UserOverviewScreen({super.key});

  @override
  State<UserOverviewScreen> createState() => _UserOverviewScreenState();
}

class _UserOverviewScreenState extends State<UserOverviewScreen> {
  bool isLoading = false;
  String? selectedStatus;
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'username': 'john_doe',
      'email': 'john.doe@example.com',
      'phone': '+387 61 123 456',
      'address': 'Sarajevo, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 5, 15),
      'lastLogin': DateTime(2026, 1, 8),
      'totalBookings': 24,
      'completedBookings': 20,
      'cancelledBookings': 4,
      'totalSpent': 1850.0,
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 2,
      'username': 'jane_smith',
      'email': 'jane.smith@example.com',
      'phone': '+387 62 234 567',
      'address': 'Mostar, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 6, 20),
      'lastLogin': DateTime(2026, 1, 9),
      'totalBookings': 18,
      'completedBookings': 15,
      'cancelledBookings': 3,
      'totalSpent': 1320.0,
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 3,
      'username': 'bob_johnson',
      'email': 'bob.j@example.com',
      'phone': '+387 63 345 678',
      'address': 'Banja Luka, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 3, 10),
      'lastLogin': DateTime(2025, 12, 20),
      'totalBookings': 32,
      'completedBookings': 28,
      'cancelledBookings': 4,
      'totalSpent': 2450.0,
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 4,
      'username': 'alice_brown',
      'email': 'alice.b@example.com',
      'phone': '+387 64 456 789',
      'address': 'Tuzla, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 7, 5),
      'lastLogin': DateTime(2026, 1, 7),
      'totalBookings': 15,
      'completedBookings': 13,
      'cancelledBookings': 2,
      'totalSpent': 1100.0,
      'status': 'Active',
      'avatar': null,
    },
    {
      'id': 5,
      'username': 'charlie_davis',
      'email': 'charlie.d@example.com',
      'phone': '+387 65 567 890',
      'address': 'Zenica, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 4, 12),
      'lastLogin': DateTime(2025, 11, 15),
      'totalBookings': 8,
      'completedBookings': 5,
      'cancelledBookings': 3,
      'totalSpent': 580.0,
      'status': 'Blocked',
      'avatar': null,
    },
    {
      'id': 6,
      'username': 'eva_martinez',
      'email': 'eva.m@example.com',
      'phone': '+387 66 678 901',
      'address': 'Sarajevo, Bosnia and Herzegovina',
      'registrationDate': DateTime(2025, 8, 25),
      'lastLogin': DateTime(2026, 1, 9),
      'totalBookings': 21,
      'completedBookings': 19,
      'cancelledBookings': 2,
      'totalSpent': 1575.0,
      'status': 'Active',
      'avatar': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildUsersGrid(),
            ),
          ],
        ),
      ),
      "Users Overview",
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Users Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
              ],
              onChanged: (value) {
                setState(() => selectedStatus = value);
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton(
            onPressed: () {
              setState(() {
                selectedStatus = null;
                searchController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersGrid() {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users to display',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserCard(users[index]);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    Color statusColor = user['status'] == 'Active' ? Colors.green : Colors.red;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(235, 241, 224, 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child:
                    user['avatar'] != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            user['avatar'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['username'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              user['email'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Text(
                            user['phone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${user['totalBookings']} bookings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${user['totalSpent'].toStringAsFixed(0)} BAM',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: ' spent',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user['status'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
