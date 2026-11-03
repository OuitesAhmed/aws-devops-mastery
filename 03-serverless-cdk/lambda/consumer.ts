import { EventBridgeEvent } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';

const ddbClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(ddbClient);
const TABLE_NAME = process.env.TABLE_NAME || '';

interface OrderDetail {
  orderId: string;
  customerEmail: string;
  amount: number;
  items: Array<{ id: string; name: string; quantity: number }>;
  createdAt: string;
  status: string;
}

export const handler = async (event: EventBridgeEvent<'OrderPlaced', OrderDetail>): Promise<void> => {
  console.log('Received EventBridge event:', JSON.stringify(event));

  const order = event.detail;

  if (!order || !order.orderId) {
    console.warn('Skipping event: missing order details or orderId');
    return;
  }

  const processedOrder = {
    ...order,
    status: 'CONFIRMED',
    processedAt: new Date().toISOString(),
  };

  try {
    const command = new PutCommand({
      TableName: TABLE_NAME,
      Item: processedOrder,
    });

    await docClient.send(command);
    console.log(`Successfully stored confirmed order in DynamoDB: ${order.orderId}`);
  } catch (error) {
    console.error(`Failed to store order ${order.orderId} in DynamoDB:`, error);
    throw error; // Déclenche le retry EventBridge ou l'envoi vers la Dead-Letter Queue (DLQ)
  }
};

