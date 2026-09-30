<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="LoginPage" EnableEventValidation="false" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Sign in — Legacy Auth</title>
  <link rel="stylesheet" href="Styles/Site.css" />
</head>
<body>
  <form id="form1" runat="server">
    <div class="page">
      <aside class="brand-panel">
        <p class="brand">Legacy Auth</p>
        <p class="tagline">ASP.NET Web Forms login backed by MySQL.</p>
      </aside>

      <main class="form-panel">
        <h1>Sign in</h1>
        <p class="subtitle">Use the dummy account below, or register a new one.</p>

        <div class="demo-box">
          <p class="demo-title">Dummy login</p>
          <p>Email: <strong>demo@legacyauth.local</strong></p>
          <p>Password: <strong>demo123</strong></p>
          <p class="demo-alt">Admin: <strong>admin@legacyauth.local</strong> / <strong>admin123</strong></p>
        </div>

        <div class="fields">
          <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email" />
          <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="input" Text="demo@legacyauth.local" />

          <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Password" />
          <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input" Text="demo123" />

          <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false" />

          <asp:Button ID="btnLogin" runat="server" Text="Sign in" CssClass="btn primary" OnClick="btnLogin_Click" />
        </div>

        <p class="switch">
          No account?
          <a href="Register.aspx">Create one</a>
        </p>
      </main>
    </div>
    <script>
      (function () {
        var password = document.getElementById("txtPassword");
        if (password && !password.value) {
          password.value = "demo123";
        }
      })();
    </script>
  </form>
</body>
</html>
