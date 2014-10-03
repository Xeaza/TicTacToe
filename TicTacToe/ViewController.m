//
//  ViewController.m
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/2/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
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
@property (strong, nonatomic) NSMutableArray *ticTacToeBoard;
@property (strong, nonatomic) NSArray *labelsArray;
@property int mostRecentlyTappedSquare;

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

    self.labelsArray = [[NSArray alloc] init];
    self.labelsArray = @[self.labelOne, self.labelTwo, self.labelThree, self.labelFour, self.labelFive, self.labelSix, self.labelSeven, self.labelEight, self.labelNine];

    self.ticTacToeBoard = [[NSMutableArray alloc] initWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];

    //NSLog(@"%@", self.ticTacToeBoard);

    self.mostRecentlyTappedSquare = 0;

    // Set player initial player
    self.whichPlayerLabel.text = @"Player One";
}

- (UILabel *)findLabelUsingPoint:(CGPoint)point
{
    UILabel *tappedLabel;
    //int counter = 0;
    for (UILabel *label in self.labelsArray)
    {
        if (CGRectContainsPoint(label.frame, point))
        {
            tappedLabel = label;
          //  self.mostRecentlyTappedSquare = counter;
        }
        //counter++;
    }
    //[self updateTicTacToeBoardArray:self.mostRecentlyTappedSquare];
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

        if ([self.whichPlayerLabel.text isEqualToString:@"Player One"]) {
            // Player one's turn
            tappedLabel.text = @"X";
            tappedLabel.textColor = [UIColor blueColor];
            self.whichPlayerLabel.text = @"Player Two";
            NSString *winner = [self whoWon];
            NSLog(@"%@", winner);
        }
        else {
            // Player two's turn
            tappedLabel.text = @"O";
            tappedLabel.textColor = [UIColor redColor];
            self.whichPlayerLabel.text = @"Player One";
            NSString *winner = [self whoWon];
            NSLog(@"%@", winner);
        }
    }
}

- (void)getIndexOfTappedSquare: (UILabel *)tappedLabel {
    int indexOfTappedSquare = (int)[self.labelsArray indexOfObject:tappedLabel];

    [self updateTicTacToeBoardArray:indexOfTappedSquare];
}

- (void)updateTicTacToeBoardArray: (int)ticTacToeSquareTapped {
   // NSString *yo = NSStringFromClass([self.ticTacToeBoard[ticTacToeSquareTapped] class]);
   // NSLog(@"%@", yo );
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
    NSString *winner = [[NSString alloc] init];
    NSString *playerOne = @"x";
    NSString *playerTwo = @"o";

    if ([[self checkWhichPlayerWon:playerOne playerNumberString:@"1"] isEqualToString:playerOne]) {
        winner = playerOne;
    }
    else if ([[self checkWhichPlayerWon:playerTwo playerNumberString:@"2"] isEqualToString:playerTwo]) {
        winner = playerTwo;
    }

    return winner;
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
        return @"Error";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
