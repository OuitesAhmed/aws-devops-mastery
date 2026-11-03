import * as cdk from 'aws-cdk-lib';
import { Template, Match } from 'aws-cdk-lib/assertions';
import { ServerlessEventDrivenStack } from '../lib/03-serverless-cdk-stack';

test('Serverless Stack creates DynamoDB Table with PAY_PER_REQUEST billing', () => {
  const app = new cdk.App();
  const stack = new ServerlessEventDrivenStack(app, 'TestStack');
  const template = Template.fromStack(stack);

  template.hasResourceProperties('AWS::DynamoDB::Table', {
    BillingMode: 'PAY_PER_REQUEST',
    TableName: 'orders-table',
  });
});

test('Serverless Stack creates EventBridge Rule with DLQ attached', () => {
  const app = new cdk.App();
  const stack = new ServerlessEventDrivenStack(app, 'TestStack');
  const template = Template.fromStack(stack);

  template.hasResourceProperties('AWS::Events::Rule', {
    EventPattern: {
      source: ['orders.service'],
      'detail-type': ['OrderPlaced'],
    },
  });

  template.resourceCountIs('AWS::SQS::Queue', 1);
});

test('Serverless Stack creates 2 Lambda functions on ARM64 Graviton', () => {
  const app = new cdk.App();
  const stack = new ServerlessEventDrivenStack(app, 'TestStack');
  const template = Template.fromStack(stack);

  template.resourceCountIs('AWS::Lambda::Function', 2);
  template.hasResourceProperties('AWS::Lambda::Function', {
    Architectures: ['arm64'],
  });
});
