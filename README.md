# THE-SYMPHONY-PLOTTER
 Processing software for drawing pen plotter art from music, developed for Japan Philharmonic Orchestra's “Transforming Concerts”.

## Environments
The following versions have been tested and confirmed to work:
- **Processing**: 4.3
- **Python**: 3.12.7

## Get Started

Follow these steps to get started with the project.

### 1. Generate Audio Data
Run the `audioAnalysis.py` script to generate audio data.

```bash
python audioAnalysis.py
```

### 2. Place and Configure Data
1. Move the generated data file to the `./input` directory.
2. Add the generated file name to the `CSV_PATHS` array in the `constants.pde` file.

Example:
```java
public static final String[] CSV_PATHS = {
    "generatedData.csv",
    // Add other CSV files here if necessary
};
```

### 3. Launch Visualization
Open and run `symphonyPlotter.pde` in Processing.





