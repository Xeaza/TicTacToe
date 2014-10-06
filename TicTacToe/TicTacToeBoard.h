//
//  TicTacToeBoard.h
//  TicTacToe
//
//  Created by Taylor Wright-Sanson on 10/5/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TicTacToeBoard : NSObject

- (id)initWithLabelsArray: (NSArray *)labelsAray;
- (void)updateBoardWithMove: (NSInteger)indexOfMove;


@end
