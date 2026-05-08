component {

    variables.service = 'personalize-runtime';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    /**
    * Returns a list of recommended items. The required input depends on the recipe type used to create the solution backing the campaign, as follows:
        RELATED_ITEMS - itemId required, userId not used
        USER_PERSONALIZATION - itemId optional, userId required
    * https://docs.aws.amazon.com/personalize/latest/dg/API_RS_GetRecommendations.html
    * @campaignArn a string: The Amazon Resource Name (ARN) of the solution version.
    * @itemId a string: The item ID to provide recommendations for. Required for RELATED_ITEMS recipe type.
    * @userId a string: The user ID to provide recommendations for. Required for USER_PERSONALIZATION  recipe type.
    * @numResults an integer: The number of results to return. The default is 25. The maximum is 100.
    */
    public any function getRecommendations(
        required string campaignArn,
        string itemId,
        string userId,
        numeric numResults
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'campaignArn': arguments.campaignArn };
        if ( !isNull( arguments.itemId ) ) args[ 'itemId' ] = arguments.itemId;
        if ( !isNull( arguments.userId ) ) args[ 'userId' ] = arguments.userId;
        if ( !isNull( arguments.numResults ) ) args[ 'numResults' ] = arguments.numResults;

        return apiCall(
            requestSettings,
            'GetRecommendations',
            '/recommendations',
            args
        );
    }

    /**
    * Re-ranks a list of recommended items for the given user. The first item in the list is deemed the most likely item to be of interest to the user.
        Note
        The solution backing the campaign must have been created using a recipe of type PERSONALIZED_RANKING.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_RS_GetPersonalizedRanking.html
    * @campaignArn a string: The Amazon Resource Name (ARN) of the solution version.
    * @itemList array of strings: A list of items (itemId's) to rank. If an item was not included in the training dataset, the item is appended to the end of the reranked list.
    * @userId a string: The user for which you want the campaign to provide a personalized ranking.
    */
    public any function getPersonalizedRanking(
        required string campaignArn,
        array itemList,
        string userId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'campaignArn': arguments.campaignArn, 'itemList': arguments.itemList, 'userId': arguments.userId };

        return apiCall(
            requestSettings,
            'GetPersonalizedRanking',
            '/personalize-ranking',
            args
        );
    }

    private any function apiCall(
        required struct requestSettings,
        required string target,
        required string path,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';

        var payloadString = serializeJSON( payload );
        var headers = { };
        headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

        var apiResponse = api.call(
            'personalize',
            host,
            requestSettings.region,
            'POST',
            arguments.path,
            { },
            headers,
            payloadString,
            requestSettings.awsCredentials
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

}
