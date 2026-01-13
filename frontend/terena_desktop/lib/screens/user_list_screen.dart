import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/user.dart';
import 'package:terena_admin/providers/user_provider.dart';
import 'package:terena_admin/providers/helper_providers/utils.dart';
import 'package:quickalert/quickalert.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider provider;
  late UserDataSource dataSource;

  bool isLoading = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    provider = context.read<UserProvider>();
    dataSource = UserDataSource(provider: provider, context: context);
    super.initState();
    initForm();
  }

  Future initForm() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Container(
        color: Colors.grey[100],
        child: Column(children: [_buildSearchForm(), _buildResultView()]),
      ),
      "Users",
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                hintText: "Search by username",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Search by email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 50),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: () {
              dataSource.filterServerSide(
                usernameController.text,
                emailController.text,
              );
            },
            icon: const Icon(Icons.search, size: 20),
            label: const Text(
              "Search",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 50),
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              usernameController.clear();
              emailController.clear();
              dataSource.filterServerSide("", "");
            },
            icon: const Icon(Icons.clear, size: 20),
            label: const Text(
              "Clear",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AdvancedPaginatedDataTable(
            showCheckboxColumn: false,
            rowsPerPage: 10,
            columns: [
              DataColumn(
                label: Text(
                  "Username",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Phone",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Action",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            source: dataSource,
            addEmptyRows: false,
          ),
        ),
      ),
    );
  }
}

class UserDataSource extends AdvancedDataTableSource<User> {
  List<User>? data = [];
  final UserProvider provider;
  int count = 10;
  int page = 1;
  int pageSize = 10;
  String _username = "";
  String _email = "";
  BuildContext context;

  UserDataSource({required this.provider, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data!.length) {
      return null;
    }

    final item = data?[index];

    return DataRow(
      cells: [
        DataCell(Text(item?.username ?? "")),
        DataCell(Text(item?.email ?? "")),
        DataCell(Text(item?.phoneNumber?.toString() ?? "")),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item?.isBlocked == true ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              item?.isBlocked == true ? "Blocked" : "Active",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  item?.isBlocked == true ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              if (item?.isBlocked == true) {
                await _unblockUser(item!.id!);
              } else {
                await _blockUser(item!.id!);
              }
            },
            child: Text(
              item?.isBlocked == true ? "Unblock" : "Block",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _blockUser(int userId) async {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Block User"),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Block Reason",
                  hintText: "Enter reason...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Block reason is required";
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(120, 45),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text("Block", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      try {
        await provider.blockUser(userId, reasonController.text);
        if (context.mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "User has been blocked successfully",
          );
        }
        setNextView();
      } catch (e) {
        if (context.mounted) {
          await buildErrorAlert(context, "Error", e.toString(), e as Exception);
        }
      }
    }
  }

  Future<void> _unblockUser(int userId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unblock User"),
          content: const Text("Are you sure you want to unblock this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Unblock"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await provider.unblockUser(userId);
        if (context.mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "User has been unblocked successfully",
          );
        }
        setNextView();
      } catch (e) {
        if (context.mounted) {
          await buildErrorAlert(context, "Error", e.toString(), e as Exception);
        }
      }
    }
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<User>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    page = (pageRequest.offset ~/ pageSize).toInt() + 1;

    var filter = {
      'Username': _username,
      'Email': _email,
      'Page': page,
      'PageSize': pageSize,
    };

    try {
      var result = await provider.get(filter: filter);
      data = result.result;
      count = result.count ?? 0;
      notifyListeners();
    } on Exception catch (e) {
      if (context.mounted) {
        await buildErrorAlert(context, "Error", e.toString(), e);
      }
    }
    return RemoteDataSourceDetails(count, data!);
  }

  void filterServerSide(String username, String email) {
    _username = username;
    _email = email;
    setNextView();
  }
}
