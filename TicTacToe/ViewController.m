//
//  ViewController.m
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/2/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//
#import "ViewController.h"
#import "HelpWebViewController.h"
#import "TicTacToeBoard.h"

const int kTurnTimerValue = 10;

@interface ViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelFive;
@property (weak, nonatomic) IBOutlet UILabel *labelSix;
@property (weak, nonatomic) IBOutlet UILabel *labelSeven;
@property (weak, nonatomic) IBOutlet UILabel *labelEight;
@property (weak, nonatomic) IBOutlet UILabel *labelNine;
@property (weak, nonatomic) IBOutlet UILabel *whichPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelXOToDrag;
@property (strong, nonatomic) NSMutableArray *ticTacToeBoard;
@property (strong, nonatomic) NSArray *labelsArray;
@property int mostRecentlyTappedSquare;
@property CGPoint originalCenterPointForDraggableXOLabel;

@property BOOL hasGameBegun;
@property BOOL isTurnTimedGame;

@property NSTimer *turnTimer;
@property int turnTimerCounter;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gameTimerSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property int playerScore;
@property int computerScore;
@property NSInteger indexOfSquareToMove;

@property BOOL areYouPlayingAComputer;

@property NSArray *topRow;
@property NSArray *middleRow;
@property NSArray *bottomRow;
@property NSArray *diagLeftRow;
@property NSArray *diagRightRow;
@property NSArray *leftRow;
@property NSArray *middleVertRow;
@property NSArray *rightRow;
@property NSArray *arrayOfRows;

@property BOOL validMoveNotFound;
@property BOOL hasComputerMadeFirstMove;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.topRow = @[@0,@1,@2];
    self.middleRow = @[@3,@4,@5];
    self.bottomRow = @[@6,@7,@8];
    self.diagLeftRow = @[@0,@4,@8];
    self.diagRightRow = @[@2,@4,@6];
    self.leftRow = @[@0,@3,@6];
    self.middleVertRow = @[@1,@4,@7];
    self.rightRow = @[@2,@5,@8];

    self.arrayOfRows = @[self.topRow, self.middleRow, self.bottomRow, self.diagLeftRow, self.diagRightRow, self.leftRow, self.middleVertRow, self.rightRow];

    [self resetBoard];

    self.areYouPlayingAComputer = YES;
    self.playerScore = 5;
    self.computerScore = 11;
    self.originalCenterPointForDraggableXOLabel = self.labelXOToDrag.center;
    self.isTurnTimedGame = NO;
    self.turnTimerCounter = kTurnTimerValue;

    [self.gameTimerSegmentedControl addTarget:self
                                       action:@selector(gameTimerSegmentedControlChanged:)
                             forControlEvents:UIControlEventValueChanged];
}

- (void)resetBoard {
    self.labelOne.text   = @"";
    self.labelTwo.text   = @"";
    self.labelThree.text = @"";
    self.labelFour.text  = @"";
    self.labelFive.text  = @"";
    self.labelSix.text   = @"";
    self.labelSeven.text = @"";
    self.labelEight.text = @"";
    self.labelNine.text  = @"";

    self.labelsArray = nil;
    self.labelsArray = [[NSArray alloc] init];
    self.labelsArray = @[self.labelOne, self.labelTwo, self.labelThree, self.labelFour, self.labelFive, self.labelSix, self.labelSeven, self.labelEight, self.labelNine];

    self.validMoveNotFound = YES;
    self.hasComputerMadeFirstMove = NO;

    //int counter = 0;

    /*for (UILabel *label in self.labelsArray) {
        label.text = @"";
        self.ticTacToeBoard[counter] = @"0";
        counter++;
    } */

    [self updateWhichPlayerLabel:@"Player One"];
    self.labelXOToDrag.textColor = [UIColor blueColor];
    self.labelXOToDrag.text = @"X";

    self.ticTacToeBoard = [[NSMutableArray alloc] initWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];

    self.labelXOToDrag.textColor = [UIColor blueColor];

    // Set player initial player
    self.whichPlayerLabel.text = @"Player One";
    self.timerLabel.text = [NSString stringWithFormat:@"%i", kTurnTimerValue];
    self.timerLabel.alpha = 0.0;

    self.hasGameBegun = NO;
    self.mostRecentlyTappedSquare = 0;
    self.indexOfSquareToMove = 0;
}

- (void)gameTimerSegmentedControlChanged: (id)sender {
    if (self.gameTimerSegmentedControl.selectedSegmentIndex == 0) {
        //Turn off Timer
    }
    else
    {
        [self startTurnTimer];
        self.gameTimerSegmentedControl.enabled = NO;
        [UIView animateWithDuration:1.0 animations:^{
            self.timerLabel.alpha = 1.0;
        }];
    }
}

- (UILabel *)findLabelUsingPoint:(CGPoint)point
{
    UILabel *tappedLabel;
    for (UILabel *label in self.labelsArray)
    {
        if (CGRectContainsPoint(label.frame, point))
        {
            tappedLabel = label;
            if (!self.hasGameBegun)
            {
                self.hasGameBegun = YES;
            }
        }
    }
    return tappedLabel;
}

- (IBAction)onLabelTapped:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.view];
    UILabel *tappedLabel = [self findLabelUsingPoint:point];

    [self updateTappedLabel:tappedLabel];
    //NSLog(@"%ld", (long)self.indexOfSquareToMove);
    //[self makeComputersMove];
}

- (void)updateTappedLabel: (UILabel *)tappedLabel
{
    // The user tapped on an empty tic tac toe square
    if ([tappedLabel.text isEqualToString:@""])
    {
        // Update the tictactoeBoard Array to have a 1 or 2 instead of a 0 at index user tapped
        [self updateTicTacToeBoardArray:tappedLabel];
        // If it's player one or the human player's turn...
        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"])
        {
            // Player one's turn
            tappedLabel.text = @"X";
            tappedLabel.textColor = [UIColor blueColor];
            [self updateWhichPlayerLabel:@"Player Two"];
            [self updateLabelXOToDrag];
            [self whoWon];

            //if (self.hasGameBegun && self.hasComputerMadeFirstMove == NO) { self.hasComputerMadeFirstMove == NO
            if (self.hasGameBegun) {
                int counter = 0;
                while (counter < 8) {
                    [self makeComputersMove:self.arrayOfRows[counter]];
                    counter++;

                    //UILabel *computersMoveLabel = [self.labelsArray objectAtIndex:self.indexOfSquareToMove];
                    //[self updateTappedLabel:computersMoveLabel];
                }
                UILabel *computersMoveLabel = [self.labelsArray objectAtIndex:self.indexOfSquareToMove];
                [self updateTappedLabel:computersMoveLabel];
            }
            //[self whoWon];
            if (self.gameTimerSegmentedControl.selectedSegmentIndex == 1) {
                [self stopTurnTimer];
                [self startTurnTimer];
            }
            else {
                self.gameTimerSegmentedControl.enabled = NO;
            }
        }
        else {
            // Player two's turn
            tappedLabel.text = @"O";
            tappedLabel.textColor = [UIColor redColor];
            [self updateWhichPlayerLabel: @"Player One"];
            [self updateLabelXOToDrag];
            [self whoWon];

           /* if (self.hasGameBegun) {
                int counter = 0;
                while (counter < 8) {
                        [self makeComputersMove:self.arrayOfRows[counter]];
                        counter++;
                    }
                UILabel *computersMoveLabel = [self.labelsArray objectAtIndex:self.indexOfSquareToMove];
                [self updateTappedLabel:computersMoveLabel];
            }*/
            self.validMoveNotFound = YES;
            if (self.gameTimerSegmentedControl.selectedSegmentIndex == 1) {
                [self stopTurnTimer];
                [self startTurnTimer];
            }
            else {
                self.gameTimerSegmentedControl.enabled = NO;
            }
        }
    }
    else
    {
        /*if (self.hasGameBegun) {
            [self makeComputersMove];
        }*/
    }
}

- (void)updateWhichPlayerLabel: (NSString *)player {
    self.whichPlayerLabel.text = player;
}

- (void)updateLabelXOToDrag {
    if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
        self.labelXOToDrag.textColor = [UIColor blueColor];
        self.labelXOToDrag.text = @"X";
    }
    else
    {
        self.labelXOToDrag.textColor = [UIColor redColor];
        self.labelXOToDrag.text = @"O";
    }
}

- (void)updateTicTacToeBoardArray: (UILabel *)tappedLabel {
    int indexOfTappedSquare = (int)[self.labelsArray indexOfObject:tappedLabel];
    // Change the index of where the user moved to a 1 or 2 respectively
    if ([self.ticTacToeBoard[indexOfTappedSquare] isEqualToString:@"0"]) {
        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
            self.ticTacToeBoard[indexOfTappedSquare] = @"1";
        }
        else {
            self.ticTacToeBoard[indexOfTappedSquare] = @"2";
        }
    }
}


- (IBAction)printBoardArray:(id)sender {
//    for (NSString *boardSquare in self.ticTacToeBoard) {              <------------- HERE I AM!!! **********************************
//
//    }
    //NSLog(@"%@", self.ticTacToeBoard);
    //[self getValidMoves];
    //NSArray *boardScore = [self getBoardScore];
    //[self calculateComputersMove:boardScore];
}

- (void)getValidMoves {
    NSMutableArray *indexesWhereCompCanMove = [[NSMutableArray alloc] init];

    for (int a = 0; a < self.ticTacToeBoard.count; a++) {
        if ([self.ticTacToeBoard[a] isEqualToString:@"0"]) {
            [indexesWhereCompCanMove addObject:[NSNumber numberWithInt:a]];
        }
    }
}

- (void)makeComputersMove: (NSArray *)rowToTest
{ // TODO - Test all rows to make sure it will get you a good move for all.
    // Getting object on board at [0][0]
    NSInteger valueAtTopLeft = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[rowToTest[0] integerValue]]] integerValue];
    // Getting object on board at [0][1]
    NSInteger valueAtMiddleTop = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[rowToTest[1] integerValue]]] integerValue];
    // Getting object on board at [0][2]
    NSInteger valueAtTopRight = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[rowToTest[2] integerValue]]] integerValue];
    NSLog(@"%ld, %ld, %ld", (long)valueAtTopLeft, (long)valueAtMiddleTop, (long)valueAtTopRight);

    // attacking code
    if (valueAtTopLeft != 1 && valueAtTopLeft != 2 && valueAtMiddleTop == 2 && valueAtTopRight == 2) {
        // Win to the left
        self.indexOfSquareToMove = [rowToTest[0] integerValue];
        self.validMoveNotFound = NO;
        NSLog(@"Win left");
    } else if (valueAtTopLeft == 2 && valueAtMiddleTop != 1 && valueAtMiddleTop != 2 && valueAtTopRight == 2) {
        // Win to the middle
        self.indexOfSquareToMove = [rowToTest[1] integerValue];
        self.validMoveNotFound = NO;
        NSLog(@"Win middle");
    } else if (valueAtTopLeft == 2 && valueAtMiddleTop == 2 && valueAtTopRight != 2 && valueAtTopRight != 1) {
        // Win to the right
        self.indexOfSquareToMove = [rowToTest[2] integerValue];
        self.validMoveNotFound = NO;
        NSLog(@"Win right");
    } else
    {
        // Blocking Code
        if (valueAtTopLeft != 2 && valueAtTopLeft != 1 && valueAtMiddleTop == 1 && valueAtTopRight == 1) {
            // Block to the left
            self.indexOfSquareToMove = [rowToTest[0] integerValue];
            self.validMoveNotFound = NO;
            NSLog(@"Block left");
        } else if (valueAtTopLeft == 1 && valueAtMiddleTop != 1 && valueAtMiddleTop != 2 && valueAtTopRight == 1) {
            // Block to the middle
            self.indexOfSquareToMove = [rowToTest[1] integerValue];
            self.validMoveNotFound = NO;
            NSLog(@"Block middle");
        } else if (valueAtTopLeft == 1 && valueAtMiddleTop == 1 && valueAtTopRight != 2 && valueAtTopRight != 1) {
            // Block to the right
            self.indexOfSquareToMove = [rowToTest[2] integerValue];
            self.validMoveNotFound = NO;
            NSLog(@"Block right");
        }
        else { // Otherwise make random valid move
            self.indexOfSquareToMove = [[self getRandomValidIndexToMove] integerValue];
            self.validMoveNotFound = NO;
            NSLog(@"Make a random move");
        }

    }

    //UILabel *computersMoveLabel = [self.labelsArray objectAtIndex:self.indexOfSquareToMove];

    //[self updateTappedLabel:computersMoveLabel];
    self.hasComputerMadeFirstMove = YES;
}

- (NSNumber *)getRandomValidIndexToMove {
    int sizeOfEmptySquareIndexesCounter = 0;
    int indexCounter = 0;
    NSNumber *randomValidIndexToMove;
    NSMutableArray *emptySquareIndexes = [[NSMutableArray alloc] init];

    for (NSNumber *boardSquareValue in self.ticTacToeBoard) {

        if ([boardSquareValue integerValue] == 0) {
            sizeOfEmptySquareIndexesCounter++;
            NSNumber *emptyBoardIndex = [NSNumber numberWithInt:indexCounter];
            [emptySquareIndexes addObject:emptyBoardIndex];
        }
        indexCounter++;
    }
    if (emptySquareIndexes.count > 0) {
        NSInteger randomIndex = arc4random() % sizeOfEmptySquareIndexesCounter;
        randomValidIndexToMove = [emptySquareIndexes objectAtIndex:randomIndex];
    }
       return randomValidIndexToMove;
}

- (NSString *)whoWon {
    NSString *winner = @"No Winner";
    NSString *playerOne = @"X";
    NSString *playerTwo = @"O";

    if ([[self checkWhichPlayerWon:playerOne playerNumberString:@"1"] isEqualToString:playerOne])
    {
        winner = playerOne;
    }
    else if ([[self checkWhichPlayerWon:playerTwo playerNumberString:@"2"] isEqualToString:playerTwo])
    {
        winner = playerTwo;
    }

    if ([winner isEqualToString:playerOne])
    {
        self.hasGameBegun = NO;
        [self showWinnerAlert:winner];
    }
    else if ([winner isEqualToString:playerTwo])
    {
        self.hasGameBegun = NO;
        [self showWinnerAlert:winner];
    }

    // winner will be equal to Tie! if there is a Tie.
    [self checkForTie:winner];

    return winner;
}

- (void)showWinnerAlert: (NSString *)winner {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.delegate = self;
    if ([winner isEqualToString:@"X"]) {
        alertView.title = @"Player One Wins!";
    } else if ([winner isEqualToString:@"O"]) {
        alertView.title = @"Player Two Wins!";
    } else if ([winner isEqualToString:@"Tie!"]) {
        alertView.title = @"Tie!";
    }

    [alertView addButtonWithTitle:@"New Game"];
    [alertView show];
}

- (void)checkForTie: (NSString *)winner {
    int fullSquares = 0;
    for (int counter = 0; counter < self.ticTacToeBoard.count; counter++)
    {
        // Check if there is no winner and that board is full
        if ([winner isEqualToString:@"No Winner"] && ![@"0" isEqualToString:[self.ticTacToeBoard objectAtIndex:counter]])
        {
            fullSquares++;
        }
    }
    if (fullSquares == self.ticTacToeBoard.count) {
        [self showWinnerAlert:@"Tie!"];
    }

}

- (NSString *)checkWhichPlayerWon: (NSString *)player playerNumberString:(NSString *)playerNumberString {
    // Check for win accross top win
    if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.topRow] isEqualToString:player]) {
        return player;
    } // Check for win accross middle win
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.middleRow] isEqualToString:player]) {
        return player;
    } // Check for win accross bottom win
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.bottomRow] isEqualToString:player]) {
        return player;
    } // Check for win straight down left
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.leftRow] isEqualToString:player]) {
        return player;
    } // Check for win straight down middle
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.middleVertRow] isEqualToString:player]) {
        return player;
    } // Check for win straight down right
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.rightRow] isEqualToString:player]) {
        return player;
    } // Check for win diagonal starting a top left
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.diagLeftRow] isEqualToString:player]) {
        return player;
    } // Check for win diagonal starting a top right
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.diagRightRow] isEqualToString:player]) {
        return player;
    } else {
        return @"No Winner";
    }
}

- (NSString *)checkBoardForValidWin: (NSString *)playerToCheck
                       playerNumber: (NSString *)playersNumberString
                         rowToCheck: (NSArray *)rowToCheck{

    NSInteger checkOne = [rowToCheck[0] integerValue];
    NSInteger checkTwo = [rowToCheck[1] integerValue];
    NSInteger checkThree = [rowToCheck[2] integerValue];
    if ([self.ticTacToeBoard[checkOne] isEqualToString:playersNumberString] &&
        [self.ticTacToeBoard[checkTwo] isEqualToString:playersNumberString] &&
        [self.ticTacToeBoard[checkThree] isEqualToString:playersNumberString])
    {
        return playerToCheck;
    }
    else
    {
        return playerToCheck = @"";
    }
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if (buttonIndex == 0){
        [self resetBoard];
        [self stopTurnTimer];
        [UIView animateWithDuration:1.0 animations:^{
            self.timerLabel.alpha = 0.0;
        }];
        self.gameTimerSegmentedControl.selectedSegmentIndex = 0;
        self.gameTimerSegmentedControl.enabled = YES;
    }
}

- (IBAction)onDrag:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture locationInView:self.view];
    self.labelXOToDrag.center = point;

    /* // Uncomment this to make the labelXOToDrag only when you're touching it,
     // But for some reason in makes the lagging really buggy and slow so I'm sticking with
     // the two lines above.
    if (CGRectContainsPoint(self.labelXOToDrag.frame, point)) {
        self.labelXOToDrag.center = point;
    } */


    if (panGesture.state == UIGestureRecognizerStateEnded) {

        for (UILabel *label in self.labelsArray) {
            if (CGRectContainsPoint(label.frame, point) && [label.text isEqualToString:@""]) {
                if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
                    [self updateTicTacToeBoardArray:label];
                    [self dragLabelOnToBoardForPlayer:@"Player One" playerColor:[UIColor blueColor] playerLetter:@"X" label:label];
                    //[self whoWon];
                }
                else
                {
                    [self updateTicTacToeBoardArray:label];
                    [self dragLabelOnToBoardForPlayer:@"Player Two" playerColor:[UIColor redColor] playerLetter:@"O" label:label];
                    //[self whoWon];
                }
            }
            else {
                [UIView animateWithDuration:0.5 animations:^{
                    self.labelXOToDrag.center = self.originalCenterPointForDraggableXOLabel;
                }];
            }
        }
        [self whoWon];
    }
}


- (void)dragLabelOnToBoardForPlayer: (NSString *)player
                        playerColor:(UIColor *)playercolor
                       playerLetter:(NSString *)playerLetter
                              label:(UILabel *)label {
    if ([self.whichPlayerLabel.text isEqualToString:player])
    {
        label.text = playerLetter;
        label.textColor = playercolor;
        self.labelXOToDrag.alpha = 0.0;
        self.labelXOToDrag.center = self.originalCenterPointForDraggableXOLabel;
        // Switch the player who's turn it is
        if ([player isEqualToString:@"Player One"]) {
            [self updateWhichPlayerLabel:@"Player Two"];
        } else {
            [self updateWhichPlayerLabel:@"Player One"];
        }

        // Place the label at it's original location and switch it's text to the now current player
        [UIView animateWithDuration:1.0 animations:^{
            if ([playerLetter isEqualToString:@"X"]) {
                [self updateLabelXOToDrag];
            } else {
                [self updateLabelXOToDrag];
            }
            self.labelXOToDrag.alpha = 1.0;
        }];
    }
}

- (void)startTurnTimer {
    if (self.turnTimer) {
        [self stopTurnTimer];
    }
    self.turnTimerCounter = kTurnTimerValue;
    self.turnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(turnCountdown)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopTurnTimer {
    if (self.turnTimer) {
        [self.turnTimer invalidate];
        self.turnTimer = nil;
    }
}

- (void)resetTurnTimer {
    [self stopTurnTimer];
    self.timerLabel.text = [NSString stringWithFormat:@"%i", kTurnTimerValue];
}

- (void)turnCountdown {
    if (self.turnTimerCounter == 0) {
        if (self.turnTimer) {
            [self stopTurnTimer];
            [self forfitCurrentUsersTurn];
            [self startTurnTimer];
        }
    }
    //timerLabel
    self.timerLabel.text = [NSString stringWithFormat:@"%i", self.turnTimerCounter];
    self.turnTimerCounter--;
}

- (void)forfitCurrentUsersTurn {
    if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
        [self updateWhichPlayerLabel:@"Player Two"];
        [self updateLabelXOToDrag];
    }
    else
    {
        [self updateWhichPlayerLabel:@"Player One"];
        [self updateLabelXOToDrag];
    }
}
- (IBAction)onHelpedButtonPressed:(id)sender {
    HelpWebViewController *helpWebViewController = [[HelpWebViewController alloc] init];
    //[self presentViewController:helpWebViewController animated:NO completion:nil];
    UIStoryboardSegue *helpSeque = [[UIStoryboardSegue alloc] initWithIdentifier:@"helpSeque" source:self destination:helpWebViewController];
    [self prepareForSegue:helpSeque sender:self];
}

@end
