component {

    variables.service = 'sqs';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    public any function listQueues() {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            { 'Action': 'ListQueues' }
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Sends a message
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html
    * @queueName Required string. The name of the queue to send to (e.g. "123456789/my-sqs-queue").
    * @message Required string. The message to post, text format.
    * @delaySeconds Optional numeric. The length of time, in seconds, for which to delay a specific message.
    * Valid values: 0 to 900. Maximum: 15 minutes. Messages with a positive DelaySeconds value become available for
    * processing after the delay period is finished. If you don't specify a value, the default value for the queue applies.
    * Note: When you set FifoQueue, you can't set DelaySeconds per message. You can set this parameter only on a queue level.
    * @messageAttributes Optional array. An array of message attributes to be added to the message. Each array item must contain a structure
    * containing 3 keys: Name, Value, DataType. String and Number are supported DataType values.
    * Example: [{'Name':'AttName','Value':'AttVal','DataType':'String'},{'Name':'AttName3','Value':34,'DataType':'Number'}]
    * @messageDeduplicationId Optional string. This parameter applies only to FIFO (first-in-first-out) queues.
    * The token used for deduplication of sent messages.
    * @messageGroupId Optional string. This parameter applies only to FIFO (first-in-first-out) queues.
    * Note: MessageGroupId is required for FIFO queues. You can't use it for Standard queues.
    */
    public any function sendMessage(
        required string queueName,
        required string message,
        numeric delaySeconds,
        array messageAttributes = [ ],
        string messageDeduplicationId,
        string messageGroupId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Action': 'SendMessage', 'MessageBody': message };
        if ( structKeyExists( arguments, 'delaySeconds' ) && isNumeric( delaySeconds ) ) {
            structAppend( payload, { 'DelaySeconds': delaySeconds } );
        }
        for ( var idx = 1; idx <= arrayLen( messageAttributes ); idx++ ) {
            structAppend(
                payload,
                {
                    'MessageAttribute.#idx#.Name': messageAttributes[ idx ].Name,
                    'MessageAttribute.#idx#.Value.StringValue': messageAttributes[ idx ].Value,
                    'MessageAttribute.#idx#.Value.DataType': messageAttributes[ idx ].DataType
                }
            );
        }
        if ( structKeyExists( arguments, 'messageDeduplicationId' ) && len( messageDeduplicationId ) ) {
            structAppend( payload, { 'MessageDeduplicationId': messageDeduplicationId } );
        }
        if ( structKeyExists( arguments, 'messageGroupId' ) && len( messageGroupId ) ) {
            structAppend( payload, { 'MessageGroupId': messageGroupId } );
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & queueName,
            payload
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Receives SQS messages
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ReceiveMessage.html
    * @queueName Required string. The name of the queue to receive messages from (e.g. "123456789/my-sqs-queue").
    * @maxNumberOfMessages Optional numeric. The number of messages to receive from the queue. The mmaxNumberOfMessages is limited to 10.
    * @visibilityTimeout Optional numeric. The amount of time until the message will be available in subsequent requests if not deleted.
    * Note: When AWS receives more than one message, ReceiveMessageResult is an array.
    *       When only one message is received, ReceiveMessageResult it is not an array.
    * @waitTimeSeconds Optional numeric. The duration (in seconds) for which the call waits for a message to arrive in the queue before returning.
    * @attributeNames Optional array. An array of strings for attributes that need to be returned along with each message. ['All'] returns all attributes.
    * @messageAttributeNames Optional array. An array of strings for user-defined attributes. Case-sensitive. ['All'] returns all user-defined attributes.
    * Example: ['userAttribute1','userAttribute2']
    */
    public any function receiveMessage(
        required string queueName,
        numeric maxNumberOfMessages = 1,
        numeric visibilityTimeout,
        numeric waitTimeSeconds,
        array attributeNames = [ ],
        array messageAttributeNames = [ ]
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        if ( maxNumberOfMessages > 10 ) {
            maxNumberOfMessages = 10;
        }
        var payload = { 'Action': 'ReceiveMessage', 'MaxNumberOfMessages': maxNumberOfMessages };
        if ( structKeyExists( arguments, 'visibilityTimeout' ) && isNumeric( visibilityTimeout ) ) {
            payload[ 'VisibilityTimeout' ] = visibilityTimeout;
        }
        if ( structKeyExists( arguments, 'waitTimeSeconds' ) && isNumeric( waitTimeSeconds ) ) {
            payload[ 'WaitTimeSeconds' ] = waitTimeSeconds;
        }
        for ( var idx = 1; idx <= arrayLen( attributeNames ); idx++ ) {
            structAppend( payload, { 'AttributeName.#idx#': attributeNames[ idx ] } );
        }
        for ( var idx = 1; idx <= arrayLen( messageAttributeNames ); idx++ ) {
            structAppend( payload, { 'MessageAttributeName.#idx#': messageAttributeNames[ idx ] } );
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & queueName,
            payload
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Deletes a message
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessage.html
    * @queueName Required string. The name of the queue (e.g. "123456789/my-sqs-queue").
    * @receiptHandle Required string. Receipt handle of the message to be deleted. This is obtained from receiveMessage response.
    */
    public any function deleteMessage(
        required string queueName,
        required string receiptHandle
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & queueName,
            { 'Action': 'DeleteMessage', 'ReceiptHandle': receiptHandle }
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Create a queue
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_CreateQueue.html
    * @queueName Required string. The name of the queue to create (e.g. "my-sqs-queue").
    * @delaySeconds Optional numeric. The length of time, in seconds, for which the delivery of all messages in the queue is delayed.
    * Valid values: An integer from 0 to 900 seconds (15 minutes). Default: 0.
    * @messageRetentionPeriod Optional numberic. The length of time, in seconds, for which Amazon SQS retains a message.
    * Valid values: An integer from 60 seconds (1 minute) to 1,209,600 seconds (14 days). Default: 345,600 (4 days).
    * @receiveMessageWaitTimeSeconds Optional numeric. The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive.
    * Valid values: An integer from 0 to 20 (seconds). Default: 0.
    * @visibilityTimeout Optional numeric. The visibility timeout for the queue, in seconds.
    * Valid values: An integer from 0 to 43,200 (12 hours). Default: 30.
    * @fifoQueue Optional boolean. false will create a standard queue, true will create a FIFO queue. Valid values: true/false.
    * @contentBasedDeduplication Enables content-based deduplication. Only applies for FIFO queues.
    */
    public any function createQueue(
        required string queueName,
        numeric delaySeconds = 0,
        numeric messageRetentionPeriod = 345600,
        numeric receiveMessageWaitTimeSeconds = 0,
        numeric visibilityTimeout = 30,
        boolean fifoQueue = false,
        boolean contentBasedDeduplication = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        // Append .fifo suffix for fifo queues as requied by AWS
        if ( fifoQueue && right( queueName, 5 ) NEQ '.fifo' ) {
            queueName = queueName & '.fifo';
        }
        var payload = {
            'Action': 'CreateQueue',
            'QueueName': queueName,
            'Attribute.1.Name': 'DelaySeconds',
            'Attribute.1.Value': delaySeconds,
            'Attribute.2.Name': 'MessageRetentionPeriod',
            'Attribute.2.Value': messageRetentionPeriod,
            'Attribute.3.Name': 'ReceiveMessageWaitTimeSeconds',
            'Attribute.3.Value': receiveMessageWaitTimeSeconds,
            'Attribute.4.Name': 'VisibilityTimeout',
            'Attribute.4.Value': visibilityTimeout
        }
        // Only append fifo attributes for fifo queues
        if ( fifoQueue ) {
            structAppend(
                payload,
                {
                    'Attribute.5.Name': 'FifoQueue',
                    'Attribute.5.Value': fifoQueue,
                    'Attribute.6.Name': 'ContentBasedDeduplication',
                    'Attribute.6.Value': contentBasedDeduplication
                }
            );
        }
        var apiResponse = apiCall( requestSettings, 'GET', '/', payload );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Delete a queue
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteQueue.html
    * @queueName Required string. The name of the queue to delete (e.g. "123456789/my-sqs-queue").
    */
    public any function deleteQueue(
        required string queueName
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & queueName,
            { 'Action': 'DeleteQueue', 'QueueName': queueName }
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Purge all messages in queue
    * https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_PurgeQueue.html
    * @queueName Required string. The name of the queue to purge (e.g. "123456789/my-sqs-queue").
    */
    public any function purgeQueue(
        required string queueName
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & queueName,
            { 'Action': 'PurgeQueue' }
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    // private

    private string function getHost(
        required string region
    ) {
        return variables.service & '.' & region & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = ''
    ) {
        var host = getHost( requestSettings.region );
        structAppend( queryParams, { 'Version': variables.apiVersion }, false );

        return api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials
        );
    }

}
