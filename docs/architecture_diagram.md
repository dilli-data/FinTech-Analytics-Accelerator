# FinTech Analytics Accelerator Architecture Diagram

```mermaid
graph TB
    subgraph "Source Systems"
        A1[Core Banking System]
        A2[Transaction Logs]
        A3[KYC Data]
    end

    subgraph "Data Ingestion"
        B1[AWS S3 Landing Zone]
        B2[AWS Glue ETL]
    end

    subgraph "Data Warehouse"
        C1[Raw Layer]
        C2[Staging Layer]
        C3[Mart Layer]
    end

    subgraph "Data Transformation"
        D1[dbt Models]
        D2[dbt Tests]
        D3[dbt Documentation]
    end

    subgraph "Analytics"
        E1[QuickSight Dashboards]
        E2[ML Models]
        E3[Reports]
    end

    subgraph "Security & Monitoring"
        F1[AWS KMS]
        F2[CloudWatch]
        F3[CloudTrail]
    end

    %% Data Flow
    A1 --> B1
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> C1
    C1 --> C2
    C2 --> C3
    C3 --> D1
    D1 --> E1
    D1 --> E2
    E1 --> E3
    E2 --> E3

    %% Security & Monitoring
    F1 -.-> B1
    F1 -.-> C1
    F2 -.-> B2
    F2 -.-> D1
    F3 -.-> B1
    F3 -.-> C1

    %% Styling
    classDef source fill:#f9f,stroke:#333,stroke-width:2px
    classDef ingestion fill:#bbf,stroke:#333,stroke-width:2px
    classDef warehouse fill:#bfb,stroke:#333,stroke-width:2px
    classDef transformation fill:#fbb,stroke:#333,stroke-width:2px
    classDef analytics fill:#fbf,stroke:#333,stroke-width:2px
    classDef security fill:#ff9,stroke:#333,stroke-width:2px

    class A1,A2,A3 source
    class B1,B2 ingestion
    class C1,C2,C3 warehouse
    class D1,D2,D3 transformation
    class E1,E2,E3 analytics
    class F1,F2,F3 security
```

## Component Details

### Source Systems
- **Core Banking System**: Customer accounts, transactions, and balances
- **Transaction Logs**: Payment processing and ATM transactions
- **KYC Data**: Customer verification and compliance information

### Data Ingestion
- **AWS S3 Landing Zone**: Raw data storage with partitioning
- **AWS Glue ETL**: Data extraction and initial transformation

### Data Warehouse
- **Raw Layer**: Source-aligned tables
- **Staging Layer**: Cleaned and transformed data
- **Mart Layer**: Business-aligned models

### Data Transformation
- **dbt Models**: SQL transformations and business logic
- **dbt Tests**: Data quality and integrity checks
- **dbt Documentation**: Model documentation and lineage

### Analytics
- **QuickSight Dashboards**: Interactive visualizations
- **ML Models**: Predictive analytics
- **Reports**: Scheduled and ad-hoc reporting

### Security & Monitoring
- **AWS KMS**: Encryption key management
- **CloudWatch**: Performance monitoring
- **CloudTrail**: Audit logging 