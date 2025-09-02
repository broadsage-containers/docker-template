// SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
//
// SPDX-License-Identifier: Apache-2.0

/**
 * @name Insecure Dockerfile patterns
 * @description Detects insecure patterns commonly found in Dockerfiles
 * @kind problem
 * @problem.severity warning
 * @security-severity 6.0
 * @precision medium
 * @id container/insecure-dockerfile
 * @tags security
 *       security/container
 *       security/dockerfile
 *       maintainability/security
 */

import python

/**
 * Patterns indicating insecure Dockerfile practices
 */
class InsecureDockerfilePattern extends StrConst {
  InsecureDockerfilePattern() {
    exists(string value | value = this.getText() |
      // Avoid running as root
      value.regexpMatch("(?i).*USER\\s+root.*") or
      value.regexpMatch("(?i).*USER\\s+0.*") or
      
      // Avoid privileged containers
      value.regexpMatch("(?i).*--privileged.*") or
      
      // Avoid latest tags
      value.regexpMatch("(?i).*:latest.*") or
      
      // Avoid ADD when COPY should be used
      value.regexpMatch("(?i)ADD\\s+http.*") or
      
      // Avoid curl/wget in single RUN without cleanup
      value.regexpMatch("(?i).*curl\\s+.*&&\\s*$") or
      value.regexpMatch("(?i).*wget\\s+.*&&\\s*$") or
      
      // Avoid package managers without cleanup
      value.regexpMatch("(?i).*apt-get\\s+install.*&&\\s*$") or
      value.regexpMatch("(?i).*yum\\s+install.*&&\\s*$") or
      value.regexpMatch("(?i).*apk\\s+add.*&&\\s*$") or
      
      // Avoid hardcoded secrets
      value.regexpMatch("(?i).*password\\s*=.*") or
      value.regexpMatch("(?i).*secret\\s*=.*") or
      value.regexpMatch("(?i).*token\\s*=.*") or
      value.regexpMatch("(?i).*api_key\\s*=.*") or
      
      // Avoid insecure COPY patterns
      value.regexpMatch("(?i)COPY\\s+\\.\\s+/.*") or
      
      // Avoid running unnecessary services
      value.regexpMatch("(?i).*ssh.*") or
      value.regexpMatch("(?i).*systemd.*") or
      
      // Avoid insecure network configurations
      value.regexpMatch("(?i).*EXPOSE\\s+22.*") or
      value.regexpMatch("(?i).*EXPOSE\\s+3389.*")
    )
  }
  
  string getIssueType() {
    exists(string value | value = this.getText() |
      if value.regexpMatch("(?i).*password\\s*=.*|.*secret\\s*=.*|.*token\\s*=.*|.*api_key\\s*=.*")
      then result = "hardcoded-secrets"
      else if value.regexpMatch("(?i).*USER\\s+root.*|.*USER\\s+0.*|.*--privileged.*")
      then result = "privilege-escalation"
      else if value.regexpMatch("(?i).*:latest.*")
      then result = "unversioned-base-image"
      else if value.regexpMatch("(?i).*apt-get\\s+install.*&&\\s*$|.*yum\\s+install.*&&\\s*$")
      then result = "package-manager-cleanup"
      else if value.regexpMatch("(?i)COPY\\s+\\.\\s+/.*")
      then result = "overly-broad-copy"
      else if value.regexpMatch("(?i).*EXPOSE\\s+22.*|.*EXPOSE\\s+3389.*")
      then result = "insecure-port-exposure"
      else result = "general-insecurity"
    )
  }
  
  string getRecommendation() {
    exists(string issueType | issueType = this.getIssueType() |
      if issueType = "hardcoded-secrets"
      then result = "Use environment variables or secrets management instead of hardcoded credentials"
      else if issueType = "privilege-escalation" 
      then result = "Run containers as non-root user and avoid privileged mode"
      else if issueType = "unversioned-base-image"
      then result = "Use specific version tags instead of 'latest' for reproducible builds"
      else if issueType = "package-manager-cleanup"
      then result = "Clean up package manager cache in the same RUN instruction"
      else if issueType = "overly-broad-copy"
      then result = "Use specific file patterns instead of copying entire directory"
      else if issueType = "insecure-port-exposure"
      then result = "Avoid exposing administrative ports (SSH, RDP) in containers"
      else result = "Review Dockerfile security best practices"
    )
  }
}

/**
 * Check for insecure Dockerfile patterns in string literals
 */
from InsecureDockerfilePattern pattern
where
  // Only check files that might contain Dockerfile content
  (pattern.getLocation().getFile().getBaseName().matches("*dockerfile*") or
   pattern.getLocation().getFile().getBaseName().matches("*docker*") or
   pattern.getLocation().getFile().getExtension() = "" or  // Dockerfile usually has no extension
   pattern.getText().regexpMatch("(?i).*(FROM|RUN|COPY|ADD|USER|EXPOSE).*")) and
  // Exclude test files
  not pattern.getLocation().getFile().getBaseName().matches("*test*")
select pattern,
  "Insecure Dockerfile pattern detected (" + pattern.getIssueType() + "): " +
  pattern.getRecommendation()
