using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;

public partial class DashboardPage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SiteMaster master = Master as SiteMaster;
        if (master != null)
        {
            master.PageTitle = "Dashboard";
            master.PageHint = "Overview";
        }

        string name = Session["UserName"] as string ?? "User";
        litWelcome.Text = "Welcome back, " + Server.HtmlEncode(name) + ". Here is a snapshot of your workspace.";

        int userId = GetUserId();
        if (userId <= 0)
        {
            return;
        }

        try
        {
            DashboardStats stats = AppDb.GetDashboardStats(userId);
            litOpenTasks.Text = stats.OpenTasks.ToString();
            litTasksDue.Text = stats.TasksDueThisWeek + " due this week";
            litReports.Text = stats.ReportCount.ToString();
            litNotifications.Text = stats.NotificationCount.ToString();
            litUnread.Text = stats.UnreadNotifications + " unread";
            litTeam.Text = stats.TeamMembers.ToString();

            List<ActivityItem> activity = AppDb.GetRecentActivity(userId, 5);
            StringBuilder html = new StringBuilder();
            foreach (ActivityItem item in activity)
            {
                html.Append("<li><strong>")
                    .Append(Server.HtmlEncode(item.Description))
                    .Append("</strong><span>")
                    .Append(Server.HtmlEncode(FormatWhen(item.CreatedAt)))
                    .Append("</span></li>");
            }

            if (html.Length == 0)
            {
                html.Append("<li><strong>No recent activity</strong><span>—</span></li>");
            }

            litActivity.Text = html.ToString();
            litTasks.Text = BuildTaskRows(AppDb.GetOpenTasks(userId));
        }
        catch (Exception)
        {
            litOpenTasks.Text = "—";
            litTasksDue.Text = "Database unavailable";
            litReports.Text = "—";
            litNotifications.Text = "—";
            litUnread.Text = "—";
            litTeam.Text = "—";
            litActivity.Text = "<li><strong>Could not load activity</strong><span>Check LegacyBizDb</span></li>";
            litTasks.Text = "<tr><td colspan=\"4\">Could not load tasks from LegacyBizDb.</td></tr>";
        }
    }

    private string BuildTaskRows(List<TaskItem> tasks)
    {
        StringBuilder rows = new StringBuilder();
        foreach (TaskItem task in tasks)
        {
            string due = task.DueDate.HasValue
                ? task.DueDate.Value.ToString("MMM d, yyyy")
                : "No due date";
            string assigned = string.IsNullOrEmpty(task.AssignedUser) ? "\u2014" : task.AssignedUser;
            rows.Append("<tr>")
                .Append("<td>").Append(Server.HtmlEncode(task.Title)).Append("</td>")
                .Append("<td>").Append(Server.HtmlEncode(due)).Append("</td>")
                .Append("<td><span class=\"pill ").Append(StatusCss(task.Status)).Append("\">")
                .Append(Server.HtmlEncode(task.Status ?? string.Empty))
                .Append("</span></td>")
                .Append("<td>").Append(Server.HtmlEncode(assigned)).Append("</td>")
                .Append("</tr>");
        }

        if (rows.Length == 0)
        {
            rows.Append("<tr><td colspan=\"4\">No open tasks.</td></tr>");
        }

        return rows.ToString();
    }

    private static string StatusCss(string status)
    {
        if (string.Equals(status, "InProgress", StringComparison.OrdinalIgnoreCase))
        {
            return "ok";
        }

        if (string.Equals(status, "Open", StringComparison.OrdinalIgnoreCase))
        {
            return "warn";
        }

        return "muted";
    }

    private int GetUserId()
    {
        object value = Session["UserId"];
        return value is int ? (int)value : 0;
    }

    private static string FormatWhen(DateTime utc)
    {
        TimeSpan age = DateTime.UtcNow - utc;
        if (age.TotalMinutes < 5)
        {
            return "Just now";
        }

        if (age.TotalHours < 24)
        {
            return "Today";
        }

        if (age.TotalDays < 2)
        {
            return "Yesterday";
        }

        return ((int)age.TotalDays) + " days ago";
    }
}
