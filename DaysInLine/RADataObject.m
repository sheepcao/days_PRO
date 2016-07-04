
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RADataObject.h"
#import "CommonUtility.h"

@implementation RADataObject


- (id)initWithName:(NSString *)name children:(NSArray *)children
{
  self = [super init];
  if (self) {
    self.children = [NSArray arrayWithArray:children];
    self.name = name;

  }
  return self;
}
- (id)initWithName:(NSString *)name andStartTime:(double)startTime andEndTime:(double)endTime children:(NSArray *)children
{
    self = [super init];
    if (self) {
        
        NSString *start = [[CommonUtility sharedCommonUtility] doubleToTime:(int)startTime];
        NSString *end = [[CommonUtility sharedCommonUtility] doubleToTime:(int)endTime];

        self.children = [NSArray arrayWithArray:children];
        self.name = name;
        self.startTimeString = start;
        self.endTimeString = end;

    }
    return self;
}

- (id)initWithName:(NSString *)name andWorkTime:(double)workTime andLifeTime:(double)lifeTime children:(NSArray *)children
{
    self = [super init];
    if (self) {
        

        self.children = [NSArray arrayWithArray:children];
        self.name = name;
        self.workTimeString = [NSString stringWithFormat:NSLocalizedString(@"%.2f 小时",nil),workTime/60];
        self.lifeTimeString = [NSString stringWithFormat:NSLocalizedString(@"%.2f 小时",nil),lifeTime/60];
        
    }
    return self;
}

+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children
{
  return [[self alloc] initWithName:name children:children];
}

+ (id)dataObjectWithName:(NSString *)name andStartTime:(double)startTime andEndTime:(double)endTime children:(NSArray *)children
{
    return [[self alloc] initWithName:name andStartTime:startTime andEndTime:endTime children:(NSArray *)children];
}

+ (id)dataObjectWithName:(NSString *)name andWorkTime:(double)workTime andLifeTime:(double)lifeTime children:(NSArray *)children
{
    return [[self alloc] initWithName:name andWorkTime:workTime andLifeTime:lifeTime children:children];
}

- (void)addChild:(id)child
{
  NSMutableArray *children = [self.children mutableCopy];
  [children insertObject:child atIndex:0];
  self.children = [children copy];
}

- (void)removeChild:(id)child
{
  NSMutableArray *children = [self.children mutableCopy];
  [children removeObject:child];
  self.children = [children copy];
}

@end
