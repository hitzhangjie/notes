---
layout: post  
title: 前端学习HTML
description: ""
date: 2013-06-17 10:34:53 +0800
categories: ["过去的学习笔记"]
tags: ["html"]
toc: true
reward: true
draft: true
---

迁移自 hitzhangjie/Study 项目下的内容，本文主要总结的是HTML里的一些知识要点。

```
HTML Learning

A --- HTML Basic Knowledge
2012-6-17

1.	HTML INTRO
@html is not a programming language,it is just a markup language to describe the content of pages.
@html elements include both the html tags and the plain texts between the tags.
@browsers use html tags to interpret the web pages.

@<!DOCTYPE doctype>	: this declaration defines the document type,such as <!DOCTYPE html>.
@<h1>to<h6> defines the headings use different font size.
@<p> defines paragraph.
@<a> defines a link,and the link address is included in the attribute 'href',such as,<a href="http://www.baidu.com">baidu</a>.
@<img> defines the image elements,its name,height,width is included in attributes 'src','width','height'.
@most html elements can be nested.
@empty elements are closed in the openning tags,such as <br/>.
@html tags are case-insensitive,but we suggest we should use lowercase html tags.
@html tags attributes appear in openning tags,its form is: attName="value",please note that value must be quoted.if content of value include double quotes,value should be quotoed by single quoto.

2.	HTML TAGS

<!--comment-->
<!DOCTYPE doctype>
<a>:	<a href="http://www.baidu.com"
	<a name="anchorName">
	<a href="#achorName">
	<a href="mailto:hit.zhangjie@gmail.com?username@xxx.com&username2@xxx.com&username3@xxx.com&subject=hello%20world&body=hello%20world>send m
	ail</a>
<abbr>:	abbreviation of some words or sentences,when mouse over,content will be displayed and content is included in attribute 'title'
<acronym>: content in attr 'title' will be displayed when mouse over
<area>:	specify an area of image mapping
	<img src="..." usemap="#mapname">
	<map name="mapname">
		<area shape="..." coords="..." title="">
	</map>
<b>	:bold
<strong>:strong
<big>	:big
<i>	:italic
<em>	:emphasize
<small>	:small
<tt>	:teletype
<sub>	:下标
<sup>	:上标
<base>	:base url,must be included between <head></head>
	<head>
		<base href="http://localhost" target="_blank"/>
	</head>
	<body>
		<img src="world.jpg" width="100" height="100"/>
		<a href="http://www.baidu.com" target="_self">baidu</a>
	</body>
	world.jpg将在路径localhost/world.jpg中检索，而链接如果不指明target="_self",将默认使用base中约定的_blank.
<bdo>	:dir="ltr" characters will be written from left to right
	:dir="rtl" characters will be written from right to left
<blockquote>	:insert into a long quotation
<button>	:define a button control
<caption>	:specify table name for a following table
<dfn>	:definition term
<code> 	:computer code segments
<samp>	:computer program output 
<kbd>	:keyboard input
<var>	:variable
<cite>	:citation,quoto a short information
<tr>	:one row in table
<td>	:one unit in table,accurately in a table row
<th>	:table heading
<col>	:specify one or more columns' attributes in a table
<colgroup>	:specify a group consist one or more columns by attribute 'span'
<dl>	:definition list
<dt>	:definition term
<dd>	:definition description
<del>	:strikethrough the text marked by <del>
<ins>	:underline the text marked by <ins>
<div>	:specify a section in the document,and content's style in this secton will be controlled by attribute in <div>
<fieldset>	:specify a field set of one or more controls,combined with <legend>
<legend>	:specify a caption of a field set defined by <fieldset>
<form>	:defines a form in the html document
<frameset>	:one html document can reference to one or more html documents and display their contents in separate frame
		:frameset can be vertically,horizontally separate,also mixed,that means <frameset> can be nested
<frame>		:nested into the body of <frameset>,to specify the referenced html document's url.if set its attribute 'noresize' to value 
		'noresize',then its size can't be adjusted,if you want to adjust it,delete the attribute and its value.
<h1>to<h6>	:headings in defferent size of font,h1 is the biggest,h6 is the smallest
<head>	:<title>,<style>,<meta>,<link> can be added into its body
<hr>	:defines a horizontal line
<html>	:defines the root of a html document
<iframe>	:defines a inline frame that can be used to display other referenced html document
<img>	:defines a image
<input>	:some input controls included text,password,checkbox,radio,reset,submit,img,hidden,file.
<label>	:define a label for a control defined by <input>,when you click the text of label,equal to click the relevant control.
	<label> has an atrribute for="id value",idvalue is the id value of <input> control
<legend>:defines a caption for the field set 
<ol>	:ordered list
<ul>	:unordered list
<li>	:one item in the <ol> or <ur> list
	:<ol><ul> can be nested
<link>	:define a link between current document and an external document
<map>	:in a picture,define several clickable areas
<meta>	:define meta data in document
<noframes>	:if <frame> used but it can't be supported by your browser,an alternate text will be useful,<noframes> does this
<noscript>	:if <script> used but your browser doesn't support it,<noscript> will output an alternate text instead
<object>	:define an embeded object,such as audio,video,picture,etc
<select>	:define a drop-down list,including two styles,single selection or multiple selections
<option>	:one selection in <select>
<optgroup>	:define a group consist of several options,add a name to it by attribute 'label'
<param>	:pass parameters to object defined by <object>
<pre>	:define preformatted text,the defined text will be displayed as the same style as in <pre> body.it is often used to display computer code
<q>	:define a short quotation,text between <q>and</q> will be quotoed by double quoto
<script>:define a client-side script
<span>	:define a section in the document
<style>	:define style information in the document
<table>	:define a table
<thead>	:groups the head content in a table
<tbody>	:groups the body content in a table
<tfoot>	:groups the foot content in a table
<td>	:define a cell in a table
<textarea>	:multiple lines input
<th>	:defines a head cell in a table
<title>	:defines a title for current document
<tr>	:defines a row in table

3.	2012-6-18
html中连续出现的空格会被当作一个空格，段落内部<p></p>之间的部分出现的换行会被忽略。

4.	2012-6-19
1）css，即层叠样式表，用来对html中特定标签的风格进行设置。这里的风格可以在当前html文档中，在<head></head>之间通过设置<style type="text/css">来实现，也可以在当前文档中的<head></head>之间添加链接，指向外部的stylesheet文件*.css，例如：<link rel="stylesheet" type="text/css" href="mystyle.css"/>。当然也可以在单独的标签中通过设置style属性来实现。
2）如果一个通过<a href="">定义的超链接，如果不想让其显示下划线，可以在添加属性style="text-decoration:none"来实现。
3）在<img>标签中，有个属性alt，代表alternate的意思，如果图片由于某种原因在客户端浏览器无法正常显示，那么就显示alt指定的代替文本信息。
4）当图片跟文本混合出现时，默认是底部对齐，可以在<img>标签中通过align指定对其方式，比如bottom，center，top。如果设置成left或者right，那么图片会浮动在文本的左端或右端。
5）利用图片设置超链接，可以将图片作为<a href="">的元素，也可以在图片<img>中使用usemap。
6）<tr><td>:table row,table data.在<table>中通过设置border的大小，可以让table产生边界产生不同的视觉效果。通过设置属性frame，可以控制显示指定边的边界。
7）添加标题，<fieldset>用<legend>,<table>用<caption>。
8）html中的颜色设置，通过十六进制数表示，红绿蓝三种颜色混合而成。这三种基色的最小取值为0，最大取值为255，即分别对应十六进制的0和ff。常用的颜色取值有：
黑色	：#000000
红色	：#ff0000
绿色	：#00ff00
蓝色	：#0000ff
黄色	：#ffff00
天蓝	：#00ffff
粉红	：#00ffff
灰色	：#c0c0c0
共有颜色组合数256X256X256种，so many，用的时候可以查表。
为了使用颜色的方便，在html和css中通过“颜色名字”定义了147种颜色，可以通过名字直接引用对应的颜色。


B --- HTML Advanced Knowledge

1. 	2012-6-21
1）<!DOCTYPE>不是html标记，它是用来指明当前html文档使用的是哪一个版本，它是给浏览器看的，只有在浏览器确切的知道当前html文档使用的html版本的情况下，浏览器才能100%的正常显示文档内容。

常见的html版本如下：
HTML	: 	1991 YEAR
HTML+	:	1993
HTML2.0	:1995
HTML3.2	:1997
HTML4.01:1999
XHTML1.0:2000
HTML5	:2012
XHTML5	:2013

常见的html版本声明方法如下：
HTML5:	<!DOCTYPE html>
HTML4.01:	
	<!DOCTYPE HTML PUBLIC "-//W3C/DTD HTML 4.01 Transitional //EN" "http://www.w3.org/TR/html4/loose.dtd">
XHTML1.0：
	<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml/DTD/xhtml-transitional.dtd"
2)<head>
	<meta name="author" content="zhangjie"/>
	<meta name="revise" content="2012/6/21"/>
 </head>
在<head>体内定义了文档的作者是谁，也定义了文档的修订日期。
也可以在<meta>内定义文档的描述description和关键字keywords，关键字的content值，如果有多个关键字，需要用逗号隔开。
3）页面重定向
利用<meta http-equiv="Refresh" content="5;http://www.baidu.com"/>
这里的http-equiv="Refresh"表示当前页面经过5秒钟，将被重定向到url http://www.baidu.com。
4）可以添加到<head>标记体内的tag包括:title,base,style,meta,script,link。
<title>指定当前文档页面的标题；
<base href="base url" _target="_blank">指定当前页面内所有元素的基本url以及当前页面在浏览器中的打开方式，_blank表示在新窗口中打开；
<style type="text/css">可以在页面内部定义当前页面要使用的层叠样式表；
<link rel="stylesheet" type="text/css" href="mystyle.css">可以定义当前页面使用的外部的层叠样式表;
<meta>刚刚在前面叙述了，值得注意的是<meta>定义的关键字keywords的content是给搜索引擎看得；
<script>定义的使一个客户端的脚本，如javascript。
5）在<body>体内插入一个简单的script：
   <body>
	<script type="text/javascript">
	document.write("hello,zhangjie")
	</script>
   </body>
   注意，函数write后面没有分号，另外是小写。
6）<noscript>content</noscript>:<noscript>体内的内容content，只有当客户端浏览器不支持脚本时才会显示出来。
   
2.	2012-6-22

1）在html标记语言中，存在一些保留字，我们不能直接使用这些保留字，比如尖括号，因为浏览器会错误地将它们解释为tag标记，如果要使用这些特殊的保留子的普通文本意思，而非在html语言中的保留意义，那么就需要使用entity，有两种方式：通过实体名entity-name来引用，比如&lt,表示less than，即小于号；通过实体编号来引用，&#60，也表示小于号。
2）需要注意的是，并非所有的实体名entity-name，浏览器都能够支持，相比之下，浏览器对实体编号entity-number的支持更好。
3）在使用的时候，如果需要用到这样的特殊保留字，可以查找entity表。
4）url：uniform resource locators
	它的语法格式如下：scheme://host.domain：port/path/filename
5）scheme指的是internet服务类型，可以是http，https,ftp,file。http即超文本传输协议，https即安全的超文本传输协议，ftp文件传输协议，file是指自己电脑上   的文件。
   host通常是www，domain即域名，port为发送到服务器的端口编号，对于http，通常为80端口。
   path指的是相对与根目录的路径，如果没有指定path，那么文档一定是在根目录下面。
   filename为请求的文件名。
   需要注意的是，通常我们访问一个站点的主页时，不许要指定index.html，但是站点确实显示的是主页index.html的信息，其实这是在服务器中进行配置的。如果我   们访问一个站点，服务器自动加载主页。
6）url encoding:
   url传送的字符都必须是ascii字符集中的字符，如果要传送的字符中含有ascii字符集之外的字符，需要对其进行转换，将非ascii字符转换为ascii字符。通常转换    的形式是：一个百分号%后面跟两个十六进制数字，%num1num2,以这种ascii形式来代表非ascii字符。
   另外，url传送的内容中，不允许包含空格，也需要对空格进行转换，通常的方式是：将空格用加号“+”代替。

 
C --- CSS (Cascading Style Sheet)

1. 2012-6-23

CSS backgrounds:

1)set the background color of page	:	body {background-color:#...;}
2)set the background color of elements	:	h1 {background-color:#..} p {background-color:#...} div {background-color:#...} ...
3)set the background image of page	:	body {background-image:url("url of img");}
4)repeat a background image only horizontally	:	background-repeat:repeat-x;
			    only vertically	: 	background-repeat:repeat-y;
5)position a image in a page		:	body {background-image:url("..");background-repeat:no-repeat;background-position:right top;}
  note: top,bottom stands for "bottom,top",it stands for the contrary side
6)fix a image in order to disable scroll with the pag	:	body {...background-attachment:fixed;}
no-repeat fixed right top margin-right:200px
8)customize a div section,such as:
	<head>
		<style type="text/css">
			.myCssName
			{
				text-align:center;
			}
		</style>
	</head>
	<body>
		<div class="myCssName">
			<p>hello world</p>
		</div>
	</body>
	
9)可以通过与（8)中类似的方法定义一些标签的额外风格，比如定义风格:p.mystyle {.....},当使用<p>的时候是一种风格，当使用<p class="mystyle">的时候就是使用的刚才自定义的风格。
10）通过css定义文本的颜色有3种方式：color:颜色的名字,color:#颜色编号,color:rgb(xx,xx,xx)
11)文本对齐定义：text-align:center,另有left,right,justity。justify是一种类似于左对齐的方式，但是文本排列的比较均匀。
12）文本修饰：text-decoration:overline,另有line-through,underline,blink。分别表示上划线，删除线，下划线，闪烁。
13）文本转换text-transform:uppercase,另有lowercase,capitalize。分别表示全部大写，全部小写，各个单词首字母大写。
14）文本缩进：text-indent:50px，表示首行字符向右缩进50px。
15）字母间距：letter-spacing:2px,允许值为负值，但是字符会相互覆盖。
16）设置行高：line-height:70%,表示标准行高的70%，200%表示标准行高的两倍。
17）文本排列方式：direction:rtl
18）单词间距：word-spacing:30px
定义文本中嵌套的图片的对其方式，默认的是与文本的底部对齐。对齐设置方式为：vertical-align:text-top表示与文本顶部对齐，text-bottom表示与文本底部对齐。
文本折叠，也就是通俗意义上的文本自动换行，white-space:nowrap，表示不折叠，wrap表示折叠。
21）设置文本字体，font-family:Times New Roman。设置字体为Times New Roman。
22）设置文本大小，font-size：200%，表示设置为标准大小的2倍。
23）设置文本大小，也可以通过设置px的值来设置，比如font-size:20px。
24）设置文本大小，也可以通过设置em的值来设置。
25）设置文本的字体风格，font-style:normal,另有italic，oblique。
设置字体的ariant，font-ariant：normal,另有small-caps，small-caps表示将小写转成大写。
27）设置链接的颜色：
注意为了使hover设置有效，hover的设置必须放在link和visited之后。
a:link {color:#...} /* unvisited link */
a:visited {color:#...} /* visited link */
a:hover {color:#...} /* mouse over link */
a:active {color:#...} /* selected link */
链接上的文本修饰：
a:link {text-decoration:none;} /*unvisited*/
a:visited {text-decoration:none;} /*visited link*/
a:hover {text-decoration:underline;} /*mouse over link*/
a:active {text-decoration:underline;} /*selected link*/
设置链接文本的背景色：
格式同上，只是将设置的内容改为：background-color:#...
设置链接文本的前景色：格式同上，将社会子的内容改为color:#...
如果想为链接设置额外的风格，格式为a.stylename:link,a.stylename:visited.....
设置link-box，显示出来的样式跟一个超链接按钮差不多。
a:link,a:visited
{
display:block;
...
}

2012-6-25

设置列表的显示风格：ol {list-style-type:circle},这里的list-style-type还可以是disc,square,armenian,cjk-ideographic,decimal,decimal-leading-zero,georgian,hebrew,hiragana,hiragana-iroha,katakana,katakana-iroha,lower-alpha,lower-greek,lower-roman,upper-alpha,upper-greek,upper-latin,upper-roman,none,inherit。
34）设置列表项为图片：ul {list-style-image:url("...");}。
35）在一个声明中，生命所有的列表项风格：ul {list-style:square url("..");}。
36）通过css设置table的风格，包括以下几点：
设置表格table，表头th，表格元素td的边界属性，如边界宽度和颜色；
使用边界风格border-collapse；
指定表格的宽度和高度；
设置文本内容的水平对齐方式，利用text-align；
设置文本内容的垂直对齐方式，利用vertical-align；
设置th和td元素的padding，即与表格的距离；
设置表格边界的颜色和宽度；
设置表格标题caption的位置，利用caption-side，可以选择top或者bottom，left，right。
37）设置边界风格：border-style，可选的有solid等。
设置四条边边界宽度：border-width，用“数字px“来表示取值。
设置上边界宽度：border-top-width，用“数字px”来表示取值。
设置下边界宽度：border-bottom-width。
设置左边界宽度：border-left-width。
设置右边界宽度：border-right-width。
38）设置四条边风格：border-style，可选none,dotted,dashed,solid,double,groove,ridge,inset,outset,hidden。
设置上下左右边界风格：border-top-style,border-bottom-style,border-left-style,border-right-style。
39）设置边界的颜色：
如果利用border-color来设置，可以指定多个颜色，这样每条边从上边界按顺时针使用指定的颜色，剩余的边的颜色与对边颜色相同。
也可以单独指定上下左右边界的颜色，border-top-color,border-bottom-color,border-left-color,border-right-color。
40）在一个元素周围画边界或者轮廓，如 p {border:1px solid red;outline:green dotted thick;}。
也可以单独设置outline-style，可选值为dotted,dashed,solid,double,groove,ridge,inset,outset。
设置outline的颜色：outline-color。
设置outline的宽度：outline-width，可选的取值为thin或者thick。
41）css margin and padding
42）css dimension

2012-6-26

43)设置图片的高度宽度height，width，最大高度最大宽度max-height,max-width，最小高度最小宽度min-height,min-width，它们的取值有两种，一种是通过设置px的值，另一种是通过设置百分比数值。
44）设置隐藏元素：{visibility:hidden；}，这样设置的元素不会显示，但是仍然会占据一定的空间。
设置不显示的元素：{display:none；},这样设置的元素不会显示，也不占据空间。
设置内联显示方式：{display:inline;},这样风格的几个元素相邻时，之间无空格。
设置块显示方式：{display:block;},这样风格的几个元素相邻时，之间有一个换行。
45）在浏览器窗口中设置一个位置固定的元素,{position:fixed;}。

相对于正常位置的相对位置：{position:relative;left:...;}或{position:relative;right:...;}。

以绝对位置的方式定位元素：{position:absolute;left:..px;right:..px;}。

允许覆盖的层叠方式定位：{position:absolute;left:..;right:..;z-index:..;}。如果z-index的值越大，当前元素越位于顶层。位于下层的会被覆盖。

设置一个元素的形状：{position:absolute; clip:rect（0px,60px,200px,0px);}
设置滚动条或者隐藏超出边界的内容，利用属性overflow，取值scroll或者hidden也可以取auto。
47）设置图片的top,bottom,left,right位置，利用px的值。
48）设置改变鼠标指针的形状：
<span style="cursor:auto">auto</auto>
另外style也可以取值为：auto,crosshair,default,e-resize,help,move,n-resize,nw-resize,pointer,progress,s-resize,se-resize,sw-resize,text,w-resize,wait。
note：resize属性中n表示north，s表示south，w表示west，e表示east。

2012-6-27

CSS Floating
应用：
a simple use of the float property
an image with border and margins that floats to the right in a paragraph
an image with a caption that floats to the right
let the first letter of a paragraph float to the right
create an image gallery with the float property
turn of float - with the clear property
creating a horizontal menu
creating a homepage without tables

CSS Aligning Elements
应用：
center aligning with margin
left/right aligning with position
left/right aligning with position - crossbrowser solution
left/right aligning with float
left/right aligning with float - crossbrowser solution

CSS Generated Content
应用：
insert the url in parenthesis after each link with the content property
numbering sections and sub-sections with "Section 1","1.1","1.2",etc
specify the quotation marks with quotes property

CSS Pseudo-classes
应用：
add different colors to a hyperlink
add other styles to hyperlinks
input,use of :focus
:first-child - match the first p element
:first-child - match the first i element in all p elements
:first-child - match all i elements in all first child p elements
:use of:lang

CSS Pseudo-elements
应用：
72）make the first letter special in a text
make the first line special in a text
make the first letter and first line special
use:before to insert some content before an element
use:after to insert some content after an element

CSS Navigation Bars
应用：
77）fully styled vertical navigation bar
fully styled horizontal navigation bar ( li {float:left;} )

CSS Image Gallery
image gallery

CSS Image Opacity
creating transparent images - mouseover effect
creating a transparent box with text on a background image

CSS Image Sprites
An image sprite
An image sprite - a navigation list
An image sprite with hover effect

CSS Attribute Selectors
85）select elements with a title attribute
select elements with title=a specify value
select elements with title=a specify value（even if the attribute has space-separated values)
select elements with title=a specify value (even if the attribute has hyphen-separated values)

2012-6-28 

html tables
table headers	： th
table with a caption	: 	<caption> behind <table>
table cells that span more than one row or column	: rowspan,colspan


html layouts
<div>	:	id="container","header","menu","footer","content"

html forms
<input type="..."> type可以是：text,textarea,button,submit,radio,checkbox.
表单中可以包含<select>下拉列表.

<iframe>是为了在一个页面中，利用页面的一块区域显示另一个页面。

！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
HTML QuickList


HTML Basic Document

<!DOCTYPE html>
<html>
<head>
<title>Title of document goes here</title>
</head>
<body>
Visible text goes here...
</body>

</html>
Heading Elements
<h1>Largest Heading</h1>

<h2> . . . </h2>
<h3> . . . </h3>
<h4> . . . </h4>
<h5> . . . </h5>

<h6>Smallest Heading</h6>
Text Elements
<p>This is a paragraph</p>
<br /> (line break)
<hr /> (horizontal rule)
<pre>This text is preformatted</pre>
Logical Styles
<em>This text is emphasized</em>
<strong>This text is strong</strong>
<code>This is some computer code</code>
Physical Styles
<b>This text is bold</b>
<i>This text is italic</i>
Links
Ordinary link: <a href="http://www.example.com/">Link-text goes here</a>
Image-link: <a href="http://www.example.com/"><img src="URL" alt="Alternate Text" /></a>
Mailto link: <a href="mailto:webmaster@example.com">Send e-mail</a>

A named anchor:
<a name="tips">Tips Section</a>
<a href="#tips">Jump to the Tips Section</a>
Unordered list
<ul>
  <li>Item</li>
  <li>Item</li>
</ul>
Ordered list
<ol>
  <li>First item</li>
  <li>Second item</li>
</ol>
Definition list
<dl>
  <dt>First term</dt>
    <dd>Definition</dd>
  <dt>Next term</dt>
    <dd>Definition</dd>
</dl>
Tables

<table border="1">
  <tr>
    <th>Tableheader</th>
    <th>Tableheader</th>
  </tr>
  <tr>
    <td>sometext</td>
    <td>sometext</td>
  </tr>
</table>
Iframe

<iframe src="demo_iframe.htm"></iframe>
Frames

<frameset cols="25%,75%">
  <frame src="page1.htm" />
  <frame src="page2.htm" />
</frameset>
Forms
<form action="http://www.example.com/test.asp" method="post/get">

<input type="text" name="email" size="40" maxlength="50" />
<input type="password" />
<input type="checkbox" checked="checked" />
<input type="radio" checked="checked" />
<input type="submit" value="Send" />
<input type="reset" />
<input type="hidden" />

<select>
<option>Apples</option>
<option selected="selected">Bananas</option>
<option>Cherries</option>
</select>

<textarea name="comment" rows="60" cols="20"></textarea>

</form>
Entities
&lt; is the same as <
&gt; is the same as >
&#169; is the same as ©
Other Elements

<!-- This is a comment -->

<blockquote>
Text quoted from a source.
</blockquote>

<address>
Written by W3Schools.com<br />
<a href="mailto:us@example.org">Email us</a><br />
Address: Box 564, Disneyland<br />
Phone: +12 34 56 78
</address>
```
