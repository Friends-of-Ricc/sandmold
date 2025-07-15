# Future Extensions

This document outlines potential future enhancements to the classroom YAML schema. These are not yet implemented but provide a vision for the project's direction.

## Ideas

In the future we might want:

1.  **Make `project` non-mandatory.** The system could auto-generate project names if one is not provided.
2.  **Template-based schoolbenches.** Instead of defining every bench, a user could define a single template and specify a number of benches to create.
3.  **Automatic bench creation from a user list.** Provide a list of emails and a bench size (e.g., 2). The system would then automatically create the correct number of benches, handling any remainders (e.g., 51 users with a bench size of 2 would create 25 pairs and one single-occupant bench).
