//
//  Authorize.h
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Authorize: NSObject

+ (void)runCommandAsRoot:(NSString *)string;

@end
