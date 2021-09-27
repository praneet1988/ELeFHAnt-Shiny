#### Celltype Annotation Module
Celltype annotation is a function to annotate celltypes in single cell datasets. It requires a reference dataset (a processed Seurat Object with Celltypes column in metadata) and a query dataset (a processed seurat object with seurat_clusters column in metadata).

#### Label Harmonization Module
Label Harmonization is a function used to harmonize cell labels (celltypes) across single cell datasets. It requires an integrated seurat object (seurat object with Celltypes and seurat_clusters columns in the metadata).

#### Deduce Relationship Module
Deduce Relationship is a function used to infer the similarity between celltypes across single cell datasets. The output is a heatmap that shows relative similarity among celltypes between two refeences. It requires two reference datasets (both processed Seurat Objects with Celltypes columns in the metadata).

#### How to process single cell data using Seurat
Please refer to https://satijalab.org/seurat/articles/pbmc3k_tutorial.html to process single cell datasets using Seurat

#### Parameters (Celltype Annotation)

```
Reference: a processed Seurat object with Celltypes column in the metadata

Query: a processed Seurat object with seurat_clusters column in the metadata

Annotaton approach: apprach to classify cells 1) ClassifyCells 2) ClassifyCells_usingApproximation. Default: ClassifyCells. We recommend using ClassifyCells_usingApproximation when reference has significantly less number of cells compared to query

Perform downsampling: logical Indicator (TRUE or FALSE) to downsample reference, enabling fast computation. if classification.approach is set to "ClassifyCells_usingApproximation" query will be downsampled along with reference.

Number of cells to downsample to: a numerical value > 1 to downsample cells [Default: 100] in reference and query for Celltypes and seurat_clusters respectively

k-fold cross validation SVM: if a integer value k>0 is specified, a k-fold cross validation on the training data is performed to assess the quality of the model

Number of features to select for training: number of variable features to select for training (default: 2000)

Number of trees randomForest cclassifier should grow: number of trees randomForest classifier should build (Default: 500)
```

#### Parameters (Label Harmonization)

```
Integrated reference: an integrated Seurat object with CellTypes and seurat_clusters column in meta.data

Perform downsampling: logical Indicator (TRUE or FALSE) to downsample integrated reference, enabling fast computation.

Number of cells to downsample to: a numerical value > 1 to downsample cells [Default: 100]

k-fold cross validation SVM: if a integer value k>0 is specified, a k-fold cross validation on the training data is performed to assess the quality of the model

Number of trees randomForest cclassifier should grow: number of trees randomForest classifier should build (Default: 500)
```

#### Parameters (Deduce Relationship)

```
Reference1: a processed Seurat object with Celltypes column in the metadata

Reference2: a processed Seurat object with Celltypes column in the metadata

Perform downsampling: logical Indicator (TRUE or FALSE) to downsample reference1 and reference2, enabling fast computation.

Number of cells to downsample to: a numerical value > 1 to downsample cells [Default: 100]

k-fold cross validation SVM: if a integer value k>0 is specified, a k-fold cross validation on the training data is performed to assess the quality of the model

Number of features to select for training: number of variable features to select for training (default: 2000)

Number of trees randomForest cclassifier should grow: number of trees randomForest classifier should build (Default: 500)
```

#### Important Note:
When selecting genes please wait until all the data has been uploaded (Status: Upload Complete)
This Shiny resource is for exploration purposes. For computationally intensive tasks please use ELeFHAnt R package (https://github.com/praneet1988/ELeFHAnt) 