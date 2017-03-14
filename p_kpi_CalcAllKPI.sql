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
-- Расчёт месячных КП по всем
--
-- =============================================
ALTER PROCEDURE [dbo].p_kpi_CalcAllKPI 
@Mode           int      = NULL,	-- режим работы: 1 - запустить пересчет по открытым месяцам
-- 2 - за указанный месяц
@YearMonth char(6)	= NULL	-- для какого месяца пересчитывать при @Mode = 2
AS
-- =============================================

DECLARE @Res int = 0;
DECLARE @YM VARCHAR(6)
-- =============================================
-- 1 - запустить пересчет
IF (@Mode in(1, 2))
BEGIN  
	IF object_id('tempdb..##tmpYM') is not NULL drop table ##tmpYM
	
	SET NOCOUNT ON;
	
	-- Какие месяцы будем обрабатывать? (создание временно-глобальной таблицы...)
	CREATE TABLE ##tmpYM(YM varchar(6) NOT NULL)	
	IF (@Mode = 1)
	BEGIN	-- только открытые месяцы
		INSERT into ##tmpYM(YM) 
		SELECT YearMonth FROM tMonthClose (NOLOCK)
		WHERE IsClose = 0
			AND NumYear * 100 + NumMonth <= YEAR(GETDATE()) * 100 + MONTH(GETDATE())  --  незачем обрабатывать будущие открытые периоды
		ORDER BY YearMonth ASC
	END
	IF (@Mode = 2)
	BEGIN	-- только один заданный месяц
		INSERT into ##tmpYM(YM) 
		SELECT YM = @YearMonth 	
	END	
		
	PRINT(CAST(GETDATE() as varchar(50))+' Прцесс пересчета начат!')	
		
	-- Step 1
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры ps_BaseTable_RecalcSumCur (Шаг 1)')
	
	EXEC @Res = ps_BaseTable_RecalcSumCur @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры ps_BaseTable_RecalcSumCur (Шаг 1)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	-- Step 2	
	/*EXEC @Res = p_kpi_CalcMonthRegionKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthRegionKPI (Шаг 2)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END*/
	
	-- Step 3	
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры p_kpi_CalcMonthEUKPI (Шаг 3)')
	
	EXEC @Res = p_kpi_CalcMonthEUKPI @Mode = @Mode	
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthEUKPI (Шаг 3)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END	
	
	-- Step 5
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры p_kpi_CalcMonthOfficeManagerKPI (Шаг 5)')	
	EXEC @Res = p_kpi_CalcMonthOfficeManagerKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthOfficeManagerKPI (Шаг 5)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	/*-- Step 5
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры p_kpi_CalcMonthOfficeKPI (Шаг 5)')	
	EXEC @Res = p_kpi_CalcMonthOfficeKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthOfficeKPI (Шаг 5)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END
	
	-- Step 6	
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры p_kpi_CalcMonthManagerKPI (Шаг 6)')	
	EXEC @Res = p_kpi_CalcMonthManagerKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthManagerKPI (Шаг 6)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END*/
	
	-- Step 7	
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры ps_BaseTable_RecalcSumCur (Шаг 7)')	
	EXEC @Res = ps_BaseTable_RecalcSumCur @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры ps_BaseTable_RecalcSumCur (Шаг 7)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END		
	
	-- Step 4
	PRINT(CAST(GETDATE() as varchar(50))+' Вызов процедуры p_kpi_CalcMonthClientKPI (Шаг 4)')	
	EXEC @Res = p_kpi_CalcMonthClientKPI @Mode = @Mode
	IF (@@ERROR <> 0 OR @Res <> 0)
	BEGIN
		RAISERROR('Обнаружена ошибка при вызове процедуры p_kpi_CalcMonthClientKPI (Шаг 4)', 16, 10)
		ROLLBACK TRAN
		RETURN -1
	END	
	
	
	PRINT(CAST(GETDATE() as varchar(50))+' Процесс пересчета завершен!')	
	IF object_id('tempdb..##tmpYM') is not NULL drop table ##tmpYM
END

-- Покажем фиктивный итог
SELECT @Mode
