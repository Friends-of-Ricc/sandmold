# Test Plan: Comprehensive Classroom YAML Validation

## 1. Goal

To create a robust and thorough validation suite for the classroom YAML configuration files, ensuring that all required fields are present, data types are correct, and logical rules are enforced as specified in `doc/schemas/class_yaml_format.md`.

## 2. Strategy

The current validation script (`tests/test_yaml_validation.py`) is a good starting point but is limited in scope. We will expand this into a modular, multi-file test suite. This will improve maintainability and allow for more targeted and detailed testing.

- **Modular Design:** We will split the validation logic into multiple files, with each file responsible for a specific part of the YAML structure (e.g., `folder` stanza, `schoolbenches` stanza).
- **Main Validator:** The existing `tests/test_yaml_validation.py` will be refactored to act as an orchestrator, loading the YAML file and calling the specific validation functions from the other modules.
- **Clear Error Reporting:** Each validation check will provide a clear, user-friendly error message indicating what is wrong and where the error occurred in the file.

## 3. Implementation Phases

### Phase 1: Test Suite Structure

1.  **Create `tests/validation` directory:** A new directory to hold the modular validation files.
2.  **Create Validator Modules:**
    - `tests/validation/common.py`: Helper functions and constants.
    - `tests/validation/test_folder_stanza.py`: All validation logic for the `folder` stanza.
    - `tests/validation/test_schoolbenches_stanza.py`: All validation logic for the `schoolbenches` stanza.
    - `tests/validation/test_common_stanza.py`: All validation logic for the `common` stanza.
3.  **Refactor `tests/test_yaml_validation.py`:** This script will be the main entry point. It will:
    - Parse command-line arguments.
    - Load the classroom YAML file.
    - Call the validation functions from the other modules in sequence.

### Phase 2: Detailed Test Cases

The following checks will be implemented in their respective modules:

#### **A. Top-Level Validation** (`test_yaml_validation.py`)

- [ ] Fail if root is not a dictionary.
- [ ] Fail if `folder` stanza is missing.
- [ ] Fail if `schoolbenches` stanza is missing.

#### **B. `folder` Stanza Validation** (`test_folder_stanza.py`)

- [ ] **Mandatory Fields:** Fail if any of the following are missing:
    - `org_id`
    - `domain`
    - `parent_folder_id`
    - `billing_account_id`
    - `name`
    - `description`
    - `teachers`
- [ ] **Data Types:**
    - `org_id`: must be a numeric value.
    - `domain`, `parent_folder_id`, `billing_account_id`, `name`, `description`: must be non-empty strings.
    - `teachers`: must be a non-empty list of strings (emails).
    - `env` (if present): must be a list of dictionaries, each with `name` and `value` keys.
    - `labels` (if present): must be a list of dictionaries, each with `key` and `value` keys.

#### **C. `schoolbenches` Stanza Validation** (`test_schoolbenches_stanza.py`)

- [ ] Must be a non-empty list of dictionaries.
- [ ] For each "bench" in the list:
    - [ ] **Mandatory Fields:** Fail if `project` or `seats` are missing.
    - [ ] **Data Types & Rules:**
        - `project`: must be a string and must not contain underscores (`_`).
        - `seats`: must be a non-empty list of strings (emails).
        - `type` (if present): must be either "teacher" or "student".
        - `apps` (if present): must be a list of strings.
        - `app` (if present): must be a string.

#### **D. `common` Stanza Validation** (`test_common_stanza.py`)

- [ ] If `common` stanza exists, it must be a dictionary.
- [ ] If `common.schoolbenches` exists, it must be a dictionary.
- [ ] If `common.schoolbenches.foreach_project` exists, it must be a dictionary.
- [ ] `applies_to` field must exist and be one of `ALL_STUDENTS` or `ALL`.
- [ ] `apps` (if present): must be a list of strings.
- [ ] `seats` (if present): must be a list of strings.

## 4. Next Steps

Once this plan is approved, I will begin with Phase 1 by creating the new directory structure and refactoring the main test script. I will then proceed to implement the detailed test cases in Phase 2, one module at a time.
