//
//  TicTacToeBoard.h
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/3/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicTacToeBoard : NSObject

@property (strong, nonatomic) NSArray *board;
@property (strong, nonatomic) NSArray *boardLabelsArray;


-(id)initWithLabels:(NSArray *)labelsArray;


@end
