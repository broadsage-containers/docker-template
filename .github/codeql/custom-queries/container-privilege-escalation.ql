// SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
//
// SPDX-License-Identifier: Apache-2.0

/**
 * @name Container privilege escalation patterns
 * @description Detects potential privilege escalation vulnerabilities in container configurations
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision medium
 * @id container/privilege-escalation
 * @tags security
 *       security/container
 *       security/privilege
 *       external/cwe/cwe-250
 */

import python

/**
 * Potentially dangerous privilege operations in containers
 */
class PrivilegeEscalationPattern extends StrConst {
  PrivilegeEscalationPattern() {
    exists(string value | value = this.getText().toLowerCase() |
      // Docker privilege flags
      value.matches("*--privileged*") or
      value.matches("*--cap-add*") or
      value.matches("*cap_sys_admin*") or
      value.matches("*cap_dac_override*") or
      value.matches("*cap_setuid*") or
      value.matches("*cap_setgid*") or
      
      // User elevation
      value.matches("*sudo *") or
      value.matches("*su -*") or
      value.matches("*runuser*") or
      
      // File permission changes
      value.matches("*chmod 777*") or
      value.matches("*chmod +s*") or
      value.matches("*chown root*") or
      
      // Process execution as root
      value.matches("*user=root*") or
      value.matches("*uid=0*") or
      value.matches("*gid=0*") or
      
      // Container escape techniques
      value.matches("*/proc/1/root*") or
      value.matches("*/host/*") or
      value.matches("*/var/run/docker.sock*") or
      
      // Dangerous mount points
      value.matches("*/dev/*") or
      value.matches("*/sys/*") or
      value.matches("*/proc/*")
    )
  }
  
  string getRiskLevel() {
    exists(string value | value = this.getText().toLowerCase() |
      if value.matches("*--privileged*") or value.matches("*/var/run/docker.sock*")
      then result = "critical"
      else if value.matches("*sudo *") or value.matches("*cap_sys_admin*")
      then result = "high"
      else result = "medium"
    )
  }
}

/**
 * Variables or string literals containing privilege escalation patterns
 */
from PrivilegeEscalationPattern pattern
where
  // Exclude comments and test files
  not pattern.getLocation().getFile().getBaseName().matches("*test*") and
  not pattern.getLocation().getFile().getBaseName().matches("*example*")
select pattern,
  "Potential privilege escalation pattern detected in container configuration (" + 
  pattern.getRiskLevel() + " risk). " +
  "Review if elevated privileges are necessary and implement principle of least privilege. " +
  "Consider using specific capabilities instead of --privileged flag."
