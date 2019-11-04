//
//  DelegateResponseMask.h
//  Pods
//
//  Created by Dmitriy Petrusevich on 3/21/19.
//

#ifndef DelegateResponseMask_h
#define DelegateResponseMask_h

typedef NS_OPTIONS(NSUInteger, ResponseMask) {
    ResponseMaskDidChangeObject = 1 << 0,
    ResponseMaskDidChangeSection = 1 << 1,
    ResponseMaskWillChangeContent = 1 << 2,
    ResponseMaskDidChangeContent = 1 << 3,
};

#endif /* DelegateResponseMask_h */
