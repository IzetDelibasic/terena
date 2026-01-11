import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final bool isList;
  final String title;
  final List<Widget> actions;

  const FullScreenLoader({
    super.key,
    required this.isLoading,
    required this.child,
    required this.isList,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading == false
            ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (isList == true) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
                actions: actions,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(title, style: const TextStyle(color: Colors.white)),
                backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
              ),
              body: child,
            )
            : Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(title, style: const TextStyle(color: Colors.white)),
                backgroundColor: const Color.fromRGBO(32, 76, 56, 1),
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
      ],
    );
  }
}
