component {

    variables.service = 'connect';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.settings = arguments.settings;
        return this;
    }

    /**
    * Return a list of instances which are in active state, creation-in-progress state, and failed state.
    * Instances that aren't successfully created (they are in a failed state) are returned only for 24 hours
    * after the CreateInstance API was invoked.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_ListInstances.html
    *
    * @preview
    */
    public any function listInstances(
        maxResults = 10,
        nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'maxResults': arguments.maxResults };
        if ( !isNull( arguments.nextToken ) ) {
            queryParams[ 'nextToken' ] = arguments.maxResults;
        }
        var apiResponse = apiCall(
            requestSettings = requestSettings,
            httpMethod = 'GET',
            path = '/instance',
            queryParams = queryParams
        );
        return apiResponse;
    }

    /**
    * Describes the specified contact.
    * Contact information remains available in Amazon Connect for 24 months, and then it is deleted.
    * Only data from November 12, 2021, and later is returned by this API.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_DescribeContact.html
    *
    * @preview
    */
    public any function describeContact(
        required string instanceId,
        required string contactId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings = requestSettings,
            httpMethod = 'GET',
            path = '/contacts/#arguments.instanceId#/#arguments.contactId#'
        );
        return apiResponse;
    }

    /**
    * Assigns the specified routing profile to the specified user.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_UpdateUserRoutingProfile.html
    */
    public any function updateUserRoutingProfile(
        required string instanceId,
        required string userId,
        required string routingProfileId
    ) {
        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'POST',
            path = '/users/#arguments.instanceId#/#arguments.userId#/routing-profile',
            payload = serializeJSON( { 'RoutingProfileId': arguments.routingProfileId } )
        );
    }

    /**
    * Places an outbound call to a contact, and then initiates the flow.
    * It performs the actions in the flow that's specified (in ContactFlowId).
    * Agents do not initiate the outbound API, which means that they do not dial the contact.
    * If the flow places an outbound call to a contact, and then puts the contact in queue, the call is then routed to the agent, like any other inbound case.
    * There is a 60-second dialing timeout for this operation. If the call is not connected after 60 seconds, it fails.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_StartOutboundVoiceContact.html
    */
    public any function startOutboundVoiceContact(
        required string instanceId,
        required string contactFlowId,
        required string destinationPhoneNumber,
        string campaignId,
        boolean awaitAnswerMachinePrompt,
        boolean enableAnswerMachineDetection,
        string queueId,
        string sourcePhoneNumber,
        string clientToken,
        struct attributes = { }
    ) {
        if ( isNull( arguments.queueId ) && isNull( arguments.sourcePhoneNumber ) ) {
            throw( 'Either a queueId or a sourcePhoneNumber must be provided' );
        }

        // Denotes the class of traffic. Calls with different traffic types are handled differently by Amazon Connect.
        // The default value is GENERAL. Use CAMPAIGN if `EnableAnswerMachineDetection` is set to true. For all other cases, use GENERAL.
        var trafficType = 'GENERAL';
        if ( !isNull( arguments.enableAnswerMachineDetection ) && arguments.enableAnswerMachineDetection ) {
            trafficType = 'CAMPAIGN';
        }

        var payload = {
            'InstanceId': arguments.instanceId,
            'ContactFlowId': arguments.contactFlowId,
            'Attributes': arguments.attributes,
            'DestinationPhoneNumber': arguments.destinationPhoneNumber,
            'TrafficType': trafficType
        };

        // Optional Keys
        if ( !isNull( arguments.campaignId ) ) {
            payload[ 'CampaignId' ] = arguments.campaignId;
        }
        if ( !isNull( arguments.queueId ) ) {
            payload[ 'QueueId' ] = arguments.queueId;
        }
        if ( !isNull( arguments.sourcePhoneNumber ) ) {
            payload[ 'SourcePhoneNumber' ] = arguments.sourcePhoneNumber;
        }
        if ( !isNull( arguments.clientToken ) ) {
            payload[ 'ClientToken' ] = arguments.clientToken;
        }

        if ( !isNull( arguments.awaitAnswerMachinePrompt ) || !isNull( arguments.enableAnswerMachineDetection ) ) {
            payload[ 'AnswerMachineDetectionConfig' ] = { };
            if ( !isNull( arguments.awaitAnswerMachinePrompt ) ) {
                payload[ 'AnswerMachineDetectionConfig' ][ 'AwaitAnswerMachinePrompt' ] = arguments.awaitAnswerMachinePrompt;
            }
            if ( !isNull( arguments.enableAnswerMachineDetection ) ) {
                payload[ 'AnswerMachineDetectionConfig' ][ 'EnableAnswerMachineDetection' ] = arguments.enableAnswerMachineDetection;
            }
        }

        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'PUT',
            path = '/contact/outbound-voice',
            payload = serializeJSON( payload )
        );
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = ''
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';
        var useSSL = !structKeyExists( variables.settings, 'useSSL' ) || variables.settings.useSSL;
        var apiResponse = api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials,
            false,
            useSSL
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );
        return apiResponse;
    }

}
