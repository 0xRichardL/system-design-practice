#!/usr/bin/env node

/**
 * Simple Mermaid diagram validator
 * Checks if .mmd files have valid basic syntax
 */

const fs = require('fs');
const path = require('path');

const DIAGRAMS_DIR = path.join(__dirname, 'diagrams');

function validateMermaidFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const errors = [];
    
    // Check if file starts with a valid diagram type
    const validTypes = [
        'graph', 'flowchart', 'sequenceDiagram', 'classDiagram', 
        'stateDiagram', 'erDiagram', 'journey', 'gantt', 'pie',
        'gitGraph', 'requirementDiagram', 'C4Context', 'mindmap',
        'timeline', 'zenuml', 'sankey-beta'
    ];
    const firstLine = content.trim().split('\n')[0];
    
    const hasValidType = validTypes.some(type => firstLine.startsWith(type));
    if (!hasValidType) {
        errors.push('File does not start with a valid Mermaid diagram type');
    }
    
    // Check for common connection syntax (only warn if graph/flowchart type)
    const isGraphType = firstLine.startsWith('graph') || firstLine.startsWith('flowchart');
    if (isGraphType) {
        // Check for various Mermaid connection types
        const connectionPattern = /-{2,3}>|={2,3}>|\.-+>|~{3,}/;
        const hasConnections = connectionPattern.test(content);
        if (!hasConnections) {
            errors.push('Warning: No connections found in graph diagram');
        }
    }
    
    return errors;
}

function main() {
    console.log('🔍 Validating Mermaid diagrams...\n');
    
    const files = fs.readdirSync(DIAGRAMS_DIR)
        .filter(file => file.endsWith('.mmd'));
    
    let hasErrors = false;
    
    files.forEach(file => {
        const filePath = path.join(DIAGRAMS_DIR, file);
        const errors = validateMermaidFile(filePath);
        
        if (errors.length === 0) {
            console.log(`✅ ${file} - Valid`);
        } else {
            console.log(`❌ ${file} - Issues found:`);
            errors.forEach(error => console.log(`   - ${error}`));
            hasErrors = true;
        }
    });
    
    console.log(`\n📊 Validated ${files.length} diagram(s)`);
    
    if (hasErrors) {
        process.exit(1);
    } else {
        console.log('✨ All diagrams are valid!');
        process.exit(0);
    }
}

if (require.main === module) {
    main();
}

module.exports = { validateMermaidFile };
