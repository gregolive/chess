# Chess

A command line version of chess made in Ruby.

Live demo on [Replit](https://replit.com/@gregolive/Chess) 👈

## Functionality

Classes:
- **Game** controls the overall flow of the game by prompting the player(s), display output to the console and checks for important game conditions (i.e. checkmate).
- **Board** creates an array game board with subarrays for each row containing chess pieces or nil when a space is empty. Updates the board when a move is made and determines the possible moves for each piece on the board. Having
- **ChessPieces** creates the chessboard pieces with each being a hash containing the type of piece, it's owner, it's current position, and it's possible moves from this current position.
- **Database** is used to save and load the current state of an in progress game via Game class instance variables. Serialization is completed using YAML since there the size requirements are small.

On startup:
- The player chooses whether to begin a new game or load a previously saved game. To load a game they must choose a saved game by entering the save file name.
- When starting a new game, the player(s) are prompted to select a single player against a computer or two players against each other. The computer player simply makes random moves, unless in check when it is forced to make a legal move to continue the game.
- In single player, the player has the option to play as the white or black pieces.

In game:
- Methods included in the Board class calculate the possible moves for each piece on the board, based on the type of piece, the piece location on the board and interference by other pieces.
- The board is displayed prior to each turn, along with a message stating whose turn it is and a warning if the player is in check.
- Players take turns making moves by first entering the coordinates of the piece they would like to move, followed by the coordinates they want to move the piece to. Checks are completed to ensure: 1) players enter proper board coordinates 2) players are attempting to move their own piece 3) players are not attempting to select a piece that cannot move in its current position 4) players make a move that is legal for the selected piece type 5) when in check, players are only making a move that gets them out of check
- If a player enters a piece to move but change their mind, they can enter 'back' instead of the target coordinates and select a new piece.
- A player can save the game state at anytime by entering 'save' at the start of their turn. The player is then prompted to enter a save file name and the program stops. 


## Reflection

In this 'final' pure Ruby project, most of the core Ruby concepts I have learned over the past month were combined into what turned out to be quite a challenging project. For many of the concepts, like serialization, implementation for this project was similar enough to past projects that there was nothing overly challenging. Including a computer player was also straightforward since it was kept simple with random moves. The problems I did run into were simply the result of the scope and logic of chess itself and the numerous cases that need to be accounted for.

The first big challenge was determining the possible moves of each piece on the board. Having completed the Knight Travails project in the past, I had some experience with the basic logic here, making the task tedious but not overly difficult. There were some special cases that required some care however, such as allowing a piece to move into the space of another piece only if it was a different color. Pawns were complex as well, due to the range of their possible moves in certain conditions (can move 1 or 2 spaces forward on their first turn, can move diagonally if an opposing piece occupies a forward diagonal space, or can only move one space forward otherwise). Some efficiency was achieved with the non pawns by grouping pieces that can move 1 space at a time (king, knight) and pieces that can move 1 or more spaces away (queen, rook, bishop).

The main challenge that stumped me for an extended period of time was checking for the checkmate. While verifying if a player is in check is simple to implement by checking the current status of the board, checking for checkmate requires moving one turn ahead to see if the player in check has any move that can get them out of check. When I tried to implement this, I kept running into an issue where the attacking player or a defending disappeared after rolling the board forward one turn for each of the defenders' moves. To fix this, I saved the position of the attacking player and the defending player being moved, and then rerunning the #refresh_board with the original positions. More testing is needed to ensure that this approach works in the vast scenarios that can arise in a game of chess. 

-Greg Olive