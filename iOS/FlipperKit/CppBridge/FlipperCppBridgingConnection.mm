/*
 *  Copyright (c) 2018-present, Facebook, Inc.
 *
 *  This source code is licensed under the MIT license found in the LICENSE
 *  file in the root directory of this source tree.
 *
 */
#import "FlipperCppBridgingConnection.h"

#import <FBCxxUtils/FBCxxFollyDynamicConvert.h>

#import "SonarCppBridgingResponder.h"

@implementation FlipperCppBridgingConnection
{
  std::shared_ptr<facebook::flipper::FlipperConnection> conn_;
}

- (instancetype)initWithCppConnection:(std::shared_ptr<facebook::flipper::FlipperConnection>)conn
{
  if (self = [super init]) {
    conn_ = conn;
  }
  return self;
}

#pragma mark - SonarConnection

- (void)send:(NSString *)method withParams:(NSDictionary *)params
{
  conn_->send([method UTF8String], facebook::cxxutils::convertIdToFollyDynamic(params, true));
}

- (void)receive:(NSString *)method withBlock:(SonarReceiver)receiver
{
    const auto lambda = [receiver](const folly::dynamic &message,
                                   std::unique_ptr<facebook::flipper::FlipperResponder> responder) {
      @autoreleasepool {
        SonarCppBridgingResponder *const objCResponder =
        [[SonarCppBridgingResponder alloc] initWithCppResponder:std::move(responder)];
        receiver(facebook::cxxutils::convertFollyDynamicToId(message), objCResponder);
      }
    };
    conn_->receive([method UTF8String], lambda);
}

@end
