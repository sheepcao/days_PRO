//
//  constellationView.h
//  simpleFinance
//
//  Created by Eric Cao on 5/6/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol constellationDelegate <NSObject>

-(void)constellationChoose;
-(void)cancelConstellation;
@end

@interface constellationView : UIView
@property (nonatomic,weak) id <constellationDelegate> constellDelegate;
@property (nonatomic, strong) UIPickerView *constellPicker;
-(void)removeDimView;
-(void)addGesture;
@end
