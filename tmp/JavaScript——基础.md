--- 

title: JavaScript——基础
layout: post
category: js
hidden: true

---


这篇文章里，我想简单且快速而又不降低质量地将 JavaScript 基础语法部分带过，这个部分包括`变量，运算符，控制流和函数`。阅读这篇文章需要对网页和编程至少有一些概念性的知识。

**目录**

* 目录
{:toc}

# 准备工作

## 储备知识
先来了解一下编写 js 之前的基础知识。

`<script>` 标签
如需在 HTML 页面中插入 JavaScript，请使用 `<script>` 标签。`<script>` 和 `</script>` 会告诉 JavaScript 在何处开始和结束。`<script>` 和 `</script>` 之间的代码行包含了 JavaScript：

{% highlight html %}
<script>

alert("My First JavaScript");

</script>
{% endhighlight %}

你无需理解上面的代码。只需明白，浏览器会解释并执行位于 `<script>` 和 `</script>` 之间的 JavaScript。

那些老旧的实例可能会在 `<script>` 标签中使用 type="text/javascript"。现在已经不必这样做了。JavaScript 是所有现代浏览器以及 HTML5 中的默认脚本语言。


`<body>` 中的 JavaScript
在本例中，JavaScript 会在页面加载时向 HTML 的 `<body>` 写文本。实例：

{% highlight html %}
<!DOCTYPE html>
<html>
<body>
.
.
<script>
    document.write("<h1>This is a heading</h1>");
    document.write("<p>This is a paragraph</p>");
</script>
.
.
</body>
</html>
{% endhighlight %}

JavaScript 函数和事件
上面例子中的 JavaScript 语句，会在页面加载时执行。通常，我们需要在某个事件发生时执行代码，比如当用户点击按钮时。如果我们把 JavaScript 代码放入函数中，就可以在事件发生时调用该函数。
稍后的文章会涉及到有关 JavaScript 函数和事件的知识。


## 工具

1. 一个浏览器（推荐Firefox，Google Chrome，或者基于 Chrome 的第三方浏览器）。
2. 一个编辑器（Windows 平台下的 EverEdit/Notepad++，其他平台随意）。

一般来讲，这里会使用内嵌 JavaScrpit 脚本的方式。你需要在编辑器里写好类似于这样的内嵌 js 脚本（不要在意看不看得懂），保存为扩展名为`.html`的网页文件，然后用浏览器打开。像这样：

{% highlight html %}
<script>

    var a = 1;
    document.write(a);

</script>
{% endhighlight %}

<log>
<script>

    var a = 1;
    document.write(a);

</script>
</log>

# 语法基础

在网页中输出结果，可以使用`document.write()`方法，请注意，这个方法输出的字符会嵌入到 html 页面中成为 html 的一部分，在使用它之前请确保你真的需要这个方法达成你的目的。也可以使用`alert()`方法显示数据结果，需要注意 alert 会阻塞当前脚本的运行。

而在控制台中查看输出数据需要使用一个名为` console.log()`的方法。它将一个结果输出到控制台上。打开控制台的方法一般是在浏览器的开发者菜单里。

这里我选择使用`document.write()`方法打印数据。比如可以这么打印数字 1 ：

{% highlight html %}
<script>

    document.write(1 + "<br>"); // <br>是换行标签。

</script>
{% endhighlight %}

网页中会显示数字`1`。

另外 js 中的注释和 C 系语言没有任何区别，支持单行注释`//`和多行注释`/* */`。

> 注意：网页中的注释符为`<!-- 注释内容 -->`

## 变量和基本类型

变量是一个值的名字，每个变量都有一个类型。好比每个人都有名字，每个人都有一个性别类型。js 中定义一个变量的形式如下：

{% highlight js %}
var number = 1;			// 声明数字
var name = "Wayne";		// 声明字符串
var array = [1, 2, 3, 4, 5];	// 声明数组
{% endhighlight %}

js 中的数据类型有字符串、数字、布尔、数组、对象、Null、Undefined。其中数字类型包含了整形和浮点型（js 中并没有区分这两个类型，而是把它们作为一个整体）。js 不像 C 和 java 那样必须对变量类型作出明确要求，这并不意味着 js 中的数据类型混乱不堪。实际上，js 中有一套非常智能的隐式转换体系。请看下面的代码：

{% highlight html %}
<script>
    
    var a = 1 + 1;
    document.write("a = " + a + " 类型为: " + typeof a + "<br>");

    var b = 1.2 + 1;
    document.write("b = " + b + " 类型为: " + typeof b + "<br>");

    var c = "A" + 1;
    document.write("c = " + c + " 类型为: " + typeof c + "<br>");

    var d = 1 + "A";
    document.write("d = " + d + " 类型为: " + typeof d + "<br>");

    var e = "A" + 1 + 2;
    document.write("e = " + e + " 类型为: " + typeof e + "<br>");

    var f = 1 + 2 + "A";
    document.write("f = " + f + " 类型为: " + typeof f + "<br>");

    var g = 1 + "A" + 2;
    document.write("g = " + g + " 类型为: " + typeof g + "<br>");

</script>
{% endhighlight %}

先看结果再分析：

<log>
<script>
    // 使用 typeof 关键字返回一个值的类型
    
    var a = 1 + 1;
    document.write("a = " + a + " 类型为: " + typeof a + "<br>");

    var b = 1.2 + 1;
    document.write("b = " + b + " 类型为: " + typeof b + "<br>");

    var c = "A" + 1;
    document.write("c = " + c + " 类型为: " + typeof c + "<br>");

    var d = 1 + "A";
    document.write("d = " + d + " 类型为: " + typeof d + "<br>");

    var e = "A" + 1 + 2;
    document.write("e = " + e + " 类型为: " + typeof e + "<br>");

    var f = 1 + 2 + "A";
    document.write("f = " + f + " 类型为: " + typeof f + "<br>");

    var g = 1 + "A" + 2;
    document.write("g = " + g + " 类型为: " + typeof g + "<br>");

</script>
</log>

这个结果能说明一些问题，直接看变量 c（c = A1 类型为: string），说明字符转加上一个数字以后数字会被转成 string 类型，然后再和 "A" 相加得到 "A1"。变量 d（d = 1A 类型为: string）先是 1 被转成字符转，再加 "A" 得到 "1A"。同样 e（e = A12 类型为: string）也是，"A" + 1 得到"A1"，再加 2 得到 "A12"。那么 f（f = 3A 类型为: string）也很好理解，先是 1 + 2 得 3，再 3 + "A" 得 "3A"。**可以发现，如果把数字与字符串相加，结果将成为字符串**。


另外 js 拥有动态类型，这意味着相同的变量可用作不同的类型：

{% highlight html %}
<script>

    var x;  		          
    document.write("x 的类型为: " + typeof x);	// x 为 undefined 类型
    document.write("<br>");

    x = 6;           
    document.write("x 的类型为: " + typeof x);	// x 为 number 类型
    document.write("<br>");
    
    x = "Wayne";
    document.write("x 的类型为: " + typeof x);	// x 为 string 类型
    document.write("<br>");
    
</script>
{% endhighlight %}

浏览器运行结果：

<log>
<script>
	// 使用 typeof 关键字返回一个值的类型

    var x;  		          
    document.write("x 的类型为: " + typeof x);	// x 为 undefined 类型
    document.write("<br>");

    x = 6;           
    document.write("x 的类型为: " + typeof x);	// x 为 number 类型
    document.write("<br>");
    
    x = "Wayne";
    document.write("x 的类型为: " + typeof x);	// x 为 string 类型
    document.write("<br>");
</script>
</log>


## 运算符

### 算数运算符

算术运算符用于执行变量与/或值之间的算术运算。
给定 y = 5，下面的表格解释了这些算术运算符：

| 运算符  | 描述            | 例子       | 结果    | 
| ------ | ----           | -------    |  ---   |
| +      | 加             | x = y + 2  | x = 7  |
| -	      | 减             | x = y - 2  | x = 3  |
| *	      | 乘             | x = y * 2  | x = 10 |
| /      | 除             | x = y / 2  | x = 2.5 |
| %      | 求余数 (保留整数)| x = y % 2  | x = 1   |
| ++     | 递增            | x = ++y   | x = 6   |
| --     | 递减            | x = --y   | x=4     |

### 赋值运算符

赋值运算符用于给 JavaScript 变量赋值。
给定 x=10 和 y=5，下面的表格解释了赋值运算符：

|运算符	|例子	       |等价于	         |结果
|------|------------|---------------|----
|=	    |x = y       |              |x = 5
|+=	    |x += y      |x = x + y	  |x = 15
|-=	    |x -= y      |x = x - y	  |x = 5
|*=	    |x *= y      |x = x * y	  |x = 50
|/=	    |x /= y      |x = x / y	  |x = 2
|%=	    |x %= y      |x = x % y	  |x = 0

### 比较运算符

比较运算符在逻辑语句中使用，以测定变量或值是否相等。
给定 x=5，下面的表格解释了比较运算符：

|运算符	   |描述	          |例子
|-------  |--------------- |---
|==	      |等于	          |x == 8 为 false
|===	   |全等（值和类型）	| x === 5 为 true；x === "5" 为 false
|!=	      |不等于	          |x != 8 为 true
|>	      |大于	          |x > 8 为 false
|<	      |小于	          |x < 8 为 true
|>=	      |大于或等于	       |x >= 8 为 false
|<=	      |小于或等于	       |x <= 8 为 true

{% highlight html %}
<script>
    var age = 16;
    if (age < 18)
        document.write("太嫩");
    
</script>
{% endhighlight %}
<log>
<script>
    var age = 16;
    if (age < 18)
        document.write("太嫩");
    
</script>
</log>

### 逻辑运算符

逻辑运算符用于测定变量或值之间的逻辑。
给定 x=6 以及 y=3，下表解释了逻辑运算符：

|运算符	  |描述	   |例子
|------- |------|-----
|&&	     |and   |(x < 10 && y > 1) 为 true
|\|\|   |or     |(x == 5 \|\| y == 5) 为 false
|!	     |not    |!(x == y) 为 true

<p/>
<span style="color:red;">**关于逻辑运算符的短路效应**</span>
 
`短路效应`是指在逻辑运算当中当位于`||`前方的逻辑表达式为真时（或者位于`&&`前方的逻辑表达式为假时），后方的逻辑表达式就不参与计算，类似电路中的短路。例子：

{% highlight html %}
<script>
    
    var a = 1;
    var b = 2;
    
    if (a == 1 || (++b) != 0) ;	// 空语句
        // a == 1 为真 则 || 后的 (++b) != 0 不会执行，第 1 次打印 b 还是 2
    
    document.write("b = " + b + "<br>");
    
    if (a != 1 || (++b) != 0) ;
        // a != 1 为假 则 || 后的 (++b) != 0 执行，第 2 次打印 b 为 3
    
    document.write("b = " + b + "<br>");
    
    
</script>
{% endhighlight %}

<log>
<script>
    
    var a = 1;
    var b = 2;
    
    if (a == 1 || (++b) != 0) ;	// 空语句
        // a == 1 为真 则 || 后的 (++b) != 0 不会执行，第 1 次打印 b 还是 2
    
    document.write("b = " + b + "<br>");
    
    if (a != 1 || (++b) != 0) ;
        // a != 1 为假 则 || 后的 (++b) != 0 执行，第 2 次打印 b 为 3

    document.write("b = " + b + "<br>");
    
    
</script>
</log>

短路效应产生的原因跟`||`和`&&`的特性相关，前者是只要有一个值为真则结果为真，后者是只要有一个值为假则结果为假。C/C++、Java、C#、Swift 等语言都具有这个特性。


## 控制流

控制流是软件工程中得一个概念，旨在描述程序运行走向。控制流决定了程序自身的结构：顺序结构，分支和循环。通常一个程序由若干个基本结构混合成一个复杂的结构。

### 顺序

程序自上而下一行一行的跑完，这种程序结构叫顺序结构。

{% highlight html %}
<script>
    
    var a = 1;
    var b = 2;
    var c = a + b;
    console.log(c);	// 3
    
</script>
{% endhighlight %}

### 分支

程序运行时根据条件执行对应语句，这种程序结构叫分支结构。

分支结构主要有两个簇，if/else 和 switch

{% highlight html %}
<script>
    
    var a = 1;
    var b = 2;
    var c = a + b;
    
    if (a == 1) {
        document.write("a = 1 <br>");
    }
    
    if (b == 1) 
        document.write("b = 1 <br>");
    else
        document.write("b != 1 <br>");
    
    switch (c) {
    	case 1: document.write("c = 1 <br>"); break;
    	case 2: document.write("c = 2 <br>"); break;
    	case 3: document.write("c = 3 <br>"); break;
    	case 4:
    	case 5: document.write("c = 4 or c = 5 <br>"); break;
    	default: document.write("unknow c <br>");
    }  
    
</script>
{% endhighlight %}

<log>
<script>
    
    var a = 1;
    var b = 2;
    var c = a + b;
    
    if (a == 1) {
        document.write("a = 1 <br>");
    }
    
    if (b == 1) 
        document.write("b = 1 <br>");
    else
        document.write("b != 1 <br>");
    
    switch (c) {
    	case 1: document.write("c = 1 <br>"); break;
    	case 2: document.write("c = 2 <br>"); break;
    	case 3: document.write("c = 3 <br>"); break;
    	case 4:
    	case 5: document.write("c = 4 or c = 5 <br>"); break;
    	default: document.write("unknow c <br>");
    }  
    
</script>
</log>

> break 用来跳出当前的 switch。

### 循环

程序运行时重复执行某段语句，这种程序结构叫循环结构。

循环有 4 种：while，do/while，for 和 for/in。

**while**
{% highlight html %}
<script>
    
    var a = 3;

    while (a > 0) {
        document.write(a + " ");
        a -= 1;
    } 
    
</script>
{% endhighlight %}

<log>
<script>
    
    var a = 3;

    while (a > 0) {
        document.write(a + " ");
        a -= 1;
    } 
    
</script>
</log>

<p/>
**do/while**
{% highlight html %}
<script>
    
    var a = 3;

    do {
        document.write(a + " ");
        a -= 1;
    } while (a > 0);
    
</script>
{% endhighlight %}

> 注意： while 是当条件满足时执行循环体，而 do/while 则是先执行循环体再判断条件，条件满足时再次执行循环体，然后再判断。。。

<p/>
**for**

{% highlight swift %}
for (表达式 1 ; 循环条件; 表达式 2 ) {
    循环体
}
{% endhighlight %}


之所以这个部分说的详细一点是因为 for 是这几种循环中最强大的，也最复杂。表达式 1，循环条件和表达式 2 都不是必须的。特别是表达式 2，要注意它并不属于循环体。

{% highlight html %}
<script>
    
    var a = 3;

    for (var i = a; i > 0; --i) {
        document.write(i + " ");
    } 

    document.write("<br>");

    for (var i = a; i > 0;) {
        document.write(i + " ");
        --i;
    } 
    
</script>
{% endhighlight %}


<log>
<script>
    
    var a = 3;

    for (var i = a; i > 0; --i) {
        document.write(i + " ");
    } 

    document.write("<br>");

    for (var i = a; i > 0;) {
        document.write(i + " ");
        --i;
    } 
    
</script>
</log>

<p/>
**补充: break 和 continue**

break 用来跳出 switch 和 循环，continue 用来结束当前循环体，忽略 continue 后面的语句，转而执行下一次循环。***但是***，表达式 2 并不属于循环体，所以不管有没有 continue 它都会被执行。

{% highlight html %}
<script>
    
    var a = 3;

    for (var i = a; i > 0; --i) {
        if (i == 1) {
            // 当 i = 1，if 下面的输出不会执行了(不会输出 1)，但 --i 会执行
            continue;
        }
        document.write(i + " ");
    } 
    
</script>
{% endhighlight %}

<log>
<script>
    
    var a = 3;

    for (var i = a; i > 0; --i) {
        if (i == 1) {
            continue;
        }
        document.write(i + " ");
    } 
    
</script>
</log>


**for/in**

for/in 主要用途是遍历。
{% highlight html %}
<script>
    
    var array = [1, 2, 3, 4];	// 声明一个数组

    for (var i in array) {
        // i 会依次被替换成 array 中的下标
        document.write("array[" +i + "] = " + array[i] + "<br>");
    }
    
</script>
{% endhighlight %}

<log>
<script>
    
    var array = [1, 2, 3, 4];

    for (var i in array) {
        // i 会依次被替换成 array 中的下标
        document.write("array[" +i + "] = " + array[i] + "<br>");
    }
    
</script>
</log>


## 函数

函数就是数学里的函数，你一定见过这样这样的数学题：
> 设 f(x) = x² + 2x + 1，求 f(2).

这是个函数，很典型的代数。在程序语言里的函数和这个几乎一样。

{% highlight js %}
function funName(参数列表们...) {
    // 函数体
}
{% endhighlight %}

上面的问题用 js 函数解决就是:

{% highlight html %}
<script>

    var y = f(2);
    
    function f(x) {
        var result = x * x + 2 * x + 1;
        return result;
    }
    
    document.write("y = f(2) = " + y);
    
</script>
{% endhighlight %}

<log>
<script>

    var y = f(2);
    
    function f(x) {
        var result = Math.pow(x, 2) + 2 * x + 1;
        return result;
    }

    document.write("y = f(2) = " + y);
    
</script>
</log>


这个函数跟其他编程语言比起来有点不一样，参数没有类型声明，也没有返回值类型。因为 js 的弱类型特性，所以加上类型并没有任何意义。还有，函数定义的位置并不一定要在使用之前，上面的例子中，函数定义放在了使用后面。

函数的部分先暂停到这里，下片文章里我会对函数再做详细说明。



# 参考资料

[http://www.w3school.com.cn/js/js_howto.asp](http://www.w3school.com.cn/js/js_howto.asp)
