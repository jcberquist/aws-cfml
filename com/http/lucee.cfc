component {

    public any function init(
        required any utils
    ) {
        variables.utils = utils;
        return this;
    }

    public any function makeHttpRequest(
        required string httpMethod,
        required string path,
        struct queryParams = { },
        struct headers = { },
        any body,
        boolean useSSL = true,
        numeric timeout = 50
    ) {
        var result = '';
        var fullPath = utils.encodeUrl( path, false ) & ( !queryParams.isEmpty() ? ( '?' & utils.parseQueryParams( queryParams ) ) : '' );
        var request_headers = utils.parseHeaders( headers );
        var urlPath = 'http' & (useSSL ? 's' : '') & '://' & fullPath;

        http url = urlPath method = httpMethod result = "result" encodeurl = false timeout = timeout {

            for ( var header in request_headers ) {
                if ( header.name == 'host' ) continue;
                httpparam type = "header" name = lcase( header.name ) value = header.value;
            }

            if ( arrayFindNoCase( [ 'POST','PUT' ], httpMethod ) && !isNull( arguments.body ) ) {
                httpparam type = "body" value = body;
            }

        }
        return result;
    }

}
