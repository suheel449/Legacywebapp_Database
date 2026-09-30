<%@ Page Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="DashboardPage" %>

<asp:Content ID="Title" ContentPlaceHolderID="TitleContent" runat="server">Dashboard — Legacy Auth</asp:Content>

<asp:Content ID="Main" ContentPlaceHolderID="MainContent" runat="server">
  <p class="lead"><asp:Literal ID="litWelcome" runat="server" /></p>

  <section class="stat-grid">
    <article class="card stat">
      <p class="stat-label">Open tasks</p>
      <p class="stat-value"><asp:Literal ID="litOpenTasks" runat="server" Text="0" /></p>
      <p class="stat-note"><asp:Literal ID="litTasksDue" runat="server" Text="—" /></p>
    </article>
    <article class="card stat">
      <p class="stat-label">Reports</p>
      <p class="stat-value"><asp:Literal ID="litReports" runat="server" Text="0" /></p>
      <p class="stat-note">From MySQL</p>
    </article>
    <article class="card stat">
      <p class="stat-label">Notifications</p>
      <p class="stat-value"><asp:Literal ID="litNotifications" runat="server" Text="0" /></p>
      <p class="stat-note"><asp:Literal ID="litUnread" runat="server" Text="—" /></p>
    </article>
    <article class="card stat">
      <p class="stat-label">Team members</p>
      <p class="stat-value"><asp:Literal ID="litTeam" runat="server" Text="0" /></p>
      <p class="stat-note">Active users</p>
    </article>
  </section>

  <article class="card">
    <h2>Your tasks</h2>
    <p class="subtitle">Open work assigned to you.</p>
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Task</th>
            <th>Due</th>
            <th>Status</th>
            <th>Assigned to</th>
          </tr>
        </thead>
        <tbody>
          <asp:Literal ID="litTasks" runat="server" />
        </tbody>
      </table>
    </div>
  </article>

  <section class="split-grid">
    <article class="card">
      <h2>Quick actions</h2>
      <div class="action-list">
        <a class="action" href="Profile.aspx">Update profile</a>
        <a class="action" href="Reports.aspx">View weekly reports</a>
        <a class="action" href="Notifications.aspx">Review alerts</a>
        <a class="action" href="Settings.aspx">Adjust preferences</a>
      </div>
    </article>
    <article class="card">
      <h2>Recent activity</h2>
      <ul class="timeline">
        <asp:Literal ID="litActivity" runat="server" />
      </ul>
    </article>
  </section>
</asp:Content>
