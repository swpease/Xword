/*
  GLOBAL CONSTANT VARIABLES
  */

var BLACK = "#000000"
var WHITE = "#ffffff"
var DARKGREY = "#333333"
var BLUE = "#0000ff"
var LIGHTBLUE = "#6060ff"

var KEYS = []  // Array of hexidecimal representations of Qt.Key_ 's (see Qt Namespace doc)
for (var i = 0x41; i <= 0x5a; i++) {
    KEYS.push(i)
}

/*
  FUNCTIONS
  */

function getCluesAndInfo() {
    /* Collects the metadata and the clues from the crossword for pdf exporting.
      */
    return collectData().slice(3,5);
}

function saveData() {
    /* Collects the data needed to save the crossword's current state:
      returns [dims, states, letters, clues, metadata]
      */
    return collectData().slice(0,5);
}

function collectData() {
    /* Collects data from a crossword.
      Generates six arrays:
          (1) The crossword dimensions [row, col]
          (2) The state ("" or "BLANKSPACE") of each Square
          (3) The letter of each Square
          (4) The clues for each word [[acrosses], [downs]]
          (5) The metadata [puzzlename, date, author]
          (6) The number for each Square
      */

    var dims = [xWord.rows, xWord.columns];
    var states = [];
    var letters = [];
    var clues = [];
    var metadata = [metadataForm.puzzleName, metadataForm.date, metadataForm.author]
    var numbers = [];

    for (var i = 0; i < xWord.columns * xWord.rows; i++) {
        var box = xWord.gridRepeater.itemAt(i);
        states.push(box.state);
        letters.push(box.letter);
        numbers.push(box.number);
    }

    clues.push(acrossClues.getCluesText());
    clues.push(downClues.getCluesText());

    return [dims, states, letters, clues, metadata, numbers];
}

function loadData(cppData) {
    /* Loads a saved crossword back up.
      Input is a QVariantList of QVariantLists,
      which is auto-converted into an array of arrays.
      The arrays:
         (1) The crossword dimensions
         (2) The state ("" or "BLANKSPACE")
         (3) The letter (if state == ""...)
         (4) The clues as an array of arrays [[across], [down]] (may be empty)
         (5) The metadata as an array of strings
      */

    var dims = cppData[0];
    var states = cppData[1];
    var letters = cppData[2];
    var clues = cppData[3];
    var metadata = cppData[4];

    xWord.rows = dims[0];
    xWord.columns = dims[1];

    for (var i = 0; i < xWord.columns * xWord.rows; i++) {
        var box = xWord.gridRepeater.itemAt(i);
        box.letter = letters[i];
        box.state = states[i];
    }
    assignNums(xWord.rows, xWord.columns);

    xWord.visible = true;

    if(clues != []) {
        var numClues = numberOfClues();
        acrossClues.model = numClues[0];
        downClues.model = numClues[1];
        acrossClues.setCluesText(clues[0]);
        downClues.setCluesText(clues[1]);
    }

    metadataForm.puzzleName = metadata[0];
    metadataForm.date = metadata[1];
    metadataForm.author = metadata[2];

    return;
}

function numberOfClues() {
    /* Provides the total number of Down and Across clues
      in the puzzle.
      Returns: a 2-element list containing two ints:
               [# of across clues, # of down clues]
      */
    var acrossClues = 0;
    var downClues = 0;

    for (var i = 0; i < xWord.columns * xWord.rows; i++) {

        var box = xWord.gridRepeater.itemAt(i);

        if (box.number != "") {
            if (i < xWord.columns || xWord.gridRepeater.itemAt(i - xWord.columns).state == "BLANKSPACE") {
                downClues += 1;
            }
            if (i % xWord.columns == 0 || xWord.gridRepeater.itemAt(i - 1).state == "BLANKSPACE") {
                acrossClues += 1;
            }
        }
    }
    return [acrossClues, downClues];
}

function collectClueNums() {
    /* Collects the numbers for Across and Down clues into lists,
      like:
          [[AcrossNums], [DownNums]]
      so to access the fourth Across clue's number, you would write:
          collectClueNums()[0][4]
      returns: a list of two lists, each comprising the numbers
               associated with each Across (first list) or Down
               (second list) clue.
      POSSIBLE MODIFICATION: add in the index of the boxes in separate lists,
      accessible in the same manner.
      */

    var acrossClueNums = [];
    var downClueNums = [];
    //var acrossBoxNums = [];  // for if I want to do some fancy stuff later
    //var downBoxNums = [];  // ""

    for (var i = 0; i < xWord.columns * xWord.rows; i++) {

        var box = xWord.gridRepeater.itemAt(i);

        if (box.number != "") {
            if (i < xWord.columns || xWord.gridRepeater.itemAt(i - xWord.columns).state == "BLANKSPACE") {
                downClueNums.push(box.number);
                //downBoxNums.push(box.constIndex);  // just put i?
            }
            if (i % xWord.columns == 0 || xWord.gridRepeater.itemAt(i - 1).state == "BLANKSPACE") {
                acrossClueNums.push(box.number);
                //acrossBoxNums.push(box.constIndex); // just put i?
            }
        }
    }
    return [acrossClueNums, downClueNums];
}

function assignNums(rows, cols) {
    /* Assigns numbers to those white boxes that are the starts of
      words in the crossword (e.g. 1-Across and 1-Down's box gets
      numbered "1" in the top left corner)
      rows: rows in the crossword
      cols: columns in the crossword
      */

    var num = 1; // The number to actually assign to the box

    for (var i = 0; i < rows * cols; i++) {
        var box = xWord.gridRepeater.itemAt(i);

        if (box.state == "BLANKSPACE") {
            box.number = "";
        }

        if (box.state == "") {
            if (box.constIndex < cols || box.constIndex % cols == 0) {  // Could just use i
                box.number = num;  // Does QML do automatic type coercion? YES
                num += 1;
            } else {
                var boxAbove = xWord.gridRepeater.itemAt(i - cols);
                var boxToLeft = xWord.gridRepeater.itemAt(i - 1);

                if (boxAbove.state == "BLANKSPACE" || boxToLeft.state == "BLANKSPACE") {
                    box.number = num;
                    num += 1;
                } else {
                    box.number = ""; // Getting rid of numbers for boxes that shouldn't have them any more.
                }
            }
        }
    }

    return;
}

function blackWhite(box) {
    /*Changes boxes to black or white. Optionally
      changes the symmetrical box to black or white as well,
      provided the "symmetry" CheckBox{} is checked.
      box: the Rectangle{} object that is the parent of the clicked MouseArea{}
      (i.e. the box that you clicked on while editing black and white boxes)
      */

    box.state == "" ? box.state = "BLANKSPACE" : box.state = "";

    if (symmetric.checked) {
        var maxIndex = (xWord.columns * xWord.rows) - 1;
        var symmetricBox = xWord.gridRepeater.itemAt(maxIndex - box.constIndex);

        if (symmetricBox.state == box.state)
               return
        symmetricBox.state == "" ? symmetricBox.state = "BLANKSPACE" : symmetricBox.state = "";
    }

    return;
}


function autoMove(box) {
    /* Automatically shifts the focus to the next box right or down,
      depending on clicks (default is right, then it alternates
      by click, not resetting if a click was made to a new box
      box: the box that currently has focus
      */
    if (!xWord.autoMoveDown) {
        if (box.constIndex % xWord.columns !== (xWord.columns - 1)) {
            xWord.gridRepeater.itemAt(box.constIndex + 1).focus = true;
        }
    } else if (xWord.autoMoveDown) {
        if (box.constIndex < (xWord.columns * xWord.rows) - xWord.columns) {
            xWord.gridRepeater.itemAt(box.constIndex + xWord.columns).focus = true;
        }
    }

    return;
}

function keysMove(event, index) {
    /* Lets the user use arrow keys to navigate around the
      crossword. Requires a Repeater for the "index" property.
      event: the keystroke event
      index: the index as generated by the Repeater
      returns: Nothing. Attempts to reassign the focus based on arrow keys
      */
    if (event.key === Qt.Key_Up) {
        event.accepted = true
        moveUp(event, index)
    }
    else if (event.key === Qt.Key_Down) {
        event.accepted = true
        moveDown(event, index)
    }
    else if (event.key === Qt.Key_Left) {
        event.accepted = true
        moveLeft(event, index);
    }
    else if (event.key === Qt.Key_Right) {
        event.accepted = true
        moveRight(event, index);
    }

    return;
}

//Helper functions for moving around.
function moveUp(event, index) {
    if (index >= xWord.columns) {
        xWord.gridRepeater.itemAt(index - xWord.columns).focus = true
    }
}

function moveDown(event, index) {
    if (index < (xWord.columns * xWord.rows) - xWord.columns) {
        xWord.gridRepeater.itemAt(index + xWord.columns).focus = true
    }
}

function moveRight(event, index) {
    if (index % xWord.columns !== (xWord.columns - 1)) {
        xWord.gridRepeater.itemAt(index + 1).focus = true
    }
}

function moveLeft(event, index) {
    if (index % xWord.columns !== 0) {
        xWord.gridRepeater.itemAt(index - 1).focus = true
    }
}
// End helper functions
