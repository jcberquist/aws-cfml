component extends=testbox.system.BaseSpec {

	function beforeAll() {

		dynamodb = new aws.aws( 'public_key', 'private_key' ).dynamodb;
		makePublic( dynamodb, 'toJSON' );

	}

	function run() {

		describe( "the toJSON() method", function() {

			it( "correctly serializes the number type", function() {

				var data = {'test_number':{'N':'123'}};
				var expected_json = '{"test_number":{"N":"123"}}';
				expect( dynamodb.toJSON( data ) ).toBe( expected_json );

			} );

			it( "correctly serializes the null type", function() {

				var data = {'test_null':{'NULL':'true'}};
				var expected_json = '{"test_null":{"NULL":"true"}}';
				expect( dynamodb.toJSON( data ) ).toBe( expected_json );

			} );

			it( "correctly serializes the boolean type", function() {

				var data = {'test_bool':{'BOOL':'false'}};
				var expected_json = '{"test_bool":{"BOOL":"false"}}';
				expect( dynamodb.toJSON( data ) ).toBe( expected_json );

			} );

		} );

	}

}
