
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthycart/core/custom/toast/toast.dart';
import 'package:healthycart/features/hospital_request_userside/domain/models/booking_model.dart';
import 'package:healthycart/utils/constants/colors/colors.dart';


class OrderIDAndDateSection extends StatelessWidget {
  const OrderIDAndDateSection({
    super.key,
    required this.orderData,
    required this.date,
  });

  final HospitalBookingModel orderData;
  final String date;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: orderData.id ?? ''));
            CustomToast.sucessToast(text: 'Order ID sucessfully copied.');
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            height: 28,
            width: 176,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: BColors.darkblue),
            child: Center(
              child: Text('${orderData.id}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Colors.white)),
            ),
          ),
        ),
        Container(
          height: 28,
          width: 128,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(),
              color: BColors.offWhite),
          child: Center(
            child: Text(date,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: BColors.darkblue)),
          ),
        ),
      ],
    );
  }
}
