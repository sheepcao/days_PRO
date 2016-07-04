//
//  FabonacciNum.m
//  dotaer
//
//  Created by Eric Cao on 7/15/15.
//  Copyright © 2015 sheepcao. All rights reserved.
//

#import "FabonacciNum.h"

@implementation FabonacciNum


+(float)calculateFabonacci:(int)seq
{
    int i; // used in the "for" loop
    int fcounter = seq; // specifies the number of values to loop through
    int f1 = 1; // seed value 1
    int f2 = 0; // seed value 2
    int fn = 0; // used as a holder for each new value in the loop
    
    for (i=1; i<fcounter; i++){
        
        fn = f1 + f2;
        f1 = f2;
        f2 = fn;
    }
//        printf("第%d个是 %d",i, fn); // print each value of fn
    return fn;
}
@end
