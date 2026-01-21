# Scripts

The scripts included in this folder are intended to serve as examples and may be deleted or changed as per project needs. They provide a starting point for common data cleaning and analysis workflows but should be adapted to fit your specific project requirements.

## Downloading the Do File from SurveyCTO

SurveyCTO can automatically generate a Stata do file that imports your raw CSV data into Stata format. To download this file:

1. Log in to your SurveyCTO server
2. Navigate to the **Export** tab for your form
3. Click on **Export data**
4. In the export options, select **Stata** as the export format
5. Check the box for **Include do file for importing data**
6. Click **Export** to download the ZIP file containing both the CSV data and the do file

The generated do file will:
- Import the CSV file with the correct variable types
- Apply variable labels from your form definitions
- Apply value labels for categorical variables
- Handle date and time variables appropriately

To use the do file:
1. Extract the ZIP file contents to your `$raw` folder
2. Open Stata and set your working directory to the raw data folder
3. Run the do file: `do "formname_import.do"`
4. The data will be loaded into Stata with all labels applied

**Note:** You may need to modify the file paths in the generated do file to match your project's folder structure defined in `00_setup.do`.

## Using iefieldkit

[iefieldkit](https://dimewiki.worldbank.org/Iefieldkit) is a Stata package developed by the World Bank's DIME team for managing data collected in field surveys. It provides powerful tools for codebook-based data management.

### Installation

Install iefieldkit from SSC (as shown in `00_setup.do`):

```stata
ssc install iefieldkit
```

### Key Commands

#### iecodebook template

Generates an Excel template for documenting and modifying your dataset:

```stata
iecodebook template using "codebook_template.xlsx"
```

This creates an Excel file where you can:
- Rename variables
- Add or modify variable labels
- Add or modify value labels
- Drop unnecessary variables
- Recode values

#### iecodebook apply

Applies changes from your completed codebook template to the dataset:

```stata
iecodebook apply using "codebook_template.xlsx"
```

This is particularly useful for:
- Batch renaming variables
- Applying consistent labels across the team
- Documenting all data transformations in a transparent way

#### iecodebook export

Exports a comprehensive codebook documenting your dataset:

```stata
iecodebook export using "codebook_final.xlsx", replace
```

#### ieduplicates

Identifies and helps resolve duplicate observations:

```stata
ieduplicates unique_id using "duplicates_report.xlsx", uniquevars(unique_id)
```

This creates an Excel file listing all duplicates for manual review and resolution.

### Benefits of iefieldkit

- **Excel-based workflow**: Non-Stata users can participate in data documentation
- **Reproducibility**: All changes are documented in Excel files
- **Efficiency**: Batch operations replace repetitive manual coding
- **Collaboration**: Teams can review and approve changes before applying them

For more detailed documentation, visit the [iefieldkit wiki](https://dimewiki.worldbank.org/Iefieldkit).
