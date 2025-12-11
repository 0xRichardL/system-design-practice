# Mermaid.js Syntax Guide for System Design

## Basic Graph Syntax

### Graph Direction

```mermaid
graph TB  # Top to Bottom
graph LR  # Left to Right
graph BT  # Bottom to Top
graph RL  # Right to Left
```

### Node Shapes

```mermaid
graph LR
    A[Rectangle]
    B(Rounded)
    C([Stadium])
    D[[Subroutine]]
    E[(Database)]
    F((Circle))
    G>Asymmetric]
    H{Diamond}
```

### Connections

```mermaid
graph LR
    A --> B        # Arrow
    A --- B        # Line
    A -.-> B       # Dotted arrow
    A ==> B        # Thick arrow
    A -- text --> B  # Arrow with label
```

## System Design Patterns

### Load Balancer Pattern

```mermaid
graph TB
    Client[Client] --> LB[Load Balancer]
    LB --> Server1[Server 1]
    LB --> Server2[Server 2]
    LB --> Server3[Server 3]
```

### Caching Pattern

```mermaid
graph LR
    App[Application] --> Cache[(Cache)]
    App --> DB[(Database)]
    Cache -.->|Cache Miss| DB
```

### Microservices Pattern

```mermaid
graph TB
    Client --> Gateway[API Gateway]
    Gateway --> Auth[Auth Service]
    Gateway --> User[User Service]
    Gateway --> Order[Order Service]
    Auth --> AuthDB[(Auth DB)]
    User --> UserDB[(User DB)]
    Order --> OrderDB[(Order DB)]
```

## Styling

### Node Styling

```mermaid
graph TB
    A[Node A]
    B[Node B]
    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#f66,stroke-width:2px
```

### Subgraphs

```mermaid
graph TB
    subgraph "Frontend"
        A[Web App]
        B[Mobile App]
    end
    subgraph "Backend"
        C[API Server]
        D[Database]
    end
    A --> C
    B --> C
    C --> D
```

## Sequence Diagrams

Use sequence diagrams for API flows:

```mermaid
sequenceDiagram
    Client->>+Server: Request
    Server->>+Database: Query
    Database-->>-Server: Result
    Server-->>-Client: Response
```

## Best Practices

1. **Keep it Simple**: Don't overcrowd diagrams
2. **Use Subgraphs**: Group related components
3. **Consistent Naming**: Use clear, descriptive names
4. **Add Legends**: Explain symbols if needed
5. **Use Colors**: Differentiate layers/types of components
6. **Label Connections**: Show data flow direction and type

## Common System Design Components

### Database Symbol
```mermaid
graph LR
    DB[(Database Name)]
```

### Cache Symbol
```mermaid
graph LR
    Cache[(Redis/Memcached)]
```

### Queue Symbol
```mermaid
graph LR
    Queue[Message Queue<br/>Kafka/RabbitMQ]
```

### Load Balancer
```mermaid
graph LR
    LB[Load Balancer<br/>Nginx/HAProxy]
```

## Examples

### Three-Tier Architecture

```mermaid
graph TB
    subgraph "Presentation Tier"
        UI[User Interface]
    end
    subgraph "Application Tier"
        API[API Server]
        Logic[Business Logic]
    end
    subgraph "Data Tier"
        DB[(Database)]
        Cache[(Cache)]
    end
    UI --> API
    API --> Logic
    Logic --> Cache
    Logic --> DB
```

### Event-Driven Architecture

```mermaid
graph LR
    Service1[Service 1] -->|Publish| Queue[Event Queue]
    Service2[Service 2] -->|Publish| Queue
    Queue -->|Subscribe| Service3[Service 3]
    Queue -->|Subscribe| Service4[Service 4]
```

## Reference

For complete syntax reference, visit: [Mermaid Documentation](https://mermaid.js.org/intro/)
