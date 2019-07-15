component {

    variables.service = 'personalize';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    /**
    * Creates a campaign by deploying a solution version. When a client calls the GetRecommendations and GetPersonalizedRanking APIs, a campaign is specified in the request.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateCampaign.html
    * @minProvisionedTPS required numeric. Specifies the requested minimum provisioned transactions (recommendations) per second that Amazon Personalize will support.
    * @name required string. A name for the new campaign. The campaign name must be unique within your account.
    * @solutionVersionArn required string. The Amazon Resource Name (ARN) of the solution version to deploy.
    */
    public any function createCampaign(
        required numeric minProvisionedTPS,
        required string name,
        required string solutionVersionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'minProvisionedTPS'=arguments.minProvisionedTPS, 'name'=arguments.name, 'solutionVersionArn'=arguments.solutionVersionArn };

        return apiCall( requestSettings, 'CreateCampaign', args );
    }

    /**
    * Creates an empty dataset and adds it to the specified dataset group. Use CreateDatasetImportJob to import your training data to a dataset.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateDataset.html
    * @datasetGroupArn required string. The Amazon Resource Name (ARN) of the dataset group to add the dataset to.
    * @datasetType required string. The type of dataset. One of the following (case insensitive) values: Interactions Items Users
    * @name required string. The name for the dataset.
    * @schemaArn required string. The ARN of the schema to associate with the dataset. The schema defines the dataset fields.
    */
    public any function createDataset(
        required string datasetGroupArn,
        required string datasetType,
        required string name,
        required string schemaArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'datasetGroupArn'=arguments.datasetGroupArn, 'datasetType'=arguments.datasetType, 'name'=arguments.name, 'schemaArn'=arguments.schemaArn };

        return apiCall( requestSettings, 'CreateDataset', args );
    }

    /**
    * Returns a list of dataset groups. The response provides the properties for each dataset group, including the Amazon Resource Name (ARN).
    * https://docs.aws.amazon.com/personalize/latest/dg/API_ListDatasetGroups.html
    * @maxResults Optional numeric. The maximum number of solutions to return. between 1 and 100.
    * @nextToken Optional string. A token returned from the previous call to listDatasetGroups for getting the next set of solutions (if they exist).
    */
    public any function listDatasetGroups(
        numeric maxResults,
        string nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = {  };
        if ( !isNull( arguments.maxResults ) ) args[ 'maxResults' ] = arguments.maxResults;
        if ( !isNull( arguments.nextToken ) ) args[ 'nextToken' ] = arguments.nextToken;

        return apiCall( requestSettings, 'ListDatasetGroups', args );
    }

    /**
    * Returns a list of campaigns that use the given solution. When a solution is not specified, all the campaigns associated with the account are listed. The response provides the properties for each campaign, including the Amazon Resource Name (ARN). For more information on campaigns, see CreateCampaign.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_ListCampaigns.html
    * @solutionArn a string: The Amazon Resource Name (ARN) of the solution to list the campaigns for. When a solution is not specified, all the campaigns associated with the account are listed.
    * @maxResults Optional numeric. The maximum number of solutions to return. between 1 and 100.
    * @nextToken Optional string. A token returned from the previous call to ListCampaigns for getting the next set of campaigns (if they exist).
    */
    public any function listCampaigns(
        string solutionArn,
        numeric maxResults,
        string nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = {};
        if ( !isNull( arguments.solutionArn ) ) args[ 'solutionArn' ] = arguments.solutionArn;
        if ( !isNull( arguments.maxResults ) ) args[ 'maxResults' ] = arguments.maxResults;
        if ( !isNull( arguments.nextToken ) ) args[ 'nextToken' ] = arguments.nextToken;

        return apiCall( requestSettings, 'ListCampaigns', args );
    }

    /**
    * Returns a list of solutions that use the given dataset group. When a dataset group is not specified, all the solutions associated with the account are listed. The response provides the properties for each solution, including the Amazon Resource Name (ARN). For more information on solutions, see CreateSolution.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_ListSolutions.html
    * @datasetGroupArn a string: The Amazon Resource Name (ARN) of the dataset group.
    * @maxResults Optional numeric. The maximum number of solutions to return. between 1 and 100.
    * @nextToken Optional string. A token returned from the previous call to ListSolutions for getting the next set of solutions (if they exist).
    */
    public any function listSolutions(
        required string datasetGroupArn,
        numeric maxResults,
        string nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'datasetGroupArn'=arguments.datasetGroupArn };
        if ( !isNull( arguments.maxResults ) ) args[ 'maxResults' ] = arguments.maxResults;
        if ( !isNull( arguments.nextToken ) ) args[ 'nextToken' ] = arguments.nextToken;

        return apiCall( requestSettings, 'ListSolutions', args );
    }

    /**
    * Returns a list of solution versions for the given solution. When a solution is not specified, all the solution versions associated with the account are listed. The response provides the properties for each solution version, including the Amazon Resource Name (ARN). For more information on solutions, see CreateSolution.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_ListSolutionVersions.html
    * @solutionArn a string: The Amazon Resource Name (ARN) of the solution.
    * @maxResults Optional numeric. The maximum number of solutions to return. between 1 and 100.
    * @nextToken Optional string. A token returned from the previous call to ListSolutions for getting the next set of solutions (if they exist).
    */
    public any function listSolutionVersions(
        required string solutionArn,
        numeric maxResults,
        string nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionArn'=arguments.solutionArn };
        if ( !isNull( arguments.maxResults ) ) args[ 'maxResults' ] = arguments.maxResults;
        if ( !isNull( arguments.nextToken ) ) args[ 'nextToken' ] = arguments.nextToken;

        return apiCall( requestSettings, 'ListSolutionVersions', args );
    }

    /**
    * Describes a solution. For more information on solutions, see CreateSolution.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DescribeSolution.html
    * @solutionArn a string: The Amazon Resource Name (ARN) of the solution.
    */
    public any function describeSolution(
        required string solutionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionArn'=arguments.solutionArn };

        return apiCall( requestSettings, 'DescribeSolution', args );
    }

    /**
    * Describes the given campaign, including its status.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DescribeCampaign.html
    * @campaignArn a string: The Amazon Resource Name (ARN) of the campaign.
    */
    public any function describeCampaign(
        required string campaignArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'campaignArn'=arguments.campaignArn };

        return apiCall( requestSettings, 'DescribeCampaign', args );
    }

    /**
    * Describes the given campaign, including its status.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DescribeCampaign.html
    * @campaignArn a string: The Amazon Resource Name (ARN) of the campaign.
    */
    public any function describeSolutionVersion(
        required string solutionVersionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionVersionArn'=arguments.solutionVersionArn };

        return apiCall( requestSettings, 'DescribeSolutionVersion', args );
    }

    /**
    * Gets the metrics for the specified solution version.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_GetSolutionMetrics.html
    * @solutionVersionArn a string: The Amazon Resource Name (ARN) of the solution version.
    */
    public any function getSolutionMetrics(
        required string solutionVersionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionVersionArn'=arguments.solutionVersionArn };

        return apiCall( requestSettings, 'GetSolutionMetrics', args );
    }

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';

        var payloadString = serializeJSON( payload );
        var headers = { };
        headers[ 'X-Amz-Target' ] = 'AmazonPersonalize.#target#';
        headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

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
}