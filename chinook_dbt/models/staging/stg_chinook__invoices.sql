with source as (

    select * from {{ source('chinook_raw', 'invoices') }}

),

renamed as (

    select
        InvoiceId as invoice_id,
        CustomerId as customer_id,
        cast(InvoiceDate as date) as invoice_date,
        BillingAddress as billing_address,
        BillingCity as billing_city,
        -- same "---" null-placeholder pattern as employees.ReportsTo, found
        -- here independently (e.g. the Stuttgart invoice's BillingState) —
        -- not a one-off, so staging cleans it here rather than leaving it
        -- for a downstream test to catch
        nullif(BillingState, '---') as billing_state,
        BillingCountry as billing_country,
        BillingPostalCode as billing_postal_code,
        cast(Total as numeric) as total

    from source

)

select * from renamed
