declare module 'ratelimiter' {
  import Redis from 'ioredis';

  interface Options {
    duration?: number;
    max?: number;
    id?: string;
  }

  export class Ratelimiter {
    constructor(redis: Redis, options?: Options);
    get(
      id: string,
      callback: (err: Error | null, info: { total: number; remaining: number; reset: number }) => void
    ): void;
  }
}
