IF (OBJECT_ID('p_Producer_SelectForCombo', 'P') IS NULL)
	EXEC('CREATE PROCEDURE [dbo].p_Producer_SelectForCombo AS')
GO
GRANT EXECUTE ON p_Producer_SelectForCombo TO PUBLIC
GO

/****** Object:  Stored Procedure dbo.p_Producer_SelectForCombo    Script Date: 20.10.2009 12:49:14 ******/
-- =================================================================================== --
--  
--  Справочник производителей товаров. Просмотр.
--  
-- =================================================================================== --
ALTER PROCEDURE [dbo].[p_Producer_SelectForCombo]
AS
-- =================================================================================== --

-- =================================================================================== --
SELECT
  P.ProducerId,
  P.ProducerName
from sProducer P
order by P.ProducerName

-- =================================================================================== --
-- =================================================================================== --






GO
