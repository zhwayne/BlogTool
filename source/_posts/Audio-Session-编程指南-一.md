title: Audio Session 编程指南(一)

date: 2015-07-22 13:17:37

categories:

- iOS

tags:

- Audio

------


iOS为我们的 APP 提供了一系列的方式去播放音频，常见的音频相关框架有 AVPlayer，AVAudioPlayer，AVAudioRecorder，AudioQueue 以及 Audio Unit。另外还有一个和音视频联系非常紧密的一个东西，就是 Audio Session。这个类本身并不参与控制音频的播放，它作为 iOS 设备播放音频策略的一个辅助工具并提供了以下几个主要功能：

- 决定 APP 的音频共存行为
- 选择合适的音频设备
- 音频的中断处理



什么是“APP 的音频共存行为”？你应该注意到，当你在用网易云音乐播放一首喜欢的歌，然后进入酷狗查看最新的华语排行榜时，正在播放的歌曲自动暂停了。于是曰：“网易云和酷狗的音乐不能共存。”共存即同时播放，一般情况下你见不到两个同时播放不同音乐的 APP，同时播放两首歌不是很反人类么？

<!--more-->

iOS 系统如何处理具有竞争性的音频需求？

iOS 为每一个应用程序提供了一个 Audio Session，每个 Audio Session 单独参与各自 APP 的辅助管理。虽然我们一般用 `[AVAudioSession sharedInstance]`获取一个音频会话单例，这个单例只存在于我们创建的 APP 中。你可以试着创建两个 APP，在下面的方法中展示各自获取到的 Session，不难看出它们是两个不同的实例。

``` objc
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString *message = [NSString stringWithFormat:@"%@", [AVAudioSession sharedInstance]];
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:nil
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil, nil];
    [a show];
}
```

应用程序在启动时，iOS 为其提供一个应用内的全局 Session，在默认情况下，系统会自动激活这个 Session，但是苹果推荐我们明确显式地激活它。

    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error:&activationError];
    if (!success) { /* handle the error in activationError */ }

为什么需要激活？

假设我正在用网易云音乐听《New Soul》这首歌，然后我切换到酷狗去听《Five Hundred Miles》。这时候酷狗需要向系统请求播放音频，而此时网易云正在欢乐地唱着歌，于是系统的 Core Audio 服务会暂停网易云的音频播放，让酷狗能安静深情地演唱。激活的目的就在于此，禁用其他 APP 的 Audio Session 以使自身的 Audio Session 处于活跃状态。[苹果官方文档](https://developer.apple.com/library/prerelease/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html#//apple_ref/doc/uid/TP40007875-CH2-SW7)用了一个飞机场的例子形象地说明了这个问题。

![](https://developer.apple.com/library/prerelease/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Art/competing_audio_demands_2x.png)



我就是想同时播放两首歌怎么办？！

你要是这么任性也没关系，要实现这个需求就必须再说说 Audio Session 的 Category。Category 是一个为你的 APP 定义了一套音频行为的 key，设置不同的 Category，APP 表现出来的音频行为也就不一样。具体来说，Category 有以下几个：

| Categories                            | Description                                                                                                                                             | 
| :------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------ | 
| AVAudioSessionCategoryAmbient         | 只用于音频播放。<br/>特点是允许其他应用程序播放音频，当 Audio Session 的 Active 设为 NO 时（即不激活 Session），你应该会听到两个 APP 同时播放声音。<br/>注意，使用该 Category 的 APP 的音频会随着屏幕关闭、进入后台和开启静音键而中断。    | 
| AVAudioSessionCategorySoloAmbient     | Audio Session 默认的 Category，只用于音频播放。<br/>当 Category 设置为它时，不管 Session 是否被激活，其他 APP 的音频都会被中断（不允许音频共存）。<br/>注意，使用该 Category 的 APP 的音频会随着屏幕关闭、进入后台和开启静音键而中断。 | 
| AVAudioSessionCategoryPlayback        | 只用于音频播放。<br/>不允许音频共存。<br/>允许后台播放，且忽略静音键作用。<br/>注意，为了支持后台播放，你需要在应用程序的 info.plist 文件中正确设置 Required background modes。                                      | 
| AVAudioSessionCategoryRecord          | 只用于音频录制。<br/>设置该 Category 后，除了来电铃声，闹钟或日历提醒之外的其它系统声音都不会被播放。该 Category 只提供单纯录音功能。                                                                         | 
| AVAudioSessionCategoryPlayAndRecord   | 用于音频播放和录制。<br/>用于既需要播放声音又需要录音的应用，语音聊天应用（如微信）应该使用这个Category。如果你的应用需要用到 iPhone 上的听筒，该 Category是你唯一的选择，在该 Category 下声音的默认出口为听筒（在没有外接设备的情况下）。               | 
| AVAudioSessionCategoryAudioProcessing | 只用于离线音频处理，即使用硬件编解码器处理音频，如离线音频格式转换。<br/>该音频会话使用期间，不能播放和录制音频。<br/>不过实测中并没有什么卵用，音频还是正常播，How?😧                                                             | 
| AVAudioSessionCategoryMultiRoute      | 用于音频播放和录制。<br/>它允许多个音频输入/输出，比如音频数据同时从耳机和 USB 接口中出来。好像也不怎么常用。                                                                                            | 

看看，为了能够与其他音频共存，我们只能选`AVAudioSessionCategoryAmbient`这个。先来创建第一个 APP，它只负责播放一段音乐，支持后台，那么它的 Audio Session Category 可以指定为`AVAudioSessionCategoryPlayback`。

``` objc
- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Get an active error: %@", error.description);
        return;
    }

    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Get a category error: %@", error.description);
        return;
    }

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp3"] error:nil];
    [self.player play];
}
```

在 info.plist 文件中设置`Required background modes`为`App plays audio or streams audio/video using AirPlay`避免程序进入后台后音乐中断。

运行它，美妙音乐响起，然后在音乐声中创建第二个 APP。

``` objc
- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error = nil;
    // 注意设置为 NO，强制不激活。
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (error) {
        NSLog(@"Get an active error: %@", error.description);
        return;
    }

    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    if (error) {
        NSLog(@"Get a category error: %@", error.description);
        return;
    }

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp3"] error:nil];
    [self.player play];
}
```

运行以后，就能听见两首歌在群魔乱舞了。

APP 的音频共存行为先说到这里，本文并不作为官方文档的中文翻译，详细技术还需查阅[原文](https://developer.apple.com/library/prerelease/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionBasics/AudioSessionBasics.html#//apple_ref/doc/uid/TP40007875-CH3-SW1)。

补充：

如何优雅的请求录音权限？

从 iOS 7 开始，我们的 APP 需要录音必须获得用户的授权。如果程序中开始了录音，系统会自动提示用户是否需要授权。

![](/{{path}}1.png)

出现这个提示后，录音会被暂时阻塞，直到用户确认授权。如果点击了不允许，以后只能在设置里重新手动授权。这样用户没有一点心里准备，你应该在授权之前告知用户授权的目的，很显然我们不能修改系统的这个提示框，我们需要自己掌控系统何时会弹出这个授权提示框，用`requestRecordPermission:`方法可以帮我们实现，这里有一个很简单的 Demo。

``` objc
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@protocol AVAudioSessionRequestRecordPermissionDelegate <NSObject>

@required
- (void)didRequestedRecordPermission:(BOOL)result;

@end

@interface ViewController ()
<
UIAlertViewDelegate,
AVAudioSessionRequestRecordPermissionDelegate
>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak) id<AVAudioSessionRequestRecordPermissionDelegate> permissionDelegate;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.permissionDelegate = self;
    
    @try {
        [self configAudioSession];
        [self requestRecordPermission];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.name);
    }
}

- (void)configAudioSession
{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:&error];
    if (error) {
        @throw [NSException exceptionWithName:@"Active error"
                                       reason:error.description
                                     userInfo:nil];
    }
    
    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                           error:&error];
    if (error) {
        @throw [NSException exceptionWithName:@"Category error"
                                       reason:error.description
                                     userInfo:nil];
    }
}

- (void)requestRecordPermission
{
    switch ([AVAudioSession sharedInstance].recordPermission) {
        case AVAudioSessionRecordPermissionUndetermined: {
            // 第一次运行 APP，待定状态
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"授权提示"
                                                        message:@"你需要授权该 APP 获取音频权限才能录音。"
                                                       delegate:self
                                              cancelButtonTitle:@"好的，我知道了"
                                              otherButtonTitles:nil, nil];
            [a show];
            break;
        }

        case AVAudioSessionRecordPermissionDenied:
            // 被拒绝过了
            [self.permissionDelegate didRequestedRecordPermission:NO];
            break;
            
        case AVAudioSessionRecordPermissionGranted: {
            // 已经被允许
            [self.permissionDelegate didRequestedRecordPermission:YES];
            break;
        }
            
        default:
            break;
    }
}

- (void)startRecord
{
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:NSHomeDirectory()]
                                                settings:nil
                                                   error:nil];
    [self.recorder record];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        [self.permissionDelegate didRequestedRecordPermission:granted];
    }];
}

#pragma mark - AVAudioSessionRequestRecordPermissionDelegate
- (void)didRequestedRecordPermission:(BOOL)result
{
    if (result) {
        // Granted
        NSLog(@"Granted");
        [self startRecord];
    }
    else {
        // Denied
        NSLog(@"Denied");
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"没有录音权限，去设置里开启。"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: nil, nil];
        [a show];   // 这个提示框可能要等几秒钟才出来，原因不详。
    }
}

@end
```



![](/{{path}}2.gif)