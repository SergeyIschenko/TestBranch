IF (OBJECT_ID('p_KorpKag_SelectForCombo', 'P') IS NULL)
	EXEC('CREATE PROCEDURE [dbo].p_KorpKag_SelectForCombo AS')
GO
GRANT EXECUTE ON p_KorpKag_SelectForCombo TO PUBLIC
GO


-- =============================================================================== --
--  
--  Справочник корпоративных клиентов
--  
-- =============================================================================== --
ALTER PROCEDURE [dbo].p_KorpKag_SelectForCombo
AS
-- =============================================================================== --

-- =============================================================================== --
SELECT
  CK.CorpKagId,
  CK.CorpKagName
from tCorpKag CK (NOLOCK)
order by CK.CorpKagId

-- =============================================================================== --

GO
