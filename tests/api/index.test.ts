import { createMocks } from 'node-mocks-http';
import handler from '../../src/pages/api';

describe('/api', () => {
  test('returns a message with the name', async () => {
    const { req, res } = createMocks({
      method: 'GET',
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    expect(JSON.parse(res._getData())).toEqual({
      name: 'John Doe',
    });
  });
});
