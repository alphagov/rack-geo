Rack::Geo
=========

Simple Rack middleware which processes incoming requests and adds, updates,
and passes through as a Header, Geo-location information

                                ______________
    GET / [no cookie]       -> | Geo IP       |
                               |              |
    POST / [known params]   -> | Geo lookup   |
                               |              | -> Geo Header
    GET / [with geo cookie] -> | Pass through |
                               |              |
                 Geo Cookie <- |              |
                                --------------
