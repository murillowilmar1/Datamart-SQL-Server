CREATE OR ALTER PROC dbo.usp_TL_DIM_Geografia 
AS 

---DUMMY 





--- UPDATE 










---- INSERT TO 



(SELECT    Stg.[CodGeografia]
		  ,Stg.[CodCiudad]
		  ,Stg.[Ciudad_Nombre]
		  ,Stg.[CodRegion]
		  ,Stg.[Region_Nombre]
		  ,Stg.[CodPais]
		  ,Stg.[Pais_Nombre]
		  ,Stg.[BI_Control_Extraccion ]
		  ,Stg.[BI_Control_Transformacion]
         INTO [Datamart_Norte].[dbo].[DIM_Geografia]
  FROM[Staging_Norte].[dbo].[VW_Tr_Geografia] AS Stg
  
  
  ) 

GO


