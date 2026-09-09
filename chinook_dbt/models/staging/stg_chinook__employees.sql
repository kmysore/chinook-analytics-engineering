with source as (

    select * from {{ source('chinook_raw', 'employees') }}

),

renamed as (

    select
        EmployeeId as employee_id,
        FirstName as first_name,
        LastName as last_name,
        -- renamed from "Title" -> job_title to avoid colliding with
        -- albums.Title (album_title) in downstream mart joins
        Title as job_title,
        -- raw ReportsTo uses the literal string "---" as a null placeholder
        -- for the top-level manager (Andrew Adams, General Manager); BigQuery
        -- autodetect inferred this column as STRING because of that non-
        -- numeric value, so we nullif() then cast to int to restore it as a
        -- proper self-referencing FK to employee_id
        cast(nullif(ReportsTo, '---') as int64) as reports_to,
        BirthDate as birth_date,
        HireDate as hire_date,
        Address as address,
        City as city,
        State as state,
        Country as country,
        PostalCode as postal_code,
        Phone as phone,
        Fax as fax,
        Email as email

    from source

)

select * from renamed
