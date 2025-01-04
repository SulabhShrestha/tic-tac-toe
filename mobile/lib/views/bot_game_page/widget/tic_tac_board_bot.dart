import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/utils/game_helper.dart';
import 'package:mobile/views/bot_game_page/utils/bot_game_helper.dart';
import 'package:mobile/views/widgets/line_painter.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

class TicTacBoardBot extends StatefulWidget {
  const TicTacBoardBot({super.key});

  @override
  State<TicTacBoardBot> createState() => _TicTacBoardBotState();
}

class _TicTacBoardBotState extends State<TicTacBoardBot> {
  // for preventing multiple cells to be triggered at once when clicking multiple
  bool isCellSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: RDottedLineBorder.all(
          color: ConstantColors.red,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ConstantColors.red,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(
            color: Colors.white,
            width: 8,
          ),
        ),
        child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          children: [
            for (int a = 0; a < 9; a++)
              BlocBuilder<BotCubit, Map<String, dynamic>>(builder: (_, state) {
                bool isDraw = false;

                if (state["game-end"] == "Draw") {
                  isDraw = true;
                } else if (state["game-end"] == "You" ||
                    state["game-end"] == "Bot") {
                  List<int> winningSequence = state["winningSequence"] ?? [];
                  if(winningSequence.contains(a)){
                    var winLineType =
                        GameHelper().getWinLineType(winningSequence);
                    return _buildGridCell(a, context,
                        isDraw: false, winLineType: winLineType);
                    
                  }
                  
                }
                return _buildGridCell(a, context, isDraw: isDraw);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int index, BuildContext context,
      {bool isDraw = false, WinLineType? winLineType}) {
    // list of indexes for border
    List<int> borderBottomIndexes = [0, 1, 2, 3, 4, 5];
    List<int> borderRightIndexes = [0, 1, 3, 4, 6, 7];

    final selectedCells = context.watch<BotCubit>().getSelectedCells();

    // returning the selected cells
    var cellDetails = selectedCells.firstWhere(
      (element) => element.selectedIndex == index,
      orElse: () => TicTacModel(uid: "None", selectedIndex: -1),
    );

    return Stack(
      children: [
        GestureDetector(
          // it should be both player turn and cell should be empty
          onTap: cellDetails.selectedIndex == index
              ? null
              : () {
                  debugPrint("Cell: $index");
                  context.read<BotCubit>().addSelectedCell(
                      TicTacModel(uid: "You", selectedIndex: index));
                },

          child: Container(
            decoration: BoxDecoration(
              border: RDottedLineBorder(
                dottedLength: 6,
                dottedSpace: 4,
                right: borderRightIndexes.contains(index)
                    ? const BorderSide(
                        color: ConstantColors.white,
                        width: 1,
                      )
                    : BorderSide.none,
                bottom: borderBottomIndexes.contains(index)
                    ? const BorderSide(
                        color: ConstantColors.white,
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: cellDetails.selectedIndex != index
                  ? const Text(" ")
                  : _buildSomething(cellDetails.uid),
            ),
          ),
        ),
        if (isDraw) ...{
          Center(
            child: Image.asset("images/cross.png", height: 54),
          ),
        } else if (winLineType != null) ...{
          CustomLinePainter(
            lineType: winLineType,
          ),
        }
      ],
    );
  }

  _buildSomething(String selectedBy) {
    final allPlayers = context.read<BotCubit>().getPlayers();

    return Image.asset(
      selectedBy == allPlayers.first ? "images/check.png" : "images/circle.png",
      height: 54,
    );
  }
}
