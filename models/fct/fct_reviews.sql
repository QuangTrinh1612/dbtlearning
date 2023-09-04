{{
    config(
        materialized = 'incremental',
        on_schema_change = 'fail'
    )
}}
WITH src_reviews AS (
    SELECT * FROM {{ ref('src_reviews') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['listing_id','review_date','reviewer_name','review_text','review_sentiment']) }} AS REVIEW_ID,
    *
FROM
    src_reviews
WHERE
    review_text IS NOT NULL
    {% if is_incremental() %}
        AND REVIEW_DATE > (SELECT MAX(REVIEW_DATE) FROM {{ this }})
    {% endif %}