/*
  GLOBAL CONSTANT VARIABLES
  */

var WHITE = "#ffffff"  // Have replaced with SystemPalette.window
var BLACK = "#000000"
var BLUE = "#0000ff"
var LIGHTBLUE = "#6060ff"

var KEYS = []  // Array of hexidecimal representations of Qt.Key_ 's (see Qt Namespace doc)
for (var i = 0x41; i <= 0x5a; i++) {
    KEYS.push(i)
}


/*
  FUNCTIONS
  */

function numberOfClues() {
    /* Provides the total number of Down and Across clues
      in the puzzle.
      Returns: a 2-element list containing two ints:
               [# of across clues, # of down clues]
      */
    var acrossClues = 0;
    var downClues = 0;

    for (var i = 0; i < xGrid.columns * xGrid.rows; i++) {

        var box = gridRepeater.itemAt(i);

        if (box.number != "") {
            if (i < xGrid.columns || gridRepeater.itemAt(i - xGrid.columns).color == BLACK) {
                downClues += 1;
            }
            if (i % xGrid.columns == 0 || gridRepeater.itemAt(i - 1).color == BLACK) {
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

    for (var i = 0; i < xGrid.columns * xGrid.rows; i++) {

        var box = gridRepeater.itemAt(i);

        if (box.number != "") {
            if (i < xGrid.columns || gridRepeater.itemAt(i - xGrid.columns).color == BLACK) {
                downClueNums.push(box.number);
                //downBoxNums.push(box.constIndex);  // just put i?
            }
            if (i % xGrid.columns == 0 || gridRepeater.itemAt(i - 1).color == BLACK) {
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
        var box = gridRepeater.itemAt(i);
        var color = box.color;
        if (color == BLACK) {
            box.number = "";
        }

        if (color != BLACK) {
            if (box.constIndex < cols || box.constIndex % cols == 0) {
                box.number = num;  // Does QML do automatic type coercion?? YES
                num += 1;
            } else {
                var boxAbove = gridRepeater.itemAt(i - cols);
                var boxToLeft = gridRepeater.itemAt(i - 1);

                if (boxAbove.color == BLACK || boxToLeft.color == BLACK) {
                    box.number = num;
                    num += 1;
                } else {
                    box.number = ""; // Getting rid of numbers for boxes that shouldn't have them any more.
                }
            }
        }
    }
}

function blackWhite(box) {
    /*Changes boxes to black or white. Optionally
      changes the symmetrical box to black or white as well,
      provided the "symmetry" CheckBox{} is checked.
      box: the Rectangle{} object that is the parent of the clicked MouseArea{}
      (i.e. the box that you clicked on while editing black and white boxes)
      */
    if (box.color == BLACK) {
        box.color = LIGHTBLUE
    } else {
        box.color = BLACK;
        box.letter = "";
    }
    if (symmetric.checked) {
        var maxIndex = (xGrid.columns * xGrid.rows) - 1;
        var symmetricBox = gridRepeater.itemAt(maxIndex - box.constIndex);
        if (symmetricBox === box) {  // Middle box is its own symmetric partner
            return
        }
        if (symmetricBox.color == BLACK) {
            symmetricBox.color = palette.window
        } else {
            symmetricBox.color = BLACK;
            symmetricBox.letter = "";
        }
    }
}


function autoMove(box) {
    /* Automatically shifts the focus to the next box right or down,
      depending on clicks (default is right, then it alternates
      by click, not resetting if a click was made to a new box
      box: the box that currently has focus
      */
    if (xGrid.autoMoveDirection % 2 === 0) {
        if (box.constIndex % xGrid.columns !== (xGrid.columns - 1)) {
            gridRepeater.itemAt(box.constIndex + 1).focus = true;
        }
    } else if (xGrid.autoMoveDirection % 2 === 1) {
        if (box.constIndex < (xGrid.columns * xGrid.rows) - xGrid.columns) {
            gridRepeater.itemAt(box.constIndex + xGrid.columns).focus = true;
        }
    }
}

function keysMove(event, index) {
    /* Lets the user use arrow keys to navigate around the
      crossword. Requires a Repeater for the "index" property.
      event: the keystroke event
      index: the index as generated by the Repeater
      returns: Nothing. Attempts to reassign the focus based on arrow keys

      NOTE: KeyNavigation is an alternative implementation, but would
      be just as much of a pain to make, given the edge conditions.
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
}

//Helper functions for moving around.
function moveUp(event, index) {
    if (index >= xGrid.columns) {
        gridRepeater.itemAt(index - xGrid.columns).focus = true
    }
}

function moveDown(event, index) {
    if (index < (xGrid.columns * xGrid.rows) - xGrid.columns) {
        gridRepeater.itemAt(index + xGrid.columns).focus = true
    }
}

function moveRight(event, index) {
    if (index % xGrid.columns !== (xGrid.columns - 1)) {
        gridRepeater.itemAt(index + 1).focus = true
    }
}

function moveLeft(event, index) {
    if (index % xGrid.columns !== 0) {
        gridRepeater.itemAt(index - 1).focus = true
    }
}
// End helper functions
