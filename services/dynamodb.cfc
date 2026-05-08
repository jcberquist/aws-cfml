component {

    variables.service = 'dynamodb';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        variables.argumentTypes = getArgTypes();
        variables.argumentKeys = variables.argumentTypes.keyArray();
        variables.platform = server.keyExists( 'lucee' ) ? 'Lucee' : 'ColdFusion';
        return this;
    }

    /**
    * Returns an array of table names associated with the current account and endpoint. The output from ListTables is paginated, with each page returning a maximum of 100 table names.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html
    * @ExclusiveStartTableName The first table name that this operation will evaluate. Use the value that was returned for LastEvaluatedTableName in a previous operation, so that you can obtain the next page of results.
    * @Limit A maximum number of table names to return. If this parameter is not specified, the limit is 100.
    */
    public any function listTables(
        string ExclusiveStartTableName = '',
        numeric Limit = 0
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'ListTables', payload );
    }

    /**
    * The CreateTable operation adds a new table to your account.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html
    * @AttributeDefinitions An array of attributes that describe the key schema for the table and indexes.
    * @KeySchema Specifies the attributes that make up the primary key for a table or an index. The attributes in KeySchema must also be defined in the AttributeDefinitions array.
    * @ProvisionedThroughput Represents the provisioned throughput settings for a specified table or index. The settings can be modified using the UpdateTable operation. Required keys are: ReadCapacityUnits, WriteCapacityUnits
    * @TableName The name of the table to create.
    * @GlobalSecondaryIndexes One or more global secondary indexes (the maximum is five) to be created on the table. Each global secondary index in the array includes the following: IndexName, KeySchema, Projection (sub keys include ProjectionType [KEYS_ONLY | INCLUDE | ALL], NonKeyAttributes), ProvisionedThroughput
    * @LocalSecondaryIndexes One or more local secondary indexes (the maximum is five) to be created on the table. Each index is scoped to a given hash attribute value. Each local secondary index in the array includes the following: IndexName, KeySchema, Projection (sub keys include ProjectionType [KEYS_ONLY | INCLUDE | ALL], NonKeyAttributes)
    * @StreamSpecification The settings for DynamoDB Streams on the table. These settings consist of: StreamEnabled, StreamViewType (KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES)
    */
    public any function createTable(
        required array AttributeDefinitions,
        required array KeySchema,
        required struct ProvisionedThroughput,
        required string TableName,
        array GlobalSecondaryIndexes = [ ],
        array LocalSecondaryIndexes = [ ],
        struct StreamSpecification = { }
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'CreateTable', payload );
    }

    /**
    * Returns information about the table, including the current status of the table, when it was created, the primary key schema, and any indexes on the table.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html
    * @TableName The name of the table to describe.
    */
    public any function describeTable(
        required string TableName
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'DescribeTable', payload );
        return apiResponse;
    }

    /**
    * Modifies the provisioned throughput settings, global secondary indexes, or DynamoDB Streams settings for a given table.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html
    * @TableName The name of the table to be updated.
    * @AttributeDefinitions An array of attributes that describe the key schema for the table and indexes. If you are adding a new global secondary index to the table, AttributeDefinitions must include the key element(s) of the new index.
    * @GlobalSecondaryIndexUpdates An array of one or more global secondary indexes for the table. For each index in the array, you can request one action (Create, Delete, Update)
    * @ProvisionedThroughput Represents the provisioned throughput settings for a specified table or index. The settings can be modified using the UpdateTable operation. Required keys are: ReadCapacityUnits, WriteCapacityUnits
    * @StreamSpecification Represents the DynamoDB Streams configuration for the table. These settings consist of: StreamEnabled, StreamViewType (KEYS_ONLY | NEW_IMAGE | OLD_IMAGE | NEW_AND_OLD_IMAGES)
    */
    public any function updateTable(
        required string TableName,
        array AttributeDefinitions = [ ],
        array GlobalSecondaryIndexUpdates = [ ],
        struct ProvisionedThroughput = { },
        struct StreamSpecification = { }
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'UpdateTable', payload );
    }

    /**
    * The DeleteTable operation deletes a table and all of its items. After a DeleteTable request, the specified table is in the DELETING state until DynamoDB completes the deletion.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html
    * @TableName The name of the table to delete.
    */
    public any function deleteTable(
        required string TableName
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'DeleteTable', payload );
        return apiResponse;
    }

    /**
    * Creates a new item, or replaces an old item with a new item. If an item that has the same primary key as the new item already exists in the specified table, the new item completely replaces the existing item.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html
    * @TableName The name of the table to contain the item.
    * @Item A map of attribute name/value pairs, one for each attribute. Only the primary key attributes are required; you can optionally provide other attribute name-value pairs for the item.
    * @ConditionExpression A condition that must be satisfied in order for a conditional PutItem operation to succeed. https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.SpecifyingConditions.html
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @ExpressionAttributeValues One or more values that can be substituted in an expression.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @ReturnItemCollectionMetrics Determines whether item collection metrics are returned: (SIZE | NONE)
    * @ReturnValues Use ReturnValues if you want to get the item attributes as they appeared before they were updated with the PutItem request: (NONE | ALL_OLD)
    */
    public any function putItem(
        required string TableName,
        required struct Item,
        string ConditionExpression = '',
        struct ExpressionAttributeNames = { },
        struct ExpressionAttributeValues = { },
        string ReturnConsumedCapacity = '',
        string ReturnItemCollectionMetrics = '',
        string ReturnValues = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'PutItem', payload );
        return apiResponse;
    }

    /**
    * The GetItem operation returns a set of attributes for the item with the given primary key. If there is no matching item, GetItem does not return any data.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html
    * @TableName The name of the table containing the requested item.
    * @Key A map of attribute names to AttributeValue objects, representing the primary key of the item to retrieve.
    * @ConsistentRead Determines the read consistency model: If set to true, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads.
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @ProjectionExpression A string that identifies one or more attributes to retrieve from the table.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    */
    public any function getItem(
        required string TableName,
        required struct Key,
        boolean ConsistentRead = false,
        struct ExpressionAttributeNames = { },
        string ProjectionExpression = '',
        string ReturnConsumedCapacity = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'GetItem', payload );
        if ( apiResponse.data.keyExists( 'item' ) ) {
            apiResponse.data.item = decodeValues( apiResponse.data.item );
        }
        return apiResponse;
    }

    /**
    * Edits an existing item's attributes, or adds a new item to the table if it does not already exist. You can put, delete, or add attribute values.
    * You can also perform a conditional update on an existing item (insert a new attribute name-value pair if it doesn't exist, or replace an existing name-value pair if it has certain expected attribute values).
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html
    * @TableName The name of the table containing the item to update.
    * @Key The primary key of the item to be updated. Each element consists of an attribute name and a value for that attribute.
    * @ConditionExpression A condition that must be satisfied in order for a conditional update to succeed.
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @ExpressionAttributeValues One or more values that can be substituted in an expression.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @ReturnItemCollectionMetrics Determines whether item collection metrics are returned: (SIZE | NONE)
    * @ReturnValues Use ReturnValues if you want to get the item attributes as they appeared either before or after they were updated: (NONE | ALL_OLD | UPDATED_OLD | ALL_NEW | UPDATED_NEW)
    * @UpdateExpression An expression that defines one or more attributes to be updated, the action to be performed on them, and new value(s) for them.
    */
    public any function updateItem(
        required string TableName,
        required struct Key,
        string ConditionExpression = '',
        struct ExpressionAttributeNames = { },
        struct ExpressionAttributeValues = { },
        string ReturnConsumedCapacity = '',
        string ReturnItemCollectionMetrics = '',
        string ReturnValues = '',
        string UpdateExpression = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        var apiResponse = apiCall( requestSettings, 'UpdateItem', payload );
        if ( apiResponse.data.keyExists( 'Attributes' ) ) {
            apiResponse.data.Attributes = decodeValues( apiResponse.data.Attributes );
        }
        return apiResponse;
    }

    /**
    * The DeleteItem operation deletes a single item in a table by primary key.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html
    * @TableName The name of the table from which to delete the item.
    * @Key A map of attribute names to AttributeValue objects, representing the primary key of the item to delete.
    * @ConditionExpression A condition that must be satisfied in order for a conditional DeleteItem to succeed.
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @ExpressionAttributeValues One or more values that can be substituted in an expression.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @ReturnItemCollectionMetrics Determines whether item collection metrics are returned: (SIZE | NONE)
    * @ReturnValues Use ReturnValues if you want to get the item attributes as they appeared before they were deleted: (NONE | ALL_OLD)
    */
    public any function deleteItem(
        required string TableName,
        required struct Key,
        string ConditionExpression = '',
        struct ExpressionAttributeNames = { },
        struct ExpressionAttributeValues = { },
        string ReturnConsumedCapacity = '',
        string ReturnItemCollectionMetrics = '',
        string ReturnValues = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'DeleteItem', payload );
        if ( apiResponse.data.keyExists( 'Attributes' ) ) {
            apiResponse.data.Attributes = decodeValues( apiResponse.data.Attributes );
        }
        return apiResponse;
    }

    /**
    * The BatchGetItem operation returns the attributes of one or more items from one or more tables. You identify requested items by primary key.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html
    * @RequestItems A map of one or more table names and, for each table, a map that describes one or more items to retrieve from that table. Each table name can be used only once per BatchGetItem request.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    */
    public any function batchGetItem(
        required struct RequestItems,
        string ReturnConsumedCapacity = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        // encode keys
        if ( !arguments.keyExists( 'dataTypeEncoding' ) || !arguments.dataTypeEncoding ) {
            var typeDefinitions = arguments.keyExists( 'typeDefinitions' ) ? arguments.typeDefinitions : { };
            payload[ 'RequestItems' ] = structMap( payload.RequestItems, function( TableName, args ) {
                args[ 'Keys' ] = args.Keys.map( function( key ) {
                    return encodeValues( key, typeDefinitions );
                } );
                return args;
            } );
        }

        var apiResponse = apiCall( requestSettings, 'BatchGetItem', payload );

        if ( apiResponse.data.keyExists( 'Responses' ) ) {
            for ( var TableName in apiResponse.data.Responses ) {
                apiResponse.data.Responses[ TableName ] = apiResponse.data.Responses[ TableName ].map( decodeValues );
            }
        }
        if ( apiResponse.data.keyExists( 'UnprocessedKeys' ) ) {
            for ( var TableName in apiResponse.data.UnprocessedKeys ) {
                apiResponse.data.UnprocessedKeys[ TableName ][ 'Keys' ] = apiResponse.data.UnprocessedKeys[ TableName ].Keys.map(
                    decodeValues
                );
            }
        }

        return apiResponse;
    }

    /**
    * The BatchWriteItem operation puts or deletes multiple items in one or more tables. A single call to BatchWriteItem can write up to 16 MB of data, which can comprise as many as 25 put or delete requests.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html
    * @RequestItems A map of one or more table names and, for each table, a map that describes one or more items to retrieve from that table. Each table name can be used only once per BatchGetItem request.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @ReturnItemCollectionMetrics Determines whether item collection metrics are returned: (SIZE | NONE)
    */
    public any function batchWriteItem(
        required struct RequestItems,
        string ReturnConsumedCapacity = '',
        string ReturnItemCollectionMetrics = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        // encode keys and items
        if ( !arguments.keyExists( 'dataTypeEncoding' ) || !arguments.dataTypeEncoding ) {
            var typeDefinitions = arguments.keyExists( 'typeDefinitions' ) ? arguments.typeDefinitions : { };
            payload[ 'RequestItems' ] = structMap( payload.RequestItems, function( TableName, requestItem ) {
                if ( requestItem.keyExists( 'DeleteRequest' ) ) {
                    requestItem.DeleteRequest[ 'Key' ] = encodeValues(
                        requestItem.DeleteRequest[ 'Key' ],
                        typeDefinitions
                    );
                }
                if ( requestItem.keyExists( 'PutRequest' ) ) {
                    requestItem.PutRequest[ 'Item' ] = encodeValues( requestItem.PutRequest[ 'Item' ], typeDefinitions );
                }
                return requestItem;
            } );
        }

        var apiResponse = apiCall( requestSettings, 'BatchWriteItem', payload );
        return apiResponse;
    }

    /**
    * A Query operation uses the primary key of a table or a secondary index to directly access items from that table or index.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html
    * @TableName The name of the table containing the requested items.
    * @KeyConditionExpression The condition that specifies the key value(s) for items to be retrieved by the Query action.
    * @ExpressionAttributeValues One or more values that can be substituted in an expression.
    * @ConsistentRead Determines the read consistency model: If set to true, then the operation uses strongly consistent reads; otherwise, the operation uses eventually consistent reads.
    * @ExclusiveStartKey The primary key of the first item that this operation will evaluate. Use the value that was returned for LastEvaluatedKey in the previous operation.
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @FilterExpression A string that contains conditions that DynamoDB applies after the Query operation, but before the data is returned to you.
    * @IndexName The name of an index to query. This index can be any local secondary index or global secondary index on the table.
    * @Limit The maximum number of items to evaluate (not necessarily the number of matching items).
    * @ProjectionExpression A string that identifies one or more attributes to retrieve from the table.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @ScanIndexForward Specifies the order for index traversal: If true (default), the traversal is performed in ascending order; if false, the traversal is performed in descending order.
    * @Select The attributes to be returned in the result: (ALL_ATTRIBUTES | ALL_PROJECTED_ATTRIBUTES | SPECIFIC_ATTRIBUTES | COUNT)
    */
    public any function query(
        required string TableName,
        required string KeyConditionExpression,
        required struct ExpressionAttributeValues,
        boolean ConsistentRead = false,
        struct ExclusiveStartKey = { },
        struct ExpressionAttributeNames = { },
        string FilterExpression = '',
        string IndexName = '',
        numeric Limit = 0,
        string ProjectionExpression = '',
        string ReturnConsumedCapacity = '',
        boolean ScanIndexForward = false,
        string Select = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'Query', payload );
        if ( apiResponse.data.keyExists( 'Items' ) ) {
            apiResponse.data.Items = arrayMap( apiResponse.data.Items, decodeValues );
        }
        if ( apiResponse.data.keyExists( 'LastEvaluatedKey' ) ) {
            apiResponse.data.LastEvaluatedKey = decodeValues( apiResponse.data.LastEvaluatedKey );
        }
        return apiResponse;
    }

    /**
    * The Scan operation returns one or more items and item attributes by accessing every item in a table or a secondary index.
    * To have DynamoDB return fewer items, you can provide a ScanFilter operation.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html
    * @TableName The name of the table containing the requested items.
    * @ConsistentRead A Boolean value that determines the read consistency model during the scan.
    * @ExclusiveStartKey The primary key of the first item that this operation will evaluate. Use the value that was returned for LastEvaluatedKey in the previous operation.
    * @ExpressionAttributeNames One or more substitution tokens for attribute names in an expression.
    * @ExpressionAttributeValues One or more values that can be substituted in an expression.
    * @FilterExpression A string that contains conditions that DynamoDB applies after the Scan operation, but before the data is returned to you.
    * @IndexName The name of a secondary index to scan. This index can be any local secondary index or global secondary index.
    * @Limit The maximum number of items to evaluate (not necessarily the number of matching items).
    * @ProjectionExpression A string that identifies one or more attributes to retrieve from the specified table or index.
    * @ReturnConsumedCapacity Determines the level of detail about provisioned throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    * @Segment For a parallel Scan request, Segment identifies an individual segment (zero-based) to be scanned by an application worker.
    * @Select The attributes to be returned in the result: (ALL_ATTRIBUTES | COUNT | SPECIFIC_ATTRIBUTES)
    * @TotalSegments For a parallel Scan request, TotalSegments represents the total number of segments into which the Scan operation will be divided. The value of TotalSegments corresponds to the number of application workers that will perform the parallel scan.
    */
    public any function scan(
        required string TableName,
        boolean ConsistentRead = false,
        struct ExclusiveStartKey = { },
        struct ExpressionAttributeNames = { },
        struct ExpressionAttributeValues = { },
        string FilterExpression = '',
        string IndexName = '',
        numeric Limit = 0,
        string ProjectionExpression = '',
        string ReturnConsumedCapacity = '',
        numeric Segment = 0,
        string Select = '',
        numeric TotalSegments = 0
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        // special handing for segments since they are zero based
        if ( arguments[ 'TotalSegments' ] ) {
            payload[ 'Segment' ] = arguments[ 'Segment' ];
        }

        var apiResponse = apiCall( requestSettings, 'Scan', payload );
        if ( apiResponse.data.keyExists( 'Items' ) ) {
            apiResponse.data.Items = arrayMap( apiResponse.data.Items, decodeValues );
        }
        if ( apiResponse.data.keyExists( 'LastEvaluatedKey' ) ) {
            apiResponse.data.LastEvaluatedKey = decodeValues( apiResponse.data.LastEvaluatedKey );
        }
        return apiResponse;
    }

    /**
    * This operation allows you to perform batch reads or writes on data stored in DynamoDB, using PartiQL.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchExecuteStatement.html
    * @Statements The list of PartiQL statements representing the batch to run.
    * @ReturnConsumedCapacity Determines the level of detail about either provisioned or on-demand throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    */
    public any function batchExecuteStatement(
        required array Statements = [ ],
        string ReturnConsumedCapacity = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        payload[ 'Statements' ] = arrayMap( arguments.Statements, function( batchStatementRequest ) {
            return buildPayload( batchStatementRequest );
        } );

        var apiResponse = apiCall( requestSettings, 'BatchExecuteStatement', payload );

        if ( apiResponse.data.keyExists( 'Responses' ) ) {
            apiResponse.data.Responses = arrayMap( apiResponse.data.Responses, function( response ) {
                if ( structKeyExists( response, 'Item' ) ) {
                    response.Item = decodeValues( response.Item );
                }
                return response;
            } );
        }

        return apiResponse;
    }

    /**
    * This operation allows you to perform reads and singleton writes on data stored in DynamoDB, using PartiQL.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ExecuteStatement.html
    * @Statement The PartiQL statement representing the operation to run.
    * @Parameters The parameters for the PartiQL statement, if any.
    * @ConsistentRead The consistency of a read operation. If set to true, then a strongly consistent read is used; otherwise, an eventually consistent read is used.
    * @NextToken Set this value to get remaining results, if NextToken was returned in the statement response.
    * @ReturnConsumedCapacity Determines the level of detail about either provisioned or on-demand throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    */
    public any function executeStatement(
        required string Statement = '',
        array Parameters = [ ],
        boolean ConsistentRead = false,
        string NextToken = '',
        string ReturnConsumedCapacity = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, 'ExecuteStatement', payload );

        if ( apiResponse.data.keyExists( 'Items' ) ) {
            apiResponse.data.Items = arrayMap( apiResponse.data.Items, decodeValues );
        }

        return apiResponse;
    }

    /**
    * This operation allows you to perform transactional reads or writes on data stored in DynamoDB, using PartiQL.
    * https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ExecuteTransaction.html
    * @TransactStatements The list of PartiQL statements representing the transaction to run.
    * @ClientRequestToken Set this value to get remaining results, if NextToken was returned in the statement response.
    * @ReturnConsumedCapacity Determines the level of detail about either provisioned or on-demand throughput consumption that is returned in the response: (INDEXES | TOTAL | NONE)
    */
    public any function executeTransaction(
        required array TransactStatements = [ ],
        string ClientRequestToken = '',
        string ReturnConsumedCapacity = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );

        payload[ 'TransactStatements' ] = arrayMap( arguments.TransactStatements, function( parameterizedStatement ) {
            return buildPayload( parameterizedStatement );
        } );

        var apiResponse = apiCall( requestSettings, 'ExecuteTransaction', payload );

        if ( apiResponse.data.keyExists( 'Responses' ) ) {
            apiResponse.data.Responses = arrayMap( apiResponse.data.Responses, function( response ) {
                if ( structKeyExists( response, 'Item' ) ) {
                    response.Item = decodeValues( response.Item );
                }
                return response;
            } );
        }

        return apiResponse;
    }

    public any function encodeValues(
        required any data,
        struct typeDefinitions = { }
    ) {
        if ( isStruct( data ) ) {
            return structMap( data, function( key, value ) {
                if ( isNull( value ) ) return { 'NULL': 'true' };
                return encodeAttributeValue(
                    value,
                    typeDefinitions.keyExists( key ) ? typeDefinitions[ key ] : determineValueType( value ),
                    typeDefinitions
                );
            } );
        }

        if ( isArray( data ) ) {
            return arrayMap( data, function( value ) {
                if ( isNull( value ) ) return { 'NULL': 'true' };
                return encodeAttributeValue( value, determineValueType( value ), typeDefinitions );
            } );
        }

        throw( 'encodeValues can only be used on structs and arrays.' );
    }

    public struct function decodeValues(
        required struct data
    ) {
        return structMap( data, function( key, attribute_value ) {
            return decodeAttributeValue( attribute_value );
        } );
    }

    // private methods

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';
        var payloadString = toJSON( payload );

        var headers = { };
        headers[ 'X-Amz-Target' ] = 'DynamoDB_' & variables.apiVersion & '.' & arguments.target;
        headers[ 'Content-Type' ] = 'application/x-amz-json-1.0';

        var apiResponse = api.call(
            variables.service,
            host,
            requestSettings.region,
            'POST',
            '/',
            { },
            headers,
            payloadString,
            requestSettings.awsCredentials
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

    private string function toJSON(
        required struct source
    ) {
        var json = serializeJSON( source );
        // clean up ColdFusion serialization
        if ( variables.platform == 'ColdFusion' ) {
            json = reReplace(
                json,
                '\{"([NS])":([^\}"]+)\}',
                '{"\1":"\2"}',
                'all'
            );
            json = reReplace(
                json,
                '\{"BOOL":(true|false)\}',
                '{"BOOL":"\1"}',
                'all'
            );
            json = replace( json, '{"NULL":true}', '{"NULL":"true"}' );
        }
        return json;
    }

    private any function buildPayload(
        required any args
    ) {
        var payload = { };
        for ( var key in args ) {
            var keyIndex = variables.argumentKeys.findNoCase( key );
            if ( !keyIndex ) continue;
            var argType = variables.argumentTypes[ key ];
            var casedKey = variables.argumentKeys[ keyIndex ];
            switch ( argType ) {
                case 'array':
                case 'string':
                    if ( args[ key ].len() ) payload[ casedKey ] = args[ key ];
                    break;
                case 'boolean':
                case 'numeric':
                    if ( args[ key ] ) payload[ casedKey ] = args[ key ];
                    break;
                case 'struct':
                    if ( !args[ key ].isEmpty() ) payload[ casedKey ] = args[ key ];
                    break;
                case 'typed':
                    if ( !args[ key ].isEmpty() ) {
                        if ( args.keyExists( 'dataTypeEncoding' ) && !args.dataTypeEncoding ) {
                            payload[ casedKey ] = args[ key ];
                        } else {
                            payload[ casedKey ] = encodeValues(
                                args[ key ],
                                args.keyExists( 'typeDefinitions' ) ? args.typeDefinitions : { }
                            );
                        }
                    }
                    break;
            }
        }
        return payload;
    }

    private struct function getArgTypes() {
        var metadata = getMetadata( this );
        var typed = [
            'ExclusiveStartKey',
            'ExpressionAttributeValues',
            'Item',
            'Key',
            'Parameters'
        ];
        var result = { };

        for ( var funct in metadata.functions ) {
            if ( arrayFindNoCase( [ 'init', 'encodeValues', 'decodeValues' ], funct.name ) || funct.access != 'public' )
                continue;
            for ( var param in funct.parameters ) {
                result[ param.name ] = typed.findNoCase( param.name ) ? 'typed' : param.type;
            }
        }

        return result;
    }

    private struct function encodeAttributeValue(
        required any data,
        string typeDefinition = 'S',
        struct typeDefinitions = { }
    ) {
        switch ( typeDefinition ) {
            case 'NULL':
                return { 'NULL': 'true' };
            case 'N':
                return { 'N': toString( data ) };
            case 'B':
                return { 'B': binaryEncode( data, 'base64' ) };
            case 'BOOL':
                return { 'BOOL': data ? 'true' : 'false' };
            case 'SS':
                return {
                    'SS': data.map( function( item ) {
                        return toString( item );
                    } )
                };
            case 'NS':
                return {
                    'NS': data.map( function( item ) {
                        return toString( item );
                    } )
                };
            case 'BS':
                return {
                    'BS': data.map( function( item ) {
                        return binaryEncode( item, 'base64' );
                    } )
                };
            case 'L':
                return {
                    'L': data.map( function( item ) {
                        return encodeAttributeValue( item, determineValueType( item ), typeDefinitions );
                    } )
                };
            case 'M':
                return { 'M': encodeValues( data, typeDefinitions ) };
        }
        return { 'S': toString( data ) };
    }

    private string function determineValueType(
        any valueToType
    ) {
        if ( isNull( valueToType ) ) return 'NULL';
        if ( isArray( valueToType ) ) return 'L';
        if ( isStruct( valueToType ) ) return 'M';
        if ( isBinary( valueToType ) ) return 'B';

        // only simple values left
        if ( !isSimpleValue( valueToType ) ) throw( 'dynamodb.cfc: cannot determine type of variable' );

        if ( isNumeric( valueToType ) ) return 'N';
        if ( isBoolean( valueToType ) ) return 'BOOL';

        // default is string
        return 'S';
    }

    private any function decodeAttributeValue(
        required struct attribute_value
    ) {
        var typeDefinition = attribute_value.keyArray()[ 1 ];
        switch ( typeDefinition ) {
            case 'NULL':
                return javacast( 'NULL', '' );
            case 'N':
                return val( attribute_value[ typeDefinition ] );
            case 'BOOL':
                return attribute_value[ typeDefinition ];
            case 'SS':
                return attribute_value[ typeDefinition ];
            case 'NS':
                return attribute_value[ typeDefinition ].map( function( numeric_item ) {
                    return val( numeric_item );
                } );
            case 'L':
                return attribute_value[ typeDefinition ].map( decodeAttributeValue );
            case 'M':
                return structMap( attribute_value[ typeDefinition ], function( key, attribute_value ) {
                    return decodeAttributeValue( attribute_value );
                } );
        }
        return attribute_value[ typeDefinition ];
    }

}
