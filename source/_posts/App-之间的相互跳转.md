title: App 之间的相互跳转
date: 2015-06-23 13:05:02
categories:
- iOS
tags: 
- App
---

不久前公司有个项目需要从我们自己的 Application 跳转到系统WIFI设置界面。google一番后发现一个问题，iOS 在 5.0 版本中开放了 APP 对 System Settings 的链接，开发者可以通过自己的方法实现对 Settings 的定向跳转，代码如下：

{% codeblock lang:objc %}

NSURL *url=[NSURL URLWithString:@"prefs:root=WIFI"];
[[UIApplication sharedApplication] openURL:url];

{% endcodeblock %}


不过遗憾的是，Apple 在 5.1 版本中又取消了这一支持。所以目前在项目中添加上述代码，APP 并不会有任何动作（为了考虑简便开发，我们将不再支持 iOS 7.0 以下版本，乔布斯时代总会终结的）。于是本以为这个功能无法实现，但是在使用某些著名的 APP 时发现，它们之中有的确可以从应用程序内跳转到系统设置页，当时就想，shit! 怎么搞的？但是苦于个人技术水平原因，一直弄不清所以然，所以这个问题一直放着，直到昨天整了下 App 和 App 之间的相互跳转，似乎心里有了些眉目。在解决这个问题之前，先看看 App 和 App 互跳是如何实现的。<!--more-->


# App 跳转到 App

iOS 允许将你的 App 和一个自定义的 URL Scheme 进行绑定，通过该 URL Scheme，你的应用程序可以被浏览器或者其他应用启动，也就是说我们可以在 App1 中通过某个事件响应跳转到 App2。

允许其他应用程序唤起的你的 App，给自己的应用注册一个 URL type 是必要的，这是其他程序跳转过来的入口。这里举例说明，你需要在项目 App1 设置的`info`->`URL Types`中添加一个新项，URL Scheme 随便取名为 App1:

![](/{{path}}1.png)

编译运行以后，你会发现什么都没有发生。的确，这些改动对你的应用程序本身并没有什么可见的影响，但是如果你在 Safari 中的地址栏里输入`App1://`回车之后，浏览器便切回到了 App1。

![](/{{path}}2.gif)

如果浏览器提示`Open this page in "App1"`这个是正常的，这个出现的时机不确定，允许就好。

一些网站的二维码下载就是居于这样的原理，扫码以后如果终端没有安装它的应用程序则跳转到 App Store 相关页面，否则直接打开 App。

但是光打开 App 还不够，更多的时候我们希望打开 App 以后跳转到另一个界面里去完成我们想要做得事情，这就需要在跳转的同时把相关的参数也一并传输过来。从上面的动图结合 URL Scheme不难看出应用程序之间传递信息正是依靠 URL 地址进行的。通过 GET 方法提交一个请求，如果待唤醒 App 成功响应了提交的请求，则系统会把这个 App 唤醒送回前台供用户操作，于是可以使用一些自定义的 URL Scheme 传输数据：

> * App1://test?parameter=hello
* App1://?parameter=hello
* App1://?hello

上面的这些都是可以的，格式可以按需定义，这个是很自由的，只要能把参数解得出来，随你怎么搞。

既然有了数据的发送者，那自然有数据的接受者。iOS     早期版本提供了`optional func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool`函数用来处理来自其他应用程序的 URL 请求。因此我们可以在这个函数中响应这些请求。但是在这个函数的声明文件中有这么一行注释：

> Will be deprecated at some point, please replace with application:openURL:sourceApplication:annotation:

Apple 官方不建议我们使用这个函数，它随时可能被 deprecated，于是我们还有另一个替代方案：`optional func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool`。

| 参数                | 说明             
| ---------------- | ---------------- 
| application      | 应用程序实例
| openURL          | 传递过来的 URL
| sourceApplication | 发出请求的应用程序的 Bundle ID
| annotation       | 这个参数貌似很牛逼，不过测试几番后仍不知具体有何作用。
| retutnValue      | 处理成功返回 true， 失败或者没处理返回 false.

<br>

在这个方法里我用一个 UIAlertView 来展示信息:

{% codeblock lang:swift %}

func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    var parameter = url.query
    var alert = UIAlertView(title: sourceApplication!, message: parameter, delegate: nil, cancelButtonTitle: "OK")
    alert.show()    
    return true
}

{% endcodeblock %}

![](/{{path}}3.gif)

<br>

再来看看从 App2 如何跳转到 App1，根据上面的思路，只要在 App2 中发送一个 URL 请求即可。在我的 Storyboard 中有一个 button 和一个 test field 用来发送文本框中得数据，然后在按钮的`touchUpInside`事件中实现主要代码：

{% codeblock lang:swift %}

@IBAction func btnOnClick(sender: UIButton) {
    if UIApplication.sharedApplication().canOpenURL(NSURL(string: "App1://")!){
        var str = String(format: "App1://?%@", msgField.text)
        str = str.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        UIApplication.sharedApplication().openURL(NSURL(string: str)!)
    }
}

{% endcodeblock %}

![](/{{path}}4.gif)



# 跳转到系统设置页

上面谈论的都是 用户的 App 之间的跳转，那么 App 跳转到系统设置页该如何去做，毕竟之前的那些方案已经被弃用。`prefs`这个 Scheme 想必是被 Apple 动过了，但是如果你在自己的应用程序里再弄一个 URL Scheme 取名为`prefs`，那么这段代码便活了过来：

![](/{{path}}5.png)

{% codeblock lang:swift %}

class ViewController: UIViewController {
    private var arr :[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        arr.append("")
        arr.append("prefs:root=WIFI")
        arr.append("prefs:root=Bluetooth")
        arr.append("prefs:root=General")
        arr.append("prefs:root=General&path=About")
        arr.append("prefs:root=Phone")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func execAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: arr[sender.tag])!)
    }

}

{% endcodeblock %}

![](/{{path}}6.gif)


另外 iOS 8 提供了一个方案`UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)`用来跳转到设置页。


