component {

    public any function init(
        required any utils,
        struct httpProxy = { server: '', port: 80 }
    ) {
        variables.utils = utils;
        variables.httpProxy = httpProxy;
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
        var fullPath = path & ( !queryParams.isEmpty() ? ( '?' & utils.parseQueryParams( queryParams ) ) : '' );
        var request_headers = utils.parseHeaders( headers );
        var urlPath = 'http' & ( useSSL ? 's' : '' ) & '://' & fullPath;

        // Only set proxy if proxyServer is specified (prevent empty proxy from routing through localhost)
        var actualProxyServer = len( trim( httpProxy.server ) ) ? httpProxy.server : "";
        var actualProxyPort = len( trim( httpProxy.server ) ) ? httpProxy.port : 0;

        cfhttp(
            url = urlPath,
            method = httpMethod,
            result = "result",
            timeout = timeout,
            proxyserver = actualProxyServer,
            proxyport = actualProxyPort
        ) {
            for ( var header in request_headers ) {
                if ( header.name == 'host' ) continue;
                cfhttpparam( type = "header", name = lCase( header.name ), value = header.value );
            }

            if ( arrayFindNoCase( [ 'POST', 'PUT' ], httpMethod ) && !isNull( arguments.body ) ) {
                cfhttpparam( type = "body", value = body );
            }
        }
        return result;
    }

}
