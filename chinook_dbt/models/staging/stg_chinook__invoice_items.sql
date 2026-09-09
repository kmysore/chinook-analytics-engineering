with source as (

    select * from {{ source('chinook_raw', 'invoice_items') }}

),

renamed as (

    select
        InvoiceLineId as invoice_line_id,
        InvoiceId as invoice_id,
        TrackId as track_id,
        cast(UnitPrice as numeric) as unit_price,
        Quantity as quantity

    from source

)

select * from renamed
