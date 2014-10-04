//
//  ViewController.m
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/2/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//
#import "ViewController.h"
#import "HelpWebViewController.h"

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelOne.text   = @"  ";
    self.labelTwo.text   = @"  ";
    self.labelThree.text = @"  ";
    self.labelFour.text  = @"  ";
    self.labelFive.text  = @"  ";
    self.labelSix.text   = @"  ";
    self.labelSeven.text = @"  ";
    self.labelEight.text = @"  ";
    self.labelNine.text  = @"  ";

    self.originalCenterPointForDraggableXOLabel = self.labelXOToDrag.center;

    self.labelsArray = [[NSArray alloc] init];
    self.labelsArray = @[self.labelOne, self.labelTwo, self.labelThree, self.labelFour, self.labelFive, self.labelSix, self.labelSeven, self.labelEight, self.labelNine];

    self.ticTacToeBoard = [[NSMutableArray alloc] initWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];

    self.labelXOToDrag.textColor = [UIColor blueColor];

    self.mostRecentlyTappedSquare = 0;

    // Set player initial player
    self.whichPlayerLabel.text = @"Player One";
    self.timerLabel.text = [NSString stringWithFormat:@"%i", kTurnTimerValue];

    self.hasGameBegun = NO;
    self.isTurnTimedGame = NO;

    self.turnTimerCounter = kTurnTimerValue;

    [self.gameTimerSegmentedControl addTarget:self
                                       action:@selector(gameTimerSegmentedControlChanged:)
                             forControlEvents:UIControlEventValueChanged];
    self.timerLabel.alpha = 0.0;
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
            if (!self.hasGameBegun) {
                self.hasGameBegun = YES;
            }
        }
    }
    return tappedLabel;
}

- (IBAction)onLabelTapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.view];

    UILabel *tappedLabel = [self findLabelUsingPoint:point];
    [self updateTappedLabel:tappedLabel];
}

- (void)updateTappedLabel: (UILabel *)tappedLabel {

    if ([tappedLabel.text isEqualToString:@"  "]) {
        [self getIndexOfTappedSquare:tappedLabel];
        //[self startTurnTimer];
        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
            // Player one's turn
            tappedLabel.text = @"X";
            tappedLabel.textColor = [UIColor blueColor];
            [self updateWhichPlayerLabel:@"Player Two"];
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

- (void)getIndexOfTappedSquare: (UILabel *)tappedLabel {
    int indexOfTappedSquare = (int)[self.labelsArray indexOfObject:tappedLabel];
    [self updateTicTacToeBoardArray:indexOfTappedSquare];
}

- (void)updateTicTacToeBoardArray: (int)ticTacToeSquareTapped {
    if (ticTacToeSquareTapped < 3) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
    else if (ticTacToeSquareTapped > 2 && ticTacToeSquareTapped < 6) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
    else if (ticTacToeSquareTapped > 5 && ticTacToeSquareTapped < 9) {
        [self updateBoardArray:ticTacToeSquareTapped];
    }
}

- (void)updateBoardArray: (int)ticTacToeSquareTapped {
    if ([self.ticTacToeBoard[ticTacToeSquareTapped] isEqualToString:@"0"]) {
        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
            self.ticTacToeBoard[ticTacToeSquareTapped] = @"1";
        }
        else {
            self.ticTacToeBoard[ticTacToeSquareTapped] = @"2";
        }
    }
}

- (NSString *)whoWon {
    NSString *winner = @"No Winner";
    NSString *playerOne = @"x";
    NSString *playerTwo = @"o";

    if ([[self checkWhichPlayerWon:playerOne playerNumberString:@"1"] isEqualToString:playerOne]) {
        winner = playerOne;
    }
    else if ([[self checkWhichPlayerWon:playerTwo playerNumberString:@"2"] isEqualToString:playerTwo]) {
        winner = playerTwo;
    }

    if ([winner isEqualToString:playerOne]) {
        [self showWinnerAlert:winner];
    } else if ([winner isEqualToString:playerTwo])
    {
        [self showWinnerAlert:winner];
    }

    [self checkForTie:winner];

    return winner;
}

- (void)showWinnerAlert: (NSString *)winner {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.delegate = self;
    if ([winner isEqualToString:@"x"]) {
        alertView.title = @"Player One Wins!";
    } else if ([winner isEqualToString:@"o"]) {
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
    if ([[self checkBoardForValidWin:player
                        playerNumber:playerNumberString
                            leftSpot:0 middleSpot:1 rightSpot:2] isEqualToString:player]) {
        return player;
    }
    // Check for win accross middle win
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:3 middleSpot:4 rightSpot:5] isEqualToString:player]) {
        return player;
    }
    // Check for win accross bottom win
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:6 middleSpot:7 rightSpot:8] isEqualToString:player]) {
        return player;
    }
    // Check for win straight down left
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:0 middleSpot:3 rightSpot:6] isEqualToString:player]) {
        return player;
    }
    // Check for win straight down middle
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:1 middleSpot:4 rightSpot:7] isEqualToString:player]) {
        return player;
    }
    // Check for win straight down right
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:2 middleSpot:5 rightSpot:8] isEqualToString:player]) {
        return player;
    }
    // Check for win diagonal starting a top left
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:0 middleSpot:4 rightSpot:8] isEqualToString:player]) {
        return player;
    }
    // Check for win diagonal starting a top right
    else if ([[self checkBoardForValidWin:player
                             playerNumber:playerNumberString
                                 leftSpot:2 middleSpot:4 rightSpot:6] isEqualToString:player]) {
        return player;
    }
    else {
        return @"No Winner";
    }
}

- (NSString *)checkBoardForValidWin: (NSString *)playerToCheck
                       playerNumber: (NSString *)playersNumberString
                           leftSpot: (int)leftSpot
                         middleSpot: (int)middleSpot
                          rightSpot: (int)rightSpot {

    if ([self.ticTacToeBoard[leftSpot] isEqualToString:playersNumberString] &&
        [self.ticTacToeBoard[middleSpot] isEqualToString:playersNumberString] &&
        [self.ticTacToeBoard[rightSpot] isEqualToString:playersNumberString]) {
        return playerToCheck;
    } else {
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

- (void)resetBoard {
    int counter = 0;

    for (UILabel *label in self.labelsArray) {
        label.text = @"  ";
        self.ticTacToeBoard[counter] = @"0";
        counter++;
    }
    [self updateWhichPlayerLabel:@"Player One"];
    self.labelXOToDrag.textColor = [UIColor blueColor];
    self.labelXOToDrag.text = @"X";
}

- (IBAction)onDrag:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture locationInView:self.view];
    self.labelXOToDrag.center = point;

    if (panGesture.state == UIGestureRecognizerStateEnded) {

        for (UILabel *label in self.labelsArray) {
            if (CGRectContainsPoint(label.frame, point) && [label.text isEqualToString:@"  "]) {
                if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
                    [self getIndexOfTappedSquare:label];
                    [self dragLabelOnToBoardForPlayer:@"Player One" playerColor:[UIColor blueColor] playerLetter:@"X" label:label];
                    //[self whoWon];
                }
                else
                {
                    [self getIndexOfTappedSquare:label];
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    [self]
//}


@end
