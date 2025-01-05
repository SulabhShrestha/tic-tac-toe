import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';

class RoundIndicatorBot extends StatelessWidget {
  const RoundIndicatorBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.amber, Colors.amber.shade700],
        ),
      ),
      margin: EdgeInsets.only(bottom: 14.h),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Round", style: TextStyle(fontSize: 12.sp)),
          BlocBuilder<BotCubit, BotState>(
            builder: (context, state) {
              return Text(
                state.round.toString(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              );
            },
          ),
        ],
      ),
    );
  }
}
