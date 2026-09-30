using System;
using System.Web.UI;

public partial class ProfilePage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SiteMaster master = Master as SiteMaster;
        if (master != null)
        {
            master.PageTitle = "Profile";
            master.PageHint = "Your account";
        }

        int userId = Session["UserId"] is int ? (int)Session["UserId"] : 0;
        if (userId <= 0)
        {
            litName.Text = Server.HtmlEncode(Session["UserName"] as string ?? "User");
            litEmail.Text = Server.HtmlEncode(Session["UserEmail"] as string ?? string.Empty);
            litRole.Text = "Member";
            litStatus.Text = "Unknown";
            return;
        }

        try
        {
            AppUser user = AppDb.GetUserById(userId);
            if (user == null)
            {
                litName.Text = "User not found";
                litEmail.Text = "—";
                litRole.Text = "—";
                litStatus.Text = "Inactive";
                return;
            }

            litName.Text = Server.HtmlEncode(user.Name);
            litEmail.Text = Server.HtmlEncode(user.Email);
            litRole.Text = Server.HtmlEncode(user.RoleName);
            litStatus.Text = user.IsActive ? "Active" : "Inactive";
            ShowLoginSummary(AppDb.GetLoginSummary(userId));
        }
        catch (Exception)
        {
            litName.Text = "Database unavailable";
            litEmail.Text = "—";
            litRole.Text = "—";
            litStatus.Text = "—";
            litAttempts.Text = "—";
            litSuccessful.Text = "—";
            litFailed.Text = "—";
            litLastLogin.Text = "—";
        }
    }

    private void ShowLoginSummary(LoginSummary summary)
    {
        litAttempts.Text = summary.TotalLoginAttempts.ToString();
        litSuccessful.Text = summary.SuccessfulLogins.ToString();
        litFailed.Text = summary.FailedLogins.ToString();
        if (!summary.HasHistory)
        {
            litLastLogin.Text = "No sign-ins recorded";
            return;
        }

        litLastLogin.Text = summary.LastLogin.HasValue
            ? Server.HtmlEncode(summary.LastLogin.Value.ToString("MMM d, yyyy h:mm tt"))
            : "\u2014";
    }
}
