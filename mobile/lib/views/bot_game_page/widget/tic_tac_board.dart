import 'package:flutter/material.dart';
import 'package:mobile/utils/colors.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

class TicTacBoard extends StatefulWidget {
  const TicTacBoard({super.key});

  @override
  State<TicTacBoard> createState() => _TicTacBoardState();
}

class _TicTacBoardState extends State<TicTacBoard> {
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
            for (int a = 0; a < 9; a++) _buildGridCell(a),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    // list of indexes for border
    List<int> borderBottomIndexes = [0, 1, 2, 3, 4, 5];
    List<int> borderRightIndexes = [0, 1, 3, 4, 6, 7];

    return GestureDetector(
      // it should be both player turn and cell should be empty
      onTap: () {},

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
        child: const Center(
          child: Text(" "),
        ),
      ),
    );
  }
}
