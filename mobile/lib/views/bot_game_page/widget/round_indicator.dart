import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/views/bloc/game_details_cubit/game_details_cubit.dart';

class RoundIndicator extends StatelessWidget {
  const RoundIndicator({super.key});

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
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Round", style: TextStyle(fontSize: 16)),
          BlocBuilder<GameDetailsCubit, Map<String, dynamic>>(
            builder: (context, state) {
              return Text(
                state["round"].toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              );
            },
          ),
        ],
      ),
    );
  }
}
