USE GlobalDB
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Error' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Error]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Account' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Account]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Banner' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Banner]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Project' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Project]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Project_InApp' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Project_InApp]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Purchase' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Purchase]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_CS' AND TYPE = 'U')
	DROP TABLE [dbo].[T_CS]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_CS_Reward' AND TYPE = 'U')
	DROP TABLE [dbo].[T_CS_Reward]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'T_Client_Login' AND TYPE = 'U')
	DROP TABLE [dbo].[T_Client_Login]
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Error
-- DESC         : ���� ���̺� [ Procedure Error ]
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Error]
(
	[ErrorNumber]		INT				NULL,

	[ErrorSeverity]		INT				NULL,

	[ErrorState]		INT				NULL,

	[ErrorProc]			NVARCHAR(200)	NULL,

	[ErrorLine]			INT				NULL,

	[ErrorMessage]		NVARCHAR(4000)	NULL,

	[ErrorTime]			DATETIME2		NULL,
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Account
-- DESC         : ���� ���� ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Account]
(
	[AccUid]			INT				IDENTITY(1,1),					-- T_Account Uid

	[LoginId]			VARCHAR(64)		NOT NULL,						-- ABCDE@mail.com

	[Password]			VARCHAR(16)		NOT NULL,						-- �н�����

	[LoginCount]		INT				NOT NULL DEFAULT(0),			-- �α��� Ƚ��

	[Grant]				TINYINT			NOT NULL,						-- �ο��� ���� [ 1.master / 2.allProjectAdmin / 4.oneProjectAdmin ]

	[CreatedTime]		DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ���� ���� �ð�

	[LoginTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- �α��� �ð�

	CONSTRAINT [PK_T_Account] PRIMARY KEY CLUSTERED
	(
		[AccUid] ASC
	)
)
CREATE UNIQUE NONCLUSTERED INDEX [NIX_T_Account_LoginId] ON [dbo].[T_Account]
(
	[LoginId] ASC
)
GO

-- Default T_Account
INSERT INTO [dbo].[T_Account] ([LoginId], [Password], [Grant])
VALUES('dev@test.co.kr', '123456', 1)

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Banner
-- DESC         : ��� ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Banner]
(
	[BannerUID]			INT				IDENTITY(1,1),					-- T_Banner Uid

	[Name]				NVARCHAR(64)	NOT NULL,						-- ��� ��Ī

	[Android_URL]		VARCHAR(256)	NULL DEFAULT('EMPTY'),			-- �ȵ���̵� App URL

	[IOS_URL]			VARCHAR(256)	NULL DEFAULT('EMPTY'),			-- iOS App URL

	[Image]				VARBINARY(MAX)	NOT NULL,						-- ��� �̹���

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ��� �ð�

	CONSTRAINT [PK_T_Banner] PRIMARY KEY CLUSTERED
	(
		[BannerUID] ASC
	)
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Project
-- DESC         : ������Ʈ ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Project]
(
	[ProjectUID]		INT				IDENTITY(1,1),					-- T_Project UID

	[PackageName]		VARCHAR(64)		NOT NULL,						-- ������Ʈ ��Ű�� �� [ ���� ]

	[Name]				NVARCHAR(64)	NOT NULL,						-- ������Ʈ �� [ ���� or �ѱ� ]

	[Platform]			TINYINT			NOT NULL,						-- �÷��� [ 1.Android / 2.iOS ]

	[Version]			INT				NOT NULL DEFAULT(1),			-- App Version

	[Image_Data]		VARBINARY(MAX)	NULL,							-- Project Image base64 Decode ������

	[Android_JWT]		VARBINARY(MAX)	NULL,							-- �ȵ���̵� JWT(Json Web Token)

	[CSRewardType]		VARCHAR(MAX)	NULL DEFAULT(''),				-- CS Reward Type ( �޸��� ���� )

	[InappPercent]		TINYINT			NOT NULL DEFAULT(0),			-- ��ü ��ǰ�� ���� 20%, 30% �� ������ �� �ִ�

	[BannerUID]			INT				NOT NULL DEFAULT(0),			-- T_Banner UID

	[LastUpdateTime]	DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ���� ������Ʈ �ð�

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ��� �ð�

	[Delete]			TINYINT			NOT NULL DEFAULT(0)				-- 0.Ȱ��ȭ / 1.����

	CONSTRAINT [PK_T_Project] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC
	)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [NIX_T_Project_PackageName] ON [dbo].[T_Project]
(
	[PackageName] ASC
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Project_InApp
-- DESC         : �ξ� ��ǰ ��� ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Project_InApp]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[ProductID]			VARCHAR(40)		NOT NULL,						-- �ξ��ڵ�

	[Title]				NVARCHAR(40)	NOT NULL,						-- ��ǰ��

	[Price]				INT				NOT NULL,						-- ������ ���� [ ��ȭ, �ΰ��� ���� ]

	CONSTRAINT [PK_T_Project_InApp] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC,
		[ProductId] ASC
	)
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Purchase
-- DESC         : ���� ���� ���̺� [ �������� ]
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Purchase]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[ProductID]			VARCHAR(40)		NOT NULL,						-- �ξ��ڵ�

	[OrderID]			VARCHAR(80)		NOT NULL,						-- �ֹ���ȣ

	[ErrorCode]			SMALLINT		NOT NULL,						-- �����ڵ�

	[IP]				VARCHAR(40)		NOT NULL,						-- ipv4 or ipv6

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE())		-- ��� �ð�

	CONSTRAINT [PK_T_Purchase] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC,
		[RegTime] ASC
	)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [NIX_T_Purchase_OrderID] ON [dbo].[T_Purchase]
(
	[OrderID] ASC
)
GO


-- ==========================================================================================
-- Type			: Table
-- ID			: T_CS
-- DESC         : CS ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_CS]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[CsName]			VARCHAR(12)		NOT NULL,						-- 12�ڸ� [A-Z,0-9] ����

	[IP]				VARCHAR(40)		NOT NULL,						-- ipv4 or ipv6

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ��� �ð�

	CONSTRAINT [PK_T_CS] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC,
		[CsName] ASC
	)
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_CS_Reward
-- DESC         : CS ���� ���̺�
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_CS_Reward]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[CsName]			VARCHAR(12)		NOT NULL,						-- 12�ڸ� [A-Z,0-9] ����

	[RewardObj]			VARCHAR(100)	NOT NULL,						-- ���� ��ü [ Type Value Json ]

	[InsertedTime]		DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ���� �ð�

	[GettingTime]		DATETIME2		NULL,							-- ���� �ð�
	
	[Memo]				NVARCHAR(128)	NULL,							-- �޸�

	CONSTRAINT [PK_T_CS_Reward] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC,
		[CsName] ASC,
		[InsertedTime] ASC
	)
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Client_Login
-- DESC         : Ŭ���̾�Ʈ �α��� ����
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Client_Login]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[IP]				VARCHAR(16)		NOT NULL,						-- only ipv4
	
	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- ��� �ð�

	CONSTRAINT [PK_T_Client_Login] PRIMARY KEY CLUSTERED
	(
		[ProjectUID] ASC,
		[RegTime] ASC
	)
)
GO


-- ==========================================================================================
-- RESULT CODE
-- ==========================================================================================
-- �� RESULT CODE �� 0000 - 1000 COMMON
-- #    0 : ����
-- #  401 : �߸��� ��û�Դϴ� (Request ��ü �����Ұ�)
-- #  900 : Proc Exception Error
-- #  901 : Proc ExecContext Error
-- #  902 : Proc QueryContext Error
-- #  903 : Database Query Scan Error
-- #  904 : Database Query Error
-- #  999 : Database Connection Error

-- �� RESULT CODE �� 1001 - 2000 ������Ʈ ���� ����
-- # 1401 : �������� �ʴ� ������Ʈ �Դϴ�
-- # 1402 : �̹� �����ϴ� ��Ű���� �Դϴ�
-- # 1403 : ������ �ξ� ��ǰ���� �����մϴ�
-- # 1404 : ������ �ξ� ��ǰ�� �������� �ʽ��ϴ�
-- # 1405 : �������� �ʴ� ��� �Դϴ�

-- �� RESULT CODE �� 2001 - 3000 CS ����
-- # 2401 : [CS] �������� �ʴ� csName �Դϴ�
-- # 2402 : [CS] ������ �������� �����ϴ�
-- # 2403 : [CS] �������� �ʴ� ������Ʈ, projectUID Ȯ���� �ʿ��մϴ�

-- �� RESULT CODE �� 3001 - 4000 Purchase ����
-- # 3401 : [Purchase] AndroidJWT ��ϵ��� ����
-- # 3402 : [Purchase] ����Ҽ� ���� AndroidJWT
-- # 3403 : [Purchase] Api Response Error
-- # 3404 : [Purchase] �̹� ����� �������Դϴ�
-- # 3405 : [Purchase] �������� �ʴ� productID (��ǰ �߰� �ʿ�)

-- ==========================================================================================

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Error_Insert' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Error_Insert]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Banner_Create' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Banner_Create]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Banner_Update' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Banner_Update]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Create' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Create]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Update' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Update]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Delete' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Delete]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Inapp_Create' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Inapp_Create]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Inapp_Delete' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Inapp_Delete]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_AndJWT_Update' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_AndJWT_Update]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Project_Config_Update' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Project_Config_Update]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Purchase_Insert' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Purchase_Insert]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Purchase_Appstore' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Purchase_Appstore]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_CS_Name_Create' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_CS_Name_Create]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_CS_Reward' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_CS_Reward]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_CS_Reward_Insert' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_CS_Reward_Insert]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_CS_RewardType_Update' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_CS_RewardType_Update]
GO

IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE name = 'P_Client_Login_Insert' AND TYPE = 'P')
   DROP PROCEDURE [dbo].[P_Client_Login_Insert]
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Error_Insert]
-- DESC         : ���� ���� ���ν���
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Error_Insert]
AS
SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
BEGIN
	IF ERROR_NUMBER() IS NULL
		RETURN

	INSERT INTO [dbo].[T_Error] ( [ErrorNumber], [ErrorSeverity], [ErrorState], [ErrorProc], [ErrorLine], [ErrorMessage], [ErrorTime] )
	VALUES( ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ISNULL(ERROR_PROCEDURE(), '-'), ERROR_LINE(), ERROR_MESSAGE(), GETDATE() )
END
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Banner_Create]
-- DESC         : �ű� ��� ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Banner_Create]
	@name				NVARCHAR(64),				-- ������Ʈ �� [ ���� or �ѱ� ]
	@image				VARBINARY(MAX)				-- Image base64 Decode ������
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	INSERT INTO [dbo].[T_Banner]([Name], [Image])
	VALUES(@name, @image)

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Banner_Update]
-- DESC         : ��� ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Banner_Update]
	@bannerUID			INT,
	@name				NVARCHAR(64),
	@androidURL			VARCHAR(256),
	@iosURL				VARCHAR(256),
	@isChangeImage		TINYINT,					-- [ 0.�������� ���� / 1.���� ]
	@image				VARBINARY(MAX)				-- Image base64 Decode ������
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Banner] WHERE [BannerUID] = @bannerUID)
		RETURN 1405					-- # RESULT CODE 1405 : �������� �ʴ� ��� �Դϴ�
	
	BEGIN TRAN

	IF @isChangeImage <> 0
	BEGIN
		UPDATE [dbo].[T_Banner]
		SET [Image] = @image
		WHERE [BannerUID] = @bannerUID
	END

	UPDATE [dbo].[T_Banner]
	SET [Name] = @name, [Android_URL] = @androidURL, [IOS_URL] = @iosURL
	WHERE [BannerUID] = @bannerUID

	COMMIT TRAN

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Create]
-- DESC         : �ű� ������Ʈ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Create]
	@packageName		VARCHAR(64),				-- ������Ʈ ��Ű�� �� [ ���� ]
	@name				NVARCHAR(64),				-- ������Ʈ �� [ ���� or �ѱ� ]
	@platform			TINYINT,					-- �÷��� [ 1.Android / 2.iOS ]
	@image_Data			VARBINARY(MAX)				-- Project Image base64 Decode ������
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
		RETURN 1402					-- # RESULT CODE 1402 : �̹� �����ϴ� ��Ű���� �Դϴ�.

	INSERT INTO [dbo].[T_Project]([PackageName], [Name], [Platform], [Image_Data])
	VALUES(@packageName, @name, @platform, @image_Data)

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Update]
-- DESC         : ������Ʈ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Update]
	@packageName		VARCHAR(64),				-- ������Ʈ ��Ű�� �� [ ���� ]
	@name				NVARCHAR(64),				-- ������Ʈ �� [ ���� or �ѱ� ]
	@version			INT,						-- App Version
	
	@isChangeImage		TINYINT,					-- [ 0.�������� ���� / 1.���� ]
	@image_Data			VARBINARY(MAX)				-- Project Image base64 Decode ������
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	
	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�.
	
	BEGIN TRAN

	IF @isChangeImage <> 0
	BEGIN
		UPDATE [dbo].[T_Project]
		SET [Image_Data] = @image_Data
		WHERE [ProjectUID] = @projectUID
	END

	UPDATE [dbo].[T_Project]
	SET [Name] = @name, [Version] = @version, [LastUpdateTime] = GETDATE()
	WHERE [ProjectUID] = @projectUID

	COMMIT TRAN

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Delete]
-- DESC         : ������Ʈ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Delete]
	@packageName		VARCHAR(64)					-- ������Ʈ ��Ű�� �� [ ���� ]
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	UPDATE [dbo].[T_Project]
	SET [Delete] = 1
	WHERE [PackageName] = @packageName

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Inapp_Create]
-- DESC         : �ű� ��ǰ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Inapp_Create]
	@projectUID			INT,						-- T_Project UID
	@productID			VARCHAR(40),				-- �ξ��ڵ�
	@title				NVARCHAR(40),				-- ��ǰ��
	@price				INT							-- ������ ���� [ ��ȭ, �ΰ��� ���� ]
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�.

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 1403					-- # RESULT CODE 1403 : ������ �ξ� ��ǰ���� �����մϴ�.

	INSERT INTO [dbo].[T_Project_InApp]([ProjectUID], [ProductID], [Title], [Price])
	VALUES(@projectUID, @productID, @title, @price)

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Inapp_Delete]
-- DESC         : �ξ� ��ǰ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Inapp_Delete]
	@projectUID			INT,						-- T_Project UID
	@productID			VARCHAR(40)					-- �ξ��ڵ�
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�.

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 1404					-- # RESULT CODE 1404 : ������ �ξ� ��ǰ�� �������� �ʽ��ϴ�.

	DELETE [dbo].[T_Project_InApp]
	WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_AndJWT_Update]
-- DESC         : �ȵ���̵� JWT ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_AndJWT_Update]
	@projectUID			INT,						-- T_Project UID
	@android_jwt		VARBINARY(MAX)				-- �ȵ���̵� JWT
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�.

	UPDATE [dbo].[T_Project]
	SET [Android_JWT] = @android_jwt
	WHERE [ProjectUID] = @projectUID

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Config_Update]
-- DESC         : ������Ʈ Config ������Ʈ
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Config_Update]
	@projectUID			INT,						-- T_Project UID
	@isChangePercent	TINYINT,					-- [ 0.�������� ���� / 1.���� ]
	@inappPercent		TINYINT,
	@bannerUID			INT
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�.

	IF @isChangePercent = 0
	BEGIN
		UPDATE [dbo].[T_Project]
		SET [BannerUID] = @bannerUID
		WHERE [ProjectUID] = @projectUID
	END
	ELSE
	BEGIN
		UPDATE [dbo].[T_Project]
		SET [InappPercent] = @inappPercent, [BannerUID] = @bannerUID
		WHERE [ProjectUID] = @projectUID
	END

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Purchase_Insert]
-- DESC         : �������� [ Android, iOS ]
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Purchase_Insert]
	@packageName		VARCHAR(64),				-- ������Ʈ ��Ű�� �� [ ���� ]
	@productID			VARCHAR(40),				-- �ξ��ڵ�
	@orderID			VARCHAR(80),				-- �ֹ���ȣ
	@errorCode			SMALLINT,					-- �����ڵ�
	@ip					VARCHAR(40)					-- ipv4 or ipv6
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Purchase] WHERE [ProjectUID] = @projectUID AND [OrderID] = @orderID)
		RETURN 3404					-- # RESULT CODE 3404 : [Purchase] �̹� ����� �������Դϴ�

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 3405					-- # RESULT CODE 3405 : [Purchase] �������� �ʴ� productID (��ǰ �߰� �ʿ�)

	INSERT INTO [dbo].[T_Purchase]([ProjectUID], [ProductID], [OrderID], [ErrorCode], [IP])
	VALUES(@projectUID, @productID, @orderID, @errorCode, @ip)

	RETURN 0						-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_CS_Name_Create]
-- DESC         : csName �ű� �߱�
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Name_Create]
	@packageName		VARCHAR(64),				-- ������Ʈ ��Ű�� �� [ ���� ]
	@ip					VARCHAR(40),				-- ipv4 or ipv6
	@out_name			VARCHAR(12) OUTPUT			-- out cs name
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�

	-- [CsName] �ű� �߱�
	BEGIN TRAN

	DECLARE @num INT = (SELECT rows FROM sys.sysindexes WHERE id = OBJECT_ID('T_CS') AND indid < 2)

	SET @out_name = UPPER(SUBSTRING(MASTER.[dbo].fn_varbintohexstr(HASHBYTES('MD5', CONVERT(VARCHAR(10), @num))), 3, 12))

	INSERT INTO [dbo].[T_CS]([ProjectUID], [IP], [CsName])
	VALUES(@projectUID, @ip, @out_name)

	COMMIT TRAN
	
	RETURN 0

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_CS_Reward]
-- DESC         : CS ���� ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Reward]
	@packageName		VARCHAR(64),				-- ������Ʈ ��Ű�� �� [ ���� ]
	@csName				VARCHAR(12)					-- �߱޹��� csName
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : �������� �ʴ� ������Ʈ �Դϴ�

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[T_CS] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName)
	BEGIN
		RETURN 2401					-- # RESULT CODE 2401 : [CS] �������� �ʴ� csName �Դϴ�
	END

	DECLARE @rewardCount INT = (SELECT COUNT(*) FROM [dbo].[T_CS_Reward] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName AND [GettingTime] IS NULL)
	IF @rewardCount = 0
	BEGIN
		RETURN 2402					-- # RESULT CODE 2402 : [CS] ������ �������� �����ϴ�.
	END

	-- ���� �ð� �Է� ���� [RewardObj] �÷��� ��ȯ
	UPDATE [dbo].[T_CS_Reward]
	SET [GettingTime] = GETDATE()
	OUTPUT INSERTED.[RewardObj]
	WHERE [ProjectUID] = @projectUID AND [CsName] = @csName AND [GettingTime] IS NULL

	RETURN 0

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_CS_Reward_Insert]
-- DESC         : CS ��ǰ ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Reward_Insert]
	@projectUID			INT,						-- T_Project Uid
	@csName				VARCHAR(12),				-- �߱޹��� csName
	@rewardObj			VARCHAR(100),				-- ���� ������Ʈ
	@memo				NVARCHAR(128)				-- �޸� �ۼ� ����. 128�ڱ���.
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @csUid BIGINT = 0
BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_CS] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName)
		RETURN 2401				-- # RESULT CODE 2401 : [CS] �������� �ʴ� csName �Դϴ�

	INSERT INTO [dbo].[T_CS_Reward] ([ProjectUID], [CsName], [RewardObj], [InsertedTime], [GettingTime], [Memo])
	VALUES(@projectUID, @csName, @rewardObj, GETDATE(), NULL, @memo)

	RETURN 0					-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_CS_RewardType_Update]
-- DESC         : CS ����Ÿ�� ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_RewardType_Update]
	@projectUID			INT,						-- T_Project Uid
	@rewardType			VARCHAR(MAX)
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @csUid BIGINT = 0
BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 2403					-- # RESULT CODE 2403 : [CS] �������� �ʴ� ������Ʈ, projectUID Ȯ���� �ʿ��մϴ�.

	UPDATE [dbo].[T_Project]
	SET [CSRewardType] = @rewardType
	WHERE [ProjectUID] = @projectUID

	RETURN 0					-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Client_Login_Insert]
-- DESC         : Ŭ���̾�Ʈ �α��� ����
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Client_Login_Insert]
	@projectUID			INT,						-- T_Project Uid
	@ip					VARCHAR(16)					-- only ipv4
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	INSERT INTO [T_Client_Login] (ProjectUID, IP)
	VALUES(@projectUID, @ip)

	RETURN 0					-- # RESULT CODE 0 : ����
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO