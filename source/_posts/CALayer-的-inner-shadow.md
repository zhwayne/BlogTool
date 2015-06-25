title: CALayer 的 inner shadow
date: 2015-06-24 13:22:09
toc: false
categories:
- iOS
tags: 
- UI
---

我们已经知道，给视图添加阴影效果可以使用 CALayer 对象的 shadowColor、shadowOffset、shadowRadius 和 shadowOpactiy 属性。它们指定了阴影的颜色，方位，模糊度和不透明度。不过这个阴影存在于 layer 外部，而我的需求则是创建一个`具有内阴影的圆`。

![](/{{path}}1.png)


<!--more-->


画一个圆简单，CALayer 的 cornerRadius 可以为我们指定 layer 的圆角半径。下面的代码为我们创建了一个圆。

{% codeblock lang:swift %}
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let myView                      = UIView(frame: CGRectMake(0, 0, 280, 280))
    myView.layer.backgroundColor    = UIColor.hexColor(0xeeeeee).CGColor
    myView.center                   = self.view.center
    myView.layer.cornerRadius       = myView.bounds.size.width / 2
    myView.layer.shouldRasterize    = true
    myView.layer.contentsScale      = UIScreen.mainScreen().scale
    myView.layer.rasterizationScale = UIScreen.mainScreen().scale
    
    self.view.addSubview(myView)
}
{% endcodeblock %}

![](/{{path}}1-1.png)

`hexColor`是我实现的一个 UIColor 扩展：

{% codeblock lang:swift %}
extension UIColor {
    class func hexColor(color: Int) -> UIColor {
        let r = (CGFloat)((color & 0xFF0000) >> 16) / 255.0
        let g = (CGFloat)((color & 0xFF00) >> 8) / 255.0
        let b = (CGFloat)(color & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
{% endcodeblock %}

但这个内阴影让人有点头疼，因为 Core Animation 并没有为我们提供任何可行的 API 去直接设置 layer 的 inner shadow，所以只能自己实现相关操作。最开始的想法是建立一个长度为圆周长的 CAGradientLayer，设置它的渐变色（从 blackColor 到 clearColor），然后把它弯曲变形成一个圆。

![](/{{path}}2.png)

不过，这个把简单的问题复杂化了，除了涉及渐变还要考虑图形变形。那 Core Graphics 画图呢？我们是可以直接在 layer 上绘制图形的。于是上 stackoverflow 搜寻相关问题，庆幸的是，[这个问题](https://stackoverflow.com/questions/18671355/how-to-create-rounded-uitextfield-with-inner-shadow)给了我解决方案。

由于 layer 只负责显示和动画，并不处理交互事件，而阴影只是单纯地作为装饰显示在视图中，那我们把 shadow 单独作为一个图层覆盖在需要 inner shadow 的视图上，这个 inner shadow 尺寸需要足够大，能够满足 offset 的正常需求（模拟光源位置不同产生的投影角度也不同），并且最重要的是它必须是中间镂空的，也就是说这个 inner shadow 其实是一个遮罩层。

现在子类化一个 CALayer，命名为 InnerShadowLayer，在 InnerShadowLayer 的`drawInContext`方法中设置阴影路径。另外，我们还需要 4 个属性记录和监听阴影信息，比如阴影颜色，方位，不透明度和模糊度。


{% codeblock lang:swift linenos%}
import UIKit

class InnerShadowLayer: CALayer {
    var innerShadowColor: CGColor? = UIColor.blackColor().CGColor {
        didSet {
            setNeedsDisplay()
        }
    }
    var innerShadowOffset: CGSize = CGSizeMake(0, 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    var innerShadowRadius: CGFloat = 8 {
        didSet {
            setNeedsDisplay()
        }
    }
    var innerShadowOpacity: Float = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        self.masksToBounds      = true
        self.shouldRasterize    = true
        self.contentsScale      = UIScreen.mainScreen().scale
        self.rasterizationScale = UIScreen.mainScreen().scale
        
        setNeedsDisplay()
    }
    
    override func drawInContext(ctx: CGContext) {
        print("draw")
        // 设置 Context 属性
        // 允许抗锯齿
        CGContextSetAllowsAntialiasing(ctx, true);
        // 允许平滑
        CGContextSetShouldAntialias(ctx, true);
        // 设置插值质量
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        
        // 以下为核心代码
        
        // 创建 color space
        let colorspace = CGColorSpaceCreateDeviceRGB();
        
        var rect   = self.bounds
        var radius = self.cornerRadius
        
        // 去除边框的大小
        if self.borderWidth != 0 {
            rect   = CGRectInset(rect, self.borderWidth, self.borderWidth);
            radius -= self.borderWidth
            radius = max(radius, 0)
        }
        
        // 创建 inner shadow 的镂空路径
        let someInnerPath: CGPathRef = UIBezierPath(roundedRect: rect, cornerRadius: radius).CGPath
        CGContextAddPath(ctx, someInnerPath)
        CGContextClip(ctx)
        
        // 创建阴影填充区域，并镂空中心
        let shadowPath = CGPathCreateMutable()
        let shadowRect = CGRectInset(rect, -rect.size.width, -rect.size.width)
        CGPathAddRect(shadowPath, nil, shadowRect)
        CGPathAddPath(shadowPath, nil, someInnerPath);
        CGPathCloseSubpath(shadowPath)
        
        // 获取填充颜色信息
        let oldComponents: UnsafePointer<CGFloat> = CGColorGetComponents(self.innerShadowColor)
        var newComponents:[CGFloat] = [0, 0, 0, 0]
        let numberOfComponents: Int = CGColorGetNumberOfComponents(self.innerShadowColor);
        switch (numberOfComponents){
        case 2:
            // 灰度
            newComponents[0] = oldComponents[0]
            newComponents[1] = oldComponents[0]
            newComponents[2] = oldComponents[0]
            newComponents[3] = oldComponents[1] * CGFloat(self.innerShadowOpacity)
        case 4:
            // RGBA
            newComponents[0] = oldComponents[0]
            newComponents[1] = oldComponents[1]
            newComponents[2] = oldComponents[2]
            newComponents[3] = oldComponents[3] * CGFloat(self.innerShadowOpacity)
        default: break
        }
        
        // 根据颜色信息创建填充色
        let innerShadowColorWithMultipliedAlpha = CGColorCreate(colorspace, newComponents)
        
        // 填充阴影
        CGContextSetFillColorWithColor(ctx, innerShadowColorWithMultipliedAlpha)
        CGContextSetShadowWithColor(ctx, self.innerShadowOffset, self.innerShadowRadius, innerShadowColorWithMultipliedAlpha)
        CGContextAddPath(ctx, shadowPath)
        CGContextEOFillPath(ctx)
    }
}
{% endcodeblock %}

这时我们可以使用这个 InnerShadowLayer 了:

{% codeblock lang:swift linenos%}
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let myView                      = UIView(frame: CGRectMake(0, 0, 280, 280))
    myView.layer.backgroundColor    = UIColor.hexColor(0xeeeeee).CGColor
    myView.center                   = self.view.center
    myView.layer.cornerRadius       = myView.bounds.size.width / 2
    myView.layer.shouldRasterize    = true
    myView.layer.contentsScale      = UIScreen.mainScreen().scale
    myView.layer.rasterizationScale = UIScreen.mainScreen().scale
    
    let shadowLayer          = InnerShadowLayer()
    shadowLayer.frame        = myView.bounds
    shadowLayer.cornerRadius = myView.layer.cornerRadius
    myView.layer.addSublayer(shadowLayer)
    
    self.view.addSubview(myView)
}
{% endcodeblock %}

效果大致就出来了：

![](/{{path}}3.png)

现在还有一个问题，这个阴影不太明显，我需要的阴影左上角黑色再多一点，颜色再深一点，右下角阴影很少（就是本文最上面的图右边一个），这样立体感很强。而我们只需要适当修改那 4 个属性就成实现。

{% codeblock lang:swift %}
shadowLayer.innerShadowOffset  = CGSizeMake(4, 4)
shadowLayer.innerShadowOpacity = 0.4
shadowLayer.innerShadowRadius  = 16
{% endcodeblock %}

最终结果(左图)和外阴影的效果对比：

![](/{{path}}4.png) ![](/{{path}}5.png)


---

完整工程示例：⬇⬇⬇⬇⬇⬇⬇⬇⬇⬇ （若无法显示请刷新或者点击[这里](http://github.com/zhwayne/InnerShadowLayer)）

<div class="github-widget" data-repo="zhwayne/InnerShadowLayer"></div>
<script src="/js/jquery-2.0.3.min.js"></script>
<script src="/js/jquery.githubRepoWidget.min.js"></script>
