import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terena_admin/helpers/fullscreen_loader.dart';
import 'package:terena_admin/layouts/master_screen.dart';
import 'package:terena_admin/models/user.dart';
import 'package:terena_admin/models/search_result.dart';
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
      FullScreenLoader(
        isLoading: isLoading,
        isList: true,
        title: "Users",
        actions: <Widget>[Container()],
        child: Column(children: [_buildSearchForm(), _buildResultView()]),
      ),
      "Users",
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(235, 241, 224, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(120, 50)),
                ),
                onPressed: () {
                  dataSource.filterServerSide(
                    usernameController.text,
                    emailController.text,
                  );
                },
                child: const Text("Search"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(120, 50)),
                ),
                onPressed: () {
                  usernameController.clear();
                  emailController.clear();
                  dataSource.filterServerSide("", "");
                },
                child: const Text("Clear"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return buildResultView(
      AdvancedPaginatedDataTable(
        showCheckboxColumn: false,
        rowsPerPage: 10,
        columns: const [
          DataColumn(
            label: Text(
              "Username",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Email",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Full Name",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Phone",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Status",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          DataColumn(
            label: Text(
              "Action",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
        source: dataSource,
        addEmptyRows: false,
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
        DataCell(Text("${item?.firstName ?? ""} ${item?.lastName ?? ""}")),
        DataCell(Text(item?.phoneNumber ?? "")),
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

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Block User"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: "Block Reason",
              hintText: "Enter reason...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Block"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
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
