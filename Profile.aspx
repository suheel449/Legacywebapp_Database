<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Profile.aspx.cs" Inherits="ProfilePage" %>

<asp:Content ID="Title" ContentPlaceHolderID="TitleContent" runat="server">Profile — Legacy Auth</asp:Content>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
  <article class="card">
    <h2>Account details</h2>
    <p class="subtitle">Loaded from the Users table in LegacyBizDb.</p>

    <dl class="profile">
      <div>
        <dt>Name</dt>
        <dd><asp:Literal ID="litName" runat="server" /></dd>
      </div>
      <div>
        <dt>Email</dt>
        <dd><asp:Literal ID="litEmail" runat="server" /></dd>
      </div>
      <div>
        <dt>Role</dt>
        <dd><asp:Literal ID="litRole" runat="server" /></dd>
      </div>
      <div>
        <dt>Status</dt>
        <dd><asp:Literal ID="litStatus" runat="server" /></dd>
      </div>
    </dl>
  </article>

  <article class="card">
    <h2>Sign-in summary</h2>
    <p class="subtitle">Loaded from login history.</p>

    <dl class="profile">
      <div>
        <dt>Total attempts</dt>
        <dd><asp:Literal ID="litAttempts" runat="server" Text="0" /></dd>
      </div>
      <div>
        <dt>Successful</dt>
        <dd><asp:Literal ID="litSuccessful" runat="server" Text="0" /></dd>
      </div>
      <div>
        <dt>Failed</dt>
        <dd><asp:Literal ID="litFailed" runat="server" Text="0" /></dd>
      </div>
      <div>
        <dt>Last sign-in</dt>
        <dd><asp:Literal ID="litLastLogin" runat="server" Text="No sign-ins recorded" /></dd>
      </div>
    </dl>
  </article>
</asp:Content>
