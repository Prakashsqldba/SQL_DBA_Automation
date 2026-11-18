SELECT 
    vs.volume_mount_point AS [Drive],
    CAST(vs.total_bytes / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10, 2)) AS [TotalDriveSize_GB],
    CAST(vs.available_bytes / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10, 2)) AS [FreeDriveSpace_GB],
    CAST(CAST(vs.available_bytes AS FLOAT) / CAST(vs.total_bytes AS FLOAT) * 100 AS DECIMAL(5, 2)) AS [FreeDriveSpace_Pct],
    DB_NAME(mf.database_id) AS [DatabaseName],
    mf.name AS [LogicalFileName],
    UPPER(LEFT(mf.physical_name, 1)) AS [FileDrive],
    CASE mf.type 
        WHEN 0 THEN 'Data' 
        WHEN 1 THEN 'Log' 
        ELSE 'Other' 
    END AS [FileType],
    CAST((mf.size * 8.0) / 1024.0 AS DECIMAL(10, 2)) AS [FileSize_MB],
    CASE 
        WHEN mf.is_percent_growth = 1 THEN CAST(mf.growth AS VARCHAR(10)) + '%'
        ELSE CAST((mf.growth * 8.0) / 1024.0 AS DECIMAL(10, 2)) + ' MB'
    END AS [GrowthSetting],
    mf.physical_name AS [PhysicalPath]
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
ORDER BY [FreeDriveSpace_Pct] ASC, [DatabaseName] ASC;