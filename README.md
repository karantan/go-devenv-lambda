# go-devenv-lambda
Sandbox repo for testing AWS Lambda with [Devenv](https://devenv.sh/getting-started/) and Go using the [Serverless framework](https://www.serverless.com/framework/docs).


## Requirements

- [Nix](https://nixos.org/download#download-nix)
- [Devenv](https://devenv.sh/getting-started/)
- [AWS account](https://aws.amazon.com/resources/create-account/) (or an account on any other [supported](https://www.serverless.com/framework/docs/providers) provider)
- [AWS Credentials]((https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html))

## Devenv

[Devenv](https://devenv.sh/) is a fast, declarative, reproducible, and composable developer environment.

## Serverless Framework

This template demonstrates how to deploy a Go function running on AWS Lambda using the traditional Serverless Framework. The deployed function does not include any event definitions as well as any kind of persistence (database). For more advanced configurations check out the [examples repo](https://github.com/serverless/examples/) which includes integrations with SQS, DynamoDB or examples of functions that are triggered in `cron`-like manner. For details about configuration of specific `events`, please refer to our [documentation](https://www.serverless.com/framework/docs/providers/aws/events/).

### Usage

> **_NOTE:_** `go1.x` runtime will be deprecated on Dec 31, 2023. See https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html#golang-al1

#### Configuration

Serverless tool helps us to bootstrap a bit of Go code, Makefile with a few essential commands and the [`serverless.yml`](https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml) file where all lambda configuration is defined.

```bash
sls create --template aws-go --name hello --path hello
```

Here is a minimalistic example of the serverless.yml configuration:

```yaml
service: hello

frameworkVersion: "3"

provider:
  name: aws
  runtime: go1.x
  region: us-east-1
  architecture: x86_64

functions:
  hello:
    handler: bin/hello
    events:
      - httpApi:
          path: /hello
          method: get

package:
 patterns:
   - '!./**'
   - './bin/**'
```

In the first line we define a service name. This name will be used in the AWS Lambda service for naming the application and also as for naming functions.

`provider` section describes which provider is selected (in the above case it's `aws`) and then runetime, region and arhitecture.

Next we have a section where we define our [functions](https://www.serverless.com/framework/docs/providers/aws/guide/functions) and how to access them. In the above case we have one function called `hello`. The `handler` property points to the file and module containing the code you want to run in your function. We point it to `bin/hello` because we have defined in our `Makefile` that we want to build our hello function in bin/hello (`-o bin/hello`).

[Events](https://www.serverless.com/framework/docs/providers/aws/guide/events) are the things that trigger our function. We are using [HTTP API v2](https://www.serverless.com/framework/docs/providers/aws/events/http-api).

In the [`package`](https://www.serverless.com/framework/docs/providers/aws/guide/packaging) section we define what to include and what to exclude from the resulting artifact located in `<service-name>/.serverless/<service-name>.zip` (e.g. `hello/.serverless/hello.zip`).

#### Code

Go code is located in the root folder. All Lambda functions are in `functions` folder.

#### Deployment

In order to deploy the example, you need to run the following command:

```bash
$ cd hello
# aws-go template doesn't have go.mod and go.sum files
$ go mod init hello-world
...
$ go mod tidy
...
$ make deploy
...
```

After running deploy, you should see output similar to:

```bash
✔ Service deployed to stack hello-dev (100s)

endpoints:
  GET - https://q8npk61n15.execute-api.us-east-1.amazonaws.com/hello
  GET - https://q8npk61n15.execute-api.us-east-1.amazonaws.com/world
functions:
  hello: hello-dev-hello (5.3 MB)
  world: hello-dev-world (5.3 MB)

Stack Outputs:
  HelloLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:276131759979:function:hello-dev-hello:1
  HttpApiId: q8npk61n15
  WorldLambdaFunctionQualifiedArn: arn:aws:lambda:us-east-1:276131759979:function:hello-dev-world:1
  ServerlessDeploymentBucketName: hello-dev-serverlessdeploymentbucket-6uu8qfr899kr
  HttpApiUrl: https://q8npk61n15.execute-api.us-east-1.amazonaws.com
```

#### Development

Many Serverless Framework users choose to develop on the cloud, since it matches reality and emulating Lambda locally can be complex. To develop on the cloud quickly, without sacrificing speed. [Serverless](https://www.serverless.com/framework/docs/getting-started#developing-on-the-cloud) recommends the following approach.

Skip the `sls deploy` command which is much slower since it triggers a full AWS CloudFormation update. Instead, deploy code and configuration changes to individual AWS Lambda functions in seconds via the `deploy function` command, with `--function` [function name in serverless.yml] set to the function you want to deploy.

```bash
sls deploy function --function hello
```

#### Invocation

After successful deployment, you can invoke (i.e. run) the deployed function by using the following command:

```bash
sls invoke --function hello
```

Which should result in response similar to the following:

```json
{
    "statusCode": 200,
    "headers": {
        "Content-Type": "application/json",
        "X-MyCompany-Func-Reply": "hello-handler"
    },
    "multiValueHeaders": null,
    "body": "{\"message\":\"Go Serverless v1.0! Your function executed successfully!\"}"
}
```

#### Local development

For local development you will need to run docker.

You can invoke your function locally by using the following command:

```bash
sls invoke local --function hello
```


#### Cleanup

Running the `remove` command will delete all the AWS resources created by your project and ensure that you don't incur any unexpected charges.

```bash
sls remove
```
