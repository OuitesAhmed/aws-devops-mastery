#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { ServerlessEventDrivenStack } from '../lib/03-serverless-cdk-stack';

const app = new cdk.App();

new ServerlessEventDrivenStack(app, 'ServerlessEventDrivenStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT || '453388806918',
    region: process.env.CDK_DEFAULT_REGION || 'eu-west-3',
  },
  description: 'Projet 3 : Plateforme Serverless Event-Driven (API Gateway, EventBridge, Lambda, DynamoDB)',
});
