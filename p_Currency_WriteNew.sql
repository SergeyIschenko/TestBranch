IF (OBJECT_ID('p_Currency_WriteNew', 'P') IS NULL)
	EXEC('CREATE PROCEDURE [dbo].p_Currency_WriteNew AS')
GO
GRANT EXECUTE ON p_Currency_WriteNew TO PUBLIC
GO
-- ============================================================================== --
--  
--  Валюта. Редактирование.
--  
-- ============================================================================== --
ALTER PROCEDURE [dbo].[p_Currency_WriteNew]
@Mode            int         = 0,                 -- режим работы: 1 - INSERT, 2 - UPDATE, 3 - DELETE, 4 - SET REG CUR, 5 - SET NAT CUR
@Currency_ID	 char(3)     = NULL,              -- код валюты
@Currency_Name	 varchar(50) = NULL,              -- название валюты
@Currency_ShortName	 varchar(10) = NULL,          -- сокращенное название валюты
@Currency_NBU_ID char(3)     = NULL,	-- код НБУ 
@IsOper				bit	= NULL,	-- Признак валюты оперативного учета
@SymbolCur	char(1)	= NULL,	-- Символ для обозначения валюты
@ExCur	char(2)	= NULL	-- Название валюты в Ex-приложении
AS
-- ============================================================================== --
-- ============================================================================== --
IF (@Mode = 1)
BEGIN
  INSERT into sCurrency (
		Currency_ID, 
		Currency_Name, 
		Currency_ShortName, 
		Currency_NBU_ID,
		IsOper,
		SymbolCur,
		ExCur
	) 
	values (
		@Currency_ID, 
		@Currency_Name, 
		@Currency_ShortName, 
		@Currency_NBU_ID,
		@IsOper,
		@SymbolCur,
		@ExCur)
END
-- ============================================================================== --
IF (@Mode = 2)
BEGIN
  UPDATE sCurrency set 
		Currency_Name = @Currency_Name,
		Currency_ShortName = @Currency_ShortName,
		Currency_NBU_ID = @Currency_NBU_ID,
		IsOper = @IsOper,
		SymbolCur = @SymbolCur,
		ExCur	= @ExCur
	where Currency_ID = @Currency_ID
END
-- ============================================================================== --
IF (@Mode = 3)
BEGIN
  DELETE from sCurrency where Currency_ID = @Currency_ID
END
-- ============================================================================== --
IF (@Mode = 4)
BEGIN
  IF(NOT EXISTS (SELECT * FROM sCurrency WHERE Currency_ID = @Currency_ID)) BEGIN
     RAISERROR('Валюта не найдена!', 16, 10)
     RETURN -1
  END
  BEGIN TRAN
  UPDATE sCurrency SET RegCur = 0
  IF(@@error <> 0) BEGIN
     ROLLBACK TRAN
     RETURN -1
  END
  UPDATE sCurrency SET RegCur = 1 WHERE Currency_ID = @Currency_ID
  IF(@@error <> 0) BEGIN
     ROLLBACK TRAN
     RETURN -1
  END
  COMMIT TRAN
END
-- ============================================================================== --
IF (@Mode = 5)
BEGIN
  IF(NOT EXISTS (SELECT * FROM sCurrency WHERE Currency_ID = @Currency_ID)) BEGIN
     RAISERROR('Валюта не найдена!', 16, 10)
     RETURN -1
  END
  BEGIN TRAN
  UPDATE sCurrency SET NatCur = 0
  IF(@@error <> 0) BEGIN
     ROLLBACK TRAN
     RETURN -1
  END
  UPDATE sCurrency SET NatCur = 1 WHERE Currency_ID = @Currency_ID
  IF(@@error <> 0) BEGIN
     ROLLBACK TRAN
     RETURN -1
  END
  COMMIT TRAN
END
-- ============================================================================== --

SELECT * FROM sCurrency WHERE Currency_ID = @Currency_ID
GO
