CREATE OR ALTER PROC dbo.usp_TL_DIM_Geografia 
AS 

---DUMMY 

IF NOT EXISTS (SELECT IdGeografia FROM [Datamart_Norte].[dbo].[DIM_Geografia]
					WHERE IdGeografia = -99)
BEGIN
	--Apague el Identity
	SET IDENTITY_INSERT [Datamart_Norte].[dbo].[DIM_Geografia] ON 
	             


INSERT INTO [Datamart_Norte].[dbo].[DIM_Geografia]
           ([IdGeografia]
		   ,[CodGeografia]
           ,[CodCiudad]
           ,[Ciudad_Nombre]
           ,[CodRegion]
           ,[Region_Nombre]
           ,[CodPais]
           ,[Pais_Nombre]
           ,[BI_Control_Extraccion ]
           ,[BI_Control_Transformacion])
     VALUES
           (
            -99
           ,-99
           ,-99
           ,'_Sin Ciudad'
           ,-99
           ,'_Sin Region'	
           ,-99
           ,'_Sin Pais' 
		   ,GETDATE()
		   ,GETDATE())
	--Encienda el Identity
     SET IDENTITY_INSERT [Datamart_Norte].[dbo].[DIM_Geografia] OFF 

END

---- INSERT TO 

INSERT INTO [Datamart_Norte].[dbo].[DIM_Geografia]
           ([CodGeografia]
           ,[CodCiudad]
           ,[Ciudad_Nombre]
           ,[CodRegion]
           ,[Region_Nombre]
           ,[CodPais]
           ,[Pais_Nombre]
           ,[BI_Control_Extraccion ]
           ,[BI_Control_Transformacion])


(SELECT    Stg.[CodGeografia]
		  ,Stg.[CodCiudad]
		  ,Stg.[Ciudad_Nombre]
		  ,Stg.[CodRegion]
		  ,Stg.[Region_Nombre]
		  ,Stg.[CodPais]
		  ,Stg.[Pais_Nombre]
		  ,Stg.[BI_Control_Extraccion ]
		  ,Stg.[BI_Control_Transformacion]
        -- INTO [Datamart_Norte].[dbo].[DIM_Geografia]
  FROM[Staging_Norte].[dbo].[VW_Tr_Geografia] AS Stg
      LEFT JOIN [Datamart_Norte].[dbo].[DIM_Geografia] AS Dtm 
	  ON Stg.CodGeografia = Dtm.CodGeografia 
	  WHERE Dtm.CodGeografia IS NULL ) 

GO



