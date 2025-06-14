import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import col, to_timestamp, current_timestamp

# Initialize Glue context
args = getResolvedOptions(sys.argv, ['JOB_NAME', 's3_bucket', 'redshift_connection'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Configuration
s3_bucket = args['s3_bucket']
redshift_connection = args['redshift_connection']

def process_customers():
    # Read customer data from S3
    customers_df = spark.read.format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load(f"s3://{s3_bucket}/raw/customers/")
    
    # Transform data
    customers_df = customers_df \
        .withColumn("created_at", to_timestamp(col("created_at"))) \
        .withColumn("updated_at", to_timestamp(col("updated_at"))) \
        .withColumn("processed_at", current_timestamp())
    
    # Convert to DynamicFrame
    customers_dyf = DynamicFrame.fromDF(customers_df, glueContext, "customers_dyf")
    
    # Write to Redshift
    glueContext.write_dynamic_frame.from_jdbc_conf(
        frame=customers_dyf,
        catalog_connection=redshift_connection,
        connection_options={
            "dbtable": "raw.customers",
            "database": "fintech_db"
        },
        transformation_ctx="write_customers"
    )

def process_transactions():
    # Read transaction data from S3
    transactions_df = spark.read.format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .load(f"s3://{s3_bucket}/raw/transactions/")
    
    # Transform data
    transactions_df = transactions_df \
        .withColumn("transaction_date", to_timestamp(col("transaction_date"))) \
        .withColumn("processed_at", current_timestamp())
    
    # Convert to DynamicFrame
    transactions_dyf = DynamicFrame.fromDF(transactions_df, glueContext, "transactions_dyf")
    
    # Write to Redshift
    glueContext.write_dynamic_frame.from_jdbc_conf(
        frame=transactions_dyf,
        catalog_connection=redshift_connection,
        connection_options={
            "dbtable": "raw.transactions",
            "database": "fintech_db"
        },
        transformation_ctx="write_transactions"
    )

# Execute ETL processes
process_customers()
process_transactions()

job.commit() 