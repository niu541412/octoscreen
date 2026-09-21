//
//  OctoscreenView.m
//  Octoscreen
//
//  Created by Steve Smith on 6/23/15.
//  Copyright (c) 2026 Steve Smith. All rights reserved.
//

#import "OctoscreenView.h"
#import <CoreText/CoreText.h>

static const CGFloat OctoscreenCellSize = 48.0;
static const NSTimeInterval OctoscreenColorCycleDuration = 120.0;
static const NSTimeInterval OctoscreenFadeInterval = 0.1;
static const NSTimeInterval OctoscreenFadeLockout = 8.0;
static const NSTimeInterval OctoscreenFadeVisibleDuration = 4.0;

@implementation OctoscreenView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSURL *fontURL = [[NSBundle bundleForClass:self.class] URLForResource:@"octicons"
                                                                  withExtension:@"ttf"
                                                                   subdirectory:@"build"];
        if (fontURL) {
            CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL,
                                             kCTFontManagerScopeProcess, NULL);
        }
        _iconFont = [NSFont fontWithName:@"octicons" size:32.0];
        // This is the original JavaScript icon list, mapped one-for-one from octicons.css.
        _glyphs = @[@0xf02d, @0xf08a, @0xf08e, @0xf08b, @0xf03f, @0xf040, @0xf03e, @0xf0a0,
                    @0xf0a1, @0xf071, @0xf09f, @0xf03d, @0xf069, @0xf007, @0xf07b, @0xf0d3,
                    @0xf048, @0xf0c5, @0xf091, @0xf068, @0xf03a, @0xf076, @0xf0a3, @0xf0a4,
                    @0xf078, @0xf0a2, @0xf084, @0xf0d6, @0xf035, @0xf046, @0xf00b, @0xf00c,
                    @0xf05f, @0xf065, @0xf02b, @0xf04f, @0xf045, @0xf0ca, @0xf07d, @0xf096,
                    @0xf056, @0xf057, @0xf27c, @0xf038, @0xf04d, @0xf06b, @0xf099, @0xf06d,
                    @0xf06c, @0xf06e, @0xf09a, @0xf04e, @0xf094, @0xf010, @0xf016, @0xf012,
                    @0xf014, @0xf017, @0xf0b1, @0xf0b0, @0xf011, @0xf013, @0xf0d2, @0xf0cc,
                    @0xf02f, @0xf042, @0xf00e, @0xf08c, @0xf020, @0xf01f, @0xf0ac, @0xf023,
                    @0xf009, @0xf0b6, @0xf043, @0x2665, @0xf07e, @0xf08d, @0xf070, @0xf09e,
                    @0xf09d, @0xf0cf, @0xf059, @0xf028, @0xf026, @0xf027, @0xf019, @0xf072,
                    @0xf0a5, @0xf0a6, @0xf073, @0xf049, @0xf00d, @0xf0d8, @0xf000, @0xf05c,
                    @0xf07f, @0xf062, @0xf061, @0xf060, @0xf06a, @0xf03b, @0xf03c, @0xf051,
                    @0xf00a, @0xf0c9, @0xf077, @0xf0be, @0xf089, @0xf075, @0xf024, @0xf0d7,
                    @0xf0a8, @0xf074, @0xf0a9, @0xf0a7, @0xf080, @0xf09c, @0xf008, @0xf037,
                    @0xf0c4, @0xf0d1, @0xf058, @0xf018, @0xf041, @0xf0bd, @0xf0bb, @0xf0bf,
                    @0xf0bc, @0xf0d4, @0xf05d, @0xf0af, @0xf052, @0xf053, @0xf085, @0xf0c0,
                    @0xf02c, @0xf063, @0xf030, @0xf001, @0xf04c, @0xf04a, @0xf002, @0xf006,
                    @0xf005, @0xf033, @0xf034, @0xf047, @0xf066, @0xf067, @0xf02e, @0xf097,
                    @0xf07c, @0xf036, @0xf032, @0xf0c6, @0xf0b2, @0xf02a, @0xf0c7, @0xf08f,
                    @0xf087, @0xf015, @0xf088, @0xf0c8, @0xf05e, @0xf0db, @0xf0da, @0xf031,
                    @0xf0d0, @0xf05b, @0xf044, @0xf05a, @0xf0aa, @0xf039, @0xf0ba, @0xf064,
                    @0xf081, @0x26a1];
        _startedAt = NSDate.timeIntervalSinceReferenceDate;
        _nextFlashAt = OctoscreenFadeInterval;
        [self setAnimationTimeInterval:1.0 / 30.0];
    }
    return self;
}

- (NSColor *)backgroundColorAtTime:(NSTimeInterval)time
{
    NSArray<NSColor *> *colors = @[
        [NSColor colorWithSRGBRed:132.0 / 255.0 green:75.0 / 255.0 blue:178.0 / 255.0 alpha:1.0],
        [NSColor colorWithSRGBRed:242.0 / 255.0 green:68.0 / 255.0 blue:63.0 / 255.0 alpha:1.0],
        [NSColor colorWithSRGBRed:255.0 / 255.0 green:192.0 / 255.0 blue:40.0 / 255.0 alpha:1.0],
        [NSColor colorWithSRGBRed:67.0 / 255.0 green:196.0 / 255.0 blue:185.0 / 255.0 alpha:1.0],
        [NSColor colorWithSRGBRed:39.0 / 255.0 green:165.0 / 255.0 blue:233.0 / 255.0 alpha:1.0]
    ];
    CGFloat position = fmod(time, OctoscreenColorCycleDuration) / OctoscreenColorCycleDuration * colors.count;
    NSUInteger fromIndex = (NSUInteger)floor(position) % colors.count;
    NSUInteger toIndex = (fromIndex + 1) % colors.count;
    CGFloat progress = position - floor(position);
    NSColor *from = [colors[fromIndex] colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    NSColor *to = [colors[toIndex] colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    return [NSColor colorWithSRGBRed:from.redComponent + (to.redComponent - from.redComponent) * progress
                               green:from.greenComponent + (to.greenComponent - from.greenComponent) * progress
                                blue:from.blueComponent + (to.blueComponent - from.blueComponent) * progress alpha:1.0];
}

- (BOOL)isLogoCellAtIndex:(NSUInteger)index columns:(NSInteger)columns rows:(NSInteger)rows
{
    NSInteger row = index / columns;
    NSInteger column = index % columns;
    NSInteger logoRow = rows / 2;
    NSInteger logoColumn = columns / 2 - 1;
    return row == logoRow && (column == logoColumn || column == logoColumn + 1);
}

- (void)prepareGridWithColumns:(NSInteger)columns rows:(NSInteger)rows
{
    if (_gridColumns == columns && _gridRows == rows) return;
    _gridColumns = columns;
    _gridRows = rows;
    NSUInteger count = columns * rows;
    _cellGlyphs = [NSMutableArray arrayWithCapacity:count];
    _fadeStartTimes = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger index = 0; index < count; index++) {
        [_cellGlyphs addObject:_glyphs[arc4random_uniform((u_int32_t)_glyphs.count)]];
        [_fadeStartTimes addObject:@(-DBL_MAX)];
    }
}

- (CGFloat)opacityForCell:(NSUInteger)cell atTime:(NSTimeInterval)time
{
    NSTimeInterval age = time - _fadeStartTimes[cell].doubleValue;
    if (age >= OctoscreenFadeVisibleDuration) return 0.1;
    return 0.1 + 0.6 * sin((age / OctoscreenFadeVisibleDuration) * M_PI);
}

- (void)flashIconAtTime:(NSTimeInterval)time
{
    NSMutableArray<NSNumber *> *available = [NSMutableArray array];
    for (NSUInteger index = 0; index < _cellGlyphs.count; index++) {
        if ([self isLogoCellAtIndex:index columns:_gridColumns rows:_gridRows]) continue;
        if (time - _fadeStartTimes[index].doubleValue >= OctoscreenFadeLockout) {
            [available addObject:@(index)];
        }
    }
    if (available.count) {
        NSUInteger chosen = available[arc4random_uniform((u_int32_t)available.count)].unsignedIntegerValue;
        _fadeStartTimes[chosen] = @(time);
    }
}

- (void)drawGlyph:(unichar)glyph inRect:(NSRect)rect opacity:(CGFloat)opacity
{
    if (!_iconFont) return;
    NSString *text = [NSString stringWithCharacters:&glyph length:1];
    NSDictionary *attributes = @{ NSFontAttributeName: _iconFont,
                                   NSForegroundColorAttributeName: [NSColor colorWithWhite:1.0 alpha:opacity] };
    NSSize size = [text sizeWithAttributes:attributes];
    [text drawAtPoint:NSMakePoint(NSMidX(rect) - size.width / 2.0,
                                 NSMidY(rect) - size.height / 2.0)
      withAttributes:attributes];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSTimeInterval elapsed = NSDate.timeIntervalSinceReferenceDate - _startedAt;
    [[self backgroundColorAtTime:elapsed] setFill];
    NSRectFill(self.bounds);

    NSInteger columns = (NSInteger)ceil(NSWidth(self.bounds) / OctoscreenCellSize);
    NSInteger rows = (NSInteger)ceil(NSHeight(self.bounds) / OctoscreenCellSize);
    if (columns % 2) columns++;
    if (!(rows % 2)) rows++;
    [self prepareGridWithColumns:columns rows:rows];
    CGFloat originX = NSMidX(self.bounds) - columns * OctoscreenCellSize / 2.0;
    CGFloat originY = NSMidY(self.bounds) - rows * OctoscreenCellSize / 2.0;
    NSInteger logoRow = rows / 2;
    NSInteger logoColumn = columns / 2 - 1;

    for (NSInteger row = 0; row < rows; row++) {
        for (NSInteger column = 0; column < columns; column++) {
            if (row == logoRow && column == logoColumn + 1) continue;
            NSRect cell = NSMakeRect(originX + column * OctoscreenCellSize,
                                     originY + row * OctoscreenCellSize,
                                     row == logoRow && column == logoColumn ? 96.0 : OctoscreenCellSize,
                                     OctoscreenCellSize);
            NSUInteger index = (NSUInteger)(row * columns + column);
            if (row == logoRow && column == logoColumn) {
                [self drawGlyph:0xf092 inRect:cell opacity:0.6];
            } else {
                [self drawGlyph:_cellGlyphs[index].unsignedShortValue
                          inRect:cell opacity:[self opacityForCell:index atTime:elapsed]];
            }
        }
    }
}

- (void)animateOneFrame
{
    NSTimeInterval elapsed = NSDate.timeIntervalSinceReferenceDate - _startedAt;
    while (_cellGlyphs.count && elapsed >= _nextFlashAt) {
        [self flashIconAtTime:_nextFlashAt];
        _nextFlashAt += OctoscreenFadeInterval;
    }
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet
{
    return nil;
}

@end
