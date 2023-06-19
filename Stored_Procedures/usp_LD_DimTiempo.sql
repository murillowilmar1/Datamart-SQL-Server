SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_LD_DimTiempo]
------------------------------------------------------------------------
-- Procedimiento para generar una dimensi�n de tiempo localizada
-- Se basa en una tabla de tiempo con las siguientes caracter�sticas:

/*
CREATE TABLE [dbo].[Dim_Tiempo](
	[IdTiempo] [int]  NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[NumeroDiaSemana] [tinyint] NOT NULL,
	[DiaSemanaIngles] [nvarchar](10) NULL,
	[DiaSemana] [nvarchar](10) NOT NULL,
	[NumeroDiaMes] [tinyint] NULL,
	[NumeroDiaA�o] [smallint] NULL,
	[NumeroSemanaA�o] [tinyint] NOT NULL,
	[MesIngles] [nvarchar](20) NULL,
	[Mes] [nvarchar](20) NOT NULL,
	[NumeroMesA�o] [nvarchar](20) NOT NULL,
	[TrimestreCalendario] [nvarchar](20) NOT NULL,
	[A�oCalendario] [char](4) NOT NULL,
	[SemestreCalendario] [nvarchar](20) NOT NULL,
	[TrimestreFiscal] [tinyint] NULL,
	[A�oFiscal] [char](4) NULL,
	[SemestreFiscal] [tinyint] NULL,
	[MesDelA�o] [nvarchar](20) NOT NULL,
	[Diahabil] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Tiempo] PRIMARY KEY CLUSTERED 
(
	[IdTiempo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [AK_Tiempo_Fecha] UNIQUE NONCLUSTERED 
(
	[Fecha] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
*/
-- No es necesario que la tabla tenga todos los campos. Sin embargo el
-- procedimiento toma llena los campos con valores para todas las fechas
-- especificadas en el rango dado por los dos par�metros.
-- Si el procedimiento se ejecuta varias veces, por cada nueva ejecuci�n
-- se actualizan los registros de manera que cualquier modificaci�n
-- previa que hubiera podido hacerse sobre los datos se perder�
--
-- Tiene en cuenta �nicamente algunos campos en ingl�s
------------------------------------------------------------------------
-- Desarrollado por: Mauricio Cotes
------------------------------------------------------------------------
-- Modificaciones:
-- Afortunadamente Ninguna :D
------------------------------------------------------------------------
@pFechaInicial datetime,-- = '01/01/2010', 
@pFechaFinal datetime-- = '01/31/2020'
AS

SET NOCOUNT ON
SET DATEFORMAT mdy

DECLARE 
	@ListaCampos nvarchar(4000),
	@ListaVariables nvarchar(4000),
	@ListaUpdate nvarchar(4000),
	@Insert nvarchar(4000),
	@Update nvarchar(4000),

	@Fecha datetime,
	@NumeroDiaSemana tinyint,
	@DiaSemanaIngles nvarchar(10),
	@DiaSemana nvarchar(10),
	@NumeroDiaMes tinyint,
	@NumeroDiaA�o smallint,
	@NumeroSemanaA�o tinyint,
	@MesIngles nvarchar(10),
	@Mes nvarchar(15),
	@NumeroMesA�o tinyint,
	@TrimestreCalendario nvarchar(15),
	@A�oCalendario nchar(4),
	@SemestreCalendario nvarchar(15),
	@TrimestreFiscal tinyint,
	@A�oFiscal nchar(4),
	@SemestreFiscal tinyint,

	@BimestreCalendario tinyint, 
	@BimestreFiscal tinyint, 

	@Periodo nvarchar(20),
	@Prefijo nvarchar(10),
	@DiaHabil varchar(10),
	@MesDelA�o varchar(15)

SET NOCOUNT ON


SET @Fecha = @pFechaInicial

WHILE @Fecha <= @pFechaFinal
BEGIN
-- 	 IF Day(@Fecha) = 1 
-- 	 	Select 'Generando mes ' + Convert(varchar, Month(@Fecha)) + ' de ' + Convert(varchar, Year(@Fecha))

	SET @A�oCalendario = Convert(nchar, Year(@Fecha))
	SET @A�oFiscal = Convert(nchar, Year(@Fecha))	
	
	--SET @SemestreCalendario = CASE	WHEN Month(@Fecha) <= 6 THEN 1 ELSE 2 END 
	SET @SemestreCalendario = 'S' + CASE	WHEN Month(@Fecha) <= 6 THEN '1'
											ELSE '2' END + '/' + RIGHT(@A�oCalendario, 2)
	SET @SemestreFiscal = CASE	WHEN Month(@Fecha) <= 6 THEN 1 ELSE 2 END 

	--SET @TrimestreCalendario = DatePart(quarter, @Fecha)
	SET @TrimestreCalendario = 'T' + Convert(varchar, DatePart(quarter, @Fecha)) + '/' + RIGHT(@A�oCalendario, 2)
	SET @TrimestreFiscal = DatePart(quarter, @Fecha)

	SET @BimestreCalendario = (Month(@Fecha) + 1) / 2
	SET @BimestreFiscal = (Month(@Fecha) + 1) / 2

	SET @NumeroMesA�o = Month(@Fecha)
	
	--Mes del A�o
	SET @MesDelA�o = CASE @NumeroMesA�o
		WHEN  1 THEN N'Enero' 
		WHEN  2 THEN N'Febrero' 
		WHEN  3 THEN N'Marzo' 
		WHEN  4 THEN N'Abril' 
		WHEN  5 THEN N'Mayo' 
		WHEN  6 THEN N'Junio' 
		WHEN  7 THEN N'Julio' 
		WHEN  8 THEN N'Agosto' 
		WHEN  9 THEN N'Septiembre' 
		WHEN 10 THEN N'Octubre' 
		WHEN 11 THEN N'Noviembre' 
		WHEN 12 THEN N'Diciembre' END

	SET @MesIngles = CASE @NumeroMesA�o 
		WHEN  1 THEN N'January' 
		WHEN  2 THEN N'February' 
		WHEN  3 THEN N'March' 
		WHEN  4 THEN N'April' 
		WHEN  5 THEN N'May' 
		WHEN  6 THEN N'June' 
		WHEN  7 THEN N'July' 
		WHEN  8 THEN N'August' 
		WHEN  9 THEN N'September' 
		WHEN 10 THEN N'October' 
		WHEN 11 THEN N'November' 
		WHEN 12 THEN N'December' END
	
	SET @Mes = @MesDelA�o + '/' + RIGHT(@A�oCalendario, 2)
	SET @NumeroDiaSemana = DatePart(Weekday, @Fecha)

	SET @DiaSemana = Case @NumeroDiaSemana
		WHEN 1 THEN N'Domingo'
		WHEN 2 THEN N'Lunes'
		WHEN 3 THEN N'Martes'
		WHEN 4 THEN N'Miercoles'
		WHEN 5 THEN N'Jueves'
		WHEN 6 THEN N'Viernes'
		WHEN 7 THEN N'S�bado' END

	SET @DiaSemanaIngles = Case @NumeroDiaSemana
		WHEN 1 THEN N'Sunday'
		WHEN 2 THEN N'Monday'
		WHEN 3 THEN N'Tuesday'
		WHEN 4 THEN N'Wednesday'
		WHEN 5 THEN N'Thursday'
		WHEN 6 THEN N'Friday'
		WHEN 7 THEN N'Saturday' END
	
	SET @NumeroDiaMes = Day(@Fecha)
	SET @NumeroDiaA�o = Datepart(DayOfYear, @Fecha)
	SET @NumeroSemanaA�o = Datepart(Week, @Fecha)


	 -- Evalua que campos se encuentran definidos en la tabla de tiempo y con base en ellos
	 -- Genera las instrucciones que se utilizar�n para la actualizaci�n
	 SET @ListaCampos = N'IdTiempo, '
	 SET @ListaVariables  = convert(varchar, @Fecha, 112) + N', '
	 SET @ListaUpdate  = N'IdTiempo = ' + convert(varchar, @Fecha, 112) + N', '

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
	 		WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'A�o')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'A�o, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @A�oCalendario + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[A�o] = ''' + @A�oCalendario + N''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
	 		WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'A�oCalendario')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'A�oCalendario, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @A�oCalendario + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[A�oCalendario] = ''' + @A�oCalendario + N''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
	 		WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'A�oFiscal')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'A�oFiscal, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @A�oFiscal + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[A�oFiscal] = ''' + @A�oFiscal + N''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'Semestre')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'Semestre, ' 
		SET @ListaVariables = @ListaVariables + N'''' + convert(nvarchar, @SemestreCalendario) + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[Semestre] = ' + convert(nvarchar, @SemestreCalendario) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'SemestreCalendario')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'SemestreCalendario, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @SemestreCalendario + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[SemestreCalendario] = ''' + @SemestreCalendario + N''', '
	 END 

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'SemestreFiscal')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'SemestreFiscal, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @SemestreFiscal) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[SemestreFiscal] = ' + convert(nvarchar, @SemestreFiscal) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'Trimestre')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'Trimestre, ' 
		SET @ListaVariables = @ListaVariables + N'''' + convert(nvarchar, @TrimestreCalendario) + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[Trimestre] = ' + convert(nvarchar, @TrimestreCalendario) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'TrimestreCalendario')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'TrimestreCalendario, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @TrimestreCalendario + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[TrimestreCalendario] = ''' + @TrimestreCalendario + N''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'TrimestreFiscal')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'TrimestreFiscal, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @TrimestreFiscal) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[TrimestreFiscal] = ' + convert(nvarchar, @TrimestreFiscal) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'Bimestre')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'Bimestre, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @BimestreCalendario) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[Bimestre] = ' + convert(nvarchar, @BimestreCalendario) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroMesA�o')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'NumeroMesA�o, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroMesA�o) + ', '
		SET @ListaUpdate = @ListaUpdate + '[NumeroMesA�o] = ' + convert(nvarchar, @NumeroMesA�o) + ', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'Mes')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'Mes, ' 
		SET @ListaVariables = @ListaVariables + '''' + @Mes + ''', '
		SET @ListaUpdate = @ListaUpdate + '[Mes] = ''' + @Mes + ''', '
	 END

	-- Mes del a�o
	IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'MesDelA�o')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'MesDelA�o, ' 
		SET @ListaVariables = @ListaVariables + '''' + @MesDelA�o + ''', '
		SET @ListaUpdate = @ListaUpdate + '[MesDelA�o] = ''' + @MesDelA�o + ''', '
	 END   

/*	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'MesIngles')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'MesIngles, ' 
		SET @ListaVariables = @ListaVariables + '''' + @MesIngles + ''', '
		SET @ListaUpdate = @ListaUpdate + '[MesIngles] = ''' + @MesIngles + ''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'D�a')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'D�a, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroDiaMes) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[D�a] = ' + convert(nvarchar, @NumeroDiaMes) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'Dia')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'Dia, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroDiaMes) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[Dia] = ' + convert(nvarchar, @NumeroDiaMes) + N', '
	 END  
*/
	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroDiaMes')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'NumeroDiaMes, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroDiaMes) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[NumeroDiaMes] = ' + convert(nvarchar, @NumeroDiaMes) + N', '
	 END  

--	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
--			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroSemanaA�o')
--	 BEGIN
--		SET @ListaCampos = @ListaCampos + N'NumeroSemanaA�o, ' 
--		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroSemanaA�o) + N', '
--		SET @ListaUpdate = @ListaUpdate + N'[NumeroSemanaA�o] = ' + convert(nvarchar, @NumeroSemanaA�o) + N', '
--	 END 

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroDiaA�o')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'NumeroDiaA�o, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroDiaA�o) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[NumeroDiaA�o] = ' + convert(nvarchar, @NumeroDiaA�o) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroSemanaA�o')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'NumeroSemanaA�o, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroSemanaA�o) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[NumeroSemanaA�o] = ' + convert(nvarchar, @NumeroSemanaA�o) + N', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'NumeroDiaSemana')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'NumeroDiaSemana, ' 
		SET @ListaVariables = @ListaVariables + convert(nvarchar, @NumeroDiaSemana) + N', '
		SET @ListaUpdate = @ListaUpdate + N'[NumeroDiaSemana] = ' + convert(nvarchar, @NumeroDiaSemana) + N', '
	 END  

/*	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'DiaSemanaIngles')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'DiaSemanaIngles, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @DiaSemanaIngles + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[DiaSemanaIngles] = ''' + @DiaSemanaIngles + N''', '
	 END  
*/
	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'DiaSemana')
	 BEGIN
		SET @ListaCampos = @ListaCampos + N'DiaSemana, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @DiaSemana + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[DiaSemana] = ''' + @DiaSemana + N''', '
	 END  

	 IF EXISTS (SELECT * FROM Datamart_EIA.dbo.sysObjects O INNER JOIN Datamart_EIA.dbo.sysColumns C ON O.ID = C.ID 
			WHERE O.ID = OBJECT_ID(N'Datamart_EIA.[dbo].[Dim_Tiempo]') AND C.NAME = N'DiaHabil')
	 BEGIN
		SET @DiaHabil = 'SI'
		IF RTRIM(LTRIM(@DiaSemana)) = 'S�bado' OR RTRIM(LTRIM(@DiaSemana)) = 'S�bado' 
		BEGIN 
			SET @DiaHabil = 'NO'
		END 
		SET @DiaHabil = 'NA'
		SET @ListaCampos = @ListaCampos + N'DiaHabil, ' 
		SET @ListaVariables = @ListaVariables + N'''' + @DiaSemana + N''', '
		SET @ListaUpdate = @ListaUpdate + N'[Diahabil] = ''' + @DiaHabil + N''', '
	 END  

	 -- Elimina las comas del final
	 SET @ListaCampos = LEFT(@ListaCampos, LEN(@ListaCampos) - 1)
	 SET @ListaVariables = LEFT(@ListaVariables, LEN(@ListaVariables) - 1)
	 SET @ListaUpdate = LEFT(@ListaUpdate, LEN(@ListaUpdate) - 1)

	 -- Arma las instrucciones a ejecutar
	 SET @Insert = 'INSERT INTO Datamart_EIA.[dbo].[Dim_Tiempo] (Fecha, ' + @ListaCampos + ')
	   VALUES (''' + Convert(varchar, @Fecha, 101) + ''', ' + @ListaVariables + ')'
	 SET @Update = ' UPDATE Datamart_EIA.[dbo].[Dim_Tiempo]
	    Set ' + @ListaUpdate + '
	    WHERE Fecha = ''' + Convert(varchar, @Fecha, 101) + '''' 

	 -- Realiza la actualizaci�n de la tabla de tiempo
	 IF NOT EXISTS(SELECT Fecha FROM Datamart_EIA.[dbo].[Dim_Tiempo] WHERE Fecha = Convert(varchar, @Fecha, 101))
	  -- La fecha no existe en la tabla, debe ser Insertada en la tabla
		EXECUTE (@Insert)
	 ELSE  
		EXECUTE (@Update)
	
	 SET @Fecha = DateAdd(dd, 1, @Fecha)
	 --SELECT @Insert + str(13) + @Update
END

