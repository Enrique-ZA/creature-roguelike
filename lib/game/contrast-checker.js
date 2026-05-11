/**
 * WCAG Color Contrast Checker
 * Calculates the contrast ratio between two colors and checks against WCAG standards.
 * 
 * Usage: node contrast-checker.js <foreground_hex> <background_hex>
 * Example: node contrast-checker.js #0000FF #FFFFFF
 */

function getRelativeLuminance(hex) {
  // Remove # if present
  const cleanHex = hex.replace('#', '');
  
  // Convert hex to RGB
  const r8 = parseInt(cleanHex.substring(0, 2), 16);
  const g8 = parseInt(cleanHex.substring(2, 4), 16);
  const b8 = parseInt(cleanHex.substring(4, 6), 16);

  const rsRGB = r8 / 255;
  const gsRGB = g8 / 255;
  const bsRGB = b8 / 255;

  const r = rsRGB <= 0.03928 ? rsRGB / 12.92 : Math.pow((rsRGB + 0.055) / 1.055, 2.4);
  const g = gsRGB <= 0.03928 ? gsRGB / 12.92 : Math.pow((gsRGB + 0.055) / 1.055, 2.4);
  const b = bsRGB <= 0.03928 ? bsRGB / 12.92 : Math.pow((bsRGB + 0.055) / 1.055, 2.4);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

function getContrastRatio(l1, l2) {
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

function checkContrast(fgHex, bgHex) {
  try {
    const l1 = getRelativeLuminance(fgHex);
    const l2 = getRelativeLuminance(bgHex);
    const ratio = getContrastRatio(l1, l2);

    console.log(`Foreground: ${fgHex}`);
    console.log(`Background: ${bgHex}`);
    console.log(`Contrast Ratio: ${ratio.toFixed(2)}:1\n`);

    const results = {
      'Normal Text': {
        'WCAG AA (4.5:1)': ratio >= 4.5 ? 'Pass' : 'Fail',
        'WCAG AAA (7:1)': ratio >= 7 ? 'Pass' : 'Fail',
      },
      'Large Text': {
        'WCAG AA (3:1)': ratio >= 3 ? 'Pass' : 'Fail',
        'WCAG AAA (4.5:1)': ratio >= 4.5 ? 'Pass' : 'Fail',
      },
      'Graphical Objects & UI Components': {
        'WCAG AA (3:1)': ratio >= 3 ? 'Pass' : 'Fail',
      }
    };

    for (const [category, tests] of Object.entries(results)) {
      console.log(`${category}:`);
      for (const [test, status] of Object.entries(tests)) {
        console.log(`  ${test}: ${status}`);
      }
      console.log('');
    }
  } catch (error) {
    console.error('Error: Invalid hex color format. Use #RRGGBB.');
    process.exit(1);
  }
}

// CLI Argument Handling
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log('Usage: node contrast-checker.js <foreground_hex> <background_hex>');
  process.exit(1);
}

checkContrast(args[0], args[1]);
