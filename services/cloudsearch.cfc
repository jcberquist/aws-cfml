component {

    variables.service = 'cloudsearch';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.searchEndpoint = arguments.settings.searchEndpoint;
        variables.docEndpoint = arguments.settings.docEndpoint;
        return this;
    }

    /**
    * Search the CloudSearch domain.
    * https://docs.aws.amazon.com/cloudsearch/latest/developerguide/searching.html
    * @q The search criteria for the request.
    * @queryParser The query parser to use: simple, structured, lucene, dismax.
    * @filterQuery A structured query expression that filters results without affecting scoring (fq parameter).
    * @sort A comma-separated list of fields to sort by, e.g. '_score desc,year asc'.
    * @start The zero-based offset of the first search hit to return.
    * @size The maximum number of search hits to return. Pass 0 to use the API default (10).
    * @returnFields Fields and expressions to include in the response. Corresponds to the 'return' API parameter.
    * @highlight JSON-encoded highlight options, e.g. {"body":{"format":"text","max_phrases":1,"pre_tag":"<mark>","post_tag":"</mark>"}}.
    * @queryOptions JSON-encoded options for the query parser (q.options parameter).
    */
    public any function search(
        required string q,
        string queryParser = 'simple',
        string filterQuery = '',
        string sort = '',
        numeric start = 0,
        numeric size = 0,
        string returnFields = '',
        string highlight = '',
        string queryOptions = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'q': arguments.q, 'q.parser': arguments.queryParser };
        if ( len( arguments.filterQuery ) ) queryParams[ 'fq' ] = arguments.filterQuery;
        if ( len( arguments.sort ) ) queryParams[ 'sort' ] = arguments.sort;
        if ( arguments.start > 0 ) queryParams[ 'start' ] = arguments.start;
        if ( arguments.size > 0 ) queryParams[ 'size' ] = arguments.size;
        if ( len( arguments.returnFields ) ) queryParams[ 'return' ] = arguments.returnFields;
        if ( len( arguments.highlight ) ) queryParams[ 'highlight' ] = arguments.highlight;
        if ( len( arguments.queryOptions ) ) queryParams[ 'q.options' ] = arguments.queryOptions;
        return apiCall( requestSettings, 'GET', '/2013-01-01/search', queryParams, { }, '', variables.searchEndpoint );
    }

    /**
    * Post a batch of documents to the CloudSearch domain for indexing.
    * https://docs.aws.amazon.com/cloudsearch/latest/developerguide/document-service-requests.html
    * @documents An array of document structs. Each struct requires 'type' (add/delete) and 'id'.
    *   Add operations also require a 'fields' struct. Delete operations require only 'id'.
    */
    public any function uploadDocuments(
        required array documents
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var headers = { 'Content-Type': 'application/json' };
        return apiCall(
            requestSettings,
            'POST',
            '/2013-01-01/documents/batch',
            { },
            headers,
            serializeJSON( arguments.documents ),
            variables.docEndpoint
        );
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = '',
        required string endpoint
    ) {
        var result = api.call(
            variables.service,
            arguments.endpoint,
            requestSettings.region,
            arguments.httpMethod,
            arguments.path,
            arguments.queryParams,
            arguments.headers,
            arguments.payload,
            requestSettings.awsCredentials
        );
        if ( result.keyExists( 'rawData' ) && isJSON( result.rawData ) ) {
            result[ 'data' ] = deserializeJSON( result.rawData );
        }
        return result;
    }

}
