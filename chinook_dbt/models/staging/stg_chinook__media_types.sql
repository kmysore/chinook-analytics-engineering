{{
    config(
        materialized='ephemeral'
    )
}}

-- Deliberately ephemeral (Session 2 exercise): media_types is a tiny lookup
-- (2 columns) only ever joined into stg_chinook__tracks / downstream track
-- models. It doesn't need to exist as its own view for anyone to query
-- directly, so we interpolate it as a CTE into whatever refs it instead of
-- paying for a persisted database object. Trade-off: it won't show up in
-- `dbt docs` as a queryable node in the warehouse, and if it were ever
-- ref'd from many models its logic would get compiled inline into each of
-- them rather than computed once — fine here because it has exactly one
-- consumer and near-zero logic.

with source as (

    select * from {{ source('chinook_raw', 'media_types') }}

),

renamed as (

    select
        MediaTypeId as media_type_id,
        Name as media_type_name

    from source

)

select * from renamed
