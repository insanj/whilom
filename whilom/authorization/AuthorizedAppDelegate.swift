//
//  AuthorizedAppDelegate.swift
//  whilom
//
//  Created by Julian Weiss on 3/12/21.
//  Copyright © 2021 Julian Weiss. All rights reserved.
//

import Cocoa

class AuthorizedAppDelegate2: NSObject, NSApplicationDelegate {
  private var _authRef: AuthorizationRef?
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {

    // step 1:
    // Create our connection to the authorization system.
    //
    // If we can't create an authorization reference then the app is not going to be able
    // to do anything requiring authorization.  Generally this only happens when you launch
    // the app in some wacky, and typically unsupported, way.  In the debug build we flag that
    // with an assert.  In the release build we continue with self->_authRef as NULL, which will
    // cause all authorized operations to fail.
//    var err: OSStatus
//    var extForm: AuthorizationExternalForm
//
//    err = AuthorizationCreate(NULL, NULL, 0, &self->_authRef);
//    if (err == errAuthorizationSuccess) {
//        err = AuthorizationMakeExternalForm(self->_authRef, &extForm);
//    }
//    if (err == errAuthorizationSuccess) {
//        self.authorization = [[NSData alloc] initWithBytes:&extForm length:sizeof(extForm)];
//    }
//    assert(err == errAuthorizationSuccess);
//
    
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {

  }
}
