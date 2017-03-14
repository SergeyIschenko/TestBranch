IF (object_id('p_kpi_CalcAllKPI', 'P') IS NULL)
  EXEC ('CREATE PROCEDURE [dbo].p_kpi_CalcAllKPI AS')
GO
GRANT EXECUTE ON p_kpi_CalcAllKPI TO PUBLIC
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
--
-- ������ �������� �� �� ����
--
-- =============================================
ALTER PROCEDURE [dbo].p_kpi_CalcAllKPI 
@Mode           int      = NULL,	-- ����� ������: 1 - ��������� �������� �� �������� �������
-- 2 - �� ��������� �����
@YearMonth char(6)	= NULL	-- ��� ������ ������ ������������� ��� @Mode = 2
AS
-- =============================================

DECLARE @Res int = 0;
DECLARE @YM VARCHAR(6)
-- =============================================
-- 1 - ��������� ��������
IF (@Mode in(1, 2))
BEGIN  
	IF object_id('tempdb..##tmpYM') is not NULL drop table ##tmpYM
	
	SET NOCOUNT ON;
	
	-- ����� ������ ����� ������������? (�������� ��������-���������� �������...)
	CREATE TABLE ##tmpYM(YM varchar(6) NOT NULL)	
	IF (@Mode = 1)
	BEGIN	-- ������ �������� ������
		INSERT into ##tmpYM(YM) 
		SELECT YearMonth FROM tMonthClose (NOLOCK)
		WHERE IsClose = 0
			AND NumYear * 100 + NumMonth <= YEAR(GETDATE()) * 100 + MONTH(GETDATE())  --  ������� ������������ ������� �������� �������
		ORDER BY YearMonth ASC
	END
	IF (@Mode = 2)
	BEGIN	-- ������ ���� �������� �����
		INSERT into ##tmpYM(YM) 
		SELECT YM = @YearMonth 	
	END	
		
	PRINT(CAST(GETDATE() as varchar(50))+' ������ ��������� �����!')	
		
	-- Step 1
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� ps_BaseTable_RecalcSumCur (��� 1)')
	
	EXEC @Res = ps_BaseTable_RecalcSumCur @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� ps_BaseTable_RecalcSumCur (��� 1)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	-- Step 2	
	/*EXEC @Res = p_kpi_CalcMonthRegionKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthRegionKPI (��� 2)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END*/
	
	-- Step 3	
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� p_kpi_CalcMonthEUKPI (��� 3)')
	
	EXEC @Res = p_kpi_CalcMonthEUKPI @Mode = @Mode	
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthEUKPI (��� 3)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END	
	
	-- Step 5
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� p_kpi_CalcMonthOfficeManagerKPI (��� 5)')	
	EXEC @Res = p_kpi_CalcMonthOfficeManagerKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthOfficeManagerKPI (��� 5)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	/*-- Step 5
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� p_kpi_CalcMonthOfficeKPI (��� 5)')	
	EXEC @Res = p_kpi_CalcMonthOfficeKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthOfficeKPI (��� 5)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	-- Step 6	
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� p_kpi_CalcMonthManagerKPI (��� 6)')	
	EXEC @Res = p_kpi_CalcMonthManagerKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthManagerKPI (��� 6)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END*/
	
	-- Step 7	
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� ps_BaseTable_RecalcSumCur (��� 7)')	
	EXEC @Res = ps_BaseTable_RecalcSumCur @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� ps_BaseTable_RecalcSumCur (��� 7)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END		
	
	-- Step 4
	PRINT(CAST(GETDATE() as varchar(50))+' ����� ��������� p_kpi_CalcMonthClientKPI (��� 4)')	
	EXEC @Res = p_kpi_CalcMonthClientKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('���������� ������ ��� ������ ��������� p_kpi_CalcMonthClientKPI (��� 4)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END	
	
	
	PRINT(CAST(GETDATE() as varchar(50))+' ������� ��������� ��������!')	
	IF object_id('tempdb..##tmpYM') is not NULL drop table ##tmpYM
END

-- ������� ��������� ����
SELECT @Mode
