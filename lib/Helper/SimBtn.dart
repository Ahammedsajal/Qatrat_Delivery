import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Color.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? size;
  SimBtn({super.key, this.title, this.onBtnSelected, this.size});
  @override
  Widget build(final BuildContext context) {
    size = MediaQuery.of(context).size.width * size!;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(final BuildContext context) {
    return CupertinoButton(
      child: Container(
        width: size,
        height: 35,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primarytheme,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.white,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}
