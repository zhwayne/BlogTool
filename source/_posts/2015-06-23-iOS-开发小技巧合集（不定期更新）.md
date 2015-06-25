title: iOS-开发小技巧合集（不定期更新）
date: 2015-06-23 19:18:31
toc: true
categories:
- iOS
tags: 
- App
---


总结一些 iOS 开发中常用的技巧和 bug 解决方法。


<!--more-->


># 如何检测应用更新？

你可以使用友盟等第三方工具，但如果你只想使用轻量级的方法，只需GET这个接口：`http://itunes.apple.com/lookup?id=你的应用程序的ID`，解析返回的json字符串就行。


{% blockquote %}
# 我想完全复制一个 UIView 怎么办，copy 方法好像用不了
{% endblockquote %}

iOS 中并不是所有对象都支持copy，只有遵守NSCopying协议的类才可以发送copy消息，当用你试图使用类似于`UIView *v = [_v1 copy]`方式复制一个UIView时，会抛出一个名为`Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[UIView copyWithZone:]: unrecognized selector sent to instance 0x7ff163d12060'`的异常。这时候我们可以采取使用对象序列化方式复制对象：

{% codeblock lang:objc %}

NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_v1];
UIView *v = [NSKeyedUnarchiver unarchiveObjectWithData:data];

{% endcodeblock %}



># 如何检测音频蓝牙是否连接

有个小技巧，检测一下当前音频外设是否为 BluetoothA2DPOutput 即可。

{% codeblock lang:objc %}

AVAudioSessionPortDescription *pd = [[AVAudioSession sharedInstance].currentRoute.outputs firstObject];
if ([pd.portType isEqualToString:@"BluetoothA2DPOutput"]) {
    // TODO:
}

{% endcodeblock %}



># 返回高度固定的 tableviewcell (高性能版)

一般我们用来指定 tableviewcell 的高度时使用 `- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath` 方法返回一个固定的高度。但这个方法会被 n 多次调用，其实你只要这么指定下高度就可以 `self.tableView.rowHeight = 100`。



># 我只是想修改导航栏返回按钮的文字，其他啥都不想干

你可以尝试在 `viewWillDisappear` 方法里这么干：

![](/{{path}}1.png)


># 项目中静态库有真机和模拟器两个版本，可不可以合并为一个

在 Xcode 中创建一个静态库文件，编译后会生成两个版本，一个是模拟器版本，一个是真机版本。所以导致后续引入静态库非常不方便，因此很有必要把这两个库打包成一个。合并以后的静态库文件大小是未合并的两个静态库之和。方法如下：

{% codeblock bash %}

lipo -create "path/to/模拟器专用lib.a" "path/to/真机专用lib.a" -output "path/to/通用lib.a"

{% endcodeblock %}



># 我需要一个完全透明的导航栏

So easy.

{% codeblock lang:swift %}

/// *** 这两段代码可以把导航栏变透明
UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
UINavigationBar.appearance().shadowImage = UIImage()    /// 这个是去除导航栏底部的黑色线条

{% endcodeblock %}


># 直接使用 16 进制颜色

使用 16 进制颜色相对麻烦一点，在 objc 中你可以定义这样的宏。在 swift 中建议将它改写成 UIColor 的扩展方法

{% codeblock lang:objc %}

#define UIColorHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

{% endcodeblock %}


># tableviewcell 默认的高亮太丑，如何自定义

{% codeblock lang:swift %}

cell?.selectedBackgroundView = {
    let view = UIView(frame: cell!.contentView.bounds)
    view.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
    return view
}()

{% endcodeblock %}


># 我想让 tableviewcell 的 separator 往左靠近边框，但又不想重写它怎么办

从 iOS 7 开始 tableviewcell 的 separator 遍右移了 27 个像素左右，下面的 3 行代码可以完美解决这个问题。

{% codeblock lang:swift %}

cell?.separatorInset = UIEdgeInsetsZero
cell?.layoutMargins = UIEdgeInsetsZero
cell?.preservesSuperviewLayoutMargins = false

{% endcodeblock %}


># 如何清空其他应用程序在远程控制界面留下的媒体信息

{% codeblock lang:objc %}

[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

{% endcodeblock %}



># push/pop 导航栏时有黑影

应该来说这是 iOS 7 中遗留的一个 bug，直到 8.3 发布也没解决。自己的程序中要修复这个问题也很简单，设置一下试图控制器的背景色就可以。



># 移除导航栏返回按钮的title

{% codeblock lang:objc %}

[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -100) forBarMetrics:UIBarMetricsDefault];

{% endcodeblock %}


># 移除subviews

移除 subviews 的常用方法就是遍历 view 中得所有视图依次删除：

{% codeblock lang:objc %}

for (UIView *items in view.subviews) {
    [items removeFromSuperview];
}

{% endcodeblock %}

其实还有一个方法也能快速删除 subviews 而且比 for 循环好看的多：

{% codeblock objc %}

[view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

{% endcodeblock %}

不过这个方法只存在于 objc 中。


># Build 版本号自动加1

iOS项目开发中有时需要将 build 次数记录下来，在项目的`TARGETS`->`Genneral`中修改相应的 Build 选项即可，但是如果在`Build Phases`中的`Run Script`中新建这样一个脚本就可以在每次 build 时自动把 build 次数加1：

{% codeblock lang:bash %}

#!/bin/bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"

{% endcodeblock %}

