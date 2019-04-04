component {

    variables.service = 'sns';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    /**
    * Returns a list of the requester's topics.
    * http://docs.aws.amazon.com/sns/latest/api/API_ListTopics.html
    * @NextToken Token to pass along to the next listTopics request. This element is returned if there are more subscriptions to retrieve.
    */
    public any function listTopics( string NextToken = '' ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'ListTopics' };

        if ( len( arguments.NextToken ) ) queryParams[ 'NextToken' ] = arguments.NextToken;

        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Creates a topic to which notifications can be published. Users can create at most 100,000 topics.
    * For more information, see http://aws.amazon.com/sns. This action is idempotent, so if the requester
    * already owns a topic with the specified name, that topic's ARN is returned without creating a new topic.
    * http://docs.aws.amazon.com/sns/latest/api/API_CreateTopic.html
    * @Name The name of the topic you want to create.
    */
    public any function createTopic(
        required string Name
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'CreateTopic', 'Name': arguments.Name };
        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Deletes a topic and all its subscriptions.
    * Deleting a topic might prevent some messages previously sent to the topic from being delivered to subscribers.
    * This action is idempotent, so deleting a topic that does not exist does not result in an error.
    * http://docs.aws.amazon.com/sns/latest/api/API_DeleteTopic.html
    * @TopicArn The ARN of the topic you want to delete.
    */
    public any function deleteTopic(
        required string TopicArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'DeleteTopic', 'TopicArn': arguments.TopicArn };
        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Returns a list of the requester's subscriptions.
    * http://http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptions.html
    * @NextToken Token to pass along to the next ListSubscriptions request. This element is returned if there are more subscriptions to retrieve.
    */
    public any function listSubscriptions( string NextToken = '' ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'ListSubscriptions' };

        if ( len( arguments.NextToken ) ) queryParams[ 'NextToken' ] = arguments.NextToken;

        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Returns a list of the subscriptions to a specific topic.
    * http://docs.aws.amazon.com/sns/latest/api/API_ListSubscriptionsByTopic.html
    * @TopicArn The ARN of the topic for which you wish to find subscriptions.
    * @NextToken Token to pass along to the next ListSubscriptionsByTopic request. This element is returned if there are more subscriptions to retrieve.
    */
    public any function listSubscriptionsByTopic(
        required string TopicArn,
        string NextToken = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'ListSubscriptionsByTopic', 'TopicArn': arguments.TopicArn };

        if ( len( arguments.NextToken ) ) queryParams[ 'NextToken' ] = arguments.NextToken;

        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Sends a message to an Amazon SNS topic or sends a text message (SMS message) directly to a phone number.
    * If you send a message to a topic, Amazon SNS delivers the message to each endpoint that is subscribed to the topic.
    * The format of the message depends on the notification protocol for each subscribed endpoint.
    * You must specify a value for one of the PhoneNumber, TargetArn or TopicArn parameters.
    * http://docs.aws.amazon.com/sns/latest/api/API_Publish.html
    * @Message The ARN of the topic for which you wish to find subscriptions. This can be a JSON object in order to specify different formats for different protocals - see the documentation for examples. If you use a JSON object `MessageStructure` must be set to `json`
    * @MessageAttributes Message attributes for Publish action.
    * @MessageStructure Set MessageStructure to json if you want to send a different message for each protocol.
    * @PhoneNumber The phone number to which you want to deliver an SMS message. Use E.164 format.
    * @Subject Optional parameter to be used as the "Subject" line when the message is delivered to email endpoints. This field will also be included, if present, in the standard JSON messages delivered to other endpoints.
    * @TargetArn The target you want to publish to.
    * @TopicArn The topic you want to publish to.
    */
    public any function publish(
        required string Message,
        struct MessageAttributes = { },
        string MessageStructure = '',
        string PhoneNumber = '',
        string Subject = '',
        string TargetArn = '',
        string TopicArn = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var formParams = { 'Action': 'Publish', 'Message': arguments.Message };
        for ( var key in [ 'MessageStructure', 'PhoneNumber', 'Subject', 'TargetArn', 'TopicArn' ] ) {
            if ( len( arguments[ key ] ) ) formParams[ key ] = arguments[ key ];
        }

        if ( arguments.keyExists( "MessageAttributes" ) ) {
            var i = 1;
            MessageAttributes.each(function(k, v) {
                var dataType = "String";

                if ( isNumeric(v) ) {
                    dataType = "Number";
                } else if ( isArray(v) ) {
                    dataType = "String.Array";
                }

                formParams [ "MessageAttributes.entry.#i#.Name" ] = k;
                formParams [ "MessageAttributes.entry.#i#.Value.DataType" ] = dataType;
                if ( dataType == "String.Array" ) {
                    formParams [ "MessageAttributes.entry.#i#.Value.StringValue" ] = "[\""#v.toList("\"", \""")#\""]";
                } else {
                    formParams [ "MessageAttributes.entry.#i#.Value.StringValue" ] = "#v#";
                }

                i++;
            });
        }

        var apiResponse = apiCall( requestSettings, 'POST', '/', { }, { }, formParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Prepares to subscribe an endpoint by sending the endpoint a confirmation message.
    * To actually create a subscription, the endpoint owner must call the ConfirmSubscription action with the token from the confirmation message.
    * Confirmation tokens are valid for three days.
    * http://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html
    * @Endpoint The endpoint that you want to receive notifications. Endpoints vary by protocol.
    * @Protocol The protocol you want to use. Supported protocols: (http|https|email|email-json|sms|sqs|application|lambda)
    * @TopicArn The ARN of the topic you want to subscribe to.
    */
    public any function subscribe(
        required string Endpoint,
        required string Protocol,
        required string TopicArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'Subscribe' };
        for ( var key in [ 'Endpoint','Protocol','TopicArn' ] ) {
            if ( len( arguments[ key ] ) ) queryParams[ key ] = arguments[ key ];
        }

        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Deletes a subscription.
    * If the subscription requires authentication for deletion, only the owner of the subscription or the topic's owner can unsubscribe, and an AWS signature is required.
    * If the Unsubscribe call does not require authentication and the requester is not the subscription owner, a final cancellation message is delivered to the endpoint,
    * so that the endpoint owner can easily resubscribe to the topic if the Unsubscribe request was unintended.
    * http://docs.aws.amazon.com/sns/latest/api/API_Unsubscribe.html
    * @SubscriptionArn The ARN of the subscription to be deleted.
    */
    public any function unsubscribe(
        required string SubscriptionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'Unsubscribe', 'SubscriptionArn': arguments.SubscriptionArn };

        var apiResponse = apiCall( requestSettings, 'GET', '/', queryParams );
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

        if ( isStruct( payload ) ) {
            structAppend( payload, { 'Version': variables.apiVersion }, false );
            structAppend( headers, { 'Content-Type': 'application/x-www-form-urlencoded' }, false );
            payload = utils.parseQueryParams( payload );
        } else {
            structAppend( queryParams, { 'Version': variables.apiVersion }, false );
        }
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
