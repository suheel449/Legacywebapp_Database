using System;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class SiteMaster : MasterPage
{
    public string PageTitle { get; set; }
    public string PageHint { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserEmail"] == null)
        {
            Response.Redirect("Login.aspx");
            return;
        }

        string name = Session["UserName"] as string ?? "User";
        litUserName.Text = Server.HtmlEncode(name);
        litPageTitle.Text = Server.HtmlEncode(PageTitle ?? "Workspace");
        litPageHint.Text = Server.HtmlEncode(PageHint ?? "Signed in");

        SetActiveNav();
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        object sessionId = Session["DbSessionId"];
        if (sessionId is int)
        {
            try
            {
                AppDb.CloseUserSession((int)sessionId);
            }
            catch (Exception)
            {
                // Sign-out still completes if the database is unavailable.
            }
        }

        Session.Clear();
        Session.Abandon();
        Response.Redirect("Login.aspx");
    }

    private void SetActiveNav()
    {
        string path = (Request.Path ?? string.Empty).ToLowerInvariant();
        Mark(lnkDashboard, path.Contains("dashboard.aspx") || path.Contains("home.aspx"));
        Mark(lnkProfile, path.Contains("profile.aspx"));
        Mark(lnkReports, path.Contains("reports.aspx"));
        Mark(lnkNotifications, path.Contains("notifications.aspx"));
        Mark(lnkSettings, path.Contains("settings.aspx"));
    }

    private static void Mark(HyperLink link, bool active)
    {
        link.CssClass = active ? "nav-link active" : "nav-link";
    }
}
