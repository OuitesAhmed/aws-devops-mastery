import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as events from 'aws-cdk-lib/aws-events';
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as nodejs from 'aws-cdk-lib/aws-lambda-nodejs';
import * as apigwv2 from 'aws-cdk-lib/aws-apigatewayv2';
import { HttpLambdaIntegration } from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import * as path from 'path';

export class ServerlessEventDrivenStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ==========================================
    // 1. BASE DE DONNÉES NOSQL (Amazon DynamoDB)
    // Mode PAY_PER_REQUEST (100% Free Tier, 0,00$ en idle)
    // ==========================================
    const ordersTable = new dynamodb.Table(this, 'OrdersTable', {
      tableName: 'orders-table',
      partitionKey: { name: 'orderId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'createdAt', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      encryption: dynamodb.TableEncryption.AWS_MANAGED,
      removalPolicy: cdk.RemovalPolicy.DESTROY, // Permet le nettoyage propre en lab/dev
    });

    // ==========================================
    // 2. BUS D'ÉVÉNEMENTS (Amazon EventBridge)
    // ==========================================
    const eventBus = new events.EventBus(this, 'OrdersEventBus', {
      eventBusName: 'orders-event-bus',
    });

    // Dead-Letter Queue (DLQ) pour stocker les événements en échec
    const ordersDlq = new sqs.Queue(this, 'OrdersDlq', {
      queueName: 'orders-processing-dlq',
      retentionPeriod: cdk.Duration.days(14),
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // ==========================================
    // 3. LAMBDA PRODUCER (Ingestion API Gateway)
    // Architecture ARM_64 Graviton (Économique & Rapide)
    // ==========================================
    const producerLambda = new nodejs.NodejsFunction(this, 'OrderProducerFunction', {
      functionName: 'order-producer',
      runtime: lambda.Runtime.NODEJS_22_X,
      architecture: lambda.Architecture.ARM_64,
      entry: path.join(__dirname, '../lambda/producer.ts'),
      handler: 'handler',
      memorySize: 256,
      timeout: cdk.Duration.seconds(10),
      environment: {
        EVENT_BUS_NAME: eventBus.eventBusName,
      },
      bundling: {
        minify: true,
        sourceMap: false,
        externalModules: ['@aws-sdk/*'], // Utilise le SDK v3 natif inclus dans le runtime
      },
    });

    // Grant IAM Least-Privilege en une seule ligne (Magie CDK)
    eventBus.grantPutEventsTo(producerLambda);

    // ==========================================
    // 4. API GATEWAY HTTP (Point d'entrée REST léger)
    // ==========================================
    const httpApi = new apigwv2.HttpApi(this, 'OrdersHttpApi', {
      apiName: 'orders-api',
      description: 'API HTTP Serverless pour la prise de commandes',
      corsPreflight: {
        allowHeaders: ['Content-Type'],
        allowMethods: [apigwv2.CorsHttpMethod.POST, apigwv2.CorsHttpMethod.OPTIONS],
        allowOrigins: ['*'],
      },
    });

    const producerIntegration = new HttpLambdaIntegration('ProducerIntegration', producerLambda);

    httpApi.addRoutes({
      path: '/orders',
      methods: [apigwv2.HttpMethod.POST],
      integration: producerIntegration,
    });

    // ==========================================
    // 5. LAMBDA CONSUMER (Traitement Asynchrone)
    // ==========================================
    const consumerLambda = new nodejs.NodejsFunction(this, 'OrderConsumerFunction', {
      functionName: 'order-consumer',
      runtime: lambda.Runtime.NODEJS_22_X,
      architecture: lambda.Architecture.ARM_64,
      entry: path.join(__dirname, '../lambda/consumer.ts'),
      handler: 'handler',
      memorySize: 256,
      timeout: cdk.Duration.seconds(15),
      environment: {
        TABLE_NAME: ordersTable.tableName,
      },
      bundling: {
        minify: true,
        sourceMap: false,
        externalModules: ['@aws-sdk/*'],
      },
    });

    // Grant IAM d'écriture DynamoDB au Consumer
    ordersTable.grantWriteData(consumerLambda);

    // ==========================================
    // 6. RÈGLE EVENTBRIDGE (Routage Événementiel)
    // ==========================================
    new events.Rule(this, 'OrderPlacedRule', {
      eventBus: eventBus,
      ruleName: 'order-placed-rule',
      description: 'Déclenche le consommateur pour les commandes créées',
      eventPattern: {
        source: ['orders.service'],
        detailType: ['OrderPlaced'],
      },
      targets: [
        new targets.LambdaFunction(consumerLambda, {
          deadLetterQueue: ordersDlq,
          maxEventAge: cdk.Duration.hours(2),
          retryAttempts: 2,
        }),
      ],
    });

    // ==========================================
    // 7. OUTPUTS
    // ==========================================
    new cdk.CfnOutput(this, 'ApiEndpoint', {
      value: `${httpApi.apiEndpoint}/orders`,
      description: 'URL pour envoyer une requête POST de commande',
    });

    new cdk.CfnOutput(this, 'DynamoDbTableName', {
      value: ordersTable.tableName,
      description: 'Nom de la table DynamoDB',
    });

    new cdk.CfnOutput(this, 'EventBusName', {
      value: eventBus.eventBusName,
      description: 'Nom du bus EventBridge',
    });
  }
}
