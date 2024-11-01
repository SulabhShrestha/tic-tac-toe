// true means it is concluded and shouldn't continue any more
function checkForConclusion(selectedCellsInfo, io, roomID) {
  // Grouping based on unique selectedBy values
  const groupedBySelectedBy = selectedCellsInfo.reduce((acc, cell) => {
    const { selectedBy, selectedIndex } = cell;
    acc[selectedBy] = acc[selectedBy] || [];
    acc[selectedBy].push(selectedIndex);
    return acc;
  }, {});

  // first priority is to check if any of the user has won
  for (const key in groupedBySelectedBy) {
    const element = groupedBySelectedBy[key];

    var winSequence = getWinningSequence(element);

    if (winSequence) {
      console.log(`${key} is the winner!`);

      // winner declared
      io.to(roomID).emit("game-conclusion", {
        status: "win",
        winner: key,
        winSequence,
      });
      return true;
    }
  }

  // and then, checking for draw, adding index 0 leads to same previous result so
  //the combine should be = 45, as 1+...9
  if (
    Object.values(groupedBySelectedBy)
      .flat()
      .reduce((sum, index) => sum + (index + 1), 0) === 45
  ) {
    io.to(roomID).emit("game-conclusion", { status: "draw" });
    return true; 
  }

  return false; 
}

function getWinningSequence(indices) {
  // Define the winning sequences
  const winningSequences = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8], // Rows
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8], // Columns
    [0, 4, 8],
    [2, 4, 6], // Diagonals
  ];

  // Find and return the winning sequence if it exists
  const winningSequence = winningSequences.find((sequence) =>
    sequence.every((index) => indices.includes(index))
  );

  // Return the winning sequence or null if no winning sequence found
  return winningSequence || null;
}

module.exports = { checkForConclusion };
