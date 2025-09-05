#!/usr/bin/env node

/**
 * SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Validation script for auto-label-config.json
 * This script validates the configuration file and simulates label matching
 */

const fs = require('fs');
const path = require('path');

// Load configuration
const configPath = path.join(__dirname, '..', '.github', 'auto-label-config.json');

try {
  const configContent = fs.readFileSync(configPath, 'utf8');
  const config = JSON.parse(configContent);
  
  console.log('✅ Configuration file loaded successfully');
  console.log(`📄 Enabled: ${config.enabled}`);
  console.log(`📊 Max labels: ${config.max_labels}`);
  
  // Validate structure
  const requiredSections = ['type_rules', 'priority_rules', 'status_rules'];
  const optionalSections = ['area_rules', 'conventional_commit_mappings'];
  const missingSections = requiredSections.filter(section => !config[section]);
  
  if (missingSections.length > 0) {
    console.log(`❌ Missing required sections: ${missingSections.join(', ')}`);
    process.exit(1);
  }
  
  // Count rules
  const typeRulesCount = Object.keys(config.type_rules || {}).length;
  const priorityRulesCount = Object.keys(config.priority_rules || {}).length;
  const statusRulesCount = Object.keys(config.status_rules || {}).length;
  const areaRulesCount = Object.keys(config.area_rules || {}).length;
  
  console.log(`📋 Type rules: ${typeRulesCount}`);
  console.log(`🚨 Priority rules: ${priorityRulesCount}`);
  console.log(`📊 Status rules: ${statusRulesCount}`);
  console.log(`🗺️ Area rules: ${areaRulesCount}`);
  
  // Validate conventional commit mappings
  if (config.conventional_commit_mappings) {
    const typeMapCount = Object.keys(config.conventional_commit_mappings.types || {}).length;
    const scopeMapCount = Object.keys(config.conventional_commit_mappings.scopes || {}).length;
    console.log(`🔗 Conventional commit type mappings: ${typeMapCount}`);
    console.log(`🎯 Conventional commit scope mappings: ${scopeMapCount}`);
  }
  
  // Test sample inputs
  const testCases = [
    { title: 'fix: resolve authentication bug', expected: ['type: fix'] },
    { title: 'feat: add new container support', expected: ['type: feature'] },
    { title: 'docs: update README with examples', expected: ['type: docs'] },
    { title: 'chore: update dependencies', expected: ['type: maintenance'] },
    { title: 'perf: optimize image building', expected: ['performance'] },
    { title: 'ci: update workflow configuration', expected: ['area/build'] },
    { title: 'feat!: breaking API changes', expected: ['type: feature', 'priority: critical'] },
    { title: 'urgent: critical security vulnerability', expected: ['priority: critical'] },
    { title: 'wip: implementing new feature', expected: ['status: wip'] },
    { title: 'docker container optimization', expected: ['area/containers'] },
    { title: 'security vulnerability in auth', expected: ['area/security', 'priority: critical'] }
  ];
  
  console.log('\n🧪 Testing sample inputs:');
  
  testCases.forEach(testCase => {
    const title = testCase.title.toLowerCase();
    const matchedLabels = [];
    
    // Test type rules
    for (const [labelName, rule] of Object.entries(config.type_rules)) {
      if (rule.enabled && rule.keywords.some(keyword => title.includes(keyword.toLowerCase()))) {
        matchedLabels.push(labelName);
        break; // Only one type label
      }
    }
    
    // Test priority rules
    for (const [labelName, rule] of Object.entries(config.priority_rules)) {
      if (rule.enabled && rule.keywords.some(keyword => title.includes(keyword.toLowerCase()))) {
        matchedLabels.push(labelName);
        break; // Only one priority label
      }
    }
    
    // Test area rules
    for (const [labelName, rule] of Object.entries(config.area_rules || {})) {
      if (rule.enabled && rule.keywords.some(keyword => title.includes(keyword.toLowerCase()))) {
        matchedLabels.push(labelName);
        break; // Only one area label
      }
    }
    
    // Test status rules
    for (const [labelName, rule] of Object.entries(config.status_rules || {})) {
      if (rule.enabled && rule.keywords.some(keyword => title.includes(keyword.toLowerCase()))) {
        matchedLabels.push(labelName);
        break; // Only one status label
      }
    }
    
    const passed = testCase.expected.every(label => matchedLabels.includes(label));
    const status = passed ? '✅' : '❌';
    console.log(`${status} "${testCase.title}" -> [${matchedLabels.join(', ')}]`);
  });
  
  console.log('\n✅ Validation completed successfully!');
  
} catch (error) {
  console.error(`❌ Error validating configuration: ${error.message}`);
  process.exit(1);
}
