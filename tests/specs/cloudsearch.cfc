component extends=testbox.system.BaseSpec {

    function beforeAll() {
        variables.searchEndpoint = 'search-test.us-east-1.cloudsearch.amazonaws.com';
        variables.docEndpoint    = 'doc-test.us-east-1.cloudsearch.amazonaws.com';

        // Struct-based spy: no createMock(), no init() dependencies.
        // call() stores its positional args in variables.lastCall so tests can inspect them.
        variables.apiSpy = {
            resolveRequestSettings: function() {
                return { awsCredentials: { }, region: 'us-east-1' };
            },
            call: function() {
                variables.lastCall = arguments;
                return { statusCode: 200, rawData: '{}', responseHeaders: { }, responseTime: 0 };
            }
        };

        variables.cs = new services.cloudsearch( variables.apiSpy, {
            searchEndpoint: variables.searchEndpoint,
            docEndpoint: variables.docEndpoint
        } );
    }

    function setup() {
        variables.lastCall = { };
    }

    // Returns the positional args captured from the most recent api.call() invocation.
    // Indices match api.call() signature: 1=service, 2=host, 3=region, 4=httpMethod,
    // 5=path, 6=queryParams, 7=headers, 8=body, 9=awsCredentials
    private function callArgs() {
        return variables.lastCall;
    }

    function run() {

        describe( 'search()', function() {

            it( 'sends q and q.parser as required params', function() {
                variables.cs.search( q='hello', queryParser='lucene' );
                var params = callArgs()[ 6 ];
                expect( params[ 'q' ] ).toBe( 'hello' );
                expect( params[ 'q.parser' ] ).toBe( 'lucene' );
            } );

            it( 'omits optional params when not set', function() {
                variables.cs.search( q='test' );
                var params = callArgs()[ 6 ];
                expect( params ).notToHaveKey( 'fq' );
                expect( params ).notToHaveKey( 'sort' );
                expect( params ).notToHaveKey( 'start' );
                expect( params ).notToHaveKey( 'size' );
                expect( params ).notToHaveKey( 'return' );
                expect( params ).notToHaveKey( 'highlight' );
                expect( params ).notToHaveKey( 'q.options' );
            } );

            it( 'maps returnFields to the return query param', function() {
                variables.cs.search( q='test', returnFields='title,body' );
                var params = callArgs()[ 6 ];
                expect( params ).toHaveKey( 'return' );
                expect( params[ 'return' ] ).toBe( 'title,body' );
                expect( params ).notToHaveKey( 'returnFields' );
            } );

            it( 'includes optional params when provided', function() {
                variables.cs.search(
                    q           = "(term field=body 'climate')",
                    queryParser = 'structured',
                    filterQuery = "(term field=doc_type 'bill')",
                    sort        = '_score desc',
                    start       = 10,
                    size        = 25
                );
                var params = callArgs()[ 6 ];
                expect( params[ 'q.parser' ] ).toBe( 'structured' );
                expect( params[ 'fq' ] ).toBe( "(term field=doc_type 'bill')" );
                expect( params[ 'sort' ] ).toBe( '_score desc' );
                expect( params[ 'start' ] ).toBe( 10 );
                expect( params[ 'size' ] ).toBe( 25 );
            } );

            it( 'routes to the search endpoint', function() {
                variables.cs.search( q='test' );
                expect( callArgs()[ 2 ] ).toBe( variables.searchEndpoint );
            } );

            it( 'uses the cloudsearch SigV4 service name', function() {
                variables.cs.search( q='test' );
                expect( callArgs()[ 1 ] ).toBe( 'cloudsearch' );
            } );

        } );

        describe( 'uploadDocuments()', function() {

            it( 'routes to the doc endpoint', function() {
                variables.cs.uploadDocuments( documents=[ ] );
                expect( callArgs()[ 2 ] ).toBe( variables.docEndpoint );
            } );

            it( 'sends Content-Type application/json', function() {
                variables.cs.uploadDocuments( documents=[ ] );
                var headers = callArgs()[ 7 ];
                var ctKey = headers.keyArray().filter( function( k ) {
                    return k.lcase() == 'content-type';
                } );
                expect( ctKey.len() ).toBeGT( 0, 'Content-Type header missing' );
                expect( headers[ ctKey[ 1 ] ] ).toBe( 'application/json' );
            } );

            it( 'serializes the documents array as JSON', function() {
                var docs = [
                    { type: 'add', id: 'bill123', fields: { title: 'Test Bill', body: 'some text' } }
                ];
                variables.cs.uploadDocuments( documents=docs );
                var body = callArgs()[ 8 ];
                expect( isJSON( body ) ).toBeTrue();
                var parsed = deserializeJSON( body );
                expect( parsed[ 1 ][ 'type' ] ).toBe( 'add' );
                expect( parsed[ 1 ][ 'id' ] ).toBe( 'bill123' );
            } );

            it( 'handles delete operations in the batch', function() {
                var docs = [ { type: 'delete', id: 'bill123' } ];
                variables.cs.uploadDocuments( documents=docs );
                var parsed = deserializeJSON( callArgs()[ 8 ] );
                expect( parsed[ 1 ][ 'type' ] ).toBe( 'delete' );
                expect( parsed[ 1 ] ).notToHaveKey( 'fields' );
            } );

        } );

    }

}
