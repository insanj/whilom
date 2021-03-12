//
//  Authorize.m
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//
// https://stackoverflow.com/questions/29796363/how-to-add-root-privileges-to-my-osx-application
//

#import "Authorize.h"


@implementation Authorize

+ (void)runCommandAsRoot:(NSString *)string {
    // Create authorization reference
    OSStatus status;
    AuthorizationRef authorizationRef;

    // AuthorizationCreate and pass NULL as the initial
    // AuthorizationRights set so that the AuthorizationRef gets created
    // successfully, and then later call AuthorizationCopyRights to
    // determine or extend the allowable rights.
    // http://developer.apple.com/qa/qa2001/qa1172.html
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
                                 kAuthorizationFlagDefaults, &authorizationRef);
    if (status != errAuthorizationSuccess)
        NSLog(@"Error Creating Initial Authorization: %d", status);

    // kAuthorizationRightExecute == "system.privilege.admin"
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;

    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(authorizationRef, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess)
        NSLog(@"Copy Rights Unsuccessful: %d", status);

    NSLog(@"\n\n** %@ **\n\n", @"This command should work.");
//    char *tool = "/sbin/dmesg";
//
//    NSUInteger length = [string length];
//    NSUInteger bufferSize = 500;
//    char buffer[bufferSize] = {0};
//
//    char *tool = //[string getCString:buffer maxLength:length encoding:NSUTF8StringEncoding];

    char *tool = [string UTF8String];
    char *args[] = {NULL};
    FILE *pipe = NULL;

    status = AuthorizationExecuteWithPrivileges(authorizationRef, tool,
                                                flags, args, &pipe);
    if (status != errAuthorizationSuccess)
        NSLog(@"Error: %d", status);

    // The only way to guarantee that a credential acquired when you
    // request a right is not shared with other authorization instances is
    // to destroy the credential.  To do so, call the AuthorizationFree
    // function with the flag kAuthorizationFlagDestroyRights.
    // http://developer.apple.com/documentation/Security/Conceptual/authorization_concepts/02authconcepts/chapter_2_section_7.html
    status = AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);
}

@end
