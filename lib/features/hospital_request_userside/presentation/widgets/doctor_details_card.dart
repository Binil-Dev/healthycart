import 'package:flutter/material.dart';
import 'package:healthycart/core/custom/custom_cached_network/custom_cached_network_image.dart';

class DoctorRoundImageNameWidget extends StatelessWidget {
  const DoctorRoundImageNameWidget({
    super.key,
    required this.doctorName,
    required this.doctorImage,
    required this.doctorQualification,
    required this.doctorSpecialization,
  });
  final String doctorName;
  final String doctorImage;
  final String doctorQualification;
  final String doctorSpecialization;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CustomCachedNetworkImage(image: doctorImage),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$doctorName -$doctorQualification',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                '($doctorSpecialization)',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        )
      ],
    );
  }
}
