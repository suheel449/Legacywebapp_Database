/*
    LegacyBizDb
    ----------------------------------------------------
    Purpose:
      Legacy database for ASP.NET Web Forms modernization POC.

    Intentionally contains:
      - Valid foreign keys
      - Missing foreign keys
      - Orphan records
      - Duplicate business data
      - Inconsistent status values
      - Legacy naming conventions
      - Denormalized data
      - Missing indexes
      - Stored procedures
      - Views
      - Triggers
      - Audit tables
      - Nullable columns
      - Legacy-style VARCHAR/TEXT/MONEY-like usage

    Target:
      MySQL 8.x / AWS RDS MySQL

    NOTE:
      This database is intentionally designed with issues
      for an AI modernization agent to discover.
*/


/* =====================================================
   1. DATABASE
   ===================================================== */

CREATE DATABASE IF NOT EXISTS LegacyBizDb
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE LegacyBizDb;


/* =====================================================
   2. USERS
   ===================================================== */

CREATE TABLE Users (
    UserId INT NOT NULL AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    RoleName VARCHAR(50) NOT NULL DEFAULT 'Member',
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (UserId),

    UNIQUE KEY UQ_Users_Email (Email)
);


/* =====================================================
   3. USER PREFERENCES
   ===================================================== */

CREATE TABLE UserPreferences (
    UserId INT NOT NULL,

    EmailAlerts TINYINT(1) NOT NULL DEFAULT 1,
    WeeklyDigest TINYINT(1) NOT NULL DEFAULT 1,
    CompactNav TINYINT(1) NOT NULL DEFAULT 0,

    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (UserId),

    CONSTRAINT FK_UserPreferences_Users
        FOREIGN KEY (UserId)
        REFERENCES Users(UserId)
);


/* =====================================================
   4. TASKS
   ===================================================== */

CREATE TABLE Tasks (
    TaskId INT NOT NULL AUTO_INCREMENT,

    Title VARCHAR(200) NOT NULL,

    AssignedToUserId INT NULL,

    DueDate DATE NULL,

    Status VARCHAR(20) NOT NULL DEFAULT 'Open',

    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (TaskId),

    CONSTRAINT CK_Tasks_Status
        CHECK (Status IN ('Open', 'InProgress', 'Done', 'Cancelled')),

    CONSTRAINT FK_Tasks_Users
        FOREIGN KEY (AssignedToUserId)
        REFERENCES Users(UserId)
);


/* =====================================================
   5. REPORTS
   ===================================================== */

CREATE TABLE Reports (
    ReportId INT NOT NULL AUTO_INCREMENT,

    Title VARCHAR(150) NOT NULL,

    OwnerTeam VARCHAR(80) NOT NULL,

    PeriodLabel VARCHAR(80) NOT NULL,

    Status VARCHAR(20) NOT NULL DEFAULT 'Draft',

    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (ReportId),

    CONSTRAINT CK_Reports_Status
        CHECK (Status IN ('Ready', 'Review', 'Draft'))
);


/* =====================================================
   6. NOTIFICATIONS
   ===================================================== */

CREATE TABLE Notifications (
    NotificationId INT NOT NULL AUTO_INCREMENT,

    UserId INT NULL,

    Title VARCHAR(150) NOT NULL,

    Body VARCHAR(500) NOT NULL,

    IsRead TINYINT(1) NOT NULL DEFAULT 0,

    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (NotificationId),

    CONSTRAINT FK_Notifications_Users
        FOREIGN KEY (UserId)
        REFERENCES Users(UserId)
);


/* =====================================================
   7. ACTIVITY LOG
   ===================================================== */

CREATE TABLE ActivityLog (
    ActivityId INT NOT NULL AUTO_INCREMENT,

    UserId INT NULL,

    Description VARCHAR(250) NOT NULL,

    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (ActivityId),

    CONSTRAINT FK_ActivityLog_Users
        FOREIGN KEY (UserId)
        REFERENCES Users(UserId)
);


/* =====================================================
   8. USER SESSIONS
      INTENTIONAL ISSUE:
      UserId has NO FOREIGN KEY
   ===================================================== */

CREATE TABLE UserSessions (
    SessionId INT NOT NULL AUTO_INCREMENT,

    UserId INT NOT NULL,

    SessionToken VARCHAR(255),

    LoginTime DATETIME,

    LogoutTime DATETIME,

    IsActive TINYINT(1) DEFAULT 1,

    PRIMARY KEY (SessionId)
);


/* =====================================================
   9. USER AUDIT
      INTENTIONAL ISSUE:
      UserId has NO FOREIGN KEY
   ===================================================== */

CREATE TABLE UserAudit (
    AuditId INT NOT NULL AUTO_INCREMENT,

    UserId INT,

    ActionName VARCHAR(100),

    ActionDate DATETIME,

    Details TEXT,

    PRIMARY KEY (AuditId)
);


/* =====================================================
   10. EMPLOYEE DIRECTORY
       INTENTIONAL ISSUE:
       Duplicate emails allowed
   ===================================================== */

CREATE TABLE EmployeeDirectory (
    EmployeeId INT NOT NULL AUTO_INCREMENT,

    Email VARCHAR(150),

    FullName VARCHAR(100),

    Department VARCHAR(100),

    ManagerName VARCHAR(100),

    PhoneNumber VARCHAR(50),

    PRIMARY KEY (EmployeeId)
);


/* =====================================================
   11. TASK ASSIGNMENTS
       INTENTIONAL ISSUE:
       EmployeeId probably maps to Users.UserId
       but FK is missing
   ===================================================== */

CREATE TABLE TaskAssignments (
    AssignmentId INT NOT NULL AUTO_INCREMENT,

    TaskId INT NOT NULL,

    EmployeeId INT NOT NULL,

    AssignedDate DATETIME,

    AssignmentStatus VARCHAR(50),

    PRIMARY KEY (AssignmentId),

    CONSTRAINT FK_TaskAssignments_Task
        FOREIGN KEY (TaskId)
        REFERENCES Tasks(TaskId)
);


/* =====================================================
   12. LEGACY TASK STATUS
       INTENTIONAL ISSUE:
       Inconsistent status values
   ===================================================== */

CREATE TABLE LegacyTaskStatus (
    TaskStatusId INT NOT NULL AUTO_INCREMENT,

    TaskId INT,

    Status VARCHAR(100),

    UpdatedBy VARCHAR(100),

    UpdatedDate DATETIME,

    PRIMARY KEY (TaskStatusId)
);


/* =====================================================
   13. LOGIN HISTORY
       INTENTIONAL ISSUE:
       Missing indexes on UserId / LoginDate
   ===================================================== */

CREATE TABLE LoginHistory (
    LoginId BIGINT NOT NULL AUTO_INCREMENT,

    UserId INT,

    LoginDate DATETIME,

    LoginStatus VARCHAR(30),

    IPAddress VARCHAR(50),

    UserAgent VARCHAR(500),

    FailureReason VARCHAR(255),

    PRIMARY KEY (LoginId)
);


/* =====================================================
   14. PASSWORD HISTORY
       INTENTIONAL ISSUE:
       No FK to Users
   ===================================================== */

CREATE TABLE PasswordHistory (
    PasswordHistoryId INT NOT NULL AUTO_INCREMENT,

    UserId INT NOT NULL,

    PasswordHash VARCHAR(255),

    ChangedDate DATETIME,

    ChangedBy VARCHAR(100),

    PRIMARY KEY (PasswordHistoryId)
);


/* =====================================================
   15. SUPPORT TICKETS
       INTENTIONAL ISSUE:
       UserId relationship is missing
   ===================================================== */

CREATE TABLE SupportTickets (
    TicketId INT NOT NULL AUTO_INCREMENT,

    UserId INT,

    Subject VARCHAR(200),

    Description TEXT,

    Priority VARCHAR(30),

    Status VARCHAR(50),

    CreatedDate DATETIME,

    ClosedDate DATETIME,

    PRIMARY KEY (TicketId)
);


/* =====================================================
   16. CUSTOMER NOTES
       DENORMALIZED LEGACY DESIGN
   ===================================================== */

CREATE TABLE CustomerNotes (
    NoteId INT NOT NULL AUTO_INCREMENT,

    CustomerName VARCHAR(150),

    CustomerEmail VARCHAR(150),

    NoteText TEXT,

    CreatedBy VARCHAR(100),

    CreatedDate DATETIME,

    PRIMARY KEY (NoteId)
);


/* =====================================================
   INDEXES
   ===================================================== */


/* Good indexes */

CREATE INDEX IX_Tasks_Status
    ON Tasks(Status);

CREATE INDEX IX_Tasks_AssignedToUserId
    ON Tasks(AssignedToUserId);

CREATE INDEX IX_Reports_Status
    ON Reports(Status);

CREATE INDEX IX_Notifications_UserId
    ON Notifications(UserId);

CREATE INDEX IX_Notifications_IsRead
    ON Notifications(IsRead);

CREATE INDEX IX_ActivityLog_UserId
    ON ActivityLog(UserId);

CREATE INDEX IX_ActivityLog_CreatedAt
    ON ActivityLog(CreatedAt);


/*
    INTENTIONAL:
    LoginHistory has no index on UserId or LoginDate.

    This should be discovered by the modernization agent.
*/


/* =====================================================
   17. USERS
   ===================================================== */

INSERT INTO Users
(
    FullName,
    Email,
    PasswordHash,
    RoleName
)
VALUES

(
    'Demo User',
    'demo@legacyauth.local',
    'demo123',
    'Member'
),

(
    'Admin User',
    'admin@legacyauth.local',
    'admin123',
    'Admin'
),

(
    'Sarah Chen',
    'sarah.chen@legacybiz.local',
    'sarah123',
    'Member'
),

(
    'Mike Torres',
    'mike.torres@legacybiz.local',
    'mike123',
    'Member'
),

(
    'Priya Nair',
    'priya.nair@legacybiz.local',
    'priya123',
    'Member'
),

(
    'Alex Kim',
    'alex.kim@legacybiz.local',
    'alex123',
    'Member'
),

(
    'John Wilson',
    'john.wilson@legacybiz.local',
    'john123',
    'Manager'
),

(
    'Lisa Brown',
    'lisa.brown@legacybiz.local',
    'lisa123',
    'Member'
);


/* =====================================================
   18. USER PREFERENCES
   ===================================================== */

INSERT INTO UserPreferences
(
    UserId,
    EmailAlerts,
    WeeklyDigest,
    CompactNav
)
VALUES

(1,1,1,0),
(2,1,1,0),
(3,1,0,0),
(4,0,1,1),
(5,1,1,0),
(6,1,1,0),
(7,1,0,0),
(8,1,1,1);


/* =====================================================
   19. TASKS
   ===================================================== */

INSERT INTO Tasks
(
    Title,
    AssignedToUserId,
    DueDate,
    Status
)
VALUES

(
    'Review weekly login report',
    1,
    DATE_ADD(CURDATE(), INTERVAL 2 DAY),
    'Open'
),

(
    'Update profile contact info',
    1,
    DATE_ADD(CURDATE(), INTERVAL 5 DAY),
    'Open'
),

(
    'Approve new registrations',
    2,
    DATE_ADD(CURDATE(), INTERVAL 1 DAY),
    'Open'
),

(
    'Audit failed sign-ins',
    2,
    DATE_ADD(CURDATE(), INTERVAL 3 DAY),
    'InProgress'
),

(
    'Prepare security digest',
    1,
    DATE_ADD(CURDATE(), INTERVAL 4 DAY),
    'Open'
),

(
    'Archive old sessions',
    4,
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),
    'Open'
),

(
    'Cleanup demo accounts',
    2,
    DATE_ADD(CURDATE(), INTERVAL -1 DAY),
    'Done'
),

(
    'Sync notification templates',
    3,
    DATE_ADD(CURDATE(), INTERVAL 6 DAY),
    'Open'
),

(
    'Review application logs',
    7,
    DATE_ADD(CURDATE(), INTERVAL 10 DAY),
    'Open'
),

(
    'Update security policy',
    7,
    DATE_ADD(CURDATE(), INTERVAL 15 DAY),
    'InProgress'
);


/* =====================================================
   20. REPORTS
   ===================================================== */

INSERT INTO Reports
(
    Title,
    OwnerTeam,
    PeriodLabel,
    Status
)
VALUES

('Login activity','Ops','This week','Ready'),

('New registrations','HR','This week','Ready'),

('Failed sign-ins','Security','Last 7 days','Review'),

('Session summary','IT','Last 30 days','Draft'),

('Active users','Ops','This month','Ready'),

('Password resets','Security','This week','Ready'),

('Notification volume','IT','Last 14 days','Ready'),

('Task completion','Ops','This week','Review'),

('Regional access','IT','Last 30 days','Draft'),

('Admin actions','Security','This month','Ready'),

('Support tickets','Support','This week','Ready'),

('Weekly digest stats','HR','This week','Ready');


/* =====================================================
   21. NOTIFICATIONS
   ===================================================== */

INSERT INTO Notifications
(
    UserId,
    Title,
    Body,
    IsRead
)
VALUES

(
    1,
    'Password policy reminder',
    'Use a unique password. Accounts are stored in MySQL.',
    0
),

(
    1,
    'Weekly report is ready',
    'Open Reports to review login and registration activity.',
    0
),

(
    1,
    'Welcome to Legacy Auth',
    'Your dashboard, profile, and settings pages load from the database.',
    1
),

(
    1,
    'Session notice',
    'Signing out clears this session. User accounts remain in the database.',
    1
),

(
    2,
    'Admin checklist',
    'Review failed sign-ins and open tasks assigned to Admin.',
    0
),

(
    NULL,
    'System maintenance',
    'Scheduled maintenance window this Sunday at 02:00 UTC.',
    0
);


/* =====================================================
   22. ACTIVITY LOG
   ===================================================== */

INSERT INTO ActivityLog
(
    UserId,
    Description,
    CreatedAt
)
VALUES

(
    1,
    'Signed in',
    DATE_SUB(NOW(), INTERVAL 2 MINUTE)
),

(
    1,
    'Weekly summary generated',
    DATE_SUB(NOW(), INTERVAL 1 DAY)
),

(
    1,
    'Profile viewed',
    DATE_SUB(NOW(), INTERVAL 2 DAY)
),

(
    2,
    'Password last changed',
    DATE_SUB(NOW(), INTERVAL 14 DAY)
),

(
    2,
    'Report exported',
    DATE_SUB(NOW(), INTERVAL 6 HOUR)
),

(
    3,
    'Notification marked read',
    DATE_SUB(NOW(), INTERVAL 3 DAY)
);


/* =====================================================
   23. USER SESSIONS
       Includes orphan UserId = 9999
   ===================================================== */

INSERT INTO UserSessions
(
    UserId,
    SessionToken,
    LoginTime,
    LogoutTime,
    IsActive
)
VALUES

(
    1,
    'SESSION-001',
    DATE_SUB(NOW(), INTERVAL 2 HOUR),
    NULL,
    1
),

(
    2,
    'SESSION-002',
    DATE_SUB(NOW(), INTERVAL 5 HOUR),
    DATE_SUB(NOW(), INTERVAL 4 HOUR),
    0
),

(
    3,
    'SESSION-003',
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    DATE_SUB(NOW(), INTERVAL 23 HOUR),
    0
),

/*
    Intentional orphan
*/
(
    9999,
    'SESSION-999',
    NOW(),
    NULL,
    1
);


/* =====================================================
   24. USER AUDIT
       Includes orphan UserId
   ===================================================== */

INSERT INTO UserAudit
(
    UserId,
    ActionName,
    ActionDate,
    Details
)
VALUES

(
    1,
    'LOGIN',
    DATE_SUB(NOW(), INTERVAL 2 HOUR),
    'User successfully logged in'
),

(
    2,
    'EXPORT_REPORT',
    DATE_SUB(NOW(), INTERVAL 3 HOUR),
    'Login activity report exported'
),

(
    3,
    'UPDATE_PROFILE',
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    'Profile information updated'
),

/*
    Intentional orphan
*/
(
    7777,
    'DELETE_USER',
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    'Legacy audit record'
);


/* =====================================================
   25. EMPLOYEE DIRECTORY
       Duplicate emails intentionally included
   ===================================================== */

INSERT INTO EmployeeDirectory
(
    Email,
    FullName,
    Department,
    ManagerName,
    PhoneNumber
)
VALUES

(
    'sarah.chen@legacybiz.local',
    'Sarah Chen',
    'Operations',
    'John Wilson',
    '9000000001'
),

(
    'sarah.chen@legacybiz.local',
    'Sarah Chen',
    'Operations',
    'John Wilson',
    '9000000001'
),

(
    'admin@legacyauth.local',
    'Admin User',
    'IT',
    'John Wilson',
    '9000000002'
),

(
    'priya.nair@legacybiz.local',
    'Priya Nair',
    'HR',
    'Lisa Brown',
    '9000000003'
),

(
    'mike.torres@legacybiz.local',
    'Mike Torres',
    'Operations',
    'John Wilson',
    '9000000004'
);


/* =====================================================
   26. TASK ASSIGNMENTS
   ===================================================== */

INSERT INTO TaskAssignments
(
    TaskId,
    EmployeeId,
    AssignedDate,
    AssignmentStatus
)
VALUES

(1,1,NOW(),'Active'),
(2,1,NOW(),'Active'),
(3,2,NOW(),'Active'),
(4,3,NOW(),'Active'),
(5,4,NOW(),'Pending'),
(6,9999,NOW(),'Active');


/*
    EmployeeId = 9999 is intentional.
    Also, EmployeeId does not have an FK.
*/


/* =====================================================
   27. LEGACY TASK STATUS
       Inconsistent values intentionally included
   ===================================================== */

INSERT INTO LegacyTaskStatus
(
    TaskId,
    Status,
    UpdatedBy,
    UpdatedDate
)
VALUES

(1,'Open','Admin User',NOW()),
(2,'OPEN','Admin User',NOW()),
(3,'In Progress','Admin User',NOW()),
(4,'InProgress','Admin User',NOW()),
(5,'Completed','Admin User',NOW()),
(6,'DONE','Admin User',NOW()),
(7,'Done','Admin User',NOW()),
(8,'cancelled','Admin User',NOW());


/* =====================================================
   28. LOGIN HISTORY
       UserId 9999 is intentional orphan
   ===================================================== */

INSERT INTO LoginHistory
(
    UserId,
    LoginDate,
    LoginStatus,
    IPAddress,
    UserAgent,
    FailureReason
)
VALUES

(
    1,
    DATE_SUB(NOW(), INTERVAL 10 MINUTE),
    'SUCCESS',
    '10.0.0.10',
    'Mozilla/5.0',
    NULL
),

(
    2,
    DATE_SUB(NOW(), INTERVAL 20 MINUTE),
    'SUCCESS',
    '10.0.0.11',
    'Mozilla/5.0',
    NULL
),

(
    3,
    DATE_SUB(NOW(), INTERVAL 30 MINUTE),
    'FAILED',
    '10.0.0.12',
    'Mozilla/5.0',
    'Invalid password'
),

(
    4,
    DATE_SUB(NOW(), INTERVAL 40 MINUTE),
    'SUCCESS',
    '10.0.0.13',
    'Mozilla/5.0',
    NULL
),

(
    9999,
    DATE_SUB(NOW(), INTERVAL 50 MINUTE),
    'SUCCESS',
    '10.0.0.99',
    'LegacyClient/1.0',
    NULL
);


/* =====================================================
   29. PASSWORD HISTORY
   ===================================================== */

INSERT INTO PasswordHistory
(
    UserId,
    PasswordHash,
    ChangedDate,
    ChangedBy
)
VALUES

(1,'oldhash001',DATE_SUB(NOW(),INTERVAL 90 DAY),'Admin'),
(1,'oldhash002',DATE_SUB(NOW(),INTERVAL 60 DAY),'Admin'),
(2,'oldhash003',DATE_SUB(NOW(),INTERVAL 30 DAY),'Admin'),
(3,'oldhash004',DATE_SUB(NOW(),INTERVAL 45 DAY),'Admin'),

/*
    Intentional orphan
*/
(9999,'orphanhash',DATE_SUB(NOW(),INTERVAL 100 DAY),'LegacySystem');


/* =====================================================
   30. SUPPORT TICKETS
   ===================================================== */

INSERT INTO SupportTickets
(
    UserId,
    Subject,
    Description,
    Priority,
    Status,
    CreatedDate,
    ClosedDate
)
VALUES

(
    1,
    'Cannot login',
    'User reported intermittent login failure.',
    'High',
    'Open',
    DATE_SUB(NOW(),INTERVAL 3 DAY),
    NULL
),

(
    3,
    'Notification issue',
    'Weekly digest not received.',
    'Medium',
    'In Progress',
    DATE_SUB(NOW(),INTERVAL 5 DAY),
    NULL
),

(
    4,
    'Profile update',
    'Unable to update contact information.',
    'Low',
    'Closed',
    DATE_SUB(NOW(),INTERVAL 10 DAY),
    DATE_SUB(NOW(),INTERVAL 8 DAY)
),

/*
    Intentional orphan
*/
(
    8888,
    'Legacy account issue',
    'Old user account reported an issue.',
    'High',
    'Open',
    DATE_SUB(NOW(),INTERVAL 20 DAY),
    NULL
);


/* =====================================================
   31. CUSTOMER NOTES
       Intentional denormalization
   ===================================================== */

INSERT INTO CustomerNotes
(
    CustomerName,
    CustomerEmail,
    NoteText,
    CreatedBy,
    CreatedDate
)
VALUES

(
    'Sarah Chen',
    'sarah.chen@legacybiz.local',
    'Customer requested weekly security report.',
    'Admin User',
    DATE_SUB(NOW(),INTERVAL 5 DAY)
),

(
    'Sarah Chen',
    'sarah.chen@legacybiz.local',
    'Customer contacted support regarding notifications.',
    'Admin User',
    DATE_SUB(NOW(),INTERVAL 3 DAY)
),

(
    'Unknown Customer',
    'unknown@legacybiz.local',
    'Legacy record with no matching user account.',
    'LegacySystem',
    DATE_SUB(NOW(),INTERVAL 100 DAY)
);


/* =====================================================
   32. VIEW
   ===================================================== */

CREATE OR REPLACE VIEW vw_CustomerTaskSummary AS

SELECT
    u.UserId,
    u.FullName,
    u.Email,
    u.RoleName,

    COUNT(t.TaskId) AS TaskCount,

    SUM(
        CASE
            WHEN t.Status = 'Open'
            THEN 1
            ELSE 0
        END
    ) AS OpenTaskCount,

    SUM(
        CASE
            WHEN t.Status = 'Done'
            THEN 1
            ELSE 0
        END
    ) AS CompletedTaskCount

FROM Users u

LEFT JOIN Tasks t
    ON u.UserId = t.AssignedToUserId

GROUP BY
    u.UserId,
    u.FullName,
    u.Email,
    u.RoleName;


/* =====================================================
   33. SECOND VIEW
   ===================================================== */

CREATE OR REPLACE VIEW vw_LoginSummary AS

SELECT

    UserId,

    COUNT(*) AS TotalLoginAttempts,

    SUM(
        CASE
            WHEN LoginStatus = 'SUCCESS'
            THEN 1
            ELSE 0
        END
    ) AS SuccessfulLogins,

    SUM(
        CASE
            WHEN LoginStatus = 'FAILED'
            THEN 1
            ELSE 0
        END
    ) AS FailedLogins,

    MAX(LoginDate) AS LastLogin

FROM LoginHistory

GROUP BY UserId;


/* =====================================================
   34. STORED PROCEDURE
   ===================================================== */

DELIMITER $$

CREATE PROCEDURE usp_GetDashboardStats(
    IN p_UserId INT
)

BEGIN

    SELECT

        (
            SELECT COUNT(*)
            FROM Tasks
            WHERE Status IN ('Open','InProgress')
        ) AS OpenTasks,

        (
            SELECT COUNT(*)
            FROM Tasks
            WHERE Status IN ('Open','InProgress')
              AND DueDate IS NOT NULL
              AND DueDate <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        ) AS TasksDueThisWeek,

        (
            SELECT COUNT(*)
            FROM Reports
        ) AS ReportCount,

        (
            SELECT COUNT(*)
            FROM Notifications
            WHERE UserId IS NULL
               OR UserId = p_UserId
        ) AS NotificationCount,

        (
            SELECT COUNT(*)
            FROM Notifications
            WHERE IsRead = 0
              AND (
                    UserId IS NULL
                    OR UserId = p_UserId
                  )
        ) AS UnreadNotifications,

        (
            SELECT COUNT(*)
            FROM Users
            WHERE IsActive = 1
        ) AS TeamMembers;

END$$

DELIMITER ;


/* =====================================================
   35. SECOND STORED PROCEDURE
   ===================================================== */

DELIMITER $$

CREATE PROCEDURE usp_GetUserActivity(
    IN p_UserId INT
)

BEGIN

    SELECT
        ActivityId,
        UserId,
        Description,
        CreatedAt
    FROM ActivityLog
    WHERE UserId = p_UserId
    ORDER BY CreatedAt DESC;


    SELECT
        NotificationId,
        Title,
        Body,
        IsRead,
        CreatedAt
    FROM Notifications
    WHERE UserId = p_UserId
       OR UserId IS NULL
    ORDER BY CreatedAt DESC;

END$$

DELIMITER ;


/* =====================================================
   36. THIRD STORED PROCEDURE
       Legacy business logic
   ===================================================== */

DELIMITER $$

CREATE PROCEDURE usp_GetOpenTasksForUser(
    IN p_UserId INT
)

BEGIN

    SELECT

        t.TaskId,
        t.Title,
        t.DueDate,
        t.Status,

        u.FullName AS AssignedUser

    FROM Tasks t

    LEFT JOIN Users u
        ON t.AssignedToUserId = u.UserId

    WHERE
        t.AssignedToUserId = p_UserId
        AND t.Status <> 'Done'

    ORDER BY
        t.DueDate ASC;

END$$

DELIMITER ;


/* =====================================================
   37. AUDIT TRIGGER
   ===================================================== */

DELIMITER $$

CREATE TRIGGER trg_UserAudit_Insert

AFTER INSERT ON UserAudit

FOR EACH ROW

BEGIN

    INSERT INTO ActivityLog
    (
        UserId,
        Description,
        CreatedAt
    )

    VALUES
    (
        NEW.UserId,
        CONCAT(
            'Audit action: ',
            NEW.ActionName
        ),
        NOW()
    );

END$$

DELIMITER ;


/* =====================================================
   38. DATA VALIDATION TEST QUERIES
   ===================================================== */


/*
    Find orphan sessions
*/

SELECT
    s.SessionId,
    s.UserId
FROM UserSessions s
LEFT JOIN Users u
    ON s.UserId = u.UserId
WHERE u.UserId IS NULL;


/*
    Find orphan audit records
*/

SELECT
    a.AuditId,
    a.UserId
FROM UserAudit a
LEFT JOIN Users u
    ON a.UserId = u.UserId
WHERE u.UserId IS NULL;


/*
    Find duplicate employee emails
*/

SELECT
    Email,
    COUNT(*) AS DuplicateCount
FROM EmployeeDirectory
GROUP BY Email
HAVING COUNT(*) > 1;


/*
    Find orphan task assignments
*/

SELECT
    ta.AssignmentId,
    ta.EmployeeId
FROM TaskAssignments ta
LEFT JOIN Users u
    ON ta.EmployeeId = u.UserId
WHERE u.UserId IS NULL;


/*
    Find orphan login history
*/

SELECT
    lh.LoginId,
    lh.UserId
FROM LoginHistory lh
LEFT JOIN Users u
    ON lh.UserId = u.UserId
WHERE u.UserId IS NULL;


/*
    Find orphan password history
*/

SELECT
    ph.PasswordHistoryId,
    ph.UserId
FROM PasswordHistory ph
LEFT JOIN Users u
    ON ph.UserId = u.UserId
WHERE u.UserId IS NULL;


/*
    Find orphan support tickets
*/

SELECT
    st.TicketId,
    st.UserId
FROM SupportTickets st
LEFT JOIN Users u
    ON st.UserId = u.UserId
WHERE
    st.UserId IS NOT NULL
    AND u.UserId IS NULL;


/* =====================================================
   END
   ===================================================== */