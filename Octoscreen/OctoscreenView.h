//
//  OctoscreenView.h
//  Octoscreen
//
//  Created by Steve Smith on 6/23/15.
//  Copyright (c) 2015 Steve Smith. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface OctoscreenView : ScreenSaverView
{
    NSFont *_iconFont;
    NSArray<NSNumber *> *_glyphs;
    NSMutableArray<NSNumber *> *_cellGlyphs;
    NSMutableArray<NSNumber *> *_fadeStartTimes;
    NSTimeInterval _startedAt;
    NSTimeInterval _nextFlashAt;
    NSTimeInterval _colorCycleOffset;
    NSInteger _gridColumns;
    NSInteger _gridRows;
}

@end
