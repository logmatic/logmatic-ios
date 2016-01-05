//
//  LMLogger.m
//  Logmatic
//
//  Created by Roland Borgese on 17/12/2015.
//
//

#import "LMLogger.h"
#import "NSArray+LMMerge.h"
#import "LMUserDefaultsPersistence.h"
#import "AFNetworking.h"

static NSString * const kRootUrl = @"https://api.logmatic.io/v1/input";
static NSString * const kMessageKey = @"message";
static NSString * const kTimestampKey = @"timestamp";
static NSString * const kIpTrackingHeaderKey = @"X-Logmatic-Add-IP";
static NSString * const kUserAgentTrackingHeaderKey = @"X-Logmatic-Add-UserAgent";
static const NSTimeInterval kDefaultSendingFrequency = 20;

static LMLogger * sSharedLogger;

@interface LMLogger () {
    BOOL _askedToWork;
}
@property (nonatomic, strong) id<LMPersistence> delegate;
@property (nonatomic, readonly) NSMutableArray<NSDictionary *> * pendingLogs;
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, NSArray<NSDictionary *> *> * ongoingRequests;
@property (nonatomic, readonly) AFHTTPSessionManager * sessionManager;
@property (nonatomic, readonly) NSTimer * sendingTimer;

@end

@implementation LMLogger

#pragma mark - NSObject

- (instancetype)init {
    if ([super init]) {
        _pendingLogs = [NSMutableArray new];
        _ongoingRequests = [NSMutableDictionary new];
        _sessionManager = [self _createSessionManager];
        _sendingFrequency = kDefaultSendingFrequency;
        [self setUsePersistence:YES];
        [self _startNotifs];
    }
    return self;
}

- (void)dealloc {
    [self _stopNotifs];
    [self _stop];
}

#pragma mark - Getter/Setter

- (void)setSendingFrequency:(NSTimeInterval)frequency {
    _sendingFrequency = frequency;
    if (frequency < 1) {
        NSLog(@"Warning: setting a too small sendingFrequency deteriorates phone performance");
    }
}

- (BOOL)usePersistence {
    return _delegate;
}

- (void)setUsePersistence:(BOOL)usePersistence {
    _delegate = usePersistence ? [LMUserDefaultsPersistence sharedUserDefaultsPersistence] : nil;
}

#pragma mark - LMLogger

+ (instancetype)sharedLogger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedLogger = [[self alloc] init];
    });
    return sSharedLogger;
}

- (void)startLogger {
    _askedToWork = YES;
    [self _start];
}

- (void)stopLogger {
    _askedToWork = NO;
    [self _stop];
}

- (void)log:(NSDictionary *)dictionary withMessage:(NSString *)message {
    if ([message length] == 0 && !dictionary) {
        return;
    }
    NSMutableDictionary * mutableParams = [NSMutableDictionary new];
    [mutableParams addEntriesFromDictionary:@{kTimestampKey: @([[NSDate date] timeIntervalSince1970] * 1000)}];
    if (self.metas) {
        [mutableParams addEntriesFromDictionary:self.metas];
    }
    if ([message length] > 0) {
        [mutableParams addEntriesFromDictionary:@{kMessageKey: message}];
    }
    if (dictionary) {
        [mutableParams addEntriesFromDictionary:dictionary];
    }
    [self.pendingLogs addObject:mutableParams];
}

- (void)setIPTracking:(NSString *)ipTracking {
    [self.sessionManager.requestSerializer setValue:ipTracking forHTTPHeaderField:kIpTrackingHeaderKey];
}

- (void)setUserAgentTracking:(NSString *)userAgentTracking {
    [self.sessionManager.requestSerializer setValue:userAgentTracking forHTTPHeaderField:kUserAgentTrackingHeaderKey];
}

#pragma mark - Private
#pragma mark Init

- (AFHTTPSessionManager *)_createSessionManager {
    AFHTTPSessionManager * sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kRootUrl]];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    return sessionManager;
}

- (void)_start {
    [self _loadSavedLogs];
    _sendingTimer = [self _createAndStartTimer];
}

- (NSTimer *)_createAndStartTimer {
    NSTimer * sendingTimer = [NSTimer scheduledTimerWithTimeInterval:self.sendingFrequency target:self selector:@selector(_sendPendingLogsAndSync) userInfo:nil repeats:YES];
    [sendingTimer fire];
    return sendingTimer;
}

- (void)_startNotifs {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

#pragma mark Stop

- (void)_stop {
    [self _stopTimersAndDelete];
    [self _saveAndClearAllLogs];
}

- (void)_stopTimersAndDelete {
    [_sendingTimer invalidate];
    _sendingTimer = nil;
}

- (void)_stopNotifs {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Workflow

- (void)_sendPendingLogsAndSync {
    if (self.key && self.pendingLogs.count > 0) {
        NSURLSessionDataTask * task = [self _sendLogs:self.pendingLogs];
        self.ongoingRequests[@(task.taskIdentifier)] = [self.pendingLogs copy];
        [self.pendingLogs removeAllObjects];
    }
}

- (NSURLSessionDataTask *)_sendLogs:(NSArray<NSDictionary *> *)logs {
    AFHTTPSessionManager * manager = self.sessionManager;
    NSURLSessionDataTask * task = [manager POST:self.key parameters:logs progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self _requestSucceededWithTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self _requestFailedWithTask:task error:error];
    }];
    return task;
}

- (void)_requestSucceededWithTask:(NSURLSessionDataTask *)task {
    NSNumber * taskIdentifier = @(task.taskIdentifier);
    NSArray<NSDictionary *> * succeededLogs = self.ongoingRequests[taskIdentifier];
    [self.ongoingRequests removeObjectForKey:taskIdentifier];
    NSString * successMessage = [NSString stringWithFormat:@"%lu logs sent successfully.", (unsigned long)[succeededLogs count]];
    switch (self.logLevel) {
        case LMLogLevelShort:
            NSLog(@"%@", successMessage);
            break;
        case LMLogLevelVerbose:
            NSLog(@"%@ Logs:\n%@", successMessage, succeededLogs);
            break;
        default:
            break;
    }
}

- (void)_requestFailedWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    NSNumber * taskIdentifier = @(task.taskIdentifier);
    NSArray<NSDictionary *> * failedLogs = self.ongoingRequests[taskIdentifier];
    [self.ongoingRequests removeObjectForKey:taskIdentifier];
    BOOL sentLater = NO;
    if ([error code] == NSURLErrorNotConnectedToInternet && [failedLogs count] > 0) {
        sentLater = YES;
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [failedLogs count])];
        [self.pendingLogs insertObjects:failedLogs atIndexes:indexSet]; //failedLogs are older than pendingLogs so they must be before them in the pending queue
    }
    NSString * failureMessage = [NSString stringWithFormat:@"Failed to send %lu logs. Sent later: %@.", (unsigned long)[failedLogs count], sentLater ? @"YES" : @"NO"];
    switch (self.logLevel) {
        case LMLogLevelShort:
            NSLog(@"%@", failureMessage);
            break;
        case LMLogLevelVerbose:
            NSLog(@"%@ Logs:\n%@", failureMessage, failedLogs);
            break;
        default:
            break;
    }
}

#pragma mark Notifs

- (void)_willEnterForeground {
    if (_askedToWork) {
        [self _start];
    }
}

- (void)_didEnterBackground {
    [self _stop];
}

#pragma mark Persistence

- (void)_loadSavedLogs {
    NSArray * savedLogs = [_delegate savedLogs];
    if (savedLogs) {
        [_pendingLogs addObjectsFromArray:savedLogs];
    }
    [_delegate deleteAllLogs];
}

- (void)_saveAndClearAllLogs {
    [self.delegate replaceLogs:self.pendingLogs];
    [_pendingLogs removeAllObjects];
    [_ongoingRequests removeAllObjects];
}

@end
