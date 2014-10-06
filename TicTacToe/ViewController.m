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
            if (self.hasGameBegun) {
                [self makeComputersMove];
            }
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

/*- (void)updateTicTacToeBoardArray: (int)ticTacToeSquareTapped {
    if (ticTacToeSquareTapped < 3) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
    else if (ticTacToeSquareTapped > 2 && ticTacToeSquareTapped < 6) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
    else if (ticTacToeSquareTapped > 5 && ticTacToeSquareTapped < 9) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
    [self updateBoardArray:ticTacToeSquareTapped];
}*/

//- (void)updateBoardArray: (int)ticTacToeSquareTapped {
//    // Updates the tic tac toe board array with a 1 or 2 in the index of where the board was tapped
//    // with a 1 or 2 depending on which player just made a move
//    if ([self.ticTacToeBoard[ticTacToeSquareTapped] isEqualToString:@"0"]) {
//        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
//            self.ticTacToeBoard[ticTacToeSquareTapped] = @"1";
//        }
//        else {
//            self.ticTacToeBoard[ticTacToeSquareTapped] = @"2";
//        }
//    }
//}

- (IBAction)printBoardArray:(id)sender {
//    for (NSString *boardSquare in self.ticTacToeBoard) {              <------------- HERE I AM!!! **********************************
//
//    }
    //NSLog(@"%@", self.ticTacToeBoard);
    //[self getValidMoves];
    NSArray *boardScore = [self getBoardScore];
    [self calculateComputersMove:boardScore];
}

- (void)getValidMoves {
    NSMutableArray *indexesWhereCompCanMove = [[NSMutableArray alloc] init];

    for (int a = 0; a < self.ticTacToeBoard.count; a++) {
        if ([self.ticTacToeBoard[a] isEqualToString:@"0"]) {
            [indexesWhereCompCanMove addObject:[NSNumber numberWithInt:a]];
        }
    }
}

/*- (void)makeComputersMove
{
    NSArray *boardScore = [self getBoardScore];
    [self calculateComputersMove:boardScore];

    UILabel *computersMoveLabel = [self.labelsArray objectAtIndex:self.indexOfSquareToMove];
    [self updateTappedLabel:computersMoveLabel];
} */

- (void)makeComputersMove
{ // TODO - Test all rows to make sure it will get you a good move for all.
    // Getting object on board at [0][0]
    NSInteger valueAtTopLeft = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[self.middleRow[0] integerValue]]] integerValue];
    // Getting object on board at [0][1]
    NSInteger valueAtMiddleTop = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[self.middleRow[1] integerValue]]] integerValue];
    // Getting object on board at [0][2]
    NSInteger valueAtTopRight = [[NSString stringWithString:[self.ticTacToeBoard objectAtIndex:[self.middleRow[2] integerValue]]] integerValue];
    NSLog(@"%ld, %ld, %ld", (long)valueAtTopLeft, (long)valueAtMiddleTop, (long)valueAtTopRight);

    // attacking code
    if (valueAtTopLeft != 1 && valueAtTopLeft != 2 && valueAtMiddleTop == 2 && valueAtTopRight == 2) {
        // Win to the left
        //self.indexOfSquareToMove = 0;
        NSLog(@"Win left");
    } else if (valueAtTopLeft == 2 && valueAtMiddleTop != 1 && valueAtMiddleTop != 2 && valueAtTopRight == 2) {
        // Win to the middle
        //self.indexOfSquareToMove = 1;
        NSLog(@"Win middle");
    } else if (valueAtTopLeft == 2 && valueAtMiddleTop == 2 && valueAtTopRight != 2 && valueAtTopRight != 1) {
        // Win to the right
        //self.indexOfSquareToMove = 2;
        NSLog(@"Win right");
    } else
    {
        // Blocking Code
        if (valueAtTopLeft != 2 && valueAtTopLeft != 1 && valueAtMiddleTop == 1 && valueAtTopRight == 1) {
            // Block to the left
            //self.indexOfSquareToMove = 0;
            NSLog(@"Block left");
        } else if (valueAtTopLeft == 1 && valueAtMiddleTop != 1 && valueAtMiddleTop != 2 && valueAtTopRight == 1) {
            // Block to the middle
           // self.indexOfSquareToMove = 1;
            NSLog(@"Block middle");
        } else if (valueAtTopLeft == 1 && valueAtMiddleTop == 1 && valueAtTopRight != 2 && valueAtTopRight != 1) {
            // Block to the right
            //self.indexOfSquareToMove = 2;
            NSLog(@"Block right");
        }
        else { // Otherwise make random valid move
            //self.indexOfSquareToMove = [[self getRandomValidIndexToMove] integerValue];
        }

    }


//    }
    NSInteger topRowScore = valueAtTopLeft + valueAtMiddleTop + valueAtTopRight;
    //NSLog(@"%ld", (long)topRowScore);
    /*
    for (int squareIndex = 0; squareIndex < self.ticTacToeBoard.count; squareIndex++) {
        // Only check to see if a square is a good move if nothing is there.
       // NSLog(@"%@", [self.ticTacToeBoard objectAtIndex:squareIndex]);
        NSInteger indexToMove = 0;
        if ([[self.ticTacToeBoard objectAtIndex:squareIndex] isEqualToString:@""]) {
            switch (squareIndex) {
                case 0:
                    indexToMove = [self checkTopLeftDiagonalLeftRows];
                    NSInteger boardValue = (NSInteger)[self.ticTacToeBoard[[self.topRow[0] integerValue]]]; //+ [self.topRow[1] integerValue] + [self.topRow[2] integerValue];
                    break;
                case 1:
                    //
                    break;
                case 2:
                    //
                    break;
                case 3:
                    //
                    break;
                case 4:
                    //
                    break;
                case 5:
                    //
                    break;
                case 6:
                    //
                    break;
                case 7:
                    //
                    break;
                case 8:
                    //
                    break;
                default:
                    NSLog(@"Out of bounds error");
                    break;
            } // -- End of switch statement
        } // -- End of if square is not 0
    } // -- End of for loop
     */
}

- (NSNumber *)getRandomValidIndexToMove {
    int sizeOfEmptySquareIndexesCounter = 0;
    int indexCounter = 0;
    NSMutableArray *emptySquareIndexes = [[NSMutableArray alloc] init];

    for (NSNumber *boardSquareValue in self.ticTacToeBoard) {

        if ([boardSquareValue integerValue] == 0) {
            sizeOfEmptySquareIndexesCounter++;
            NSNumber *emptyBoardIndex = [NSNumber numberWithInt:indexCounter];
            [emptySquareIndexes addObject:emptyBoardIndex];
        }
        indexCounter++;
    }
    NSInteger randomIndex = arc4random() % sizeOfEmptySquareIndexesCounter;
    NSNumber *randomValidIndexToMove = [emptySquareIndexes objectAtIndex:randomIndex];
    return randomValidIndexToMove;
}

- (void)calculateComputersMove: (NSArray *)boardScore {
    // Iterate through boardScore array
    //NSInteger indexOfSquareToMove = 0;
   /*NSInteger maths = 0;
    for (NSNumber *num in boardScore) {
        maths = maths + [num integerValue];
    }
    NSLog(@"Maths: %li", (long)maths);*/


    NSInteger bestMove = 0;
    NSArray *caseOne = @[@11, @0, @0, @0, @0, @5, @0, @5, @0];

    int counter = 0;
    for (id score in boardScore) {
        if ((int)score == (int)[caseOne objectAtIndex:counter]) {
            counter++;
        }
    }

    if (counter == boardScore.count) {
        [self setRandomIndexForComputerToMove];
    }
    else {
        for (int scoreIndex = 0; scoreIndex < boardScore.count; scoreIndex++) {
            // If the current place on the tic tac toe board is empty (i.e. a valid move)

            if ([[boardScore objectAtIndex:scoreIndex] integerValue] == 0) {
                NSInteger topRowScore, middleRowScore, bottomRowScore, leftRowScore, middleVertScore,
                rightRowScore, leftDiagonalRowScore, rightDiagonalrowScore;
                // Calcualte the score of each row the current square extends to
                if (bestMove != 10)
                {
                    switch (scoreIndex)
                    {
                        case 0:
                            // Looking at top left square. Calculate scores for Top row, diagonal left, left row
                            topRowScore          = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:1 rowSquareThree:2];
                            leftDiagonalRowScore = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:4 rowSquareThree:8];
                            leftRowScore         = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:3 rowSquareThree:6];

                            if (topRowScore == 10) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 10) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftRowScore == 10) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else if (topRowScore == 5) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 5) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftRowScore == 5) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 1:
                            // Looking at top middle square. Calculate scores for Top row, middle vertical row
                            topRowScore     = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:1 rowSquareThree:2];
                            middleVertScore = [self calculateRowScore:boardScore rowSquareOne:1 rowSquareTwo:4 rowSquareThree:7];

                            if (topRowScore == 10) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 10) {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else if (topRowScore == 5) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 5)
                            {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 2:
                            // Looking at top right square. Calculate scores for Top row, diagonal right, right row
                            topRowScore           = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:1 rowSquareThree:2];
                            rightDiagonalrowScore = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:4 rowSquareThree:6];
                            rightRowScore         = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:5 rowSquareThree:8];

                            if (topRowScore == 10) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 10) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 10) {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else if (topRowScore == 5) {
                                bestMove = topRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:topRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 5) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 5)
                            {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 3:
                            // Looking at middle left square. Calculate scores for left row, middle row
                            leftRowScore   = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:3 rowSquareThree:6];
                            middleRowScore = [self calculateRowScore:boardScore rowSquareOne:3 rowSquareTwo:4 rowSquareThree:5];

                            if (leftRowScore == 10) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleRowScore == 10) {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftRowScore == 5) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleRowScore == 5)
                            {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 4:
                            // Looking at middle middle square. Calculate scores for middle & middle vertical squares, diagonal left & right rows
                            middleRowScore        = [self calculateRowScore:boardScore rowSquareOne:3 rowSquareTwo:4 rowSquareThree:5];
                            middleVertScore       = [self calculateRowScore:boardScore rowSquareOne:1 rowSquareTwo:4 rowSquareThree:7];
                            leftDiagonalRowScore  = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:4 rowSquareThree:6];
                            rightDiagonalrowScore = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:4 rowSquareThree:8];

                            if (middleRowScore == 10) {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 10) {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 10) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 10) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else if (middleRowScore == 5) {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 5) {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 5) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 5) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 5:
                            // Looking at middle right square. Calculate scores for middle row, right row
                            middleRowScore = [self calculateRowScore:boardScore rowSquareOne:3 rowSquareTwo:4 rowSquareThree:5];
                            rightRowScore  = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:5 rowSquareThree:8];

                            if (middleRowScore == 10) {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 10) {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleRowScore == 5) {
                                bestMove = middleRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 5) {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 6:
                            // Looking at bottom left square. Calculate scores for left row, bottom row, diagonal right row
                            leftRowScore          = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:3 rowSquareThree:6];
                            bottomRowScore        = [self calculateRowScore:boardScore rowSquareOne:6 rowSquareTwo:7 rowSquareThree:8];
                            rightDiagonalrowScore = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:4 rowSquareThree:6];

                            if (leftRowScore == 10) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else if (bottomRowScore == 10) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 10) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else if (leftRowScore == 5) {
                                bestMove = leftRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftRowScore scoreIndex:scoreIndex];
                            }
                            else if (bottomRowScore == 5) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightDiagonalrowScore == 5) {
                                bestMove = rightDiagonalrowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightDiagonalrowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 7:
                            // Looking at bottom middle square. Calculate scores for bottom row, middle vert row
                            bottomRowScore  = [self calculateRowScore:boardScore rowSquareOne:6 rowSquareTwo:7 rowSquareThree:8];
                            middleVertScore = [self calculateRowScore:boardScore rowSquareOne:1 rowSquareTwo:4 rowSquareThree:7];

                            if (bottomRowScore == 10) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 10) {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else if (bottomRowScore == 5) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (middleVertScore == 5) {
                                bestMove = middleVertScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:middleVertScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        case 8:
                            // Looking at bottom right square. Calculate scores for bottom row, diagonal left row, right row
                            bottomRowScore       = [self calculateRowScore:boardScore rowSquareOne:6 rowSquareTwo:7 rowSquareThree:8];
                            leftDiagonalRowScore = [self calculateRowScore:boardScore rowSquareOne:0 rowSquareTwo:4 rowSquareThree:8];
                            rightRowScore        = [self calculateRowScore:boardScore rowSquareOne:2 rowSquareTwo:5 rowSquareThree:8];

                            if (bottomRowScore == 10) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 10) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 10) {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else if (bottomRowScore == 5) {
                                bestMove = bottomRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:bottomRowScore scoreIndex:scoreIndex];
                            }
                            else if (leftDiagonalRowScore == 5) {
                                bestMove = leftDiagonalRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:leftDiagonalRowScore scoreIndex:scoreIndex];
                            }
                            else if (rightRowScore == 5) {
                                bestMove = rightRowScore;
                                bestMove = [self checkIfBestMove:bestMove scoreToCheck:rightRowScore scoreIndex:scoreIndex];
                            }
                            else {
                                [self setRandomIndexForComputerToMove];
                            }
                            break;
                        default:
                            NSLog (@"Integer out of range");
                            break;
                    }
                }
            }   
        }
    }
    NSLog(@"Best Move Index:%li", (long)self.indexOfSquareToMove);
}

- (NSInteger)checkIfBestMove: (NSInteger)bestMove scoreToCheck:(NSInteger)scoreToCheck scoreIndex:(int)scoreIndex {

    if (bestMove == 10) {
        self.indexOfSquareToMove = scoreIndex;
        return bestMove;
    }
    else {
        return bestMove = scoreToCheck;
    }
}

- (void)setRandomIndexForComputerToMove {
    NSMutableArray *validMovesIndexesArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < self.labelsArray.count; i++) {
        UILabel *currentLabel = [self.labelsArray objectAtIndex:i];
        if ([currentLabel.text isEqualToString:@""]) {
            int validLabelIndex = (int)[self.labelsArray indexOfObject:currentLabel];
            NSLog(@"NE@WDF %ld", (long)validLabelIndex);
            [validMovesIndexesArray addObject:[NSNumber numberWithInteger:validLabelIndex]];
        }
    }
    NSNumber *newIndex;

    if (validMovesIndexesArray.count > 0) {
        int randomNum = arc4random() % 8;
        NSLog(@"randomNumInt: %i", randomNum);

        newIndex = [validMovesIndexesArray objectAtIndex:0];

        for (int i = 0; i < validMovesIndexesArray.count; i++) {
            UILabel *newIndexLabel = [self.labelsArray objectAtIndex:i];

            if ([newIndexLabel.text isEqualToString:@"X"]) {
                self.indexOfSquareToMove = [newIndex integerValue];
                NSLog(@"Front door %i", (int)self.indexOfSquareToMove);
            } else if ([newIndexLabel.text isEqualToString:@"O"]) {
                self.indexOfSquareToMove = [newIndex integerValue];
                NSLog(@"Front door %i", (int)self.indexOfSquareToMove);
            }
        }
    }
}

- (NSArray *)getBoardScore {
    NSMutableArray *boardScoreArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.ticTacToeBoard.count; i++) {
        UILabel *labelAtCurrentIndex = [self.labelsArray objectAtIndex:i];
        if ([labelAtCurrentIndex.text isEqualToString:@"X"]) {
            [boardScoreArray addObject:[NSNumber numberWithInt:self.playerScore]];
        }
        else if ([labelAtCurrentIndex.text isEqualToString:@"O"]) {
            [boardScoreArray addObject:[NSNumber numberWithInt:self.computerScore]];
        }
        else {
            [boardScoreArray addObject:[NSNumber numberWithInt:0]];
        }
    }
    NSLog(@"%@", boardScoreArray);
    return boardScoreArray;
}

- (NSInteger)calculateRowScore: (NSArray *)boardScore
                  rowSquareOne: (int)rowSquareOne
                  rowSquareTwo: (int)rowSquareTwo
                rowSquareThree: (int)rowSquareThree
{
    NSInteger firstSquareScore = [[boardScore objectAtIndex:rowSquareOne] integerValue];
    NSInteger secondSquareScore = [[boardScore objectAtIndex:rowSquareTwo] integerValue];
    NSInteger thirdSquareScore = [[boardScore objectAtIndex:rowSquareThree] integerValue];

    NSInteger rowScore = firstSquareScore + secondSquareScore + thirdSquareScore;

    return rowScore;
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
    // Check for win accross middle win
    if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.topRow] isEqualToString:player]) {
        return player;
    } // Check for win accross middle win
    else if ([[self checkBoardForValidWin:player playerNumber:playerNumberString rowToCheck:self.middleVertRow] isEqualToString:player]) {
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
