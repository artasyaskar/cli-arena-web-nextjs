// tests/mocks/next/server.ts

export class NextRequest extends Request {
  constructor(input: RequestInfo, init?: RequestInit) {
    super(input, init);
  }
}

export const NextResponse = {
  next: () => ({
    headers: new Headers(),
  }),

  json: (data: any, options?: { status?: number; headers?: HeadersInit }) =>
    new Response(JSON.stringify(data), {
      status: options?.status ?? 200,
      headers: {
        'Content-Type': 'application/json',
        ...(options?.headers || {}),
      },
    }),
};
