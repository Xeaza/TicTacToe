//
//  TicTacToeBoard.m
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/5/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import "TicTacToeBoard.h"

@interface TicTacToeBoard ()

@property (strong, nonatomic) NSArray *labelsArray;
@property (strong, nonatomic) NSMutableArray *ticTacToeBoard;

@end

@implementation TicTacToeBoard

- (id)initWithLabelsArray: (NSArray *)labelsAray {

    if ( self = [super init] ) {
        self.labelsArray = labelsAray;
        self.ticTacToeBoard = [[NSMutableArray alloc] initWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }

    return self;
}

- (void)updateBoardWithMove: (NSInteger)indexOfMove {

}



@end
