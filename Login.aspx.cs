using System;
using System.Web.UI;

public partial class LoginPage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserEmail"] != null)
        {
            Response.Redirect("Dashboard.aspx");
            return;
        }

        if (!IsPostBack)
        {
            txtEmail.Text = "demo@legacyauth.local";
            txtPassword.Attributes["value"] = "demo123";
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string email = (txtEmail.Text ?? string.Empty).Trim();
        string password = txtPassword.Text ?? string.Empty;

        if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
        {
            ShowMessage("Please enter email and password.", true);
            return;
        }

        try
        {
            AppUser user = AppDb.Validate(email, password);
            if (user == null)
            {
                RecordFailedLogin(email);
                ShowMessage("Invalid email or password.", true);
                return;
            }

            AppDb.InsertLoginHistory(user.UserId, "SUCCESS", Request.UserHostAddress, Request.UserAgent, null);
            int dbSessionId = AppDb.OpenUserSession(user.UserId);

            Session["UserId"] = user.UserId;
            Session["UserEmail"] = user.Email;
            Session["UserName"] = user.Name;
            Session["UserRole"] = user.RoleName;
            Session["DbSessionId"] = dbSessionId;

            AppDb.LogActivity(user.UserId, "Signed in");
            Response.Redirect("Dashboard.aspx");
        }
        catch (Exception)
        {
            ShowMessage("Unable to reach the database. Check the connection string and that LegacyBizDb exists.", true);
        }
    }

    private void RecordFailedLogin(string email)
    {
        AppUser known = AppDb.FindUserByEmail(email);
        int? userId = null;
        string reason;
        if (known == null)
        {
            reason = "Unknown email";
        }
        else if (!known.IsActive)
        {
            userId = known.UserId;
            reason = "Inactive account";
        }
        else
        {
            userId = known.UserId;
            reason = "Invalid password";
        }

        AppDb.InsertLoginHistory(userId, "FAILED", Request.UserHostAddress, Request.UserAgent, reason);
    }

    private void ShowMessage(string text, bool isError)
    {
        lblMessage.Visible = true;
        lblMessage.Text = text;
        lblMessage.CssClass = isError ? "message error" : "message success";
    }
}
