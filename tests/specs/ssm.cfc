component extends=testbox.system.BaseSpec {

    variables.nextToken = ''

    function beforeAll() {
        AWS_ACCESS_KEY_ID = 'public_key'
        AWS_SECRET_ACCESS_KEY = 'private_key'

        TEST_PREFIX = '/testbox/' & createUUID()
        TEST_PARAM1 = '#TEST_PREFIX#/test1'
        TEST_PARAM2 = '#TEST_PREFIX#/test2'
        TEST_PARAM3 = '#TEST_PREFIX#/test3'

        ssm = new aws( AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, 'ap-southeast-2' ).ssm;
    }

    function afterAll() {
        // This function cleans up the parameters
        ssm.deleteParameter( TEST_PARAM1 )
        ssm.deleteParameter( TEST_PARAM2 )
        ssm.deleteParameter( TEST_PARAM3 )
    }

    function run() {
        // This is going to be run first, so we can use these parameters during testing
        describe( 'The putParameter function', function() {
            it( 'puts a String parameter', function() {
                var testCase = ssm.putParameter(
                    TEST_PARAM1,
                    'test1',
                    'Testing AWS-CFML',
                    'String'
                )
                // debug( testCase )
                expect( testCase.data ).toBeStruct().toHaveKey( 'Tier' )
                expect( testCase.data.version ).toBeNumeric().toBe( 1 )
            } )

            it( 'puts a SecureString parameter', function() {
                var testCase = ssm.putParameter(
                    TEST_PARAM2,
                    'test2',
                    'Testing AWS-CFML',
                    'SecureString'
                )
                // debug( testCase )
                expect( testCase.data ).toBeStruct().toHaveKey( 'Tier' )
                expect( testCase.data.version ).toBeNumeric().toBe( 1 )
            } )

            it( 'puts a StringList parameter', function() {
                var testCase = ssm.putParameter(
                    TEST_PARAM3,
                    'test3,test3,test3',
                    'Testing AWS-CFML',
                    'StringList'
                )
                // debug( testCase )
                expect( testCase.data ).toBeStruct().toHaveKey( 'Tier' )
                expect( testCase.data.version ).toBeNumeric().toBe( 1 )
                
            } )
        } )

        describe( 'The getParameter function', function() {
            it( 'gets a String parameters information', function() {
                var testCase = ssm.getParameter( TEST_PARAM1 )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.Parameter.value ).toBeString().toBe( 'test1' )
            } )

            it( 'gets a SecureString parameters information (decrypted)', function() {
                var testCase = ssm.getParameter( TEST_PARAM2, true )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.Parameter.value ).toBeString().toBe( 'test2' )
            } )

            it( 'returns the correct response for a missing paramater', function() {
                var testCase = ssm.getParameter( '/a-missing-parameter/notfound' )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.__type ).toBeString().toBe( 'ParameterNotFound' )
                expect( testCase.statusCode ).toBeString().toBe( '400' )
            } )
        } )

        describe( 'The getParameters function', function() {
            it( 'gets multiple known parameters with decryption', function() {
                var testCase = ssm.getParameters( [ TEST_PARAM1, TEST_PARAM2 ], true )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.Parameters ).toBeArray()
                expect( testCase.data.Parameters[ 1 ].type ).toBe( 'String' )
                expect( testCase.data.Parameters[ 2 ].type ).toBe( 'SecureString' )
                expect( testCase.data.Parameters[ 1 ].value ).toBe( 'test1' )
                expect( testCase.data.Parameters[ 2 ].value ).toBe( 'test2' )
            } )
        } )

        describe( 'The getParametersByPath function', function() {
            it( 'gets a list of parameters by path with decryption', function() {
                var testCase = ssm.getParametersByPath( TEST_PREFIX, true )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.Parameters ).toBeArray().toHaveLength(3)
                expect( testCase.data.Parameters[ 1 ].type ).toBe( 'String' )
                expect( testCase.data.Parameters[ 2 ].type ).toBe( 'SecureString' )
                expect( testCase.data.Parameters[ 1 ].value ).toBe( 'test1' )
                expect( testCase.data.Parameters[ 2 ].value ).toBe( 'test2' )
            } )

            it( 'gets a list of parameters by path with decryption max params =1', function() {
                var testCase = ssm.getParametersByPath( Path=TEST_PREFIX, WithDecryption=true, MaxResults=1  )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data ).toBeStruct().toHaveKey( 'NextToken' )
                expect( testCase.data.Parameters ).toBeArray().toHaveLength(1)

                // Set the component variable so we can use it to retreive the set in the next test
                variables.nextToken = testCase.data.nextToken
            } )

            it( 'gets the next set of parameters when specifying a token', function() {
                var testCase = ssm.getParametersByPath( Path=TEST_PREFIX, WithDecryption=true, MaxResults=1, NextToken=variables.nextToken  )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data ).toBeStruct().toHaveKey( 'NextToken' )
                expect( testCase.data.Parameters ).toBeArray().toHaveLength(1)

                // Set the component variable so we can use it to retreive the set in the next test
                variables.nextToken = testCase.data.nextToken
            } )

            it( 'gets the last set of parameters when specifying a token', function() {
                var testCase = ssm.getParametersByPath( Path=TEST_PREFIX, WithDecryption=true, MaxResults=1, NextToken=variables.nextToken  )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data ).toBeStruct().notToHaveKey( 'NextToken' )
                expect( testCase.data.Parameters ).toBeArray().toHaveLength(1)
            } )

            it( 'can use a filter to retreive parameters', function() {
                var filter =  [{
                    "Key": "Type",
                    "Option": "Equals",
                    "Values": ["SecureString"]
                }]
                var testCase = ssm.getParametersByPath( Path=TEST_PREFIX, WithDecryption=true, MaxResults=1, ParameterFilters=filter  )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.data.Parameters ).toBeArray().toHaveLength(1)
                expect( testCase.data.Parameters[ 1 ].type ).toBe( 'SecureString' )
                expect( testCase.data.Parameters[ 1 ].value ).toBe( 'test2' )
            } )

        } )

        describe( 'The deleteParameter function', function() {
            it( 'removes a parameter from the store', function() {
                var testCase = ssm.deleteParameter( TEST_PARAM1 )
                // debug( testCase )
                expect( testCase ).toBeStruct().toHaveKey( 'data' )
                expect( testCase.statusCode ).toBeString().toBe( '200' )
            } )
        } )
    }

}
