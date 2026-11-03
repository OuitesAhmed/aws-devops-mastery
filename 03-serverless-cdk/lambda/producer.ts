import { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { EventBridgeClient, PutEventsCommand } from '@aws-sdk/client-eventbridge';
import { randomUUID } from 'crypto';

const eventBridge = new EventBridgeClient({});
const EVENT_BUS_NAME = process.env.EVENT_BUS_NAME || '';

export const handler = async (event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> => {
  console.log('Received API Gateway request:', JSON.stringify(event));

  try {
    if (!event.body) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: 'Request body is required' }),
      };
    }

    const payload = JSON.parse(event.body);
    const orderId = payload.orderId || randomUUID();
    const orderEvent = {
      orderId,
      customerEmail: payload.customerEmail || 'anonymous@example.com',
      amount: payload.amount || 0,
      items: payload.items || [],
      createdAt: new Date().toISOString(),
      status: 'PENDING',
    };

    // Publier l'événement sur le bus EventBridge
    const command = new PutEventsCommand({
      Entries: [
        {
          EventBusName: EVENT_BUS_NAME,
          Source: 'orders.service',
          DetailType: 'OrderPlaced',
          Detail: JSON.stringify(orderEvent),
        },
      ],
    });

    await eventBridge.send(command);
    console.log(`Successfully published OrderPlaced event for orderId: ${orderId}`);

    return {
      statusCode: 202,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: 'Order received and queued for asynchronous processing',
        orderId,
        status: 'PENDING',
      }),
    };
  } catch (error: any) {
    console.error('Error handling order ingestion:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'Internal Server Error', error: error.message }),
    };
  }
};

