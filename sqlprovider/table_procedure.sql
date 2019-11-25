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
-- DESC         : 에러 테이블 [ Procedure Error ]
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
-- DESC         : 계정 정보 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Account]
(
	[AccUid]			INT				IDENTITY(1,1),					-- T_Account Uid

	[LoginId]			VARCHAR(64)		NOT NULL,						-- ABCDE@mail.com

	[Password]			VARCHAR(16)		NOT NULL,						-- 패스워드

	[LoginCount]		INT				NOT NULL DEFAULT(0),			-- 로그인 횟수

	[Grant]				TINYINT			NOT NULL,						-- 부여된 권한 [ 1.master / 2.allProjectAdmin / 4.oneProjectAdmin ]

	[CreatedTime]		DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 계정 생성 시간

	[LoginTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 로그인 시간

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
-- DESC         : 배너 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Banner]
(
	[BannerUID]			INT				IDENTITY(1,1),					-- T_Banner Uid

	[Name]				NVARCHAR(64)	NOT NULL,						-- 배너 명칭

	[Android_URL]		VARCHAR(256)	NULL DEFAULT('EMPTY'),			-- 안드로이드 App URL

	[IOS_URL]			VARCHAR(256)	NULL DEFAULT('EMPTY'),			-- iOS App URL

	[Image]				VARBINARY(MAX)	NOT NULL,						-- 배너 이미지

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 등록 시간

	CONSTRAINT [PK_T_Banner] PRIMARY KEY CLUSTERED
	(
		[BannerUID] ASC
	)
)
GO

-- ==========================================================================================
-- Type			: Table
-- ID			: T_Project
-- DESC         : 프로젝트 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Project]
(
	[ProjectUID]		INT				IDENTITY(1,1),					-- T_Project UID

	[PackageName]		VARCHAR(64)		NOT NULL,						-- 프로젝트 패키지 명 [ 영문 ]

	[Name]				NVARCHAR(64)	NOT NULL,						-- 프로젝트 명 [ 영문 or 한글 ]

	[Platform]			TINYINT			NOT NULL,						-- 플랫폼 [ 1.Android / 2.iOS ]

	[Version]			INT				NOT NULL DEFAULT(1),			-- App Version

	[Image_Data]		VARBINARY(MAX)	NULL,							-- Project Image base64 Decode 데이터

	[Android_JWT]		VARBINARY(MAX)	NULL,							-- 안드로이드 JWT(Json Web Token)

	[CSRewardType]		VARCHAR(MAX)	NULL DEFAULT(''),				-- CS Reward Type ( 콤마로 구분 )

	[InappPercent]		TINYINT			NOT NULL DEFAULT(0),			-- 전체 상품에 대해 20%, 30% 를 적용할 수 있다

	[BannerUID]			INT				NOT NULL DEFAULT(0),			-- T_Banner UID

	[LastUpdateTime]	DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 최종 업데이트 시간

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 등록 시간

	[Delete]			TINYINT			NOT NULL DEFAULT(0)				-- 0.활성화 / 1.삭제

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
-- DESC         : 인앱 제품 등록 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Project_InApp]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[ProductID]			VARCHAR(40)		NOT NULL,						-- 인앱코드

	[Title]				NVARCHAR(40)	NOT NULL,						-- 상품명

	[Price]				INT				NOT NULL,						-- 설정된 가격 [ 한화, 부가세 포함 ]

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
-- DESC         : 결제 내역 테이블 [ 에러포함 ]
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Purchase]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[ProductID]			VARCHAR(40)		NOT NULL,						-- 인앱코드

	[OrderID]			VARCHAR(80)		NOT NULL,						-- 주문번호

	[ErrorCode]			SMALLINT		NOT NULL,						-- 에러코드

	[IP]				VARCHAR(40)		NOT NULL,						-- ipv4 or ipv6

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE())		-- 등록 시간

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
-- DESC         : CS 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_CS]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[CsName]			VARCHAR(12)		NOT NULL,						-- 12자리 [A-Z,0-9] 난수

	[IP]				VARCHAR(40)		NOT NULL,						-- ipv4 or ipv6

	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 등록 시간

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
-- DESC         : CS 보상 테이블
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_CS_Reward]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[CsName]			VARCHAR(12)		NOT NULL,						-- 12자리 [A-Z,0-9] 난수

	[RewardObj]			VARCHAR(100)	NOT NULL,						-- 보상 객체 [ Type Value Json ]

	[InsertedTime]		DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 지급 시간

	[GettingTime]		DATETIME2		NULL,							-- 받은 시간
	
	[Memo]				NVARCHAR(128)	NULL,							-- 메모

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
-- DESC         : 클라이언트 로그인 정보
-- Author       : 
-- ==========================================================================================
CREATE TABLE [dbo].[T_Client_Login]
(
	[ProjectUID]		INT				NOT NULL,						-- T_Project Uid

	[IP]				VARCHAR(16)		NOT NULL,						-- only ipv4
	
	[RegTime]			DATETIME2		NOT NULL DEFAULT(GETDATE()),	-- 등록 시간

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
-- ▣ RESULT CODE ▣ 0000 - 1000 COMMON
-- #    0 : 성공
-- #  401 : 잘못된 요청입니다 (Request 객체 생성불가)
-- #  900 : Proc Exception Error
-- #  901 : Proc ExecContext Error
-- #  902 : Proc QueryContext Error
-- #  903 : Database Query Scan Error
-- #  904 : Database Query Error
-- #  999 : Database Connection Error

-- ▣ RESULT CODE ▣ 1001 - 2000 프로젝트 관리 관련
-- # 1401 : 존재하지 않는 프로젝트 입니다
-- # 1402 : 이미 존재하는 패키지명 입니다
-- # 1403 : 동일한 인앱 상품명이 존재합니다
-- # 1404 : 삭제할 인앱 상품이 존재하지 않습니다
-- # 1405 : 존재하지 않는 배너 입니다

-- ▣ RESULT CODE ▣ 2001 - 3000 CS 관련
-- # 2401 : [CS] 존재하지 않는 csName 입니다
-- # 2402 : [CS] 지급할 아이템이 없습니다
-- # 2403 : [CS] 존재하지 않는 프로젝트, projectUID 확인이 필요합니다

-- ▣ RESULT CODE ▣ 3001 - 4000 Purchase 관련
-- # 3401 : [Purchase] AndroidJWT 등록되지 않음
-- # 3402 : [Purchase] 사용할수 없는 AndroidJWT
-- # 3403 : [Purchase] Api Response Error
-- # 3404 : [Purchase] 이미 사용한 영수증입니다
-- # 3405 : [Purchase] 존재하지 않는 productID (상품 추가 필요)

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
-- DESC         : 에러 삽입 프로시저
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
-- DESC         : 신규 배너 생성
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Banner_Create]
	@name				NVARCHAR(64),				-- 프로젝트 명 [ 영문 or 한글 ]
	@image				VARBINARY(MAX)				-- Image base64 Decode 데이터
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	INSERT INTO [dbo].[T_Banner]([Name], [Image])
	VALUES(@name, @image)

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Banner_Update]
-- DESC         : 배너 변경
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Banner_Update]
	@bannerUID			INT,
	@name				NVARCHAR(64),
	@androidURL			VARCHAR(256),
	@iosURL				VARCHAR(256),
	@isChangeImage		TINYINT,					-- [ 0.변경하지 않음 / 1.변경 ]
	@image				VARBINARY(MAX)				-- Image base64 Decode 데이터
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Banner] WHERE [BannerUID] = @bannerUID)
		RETURN 1405					-- # RESULT CODE 1405 : 존재하지 않는 배너 입니다
	
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

	RETURN 0						-- # RESULT CODE 0 : 성공
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
-- DESC         : 신규 프로젝트 생성
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Create]
	@packageName		VARCHAR(64),				-- 프로젝트 패키지 명 [ 영문 ]
	@name				NVARCHAR(64),				-- 프로젝트 명 [ 영문 or 한글 ]
	@platform			TINYINT,					-- 플랫폼 [ 1.Android / 2.iOS ]
	@image_Data			VARBINARY(MAX)				-- Project Image base64 Decode 데이터
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
		RETURN 1402					-- # RESULT CODE 1402 : 이미 존재하는 패키지명 입니다.

	INSERT INTO [dbo].[T_Project]([PackageName], [Name], [Platform], [Image_Data])
	VALUES(@packageName, @name, @platform, @image_Data)

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Update]
-- DESC         : 프로젝트 변경
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Update]
	@packageName		VARCHAR(64),				-- 프로젝트 패키지 명 [ 영문 ]
	@name				NVARCHAR(64),				-- 프로젝트 명 [ 영문 or 한글 ]
	@version			INT,						-- App Version
	
	@isChangeImage		TINYINT,					-- [ 0.변경하지 않음 / 1.변경 ]
	@image_Data			VARBINARY(MAX)				-- Project Image base64 Decode 데이터
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY
	
	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다.
	
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

	RETURN 0						-- # RESULT CODE 0 : 성공
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
-- DESC         : 프로젝트 삭제
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Delete]
	@packageName		VARCHAR(64)					-- 프로젝트 패키지 명 [ 영문 ]
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	UPDATE [dbo].[T_Project]
	SET [Delete] = 1
	WHERE [PackageName] = @packageName

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Inapp_Create]
-- DESC         : 신규 상품 생성
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Inapp_Create]
	@projectUID			INT,						-- T_Project UID
	@productID			VARCHAR(40),				-- 인앱코드
	@title				NVARCHAR(40),				-- 상품명
	@price				INT							-- 설정된 가격 [ 한화, 부가세 포함 ]
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다.

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 1403					-- # RESULT CODE 1403 : 동일한 인앱 상품명이 존재합니다.

	INSERT INTO [dbo].[T_Project_InApp]([ProjectUID], [ProductID], [Title], [Price])
	VALUES(@projectUID, @productID, @title, @price)

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Inapp_Delete]
-- DESC         : 인앱 상품 삭제
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Inapp_Delete]
	@projectUID			INT,						-- T_Project UID
	@productID			VARCHAR(40)					-- 인앱코드
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다.

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 1404					-- # RESULT CODE 1404 : 삭제할 인앱 상품이 존재하지 않습니다.

	DELETE [dbo].[T_Project_InApp]
	WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_AndJWT_Update]
-- DESC         : 안드로이드 JWT 갱신
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_AndJWT_Update]
	@projectUID			INT,						-- T_Project UID
	@android_jwt		VARBINARY(MAX)				-- 안드로이드 JWT
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다.

	UPDATE [dbo].[T_Project]
	SET [Android_JWT] = @android_jwt
	WHERE [ProjectUID] = @projectUID

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Project_Config_Update]
-- DESC         : 프로젝트 Config 업데이트
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Project_Config_Update]
	@projectUID			INT,						-- T_Project UID
	@isChangePercent	TINYINT,					-- [ 0.변경하지 않음 / 1.변경 ]
	@inappPercent		TINYINT,
	@bannerUID			INT
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Project] WHERE [ProjectUID] = @projectUID AND [Delete] = 0)
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다.

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

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_Purchase_Insert]
-- DESC         : 결제검증 [ Android, iOS ]
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_Purchase_Insert]
	@packageName		VARCHAR(64),				-- 프로젝트 패키지 명 [ 영문 ]
	@productID			VARCHAR(40),				-- 인앱코드
	@orderID			VARCHAR(80),				-- 주문번호
	@errorCode			SMALLINT,					-- 에러코드
	@ip					VARCHAR(40)					-- ipv4 or ipv6
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다

	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[T_Purchase] WHERE [ProjectUID] = @projectUID AND [OrderID] = @orderID)
		RETURN 3404					-- # RESULT CODE 3404 : [Purchase] 이미 사용한 영수증입니다

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[T_Project_InApp] WHERE [ProjectUID] = @projectUID AND [ProductID] = @productID)
		RETURN 3405					-- # RESULT CODE 3405 : [Purchase] 존재하지 않는 productID (상품 추가 필요)

	INSERT INTO [dbo].[T_Purchase]([ProjectUID], [ProductID], [OrderID], [ErrorCode], [IP])
	VALUES(@projectUID, @productID, @orderID, @errorCode, @ip)

	RETURN 0						-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO

-- ==========================================================================================
-- Program Type : Stored Procedure
-- Program ID   : [P_CS_Name_Create]
-- DESC         : csName 신규 발급
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Name_Create]
	@packageName		VARCHAR(64),				-- 프로젝트 패키지 명 [ 영문 ]
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
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다

	-- [CsName] 신규 발급
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
-- DESC         : CS 보상 지급
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Reward]
	@packageName		VARCHAR(64),				-- 프로젝트 패키지 명 [ 영문 ]
	@csName				VARCHAR(12)					-- 발급받은 csName
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	DECLARE @projectUID INT = (SELECT TOP 1 [ProjectUID] FROM [dbo].[T_Project] WHERE [PackageName] = @packageName AND [Delete] = 0)
	IF @projectUID IS NULL
		RETURN 1401					-- # RESULT CODE 1401 : 존재하지 않는 프로젝트 입니다

	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[T_CS] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName)
	BEGIN
		RETURN 2401					-- # RESULT CODE 2401 : [CS] 존재하지 않는 csName 입니다
	END

	DECLARE @rewardCount INT = (SELECT COUNT(*) FROM [dbo].[T_CS_Reward] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName AND [GettingTime] IS NULL)
	IF @rewardCount = 0
	BEGIN
		RETURN 2402					-- # RESULT CODE 2402 : [CS] 지급할 아이템이 없습니다.
	END

	-- 받은 시간 입력 이후 [RewardObj] 컬럼값 반환
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
-- DESC         : CS 물품 삽입
-- Author       : 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[P_CS_Reward_Insert]
	@projectUID			INT,						-- T_Project Uid
	@csName				VARCHAR(12),				-- 발급받은 csName
	@rewardObj			VARCHAR(100),				-- 보상 오브젝트
	@memo				NVARCHAR(128)				-- 메모 작성 가능. 128자까지.
AS

SET NOCOUNT ON
SET LOCK_TIMEOUT 3000
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @csUid BIGINT = 0
BEGIN TRY

	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[T_CS] WHERE [ProjectUID] = @projectUID AND [CsName] = @csName)
		RETURN 2401				-- # RESULT CODE 2401 : [CS] 존재하지 않는 csName 입니다

	INSERT INTO [dbo].[T_CS_Reward] ([ProjectUID], [CsName], [RewardObj], [InsertedTime], [GettingTime], [Memo])
	VALUES(@projectUID, @csName, @rewardObj, GETDATE(), NULL, @memo)

	RETURN 0					-- # RESULT CODE 0 : 성공
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
-- DESC         : CS 지급타입 갱신
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
		RETURN 2403					-- # RESULT CODE 2403 : [CS] 존재하지 않는 프로젝트, projectUID 확인이 필요합니다.

	UPDATE [dbo].[T_Project]
	SET [CSRewardType] = @rewardType
	WHERE [ProjectUID] = @projectUID

	RETURN 0					-- # RESULT CODE 0 : 성공
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
-- DESC         : 클라이언트 로그인 삽입
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

	RETURN 0					-- # RESULT CODE 0 : 성공
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	EXECUTE [P_Error_Insert]
	RETURN 900
END CATCH
GO