import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/cutom_buttons/button_widget.dart';
import 'package:healthycart/core/general/validator.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';

class RejectionReasonPopup extends StatelessWidget {
  const RejectionReasonPopup({
    super.key,
    required this.reasonController,
    this.onConfirm,
    this.formKey,
  });
  final TextEditingController reasonController;
  final void Function()? onConfirm;
  final Key? formKey;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        reasonController.clear();
      },
      child: AlertDialog(
        backgroundColor: BColors.white,
        title: Text(
          'Rejection Reason',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            validator: BValidator.validate,
            controller: reasonController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection',
              hintStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        actions: [
          ButtonWidget(
              buttonHeight: 40,
              buttonWidth: 120,
              buttonColor: BColors.darkblue,
              buttonWidget: const Text('Confirm',
                  style: TextStyle(
                      color: BColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              onPressed: onConfirm),
        ],
      ),
    );
  }
}
