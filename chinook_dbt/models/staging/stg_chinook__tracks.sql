with source as (

    select * from {{ source('chinook_raw', 'tracks') }}

),

renamed as (

    select
        TrackId as track_id,
        Name as track_name,
        AlbumId as album_id,
        MediaTypeId as media_type_id,
        GenreId as genre_id,
        Composer as composer,
        Milliseconds as milliseconds,
        Bytes as bytes,
        cast(UnitPrice as numeric) as unit_price

    from source

)

select * from renamed
