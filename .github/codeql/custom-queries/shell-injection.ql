// SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
//
// SPDX-License-Identifier: Apache-2.0

/**
 * @name Shell command injection in containers
 * @description Detects potential shell command injection vulnerabilities in container scripts
 * @kind problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id container/shell-injection
 * @tags security
 *       security/container
 *       security/shell
 *       security/injection
 *       external/cwe/cwe-78
 */

import python

/**
 * Functions that execute shell commands
 */
class ShellExecutionFunction extends Callable {
  ShellExecutionFunction() {
    this.getName() in [
      "system", "popen", "spawn", "exec", "execl", "execle", "execlp",
      "execv", "execve", "execvp", "execvpe", "spawnl", "spawnle", "spawnlp",
      "spawnv", "spawnve", "spawnvp", "spawnvpe"
    ] or
    this.getQualifiedName() in [
      "os.system", "os.popen", "os.spawn", "os.exec",
      "subprocess.call", "subprocess.check_call", "subprocess.check_output",
      "subprocess.run", "subprocess.Popen",
      "commands.getoutput", "commands.getstatusoutput"
    ]
  }
}

/**
 * User-controlled input that could be dangerous in shell commands
 */
class UserControlledInput extends Expr {
  UserControlledInput() {
    // Environment variables (common in containers)
    exists(Call call |
      call.getFunc().(Attribute).getName() = "get" and
      call.getFunc().(Attribute).getObject().getName() = "environ"
    ) or
    // Command line arguments
    exists(Subscript sub |
      sub.getObject().(Name).getId() = "argv"
    ) or
    // File reads (could contain user data)
    exists(Call call |
      call.getFunc().(Attribute).getName() in ["read", "readline", "readlines"] or
      call.getFunc().(Name).getId() in ["open", "input"]
    ) or
    // Web input (for container web apps)
    exists(Call call |
      call.getFunc().(Attribute).getObject().getName() in ["request", "form", "args", "json"]
    )
  }
}

/**
 * Shell command calls with potential injection
 */
from Call call, ShellExecutionFunction func, UserControlledInput userInput
where
  call.getFunc() = func.getAReference() and
  userInput = call.getAnArg() and
  // Exclude cases with proper shell escaping
  not exists(Call escapeCall |
    escapeCall.getFunc().(Attribute).getName() in ["quote", "escape"] and
    escapeCall.getAnArg() = userInput
  )
select call,
  "Potential shell command injection vulnerability in container script. " +
  "User-controlled input is used in shell command execution without proper sanitization. " +
  "Consider using parameterized commands or proper input validation."
