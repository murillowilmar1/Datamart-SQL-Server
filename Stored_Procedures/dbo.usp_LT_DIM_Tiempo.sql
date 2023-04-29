CREATE PROCEDURE dbo.usp_LT_DIM_Tiempo
------------------------------------------------------------------------
-- Procedimiento para generar una dimensión de tiempo localizada
-- Se basa en una tabla de tiempo con las siguientes características:

/*
CREATE TABLE [dbo].[Dim_Tiempo](
	[IdTiempo] [int]  NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[NumeroDiaSemana] [tinyint] NOT NULL,
	[DiaSemanaIngles] [nvarchar](10) NULL,
	[DiaSemana] [nvarchar](10) NOT NULL,
	[NumeroDiaMes] [tinyint] NULL,
	[NumeroDiaAño] [smallint] NULL,
	[NumeroSemanaAño] [tinyint] NOT NULL,
	[MesIngles] [nvarchar](20) NULL,
	[Mes] [nvarchar](20) NOT NULL,
	[NumeroMesAño] [nvarchar](20) NOT NULL,
	[TrimestreCalendario] [nvarchar](20) NOT NULL,
	[AñoCalendario] [char](4) NOT NULL,
	[SemestreCalendario] [nvarchar](20) NOT NULL,
	[TrimestreFiscal] [tinyint] NULL,
	[AñoFiscal] [char](4) NULL,
	[SemestreFiscal] [tinyint] NULL,
	[MesDelAño] [nvarchar](20) NOT NULL,
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
-- especificadas en el rango dado por los dos parámetros.
-- Si el procedimiento se ejecuta varias veces, por cada nueva ejecución
-- se actualizan los registros de manera que cualquier modificación
-- previa que hubiera podido hacerse sobre los datos se perderá
--
-- Tiene en cuenta únicamente algunos campos en inglés
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
	@NumeroDiaAño smallint,
	@NumeroSemanaAño tinyint,
	@MesIngles nvarchar(10),
	@Mes nvarchar(15),
	@NumeroMesAño tinyint,
	@TrimestreCalendario nvarchar(15),
	@AñoCalendario nchar(4),
	@SemestreCalendario nvarchar(15),
	@TrimestreFiscal tinyint,
	@AñoFiscal nchar(4),
	@SemestreFiscal tinyint,

	@BimestreCalendario tinyint, 
	@BimestreFiscal tinyint, 

	@Periodo nvarchar(20),
	@Prefijo nvarchar(10),
	@DiaHabil varchar(10),
	@MesDelAño varchar(15)

SET NOCOUNT ON


SET @Fecha = @pFechaInicial

WHILE @Fecha <= @pFechaFinal
BEGIN
-- 	 IF Day(@Fecha) = 1 
-- 	 	Select 'Generando mes ' + Convert(varchar, Month(@Fecha)) + ' de ' + Convert(varchar, Year(@Fecha))

	SET @AñoCalendario = Convert(nchar, Year(@Fecha))
	SET @AñoFiscal = Convert(nchar, Year(@Fecha))	
	
	--SET @SemestreCalendario = CASE	WHEN Month(@Fecha) <= 6 THEN 1 ELSE 2 END 
	SET @SemestreCalendario = 'S' + CASE	WHEN Month(@Fecha) <= 6 THEN '1'
											ELSE '2' END + '/' + RIGHT(@AñoCalendario, 2)
	SET @SemestreFiscal = CASE	WHEN Month(@Fecha) <= 6 THEN 1 ELSE 2 END 

	--SET @TrimestreCalendario = DatePart(quarter, @Fecha)
	SET @TrimestreCalendario = 'T' + Convert(varchar, DatePart(quarter, @Fecha)) + '/' + RIGHT(@AñoCalendario, 2)
	SET @TrimestreFiscal = DatePart(quarter, @Fecha)

	SET @BimestreCalendario = (Month(@Fecha) + 1) / 2
	SET @BimestreFiscal = (Month(@Fecha) + 1) / 2

	SET @NumeroMesAño = Month(@Fecha)
	
	--Mes del Año
	SET @MesDelAño = CASE @NumeroMesAño
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

	SET @MesIngles = CASE @NumeroMesAño 
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
	
	SET @Mes = @MesDelAño + '/' + RIGHT(@AñoCalendario, 2)
	SET @NumeroDiaSemana = DatePart(Weekday, @Fecha)

	SET @DiaSemana = Case @NumeroDiaSemana
		WHEN 1 THEN N'Domingo'
		WHEN 2 THEN N'Lunes'
		WHEN 3 THEN N'Martes'
		WHEN 4 THEN N'Miercoles'
		WHEN 5 THEN N'Jueves'
		WHEN 6 THEN N'Viernes'
		WHEN 7 THEN N'Sábado' END

	SET @DiaSemanaIngles = Case @NumeroDiaSemana
		WHEN 1 THEN N'Sunday'
		WHEN 2 THEN N'Monday'
		WHEN 3 THEN N'Tuesday'
		WHEN 4 THEN N'Wednesday'
		WHEN 5 THEN N'Thursday'
		WHEN 6 THEN N'Friday'
		WHEN 7 THEN N'Saturday' END
	
	SET @NumeroDiaMes = Day(@Fecha)
	SET @NumeroDiaAño = Datepart(DayOfYear, @Fecha)
	SET @NumeroSemanaAño = Datepart(Week, @Fecha)
