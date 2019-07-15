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
    * Creates an empty dataset group. A dataset group contains related datasets that supply data for training a model. A dataset group can contain at most three datasets, one for each type of dataset: Interactions Items Users
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateDatasetGroup.html
    * @name required string. The name for the dataset.
    * @kmsKeyArn optional string. The Amazon Resource Name (ARN) of a KMS key used to encrypt the datasets.
    * @roleArn optional string. The ARN of the IAM role that has permissions to access the KMS key. Supplying an IAM role is only valid when also specifying a KMS key.
    */
    public any function createDatasetGroup(
        required string name,
        string kmsKeyArn,
        string roleArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'name'=arguments.name };
        if ( !isNull( arguments.kmsKeyArn ) ) args[ 'kmsKeyArn' ] = arguments.kmsKeyArn;
        if ( !isNull( arguments.roleArn ) ) args[ 'roleArn' ] = arguments.roleArn;

        return apiCall( requestSettings, 'CreateDatasetGroup', args );
    }

    /**
    * Creates a job that imports training data from your data source (an Amazon S3 bucket) to an Amazon Personalize dataset. To allow Amazon Personalize to import the training data, you must specify an AWS Identity and Access Management (IAM) role that has permission to read from the data source.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateDatasetImportJob.html
    * @datasetArn required string. The ARN of the dataset that receives the imported data.
    * @dataLocation required string. The path to the Amazon S3 bucket where the data that you want to upload to your dataset is stored.
    * @jobName required string. The name for the dataset import job.
    * @roleArn required string. The ARN of the IAM role that has permissions to read from the Amazon S3 data source.
    */
    public any function createDatasetImportJob(
        required string datasetArn,
        required string datasetLocation,
        required string jobName,
        required string roleArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'jobName'=arguments.jobName, 'datasetArn'=arguments.datasetArn, 'dataSource'={'dataLocation'=arguments.dataLocation}, 'roleArn'=arguments.roleArn };

        return apiCall( requestSettings, 'CreateDatasetImportJob', args );
    }

    /**
    * Creates an event tracker that you use when sending event data to the specified dataset group using the PutEvents API.
      When Amazon Personalize creates an event tracker, it also creates an event-interactions dataset in the dataset group associated with the event tracker. 
      The event-interactions dataset stores the event data from the PutEvents call. The contents of this dataset are not available to the user.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateEventTracker.html
    * @datasetGroupArn required string. The Amazon Resource Name (ARN) of the dataset group that receives the event data.
    * @name required string. The name for the event tracker.
    */
    public any function createEventTracker(
        required string datasetGroupArn,
        required string name
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'name'=arguments.name, 'datasetGroupArn'=arguments.datasetGroupArn };

        return apiCall( requestSettings, 'CreateEventTracker', args );
    }

    /**
    * Creates an Amazon Personalize schema from the specified schema string. The schema you create must be in Avro JSON format.
      Amazon Personalize recognizes three schema variants. Each schema is associated with a dataset type and has a set of required field and keywords. You specify a schema when you call CreateDataset.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateSchema.html
    * @name required string. The name for the schema.
    * @schema required string. A schema in Avro JSON format.
    */
    public any function createSchema(
        required string name,
        required string schema
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'name'=arguments.name, 'schema'=arguments.schema };

        return apiCall( requestSettings, 'CreateSchema', args );
    }

    /**
    * Creates the configuration for training a model. A trained model is known as a solution. After the configuration is created, you train the model (create a solution) by calling the CreateSolutionVersion operation. 
      Every time you call CreateSolutionVersion, a new version of the solution is created.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateSolution.html
    * @name required string. The name for the solution.
    * @datasetGroupArn required string. The Amazon Resource Name (ARN) of the dataset group that provides the training data.
    * @eventType optional string. When you have multiple event types (using an EVENT_TYPE schema field), this parameter specifies which event type (for example, 'click' or 'like') is used for training the model.
    * @performAutoML optional boolean. Whether to perform automated machine learning (AutoML). The default is false. For this case, you must specify recipeArn.
                     When set to true, Amazon Personalize analyzes your training data and selects the optimal USER_PERSONALIZATION recipe and hyperparameters. In this case, you must omit recipeArn. 
                     Amazon Personalize determines the optimal recipe by running tests with different values for the hyperparameters. AutoML lengthens the training process as compared to selecting a specific recipe.
    * @performHPO optional boolean. Whether to perform hyperparameter optimization (HPO) on the specified or selected recipe. The default is false.
                  When performing AutoML, this parameter is always true and you should not set it to false.
    * @recipeArn optional string. The ARN of the recipe to use for model training. Only specified when performAutoML is false.
    * @solutionConfig optional struct. The configuration to use with the solution, see https://docs.aws.amazon.com/personalize/latest/dg/API_SolutionConfig.html for key/data format. 
                      When performAutoML is set to true, Amazon Personalize only evaluates the autoMLConfig section of the solution configuration.
    */
    public any function createSolution(
        required string name,
        required string datasetGroupArn,
        string eventType,
        boolean performAutoML,
        boolean performHPO,
        string recipeArn,
        struct solutionConfig
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'name'=arguments.name, 'datasetGroupArn'=arguments.datasetGroupArn };
        if ( !isNull( arguments.eventType ) ) args[ 'eventType' ] = arguments.eventType;
        if ( !isNull( arguments.performAutoML ) ) args[ 'performAutoML' ] = arguments.performAutoML;
        if ( !isNull( arguments.performHPO ) ) args[ 'performHPO' ] = arguments.performHPO;
        if ( !isNull( arguments.recipeArn ) ) args[ 'recipeArn' ] = arguments.recipeArn;
        if ( !isNull( arguments.solutionConfig ) ) args[ 'solutionConfig' ] = arguments.solutionConfig;

        return apiCall( requestSettings, 'CreateSolution', args );
    }

    /**
    * Trains or retrains an active solution. A solution is created using the CreateSolution operation and must be in the ACTIVE state before calling CreateSolutionVersion. A new version of the solution is created every time you call this operation.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_CreateSolutionVersion.html
    * @solutionArn required string. The Amazon Resource Name (ARN) of the solution to retrain.
    */
    public any function createSolutionVersion(
        required string solutionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionArn'=arguments.solutionArn };

        return apiCall( requestSettings, 'CreateSolutionVersion', args );
    }

    /**
    * Removes a campaign by deleting the solution deployment. The solution that the campaign is based on is not deleted and can be redeployed when needed. A deleted campaign can no longer be specified in a GetRecommendations request. For more information on campaigns, see CreateCampaign.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteCampaign.html
    * @campaignArn required string. The Amazon Resource Name (ARN) of the campaign to delete.
    */
    public any function deleteCampaign(
        required string campaignArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'campaignArn'=arguments.campaignArn };

        return apiCall( requestSettings, 'DeleteCampaign', args );
    }

    /**
    * Deletes a dataset. You can't delete a dataset if an associated DatasetImportJob or SolutionVersion is in the CREATE PENDING or IN PROGRESS state. For more information on datasets, see CreateDataset.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteDataset.html
    * @datasetArn required string. The Amazon Resource Name (ARN) of the dataset to delete.
    */
    public any function deleteDataset(
        required string datasetArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'datasetArn'=arguments.datasetArn };

        return apiCall( requestSettings, 'DeleteDataset', args );
    }

    /**
    * Deletes a dataset group. Before you delete a dataset group, you must delete the following:
      All associated event trackers.
      All associated solutions.
      All datasets in the dataset group.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteDatasetGroup.html
    * @datasetGroupArn required string. The Amazon Resource Name (ARN) of the dataset group to delete.
    */
    public any function deleteDatasetGroup(
        required string datasetGroupArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'datasetGroupArn'=arguments.datasetGroupArn };

        return apiCall( requestSettings, 'DeleteDatasetGroup', args );
    }

    /**
    * Deletes the event tracker. Does not delete the event-interactions dataset from the associated dataset group. For more information on event trackers, see CreateEventTracker.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteEventTracker.html
    * @eventTrackerArn required string. The Amazon Resource Name (ARN) of the event tracker to delete.
    */
    public any function deleteEventTracker(
        required string eventTrackerArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'eventTrackerArn'=arguments.eventTrackerArn };

        return apiCall( requestSettings, 'DeleteEventTracker', args );
    }

    /**
    * Deletes a schema. Before deleting a schema, you must delete all datasets referencing the schema. For more information on schemas, see CreateSchema.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteSchema.html
    * @schemaArn required string. The Amazon Resource Name (ARN) of the schema to delete.
    */
    public any function deleteSchema(
        required string schemaArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'schemaArn'=arguments.schemaArn };

        return apiCall( requestSettings, 'DeleteSchema', args );
    }

    /**
    * Deletes all versions of a solution and the Solution object itself. Before deleting a solution, you must delete all campaigns based on the solution. 
      To determine what campaigns are using the solution, call ListCampaigns and supply the Amazon Resource Name (ARN) of the solution. 
      You can't delete a solution if an associated SolutionVersion is in the CREATE PENDING or IN PROGRESS state.
    * https://docs.aws.amazon.com/personalize/latest/dg/API_DeleteSolution.html
    * @solutionArn required string. The Amazon Resource Name (ARN) of the solution to delete.
    */
    public any function deleteSolution(
        required string solutionArn
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'solutionArn'=arguments.solutionArn };

        return apiCall( requestSettings, 'DeleteSolution', args );
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