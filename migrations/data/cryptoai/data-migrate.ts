import * as fs from 'fs';
import * as glob from 'glob';
import * as path from 'path';
const { parseSync } = require('svgson');

// Use absolute path to testAssets folder
const PATH_ASSETS = path.join(__dirname, '../cryptoai/assetsV2');
const PATH_OUTPUT = 'migrations/data/cryptoai/datajson/data-compressed.json';
const PATH_OUTPUT_ERRORS = 'migrations/data/cryptoai/datajson/data-errors.json';

interface PixelData {
  name: string;
  trait: number;
  positions: number[];
}

// Create a palette map to store unique colors
const colorPalette: number[][] = [];

const getColorIndex = (color: number[]): number => {
  const colorString = `rgb(${color[0]},${color[1]},${color[2]})`;
  let index = colorPalette.findIndex(c => c[0] === color[0] && c[1] === color[1] && c[2] === color[2]);
  if (index === -1) {
    index = colorPalette.length;
    colorPalette.push(color);
  }
  return index;
};

const convertSvgToPositions = (svgContent: string, filePath: string): number[] => {
  const parsed = parseSync(svgContent);
  const positions: number[] = [];
  const errors: string[] = [];

  const processRect = (rect: any) => {
    try {
      const x = parseInt(rect.attributes.x);
      const y = parseInt(rect.attributes.y);

      // Get color from attributes or default
      const fill = rect.attributes.fill || [0,0,0];

      // Extract RGB values
      let [r,g,b] = [0,0,0];
      if (fill.startsWith('#')) {
        // Convert hex to rgb
        const hex = fill.substring(1);
        r = parseInt(hex.substring(0,2), 16);
        g = parseInt(hex.substring(2,4), 16);
        b = parseInt(hex.substring(4,6), 16);
      } else if (fill.startsWith('rgb')) {
        // Parse rgb format
        [r,g,b] = fill.match(/\d+/g).map(Number);
      }

      if (isNaN(x) || isNaN(y)) {
        throw new Error('Invalid coordinate values');
      }

      // Get palette index for the rgb color
      const colorIndex = getColorIndex([r,g,b]);

      positions.push(x, y, colorIndex);
    } catch (error) {
      // Only store unique error messages for each file
      const errorMsg = `Error processing rect in ${filePath}: ${error.message}`;
      if (!errors.includes(errorMsg)) {
        errors.push(errorMsg);
      }
    }
  };

  const findRects = (node: any) => {
    if (node.name === 'rect') {
      processRect(node);
    }
    if (node.children) {
      node.children.forEach(findRects);
    }
  };

  findRects(parsed);

  // Write errors to file if any occurred
  if (errors.length > 0) {
    let existingErrors = [];
    try {
      if (fs.existsSync(PATH_OUTPUT_ERRORS)) {
        existingErrors = JSON.parse(fs.readFileSync(PATH_OUTPUT_ERRORS, 'utf-8'));
      }

      // Filter out duplicate errors before writing
      const uniqueErrors = Array.from(new Set([...existingErrors, ...errors]));

      fs.writeFileSync(
          PATH_OUTPUT_ERRORS,
          JSON.stringify(uniqueErrors, null, 2)
      );
    } catch (e) {
      // If file doesn't exist or is invalid JSON, write only new errors
      fs.writeFileSync(
          PATH_OUTPUT_ERRORS,
          JSON.stringify(errors, null, 2)
      );
    }
  }

  return positions;
}

const convertAssetsToJson = (assetsPath: string): Record<string, Record<string, any>> => {
  try {
    if (!fs.existsSync(assetsPath)) {
      throw new Error(`Assets directory not found at: ${assetsPath}`);
    }

    const allData: Record<string, Record<string, any>> = {
      palette: colorPalette // Add palette to output data
    };

    // Use glob to find all SVG files in subdirectories
    const svgFiles = glob.sync(path.join(assetsPath, '**/*.svg'));

    svgFiles.forEach((filePath: string) => {
      // Get relative path segments
      const pathSegments = path.relative(assetsPath, filePath).split(path.sep);
      const mainFolder = pathSegments[0]; // First segment is the main folder
      const subFolder = pathSegments[1]; // Second segment is the sub folder
      const [subFolderTitle, subFolderTrait] = subFolder.split('_');

      if (!allData[mainFolder]) {
        allData[mainFolder] = {};
      }

      if (mainFolder === 'DNA') {
        // For DNA folder, group into arrays of names, traits and positions
        if (!allData[mainFolder][subFolderTitle]) {
          allData[mainFolder][subFolderTitle] = {
            trait: subFolderTrait,
            names: [],
            traits: [],
            positions: []
          };
        }

        const svgContent = fs.readFileSync(filePath, 'utf-8');
        const positions = convertSvgToPositions(svgContent, filePath);

        const [name, traitStr] = path.basename(filePath, '.svg').split('_');
        const trait = traitStr ? parseInt(traitStr) : allData[mainFolder][subFolderTitle].traits.length + 1;

        allData[mainFolder][subFolderTitle].names.push(name==='Empty' ? '' :name);
        allData[mainFolder][subFolderTitle].traits.push(trait);
        allData[mainFolder][subFolderTitle].positions.push(positions);

      } else {
        // For non-DNA folders, group into arrays of names, traits and positions
        if (!allData[mainFolder][subFolder]) {
          allData[mainFolder][subFolder] = {
            names: [],
            traits: [],
            positions: []
          };
        }

        const svgContent = fs.readFileSync(filePath, 'utf-8');
        const positions = convertSvgToPositions(svgContent, filePath);

        const [name, traitStr] = path.basename(filePath, '.svg').split('_');
        const trait = traitStr ? parseInt(traitStr) : allData[mainFolder][subFolder].traits.length + 1;

        allData[mainFolder][subFolder].names.push(name==='Empty' ? '' :name);
        allData[mainFolder][subFolder].traits.push(trait);
        allData[mainFolder][subFolder].positions.push(positions);
      }
    });

    console.log('Data processing complete');
    return allData;

  } catch (err) {
    console.error('Error converting assets:', err);
    process.exit(1);
  }
}

try {
  console.log('Assets path:', PATH_ASSETS);
  console.log('Output path:', PATH_OUTPUT);
  const data = convertAssetsToJson(PATH_ASSETS);
  fs.writeFileSync(PATH_OUTPUT, JSON.stringify(data, null, 2));
  console.log('Successfully wrote data to', PATH_OUTPUT);
} catch (err) {
  console.error('Fatal error:', err);
  process.exit(1);
}