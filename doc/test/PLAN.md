# Test Plan: Comprehensive Classroom YAML Validation

## 1. Goal

To create a robust, modular, and extensible validation suite for the classroom YAML files, incorporating flexible, regex-based checks for key fields.

## 2. Strategy

We will build a modular test suite that validates each part of the `Classroom` object. A central `common.py` module will store validation constants, including regex patterns, allowing for easy updates as we refine constraints.

## 3. Implementation Phases

### Phase 1: Test Suite Structure

1.  **Create `tests/validation` directory.**
2.  **Create Validator Modules:**
    - `tests/validation/common.py`: **New:** Will store shared constants and regex patterns for validation.
    - `tests/validation/test_root.py`: Validation for top-level fields.
    - `tests/validation/test_spec.py`: Orchestrates validation for the `spec` block.
    - `tests/validation/test_folder_stanza.py`: Validation for `spec.folder`.
    - `tests/validation/test_schoolbenches_stanza.py`: Validation for `spec.schoolbenches`.
    - `tests/validation/test_common_stanza.py`: Validation for `spec.common`.
3.  **Refactor `tests/test_yaml_validation.py`:** The main entry point, which will orchestrate the validation calls.

### Phase 2: Detailed Test Cases

#### **A. Root Object Validation** (`test_root.py`)

- [ ] Fail if the loaded YAML is not a dictionary.
- [ ] **`apiVersion`**: Must exist and be `sandmold.io/v1alpha1`.
- [ ] **`kind`**: Must exist and be `Classroom`.
- [ ] **`metadata`**:
    - [ ] Fail if missing or not a dictionary.
    - [ ] `metadata.name`:
        - [ ] Must exist and be a non-empty string.
        - [ ] **Regex Check:** Must match the `WORKSPACE_NAME_REGEX` (e.g., `^[a-zA-Z0-9_-]+$`) defined in `common.py`.
    - [ ] `metadata.labels`: If present, must be a dictionary of key-value string pairs.
- [ ] **`spec`**: Fail if missing or not a dictionary.

#### **B. `spec` Block Validation** (`test_spec.py` and sub-modules)

- [ ] Fail if `spec.folder` or `spec.schoolbenches` are missing.

##### **`spec.folder` Validation** (`test_folder_stanza.py`)
- [ ] **Mandatory Fields:** `org_id`, `domain`, `parent_folder_id`, `billing_account_id`, `description`, `teachers`.
- [ ] **Data Types & Rules:**
    - `displayName` (if present):
        - [ ] Must be a string.
        - [ ] **Regex Check:** Must match `FOLDER_NAME_REGEX` (e.g., `^.{3,30}$`) from `common.py`.
    - `org_id`: must be numeric.
    - `teachers`: must be a non-empty list of strings.
    - ... (other type checks)

##### **`spec.schoolbenches` Validation** (`test_schoolbenches_stanza.py`)
- [ ] Must be a non-empty list of dictionaries.
- [ ] For each bench:
    - **Mandatory Fields:** `project`, `seats`.
    - **Data Types & Rules:**
        - `project`:
            - [ ] Must be a string.
            - [ ] **Regex Check:** Must match the strict `GCP_PROJECT_ID_REGEX` (e.g., `^[a-z][a-z0-9-]{4,28}[a-z0-9]$`) from `common.py`. This is intentionally strict to prevent immediate deployment failures.
        - `seats`: must be a non-empty list of strings.
        - `desk-type` (if present): must be "teacher" or "student".

##### **`spec.common` Validation** (`test_common_stanza.py`)
- (No regex checks planned for this stanza initially)

## 4. Next Steps

With this comprehensive plan, I am ready to begin implementation.
