WITH 
civilization_trade_data AS (
    SELECT 
        c.civilization_type,
        COUNT(DISTINCT c.caravan_id) AS total_caravans,
        SUM(tt.value) AS total_trade_value,
        SUM(
            CASE 
                WHEN tt.balance_direction = 'inflow' THEN tt.value 
                ELSE -tt.value 
            END
        ) AS trade_balance,
        JSON_ARRAYAGG(DISTINCT c.caravan_id) AS caravan_ids
    FROM 
        CARAVANS c
    JOIN 
        TRADE_TRANSACTIONS tt ON c.caravan_id = tt.caravan_id
    GROUP BY 
        c.civilization_type
),

diplomatic_correlation_data AS (
    SELECT
        c.civilization_type,
        CORR(tt.value, de.relationship_change) AS diplomatic_correlation
    FROM
        TRADE_TRANSACTIONS tt
    JOIN
        CARAVANS c ON tt.caravan_id = c.caravan_id
    JOIN
        DIPLOMATIC_EVENTS de ON c.caravan_id = de.caravan_id
    WHERE 
        de.relationship_change IS NOT NULL
    GROUP BY
        c.civilization_type
),

import_dependency_data AS (
    SELECT
        cg.material_type,
        SUM(cg.quantity) AS total_imported,
        COUNT(DISTINCT c.civilization_type) AS import_diversity,
        (SUM(cg.quantity) / NULLIF(COUNT(DISTINCT c.civilization_type), 0)) AS dependency_score,
        JSON_ARRAYAGG(DISTINCT p.material_id) AS resource_ids
    FROM
        CARAVAN_GOODS cg
    JOIN
        CARAVANS c ON cg.caravan_id = c.caravan_id
    LEFT JOIN 
        PRODUCTS p ON cg.original_product_id = p.product_id
    WHERE
        cg.type = 'import'
    GROUP BY
        cg.material_type
    ORDER BY
        dependency_score DESC
),

export_effectiveness_data AS (
    WITH exports AS (
        SELECT
            p.workshop_id,
            w.type AS workshop_type,
            p.type AS product_type,
            SUM(cg.quantity) AS total_exported,
            AVG(cg.value / NULLIF(p.value, 0)) AS avg_markup
        FROM CARAVAN_GOODS cg
        JOIN PRODUCTS p ON cg.original_product_id = p.product_id
        JOIN WORKSHOPS w ON p.workshop_id = w.workshop_id
        WHERE cg.type = 'export' AND p.value > 0
        GROUP BY p.workshop_id, w.type, p.type
    ),
    production AS (
        SELECT 
            p.workshop_id,
            p.type AS product_type,
            SUM(wp.quantity) AS total_produced
        FROM WORKSHOP_PRODUCTS wp
        JOIN PRODUCTS p ON wp.product_id = p.product_id
        GROUP BY p.workshop_id, p.type
    )
    SELECT 
        e.workshop_type,
        e.product_type,
        ROUND((SUM(e.total_exported) / NULLIF(SUM(p.total_produced), 0)) * 100, 2) AS export_ratio,
        AVG(e.avg_markup) AS avg_markup,
        JSON_ARRAYAGG(DISTINCT e.workshop_id) AS workshop_ids
    FROM 
        exports e
    JOIN 
        production p ON e.workshop_id = p.workshop_id AND e.product_type = p.product_type
    GROUP BY
        e.workshop_type, e.product_type
),

trade_timeline_data AS (
    SELECT
        EXTRACT(YEAR FROM tt.date) AS year,
        EXTRACT(QUARTER FROM tt.date) AS quarter,
        SUM(tt.value) AS quarterly_value,
        SUM(
            CASE 
                WHEN tt.balance_direction = 'inflow' THEN tt.value 
                ELSE -tt.value 
            END
        ) AS quarterly_balance,
        COUNT(DISTINCT c.civilization_type) AS trade_diversity
    FROM 
        TRADE_TRANSACTIONS tt
    JOIN
        CARAVANS c ON tt.caravan_id = c.caravan_id
    GROUP BY
        year, quarter
    ORDER BY
        year, quarter
)

SELECT 
    JSON_OBJECT(
        'total_trading_partners', (SELECT COUNT(*) FROM civilization_trade_data),
        'all_time_trade_value', (SELECT SUM(total_trade_value) FROM civilization_trade_data),
        'all_time_trade_balance', (SELECT SUM(trade_balance) FROM civilization_trade_data),
        
        'civilization_data', (
            SELECT JSON_OBJECT('civilization_trade_data', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'civilization_type', ctd.civilization_type,
                    'total_caravans', ctd.total_caravans,
                    'total_trade_value', ctd.total_trade_value,
                    'trade_balance', ctd.trade_balance,
                    'trade_relationship', CASE WHEN ctd.trade_balance > 0 THEN 'Favorable' ELSE 'Unfavorable' END,
                    'diplomatic_correlation', ROUND(dcd.diplomatic_correlation, 2),
                    'caravan_ids', ctd.caravan_ids
                )
            ))
            FROM civilization_trade_data ctd
            LEFT JOIN diplomatic_correlation_data dcd ON ctd.civilization_type = dcd.civilization_type
        ),

        'critical_import_dependencies', (
            SELECT JSON_OBJECT('resource_dependency', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'material_type', material_type,
                    'dependency_score', ROUND(dependency_score, 1),
                    'total_imported', total_imported,
                    'import_diversity', import_diversity,
                    'resource_ids', resource_ids
                )
            ))
            FROM import_dependency_data
        ),

        'export_effectiveness', (
             SELECT JSON_OBJECT('export_effectiveness', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'workshop_type', workshop_type,
                    'product_type', product_type,
                    'export_ratio', export_ratio,
                    'avg_markup', ROUND(avg_markup, 2),
                    'workshop_ids', workshop_ids
                )
            ))
            FROM export_effectiveness_data
        ),

        'trade_timeline', (
            SELECT JSON_OBJECT('trade_growth', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'year', year,
                    'quarter', quarter,
                    'quarterly_value', quarterly_value,
                    'quarterly_balance', quarterly_balance,
                    'trade_diversity', trade_diversity
                )
            ))
            FROM trade_timeline_data
        )
    ) AS trade_analysis_report;