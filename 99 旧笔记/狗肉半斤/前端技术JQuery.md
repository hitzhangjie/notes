---
layout: post  
title: 前端学习JQuery
description: ""
date: 2013-09-13 23:18:53 +0800
categories: ["过去的学习笔记"]
tags: ["javascript","jquery"]
toc: true
reward: true
draft: true
---

text goes here

```
1. JQuery是一个JS框架。
2. 如何在自己的网页里面使用JQuery框架呢，有两种方式，一种是到官方网站JQuery.com下载然后加入到页面中来，另一种是通过<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>来使用JQuery提供的api。
注意通过script标记引入JQuery支持的时候，不得在该对script标记之间添加任何代码，否则JQuery无效。要书写js代码，需要在后面的script标记中书写。

3. JQuery选择器$()，它可以引用的变量类型有好几种：
$(document)引用的是当前文档，即当前页面；
$("TAG")引用的是当前文档中的tag为TAG的【所有】元素；
$("#ID")引用的是当前文档中的id为ID的【所有】元素；
$(".CLASS")引用的是当前文档中的class为CLASS的【所有】元素；
$(this)引用的是当前元素；

$(document).ready(callback)，表示当文档加载完成之后调用回调函数callback；
$("TAG").click(function() { \$("TAG").hide(); }，表示当单击文档中TAG对应元素的时候，该元素会被隐藏；
		\$("#ID).click(function() {$("$id").hide(); }，表示当单击文档中id为ID的元素时，该元素会被隐藏；
\$(".CLASS").click(function() {$("$.CLASS").hide();}，引用的是当前文档中class属性为CLASS的所有元素，当单击属于该类的某个元素时，属于该类的所有元素都将被隐藏；
		$("button").click( function() { $(this).hide(); });表示当按钮被单击时，隐藏按钮，this指代当前元素button；
		注意在写触发事件的回调函数时，不要忘记参数列表，是function()而不是function。

		与普通JS的对比，JS中：
		如果要操作文档可以通过document对象；
		如果要操作元素标记为tag的某个元素的话，需要document.getElementsById("tag")，然后通过数组索引来访问对应的元素。如果要实现上述某个标记为tag的元素单击后被隐藏的话，实现起来就比较麻烦，需要获取文档中的所有tag元素的一个列表，并清楚前被单击的tag是列表中的哪一个（可能还需要通过id或者其他的方法来定位当前元素），然后在将元素列表中的对应元素隐藏。确实，JQuery选择器要方便很多；
		如果要某个id为ID的元素被隐藏，方法同上，还是JQuery要简单一些；
		如果要隐藏class为CLASS的所有元素，方法同上，需要获取各种标记的所有元素的列表，并遍历每一个元素，检查元素的class属性，更加繁琐了。JQuery更简单；
		总结：
		JQuery选择器，可以很方便地对文档中的元素进行引用，节省了自己JS编码的时间。
	
		4. JQuery事件
		click(callback)，单击；
		dbclick(callback)，双击；
		mouseenter(callback)，鼠标进入元素区域；
		mouseleave(callback)，鼠标离开元素区域；
		mousedown(callback)，鼠标按键被按下（左键、右键、中键均可）；
		mouseup(callback)，鼠标按键弹起；
		hover(enter_callback, leave_callback)，鼠标悬停（进入元素区域、离开元素区域）；
		focus(callback)，使得某个元素进入焦点；
blur(callback)，使得某个元素失去焦点；

5. hide和show
hide()，使得元素被隐藏；
hide("slow")，使得元素被缓慢隐藏，渐变的效果；
show()，使得元素显示；
toggle()，使得元素在显示和隐藏之间切换；

css中class的上下级关系：
例如：
<div class="div1">
<button class="hide"/>
</div>
<div class="div2">
<button class="hide"/>
</div>
如果想通过选择器引用第一个按钮，可以这样写$(".div1.hide")；

通过parents()可以获得某个元素的所有父标记，如果想获得class为CLASS的某个或者某几个父标记，可以这样，parents(".CLASS")；

6. fadeIn、fadeOut、fadeToggle
fadeIn(speed,callback)，渐进显示；
speed显示速度，可以取毫秒数、"fast"、"normal"、"slow"；
也可以不指定speed，这时callback也不能指定；
callback可以不指定；
例子：
fadeIn()，立即显示；
fadeIn("slow")，缓慢显示；
fadeIn(3000)，在3秒内，渐渐地显示出来；

fadeOut(speed,callback)，渐进隐藏；
speed显示速度，可以取毫秒数、"fast"、"normal"、"slow"；
也可以不指定speed，这时callback也不能指定；
callback可以不指定；
例子：
fadeOut()，立即隐藏；
fadeOut("slow")，缓慢隐藏；
fadeOut(3000)，在3秒内，渐渐地隐藏；

fadeToggle(speed,callback)，在显示与隐藏间渐进切换；
speed显示速度，可以取毫秒数、"fast"、"normal"、"slow"；
也可以不指定speed，这时callback也不能指定；
callback可以不指定；
例子：
fadeToggle()，立即在隐藏与显示之间切换；
fadeToggle("slow")，缓慢地在隐藏与显示之间切换；
fadeToggle(3000)，在3秒内，完成在隐藏与显示之间切换；

fadeTo(speed,opacity,callback)，改变透明度；
speed可以是毫秒数、"normal"、"fast"、"slow"；
callback可以不指定；
例子：
fadeTo("slow",0.5)；

7. 滚动
slideDown(speed,callback)，向下滚动；
slideUp(speed,callback)，向上滚动；
slideToggle(speed,callback)，在向上滚动与向下滚动之间切换；

8. 动画
animate({params},speed,callback)，对这个函数的描述：
The required params parameter defines the CSS properties to be animated.
The optional speed parameter specifies the duration of the effect. It can take the following values: "slow", "fast", or milliseconds.
The optional callback parameter is a function to be executed after the animation completes.
例子：
指定一个CSS属性：
\$("button").click(function(){
		  \$("div").animate({left:'250px'});
		  }); 
指定多个CSS属性：
\$("button").click(function(){
		  \$("div").animate({
			      left:'250px',
				      opacity:'0.5',
					      height:'150px',
						      width:'150px'
							    });
		  }); 
使用预定义的值（执行后先消失，再执行一次，恢复原来的状态）：
\$("button").click(function(){
		  \$("div").animate({
			      height:'toggle'
				    });
		  }); 
指定一个动画队列：
$("button").click(function(){
		  var div=$("div");
		    div.animate({height:'300px',opacity:'0.4'},"slow");
			  div.animate({width:'300px',opacity:'0.8'},"slow");
			    div.animate({height:'100px',opacity:'0.4'},"slow");
				  div.animate({width:'100px',opacity:'0.8'},"slow");
				  }); 

9. 停止动画
stop(stopAll,goToEnd)，这个函数的描述：
一个元素的动画可能是一个动画队列；
参数stopAll、goToEnd默认为false，stopAll表示是否停止动画队列中的所有动画，goToEnd表示是否将当前动画立即切换到动画结束时的状态，再停止；
例如：
stop()，立即终止当前元素的当前动画，但是，如果该元素的动画是一个动画队列的话，那么后续的动画将继续执行；
stop(true)，立即终止当前元素的当前动画，并清空元素上对应的动画队列；
stop(true,true)，立即终止当前元素的当前动画，并清空元素上对应的动画队列，但是会将当前状态立即切换到当前被停止的动画(注意不是动画队列)结束时的状态；

10. Chaining，动作链
以前针对元素写的代码都是一条语句一个操作，这样的话，如果对同一个元素进行了多次操作，那么就有多条语句，浏览器在执行代码的时候，就会通过选择器，多次对同一个元素进行定位，这是不必要的。
为了节省浏览器开销，可以采用动作链，对同一个元素的定位只执行一次，将多个动作组织成一条语句：
\$("#p1").css("color","red").slideUp(2000).slideDown(2000);
对id为p1的元素进行一次定位，然后一次改变颜色、向上滚动、向下滚动；
动作链可能会很长，可以这样分成多行：
$("#p1").css("color","red")
    .slideUp(2000)
	  .slideDown(2000);

	  11. DOM
	    Document Object Model，它是个标准，定义了对HTML和XML文档的相关操作；

	  12. Get相关操作
	    text() - Sets or returns the text content of selected elements
	    html() - Sets or returns the content of selected elements (including HTML markup)
	  val() - Sets or returns the value of form fields

	13. Set相关操作
	text("your text") - Sets or returns the text content of selected elements
	html("your html") - Sets or returns the content of selected elements (including HTML markup)
	val("your value") - Sets or returns the value of form fields

	attr({attrname,attrvalue}) - 设置元素属性的值；
	例子：
	\$("#w3s").attr("href","http://www.w3schools.com/jquery");
	也可以指定一个属性列表：
	  \$("#w3s").attr({
			      "href" : "http://www.w3schools.com/jquery",
				      "title" : "W3Schools jQuery Tutorial"
					    });

14. Add
append，在指定元素的内容部分的结尾处，追加内容；
prepend，在指定元素内容部分的开始处，添加内容；
after，在指定元素的后面，追加元素；
before，在指定元素的前面，添加元素；

15. Remove
remove，移除指定元素及其子元素；
empty，移除指定元素的所有子元素；

16. css相关操作
addClass("classname")，在指定的元素上添加上css类；
removeClass("classname")，在指定的元素上删除css类；
toggleClass("classname")，在指定的元素上添加css类，或者移除css类，在二者之间切换；

17. css
css(propertyname)，返回指定元素上的style中的属性值；
css({propetyname,propertyvalue})，设定指定元素上的style中的属性值，可以设定一个属性，也可以指定一个属性列表，设定多个属性；

18. Dimension
JQuery Dimension，还是参看一下w3school上那张图解比较好；

19. Traversing
Traversing，表示在DOM树中进行遍历，向上遍历父节点，向下遍历子节点，遍历兄弟节点；

traversing up：
parent()，返回当前元素的直接父节点元素；
parents()，返回当前元素的所有父节点，就是从当前元素节点一直到根节点的路径上的所有父节点元素；
parents("tagname")，返回当前元素的父节点中的tag标记为tagname的所有父节点元素；
parentsUntil("tagname")，返回当前元素到tag为tagname的父节点元素之间的所有父节点元素；

traversing down：
children()，返回当前元素的所有【直接】孩子节点元素；
children("p.1")，可以给children加一个参数对孩子节点元素进行过滤，例如这里的p.1，返回所有子节点中tag为p的元素，并且元素的class属性为1；
find("tagname")，返回当前元素的【所有】孩子节点元素中tag为tagname的所有自己子节点元素；
find("*")，返回当前元素的【所有】孩子节点元素；

traversing siblings：
siblings()，返回当前元素的所有兄弟节点元素（不包含当前元素）；
siblings("tagname")，返回当前元素的所有兄弟节点元素中tag为tagname的元素，在指定过滤参数的时候，也可以在tagname后面加上class属性进行过滤，例如tagname.classname；
next()，返回当前元素的下一个兄弟节点元素，不可以加过滤参数；
nextAll()，返回当前元素的之后的所有兄弟节点元素，可以加过滤参数；
nextUntil("tagname")，返回当前元素到tag为tagname的兄弟节点元素之间的所有兄弟节点元素；
pre()，preAll()，preUntil("")，这三个元素返回当前元素之前的兄弟节点元素

如何下一个tag为p的兄弟节点元素呢？
nextAll("p").first();

first和last：
first()，返回当前的众多元素中的第一个；
last()，返回当前的众多元素中的最后一个；

eq：
eq(index)，当前选中的众元素构成一个列表，eq(index)返回该列表中的索引值为index的元素，index从0开始；

filter：
filter("criteria")，例如filter(".classname")将返回众选中节点中class为classname的众元素；

not：
not("criteria")，not方法与filter方法正好相反，filter将匹配的返回，not将不匹配的返回；

20. AJAX
Without jQuery, AJAX coding can be a bit tricky!

Writing regular AJAX code can be a bit tricky, because different browsers have different syntax for AJAX implementation. This means that you will have to write extra code to test for different browsers. However, the jQuery team has taken care of this for us, so that we can write AJAX functionality with only one single line of code.

load操作：
$(selector).load(URL,data,callback)，URL是目标地址，data中可以封装用于查询的键值对，callback是load完成后继续调用的函数；
例子：
$("#div1").load("demo_test.txt")，将url中指定的文本的内容添加到id为div1的div中；
\$("#div1").load("demo_test.txt #p1")，还可以在url中指定选择器，将url中id为p1的元素内容添加到id为div1的div中；
可选的callback函数有三个实参，reponseTxt、statusTxt、xhr。
responseTxt，若load调用成功，包含装载的内容；
statusTxt，包含load调用的状态信息；
xhr，包含XMLHttpRequest调用对象；
例子：
\$("#div1").load("demo_test.txt",function(responseTxt,statusTxt,xhr){
		  if(statusTxt=="success")
		      alert("External content loaded successfully!");
			    if(statusTxt=="error")
				    alert("Error: "+xhr.status+": "+xhr.statusText);
					});

HTTP GET、POST：
http get方法：从指定的资源请求数据；
http post方法：向指定的资源提交要处理的数据；
get方法，可能会返回被缓存的数据；post方法也可用于从服务器请求数据，但是不会返回被缓存的数据，并且，常常用于将数据和请求一起发送；

$.get(URL,callback)，使用http get请求资源，待请求数据URL，回调函数有两个实参data和status，data是请求资源的内容，status是请求的状态；
$.post(URL,data,callback)，使用http post请求资源，待请求资源URL，data中指定了伴随着该请求要发送的数据，callback有两个实参data和status，data是请求资源的内容，status是请求的状态；

21. noConflict
可能想同时使用多个JS框架，JQuery使用$这个符号，如果在其他的框架中也使用这个符号就会产生冲突，如何避免呢，有以下几种做法：
1）JQuery中不使用$
$.noConflict(); JQuery放弃使用符号$，以后使用JQuery的时候用JQuery代替符号$，如用JQuery("button")代替$("button")；
2）JQuery中不使用$，使用另外一个符号
var jq = $.noConflict();
以后使用$的地方使用jq代替，例如使用jq("button")代替$("button")；
3）如果已经写好了一段JQuery代码，当然里面使用了大量的符号$，而自己又不想改变这些符号，该如何做呢，可以做如下修改：
将$(document).ready(function()...)修改为JQuery(document).ready(function($)...)，注意到我们给ready的回调函数传递了参数$，这样就可以使得在回调函数体内使用符号$作为JQuery的标记，而在函数体外，仍然需要使用JQuery作为标记；

$.noConflict();
```
