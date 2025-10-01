# Big Data Analytics with Apache Spark: Video Games Review Analysis

##  Project Overview
This project implements a complete Big Data analytics pipeline for sentiment analysis and trend identification in Amazon video game reviews. Developed as part of an MSc Data Analytics assignment, it demonstrates hands-on experience with Apache Spark, Databricks, and the Hadoop ecosystem for processing large-scale datasets (>10GB).

The analysis extracts business insights from customer reviews, implements machine learning models for sentiment classification, and compares Spark's performance against traditional MapReduce.

##  Business Understanding
**Problem Statement**: Video game companies need to process millions of customer reviews to understand customer satisfaction, identify product issues, and guide development priorities.

**Big Data Need**: Manual analysis of large-scale review data is infeasible. This solution provides automated sentiment analysis at scale.

**Value Proposition**: Enables data-driven decisions for product improvement, customer service optimization, and targeted marketing strategies.

##  Dataset
- **Source**: Amazon Customer Reviews (Video Games category)
- **Size**: >10GB total (4.6M+ reviews in full dataset)
- **Format**: JSONL files containing review text and product metadata
- **Access**: Publicly available through AWS Registry of Open Data

##  Technical Implementation

### Environment Setup
- **Platform**: Databricks Cloud Environment
- **Processing Framework**: Apache Spark 3.0+
- **Language**: Python (PySpark)
- **Storage**: Cloud object storage with HDFS-like distribution

### Data Processing Pipeline
1. **Data Ingestion**: Loading JSONL files from cloud storage with schema inference
2. **Data Cleaning**: Handling duplicate column names, missing values, and data quality issues
3. **Feature Engineering**:
   - Sentiment classification (Positive/Negative/Neutral) based on ratings
   - Review length analysis and helpfulness ratios
   - Temporal features (review dates, seasonal trends)
4. **Advanced Analytics**:
   - Multi-level aggregations and window functions
   - Time-series trend analysis
   - Customer behavior segmentation

### Machine Learning
- **Classification**: Sentiment prediction using feature-based modeling
- **Regression**: Rating prediction based on review characteristics
- **Feature Importance**: Identifying key drivers of customer satisfaction

##  Key Insights & Results

### Performance Comparison: Spark vs MapReduce
| Aspect | Apache Spark | Traditional MapReduce |
|--------|--------------|----------------------|
| **Processing Speed** | 10-100x faster (in-memory computation) | Disk I/O bottlenecks |
| **Code Complexity** | Simple DataFrame API, less code | Complex Mapper/Reducer classes |
| **Development Time** | Faster coding and debugging | Steep learning curve |
| **Functionality** | Built-in ML libraries, SQL, Streaming | Basic map and reduce only |

### Business Recommendations
1. **Customer Satisfaction**: Focus on products with declining positive sentiment ratios
2. **Review Engagement**: Implement prompts for detailed feedback based on review length insights
3. **Product Development**: Use feature importance analysis to prioritize improvements
4. **Quality Monitoring**: Automated sentiment alerts for negative review trends

##  Getting Started

### Prerequisites
- Apache Spark 3.0+
- Python 3.8+
- Databricks Runtime or similar Spark environment

### Installation
```bash
# Clone repository
git clone https://github.com/Prayag9497/video-games-sentiment-analysis.git

# Navigate to project directory
cd video-games-sentiment-analysis
