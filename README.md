# CLI Arena Web Next.js

This is a web application built with Next.js, TypeScript, and PostgreSQL. It serves as the foundation for the CLI Arena project.

## Project Purpose

The primary purpose of this project is to provide a web interface for the CLI Arena. It will allow users to view and manage tasks, and interact with the system.

## Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/cli-arena-web-nextjs.git
    ```
2.  Install dependencies:
    ```bash
    make setup
    ```

## Building the Application

To build the application for production, run the following command:

```bash
make build
```

## Serving the Application

To serve the application in development mode, run the following command:

```bash
make serve
```

## Docker

To run the application using Docker, first create a `.env` file with the required environment variables. Then, run the following command:

```bash
docker-compose up -d
```

## Testing

To run the test suite, use the following command:

```bash
make test
```

## Linting

To lint the codebase, use the following command:

```bash
make lint
```

## Contact

If you have any questions or feedback, please contact us at [email protected]
