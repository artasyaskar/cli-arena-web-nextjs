import { prisma } from './prisma';
import { EventEmitter } from 'events';

export const logEmitter = new EventEmitter();

export interface LogEntry {
  id: string;
  level: 'debug' | 'info' | 'warn' | 'error';
  message: string;
  timestamp: Date;
  userId?: string;
  metadata?: Record<string, unknown>;
}

export class Logger {
  private static instance: Logger;
  private logs: LogEntry[] = [];

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  log(level: LogEntry['level'], message: string, userId?: string, metadata?: Record<string, unknown>) {
    const entry: LogEntry = {
      id: Math.random().toString(36),
      level,
      message,
      timestamp: new Date(),
      userId,
      metadata,
    };

    this.logs.push(entry);
    logEmitter.emit('log', entry);
    
    // Keep only last 1000 logs in memory
    if (this.logs.length > 1000) {
      this.logs = this.logs.slice(-1000);
    }

    // In a real app, you'd persist to database here
    console.log(`[${entry.level.toUpperCase()}] ${entry.message}`, entry.metadata);
  }

  debug(message: string, userId?: string, metadata?: Record<string, unknown>) {
    this.log('debug', message, userId, metadata);
  }

  info(message: string, userId?: string, metadata?: Record<string, unknown>) {
    this.log('info', message, userId, metadata);
  }

  warn(message: string, userId?: string, metadata?: Record<string, unknown>) {
    this.log('warn', message, userId, metadata);
  }

  error(message: string, userId?: string, metadata?: Record<string, unknown>) {
    this.log('error', message, userId, metadata);
  }

  getLogs(userId?: string): LogEntry[] {
    if (userId) {
      return this.logs.filter(log => log.userId === userId);
    }
    return this.logs;
  }
}

export const logger = Logger.getInstance();

export const log = async (message: string, userId: string) => {
  const logEntry = await prisma.log.create({
    data: {
      message,
      userId,
    },
  });
  logEmitter.emit('log', logEntry);
};