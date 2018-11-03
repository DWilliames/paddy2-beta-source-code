//
//  PaddyPaddingPromptWindow.m
//  PaddyFramework
//
//  Created by David Williames on 22/7/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyPaddingPromptWindow.h"
#import "PaddyDecimalTextField.h"
#import "PaddyPaddingEdgesOverlayButton.h"

typedef void(^CompletionBlock) (PaddyModelPadding*);

@interface PaddyPaddingPromptWindow ()

@property (weak) IBOutlet NSImageView *image;

@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet MSUpDownTextField *topTextField;
@property (weak) IBOutlet MSUpDownTextField *rightTextField;
@property (weak) IBOutlet MSUpDownTextField *bottomTextField;
@property (weak) IBOutlet MSUpDownTextField *leftTextField;

@property (weak) IBOutlet MSTextLabelForUpDownField *topLabel;
@property (weak) IBOutlet MSTextLabelForUpDownField *rightLabel;
@property (weak) IBOutlet MSTextLabelForUpDownField *bottomLabel;
@property (weak) IBOutlet MSTextLabelForUpDownField *leftLabel;

@property (weak) IBOutlet NSStackView *rightGroup;
@property (weak) IBOutlet NSStackView *bottomGroup;
@property (weak) IBOutlet NSStackView *leftGroup;

@property (nonatomic) PaddyPaddingViewInputCount inputCount;

@property (nonatomic, strong) PaddyModelPadding *paddingModel;

@property (nonatomic, strong) CompletionBlock completionHandler;

@end

@implementation PaddyPaddingPromptWindow

- (id)init {
    return [super initWithNibName:@"PaddyPaddingPromptWindow"];
}

- (id)initWithModel:(PaddyModelPadding*)model andCallback:(void (^)(PaddyModelPadding*))completionHandler {
    PaddyPaddingPromptWindow *prompt = [super initWithNibName:@"PaddyPaddingPromptWindow"];
    prompt.paddingModel = model;
    prompt.completionHandler = completionHandler;
    
    return prompt;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Listen for 'ESC'
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *event) {
        
        if (self.window.isVisible) {
//            NSLog(@"Keycode: %hu", [event keyCode]);
            if ([event keyCode] == 53) {
                [self cancel:nil];
                return (NSEvent *)nil;
            } else if ([event keyCode] == 13) {
                [self apply:nil];
                return (NSEvent *)nil;
            }
        }
        
        return event;
    }];
    
}

- (void)show {
    [super show];
    
    PaddyModelPadding *props = self.paddingModel;
    
    NSString *topString = props.top ? [NSString stringWithFormat:@"%g", [props.top doubleValue]] : @"";
    NSString *rightString = props.right ? [NSString stringWithFormat:@"%g", [props.right doubleValue]] : @"";
    NSString *bottomString = props.bottom ? [NSString stringWithFormat:@"%g", [props.bottom doubleValue]] : @"";
    NSString *leftString = props.left ? [NSString stringWithFormat:@"%g", [props.left doubleValue]] : @"";
    
    [self.topTextField setStringValue:topString];
    [self.rightTextField setStringValue:rightString];
    [self.bottomTextField setStringValue:bottomString];
    [self.leftTextField setStringValue:leftString];
    
    
    self.inputCount = self.paddingModel.inputCount;
    [self inputCountUpdated];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kBundleIdentifier];
    
    self.image.image = [bundle imageForResource:@"padding.png"];
    
    self.topLabel.upDownTextField = self.topTextField;
    self.rightLabel.upDownTextField = self.rightTextField;
    self.bottomLabel.upDownTextField = self.bottomTextField;
    self.leftLabel.upDownTextField = self.leftTextField;
    
    self.topLabel.tag = 99;
    self.rightLabel.tag = 99;
    self.bottomLabel.tag = 99;
    self.leftLabel.tag = 99;
    
}

- (IBAction)toggleInputsButton:(id)sender {
    [self toggleInputCount];
}


- (void)toggleInputCount {
    self.inputCount++;
    if (self.inputCount > 2) {
        self.inputCount = 0;
    }
    
    [self inputCountUpdated];
    [self updatePaddingProps];
}

- (void)inputCountUpdated {
    
    switch (self.inputCount) {
        case AllInputs:
            self.rightGroup.hidden = false;
            self.bottomGroup.hidden = false;
            self.leftGroup.hidden = false;
            
            self.topLabel.stringValue = @"Top";
            self.rightLabel.stringValue = @"Right";
            self.bottomLabel.stringValue = @"Bottom";
            self.leftLabel.stringValue = @"Left";
            
            break;
        case TwoInputs:
            self.rightGroup.hidden = false;
            self.bottomGroup.hidden = true;
            self.leftGroup.hidden = true;
            
            self.topLabel.stringValue = @"Top / Bottom";
            self.rightLabel.stringValue = @"Right / Left";
            
            break;
        case OneInput:
            self.rightGroup.hidden = true;
            self.bottomGroup.hidden = true;
            self.leftGroup.hidden = true;
            
            self.topLabel.stringValue = @"Top / Right / Bottom / Left";
            
            break;
    }
}

- (void)updatePaddingProps {
    
    if (self.inputCount == TwoInputs) {
        self.leftTextField.stringValue = self.rightTextField.stringValue;
        self.bottomTextField.stringValue = self.topTextField.stringValue;
    } else if (self.inputCount == OneInput) {
        self.rightTextField.stringValue = self.topTextField.stringValue;
        self.leftTextField.stringValue = self.topTextField.stringValue;
        self.bottomTextField.stringValue = self.topTextField.stringValue;
    }
    
    NSArray *paddingValues = @[self.topTextField.stringValue, self.rightTextField.stringValue, self.bottomTextField.stringValue, self.leftTextField.stringValue];
    
    NSMutableString *paddingString = [NSMutableString string];
    for (NSString *value in paddingValues) {
        if (value.length < 1 || [value isEqualToString:@""]) {
            [paddingString appendString:@"x "];
        } else {
            [paddingString appendFormat:@"%@ ", value];
        }
    }
    
    PaddyModelPadding *props = [PaddyModelPadding paddingFromString:[paddingString substringToIndex:paddingString.length - 1]];
    props.inputCount = self.inputCount;
    
    if (props) {
        NSString *topString = props.top ? [NSString stringWithFormat:@"%g", [props.top doubleValue]] : @"";
        NSString *rightString = props.right ? [NSString stringWithFormat:@"%g", [props.right doubleValue]] : @"";
        NSString *bottomString = props.bottom ? [NSString stringWithFormat:@"%g", [props.bottom doubleValue]] : @"";
        NSString *leftString = props.left ? [NSString stringWithFormat:@"%g", [props.left doubleValue]] : @"";
        
        [self.topTextField setStringValue:topString];
        [self.rightTextField setStringValue:rightString];
        [self.bottomTextField setStringValue:bottomString];
        [self.leftTextField setStringValue:leftString];
    }
    
    self.paddingModel = props;
}

- (IBAction)apply:(id)sender {
    [self updatePaddingProps];
    
    if (self.completionHandler) {
        self.completionHandler(self.paddingModel);
    }
    
    [self.window close];
}

- (IBAction)cancel:(id)sender {
    [self.window close];
}

@end
