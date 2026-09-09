with source as (

    select * from {{ source('chinook_raw', 'genres') }}

),

renamed as (

    select
        GenreId as genre_id,
        Name as genre_name

    from source

)

select * from renamed
